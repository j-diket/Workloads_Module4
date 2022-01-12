data "aws_vpc" "NBoS_vpc" {
  id = var.vpc_id
}

data "aws_subnets" "NBoS_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "NBoS_subnet" {
  for_each = toset(data.aws_subnets.NBoS_subnets.ids)
  id       = each.value
}

data "aws_s3_bucket" "NBoS_bucket" {
  bucket = "NBoS-developer-bucket.s3.amazonaws.com"
}