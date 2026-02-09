resource "aws_launch_template" "web_launch_template" {
  name                   = "${var.project_name}-web-launch-template"
  image_id               = var.image_id
  instance_type          = "t3.micro"
  key_name               = "aws-key"
  vpc_security_group_ids = [var.web_sg_id]

}

resource "aws_autoscaling_group" "web_asg" {
  name             = "${var.project_name}-web-asg"
  max_size         = 2
  min_size         = 1
  desired_capacity = 1
  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.private_subnet_ids
  lifecycle {
    ignore_changes = [target_group_arns]
  }
  health_check_type = "ELB"
}

resource "aws_autoscaling_attachment" "web_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  lb_target_group_arn    = var.web_tg_arn
}