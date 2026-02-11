resource "aws_security group" "alb_sg" {
  name = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Allow HTTPs traffic from within the VPC"
}

resource "aws_security group" "web_sg" {
  name = "${var.project_name}-web-sg"
  description = "Security group for ALB"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {
    security_group_id = aws_security_group.web_sg.id
    referenced_security_group_id = aws_security_group.alb_sg.id
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    description = "Allow HTTP traffic from ALB"
}

resource "aws_vpc_security_group_egress_rule" "web_egress" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

