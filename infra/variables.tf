variable "REGION" {
  default = "eu-central-1"
}

variable "project_name" {
  default = "myproject"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "db_password" {
  type        = string
  sensitive   = true
}

variable "db_username" {
  type        = string
}

variable "db_name" {
  type        = string
}