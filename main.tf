resource "aws_elastic_beanstalk_application" "NBoS" {
  name        = "NBoS_Frontend"
  description = "Front end Angular application for deployment of services."

  appversion_lifecycle {
    service_role          = aws_iam_role.beanstalk_service.arn
    max_count             = 3
    delete_source_from_s3 = true
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    sid = "1"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "beanstalk_service" {
  name = "test_role"
  assume_role_policy = data.aws_iam_policy_document.this.json

  tags = {
    Service = "ELB"
  }
}

# DATABASE **********************

# Document DB
resource "aws_docdb_cluster" "NBoS" {
  cluster_identifier        = lower("NBoS-cluster")
  engine                    = "docdb"
  availability_zones        = var.azs
  master_username           = "NBoSdev"
  master_password           = "mustbeeightchars"
  backup_retention_period   = 5
  preferred_backup_window   = "19:00-21:00"
  skip_final_snapshot       = false
  final_snapshot_identifier = "NBoS-final-cluster-snap"
}

resource "aws_docdb_cluster_instance" "NB0S-cluster_instances" {
  count              = length(var.azs)
  identifier         = "NBoS-docdb-cluster-${count.index}"
  cluster_identifier = aws_docdb_cluster.default.id
  instance_class     = "db.t3.medium"
}

# RDS
resource "aws_db_instance" "NBoS" {
  # want deployed within each private(?) subnet, pulled data from LZ
  count = length()

  allocated_storage         = 10
  max_allocated_storage     = 25
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t3.micro"
  name                      = "NBoS-SB-${count.index}"
  username                  = "foo"
  password                  = "foobarbaz"
  parameter_group_name      = "default.mysql5.7"
  skip_final_snapshot       = false
  final_snapshot_identifier = "NBoS-final-rds-snap"
}

# LAMBDA

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "NBoS_lambda" {
  s3_bucket     = data.aws_s3_bucket.NBoS_bucket
  function_name = "Hello World"
  role          = aws_iam_role.iam_for_lambda.arn
  filename = file("{path.module}/hello_world.py")
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "python3.9"

}