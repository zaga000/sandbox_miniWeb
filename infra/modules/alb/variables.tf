variable "project_name" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "public_subnet_id" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "certificate_arn" {
  type = string
}
