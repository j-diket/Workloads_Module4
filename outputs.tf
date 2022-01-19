output "vpc_id" {
  description = ""
  value       = data.aws_vpc.NBoS_vpc.id
}

output "public_subnets" {
  description = "IDs for public subnets within the VPC"
  value       = data.aws_subnet.NBoS_public_subnets.ids
}

output "private_subnets" {
  description = "IDs for private subnets within the VPC"
  value       = data.aws_subnet.NBoS_private_subnets.ids
}