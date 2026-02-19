variable "image_id" {
  type        = string
  default     = "ami-0191d47ba10441f0b"
  description = "The AMI ID for the EC2 instances"
}

variable "project_name" {
  type        = string
  default     = "myproject"
  description = "The name of the project for tagging resources"
}

variable "web_sg_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "web_tg_arn" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "eic_sg_id" {
  type = string
}

variable "user_data" {
  type = string
}