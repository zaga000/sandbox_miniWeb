resource "aws_launch_template" "web_launch_template" {
  name                   = "${var.project_name}-web-launch-template"
  image_id               = var.image_id
  instance_type          = "t3.micro"
  key_name               = "aws-key"
  vpc_security_group_ids = [var.web_sg_id]

  user_data = var.user_data

  lifecycle {
    create_before_destroy = true
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name      = "${var.project_name}-web-server"
      Version   = "v2.0"
      Project   = var.project_name
      ManagedBy = "Terraform"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.project_name}-web-asg"
  vpc_zone_identifier = var.private_subnet_ids
  health_check_type   = "ELB"

  max_size         = 2
  min_size         = 1
  desired_capacity = 1


  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }
  instance_maintenance_policy {
    min_healthy_percentage = 100
    max_healthy_percentage = 200
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
      instance_warmup        = 180
    }
  }
  lifecycle {
    ignore_changes = [target_group_arns]
  }
}

resource "aws_autoscaling_attachment" "web_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  lb_target_group_arn    = var.web_tg_arn
}

resource "aws_ec2_instance_connect_endpoint" "ssh_endpoint" {
  subnet_id          = var.private_subnet_ids[0]
  security_group_ids = [var.eic_sg_id]
}