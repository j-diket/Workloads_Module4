terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
      bucket = "jd504-tf-state-bucket"
      key = "workload/terraform.tfstate"
      region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region_primary

  default_tags {
    tags = {
      Region = var.aws_region_primary
      User   = "NBoS"
    }
  }
}