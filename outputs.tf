output "vpc_id" {
    description = ""
    value = data.aws_vpc.NBoS_vpc.id  
}

output "public_subnets" {
    description = "value"
    value = data.aws_subnets.NBoS_subnets.id  
}