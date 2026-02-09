output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet_.*.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet_.*.id
}

output "cidr_block" {
  value = aws_vpc.vpc.cidr_block
}
