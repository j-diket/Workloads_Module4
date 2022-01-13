data "aws_vpc" "NBoS_vpc" {
    filter {
      name = "tag:Name"
      values = ["NBoS"]
    }
    filter {
      name = "tag:Stage"
      values = ["dev"]
    }
}

data "aws_subnets" "NBoS_public_subnets" {
  vpc_id = data.aws_vpc.NBoS_vpc.id
  filter {
    name = "tag:Name"
    values = ["Public-*"]
  }
}

data "aws_s3_bucket" "NBoS_bucket" {
  bucket = "NBoS-developer-bucket.s3.amazonaws.com"
}