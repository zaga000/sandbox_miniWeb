output "my_vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet_1.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet_.*.id
}

output "web_sg_id" {
  value = aws_security_group.web_sg.id
}