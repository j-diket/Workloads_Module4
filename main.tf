resource "aws_elastic_beanstalk_application" "NBoS" {
  name        = "NB of S Front End"
  description = "Front end Angular application for deployment of services."

  appversion_lifecycle {
    service_role          = aws_iam_role.beanstalk_service.arn
    max_count             = 3
    delete_source_from_s3 = true
  }
}

resource "aws_iam_role" "beanstalk_service" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "elb.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Service = "ELB"
  }
}