#
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "default_security_group_id" {
  description = "ID of the default security group created for the VPC"
  value       = aws_security_group.default.id
}

#output "default_security_group_id" {
#  description = "Default security group ID for the VPC"
#  value       = aws_vpc.main.default_security_group_id
#}
