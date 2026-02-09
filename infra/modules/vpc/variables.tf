variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "The CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  description = "The CIDR block for the private-1 subnet"
}


variable "project_name" {
  type        = string
  default     = "myproject"
  description = "The name of the project for tagging resources"

}