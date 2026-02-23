resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.project_name}-rds-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for RDS instances"
}

resource "aws_db_instance" "rds_instance" {
  identifier           = "${var.project_name}-rds-instance"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]

  publicly_accessible = false
  skip_final_snapshot = true
  multi_az            = false

  tags = {
    Name = "${var.project_name}-rds-instance"
  }

}