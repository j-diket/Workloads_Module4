variable "aws_region_primary" {
  description = "AWS primary region for deployment"
  type        = string
}

variable "azs" {
  description = "Availability Zones for use"
  type        = list(string)
}

variable "stage" {
  description = "Stage of environment: dev, test, prod"
  type        = string
}