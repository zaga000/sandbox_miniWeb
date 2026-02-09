variable "vpc_id" {
  type        = string
  description = "ID нашої VPC, переданий з модуля VPC"
}

variable "project_name" {
  type = string
}

variable "cidr_block" {
  type = string
}

