variable "project_name" {
  type = string
}

variable "web_sg_id" {
  type = string
}

variable "public_subnet_id" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}