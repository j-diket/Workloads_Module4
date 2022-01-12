resource "aws_elastic_beanstalk_application" "NBoS" {
  name        = "NBoS_Frontend"
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

resource "aws_docdb_cluster" "NBoS" {
  cluster_identifier      = "NBoS-cluster"
  engine                  = "docdb"
  availability_zones = var.azs
  master_username         = "NBoS-dev"
  master_password         = "mustbeeightchars"
  vpc_security_group_ids = ""
  backup_retention_period = 5
  preferred_backup_window = "19:00-21:00"
  skip_final_snapshot     = false
  final_snapshot_identifier = NBoS-final-cluster-snap
}