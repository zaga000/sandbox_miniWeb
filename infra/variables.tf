variable "REGION" {
  default = "eu-central-1"
}

variable "project_name" {
  default = "myproject"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "cidr_ipv4_block" {
  default = "0.0.0.0/0"
}