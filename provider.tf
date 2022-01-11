terraform {
  required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
      }
  }
}

provider "aws" {
    region = var.aws_region_primary

    default_tags {
      tags = {
          Region = var.aws_region_primary
          User = "NBoS"
      }
    }
  
}