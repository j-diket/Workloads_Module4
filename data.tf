data "aws_vpc" "NBoS_vpc" {
  filter {
    name   = "tag:Name"
    values = ["NBoS VPC"]
  }
  filter {
    name   = "tag:Stage"
    values = ["dev"]
  }
}

data "aws_subnet" "NBoS_public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["Public-*"]
  }
}

data "aws_subnet" "NBoS_private_subnets" {
  filter {
    name   = "tag:Name"
    values = ["Private-*"]
  }
}

data "aws_s3_bucket" "NBoS_bucket" {
  bucket = "NBoS-developer-bucket.s3.amazonaws.com"
}