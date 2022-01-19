# COMPUTE

resource "aws_elastic_beanstalk_application" "NBoS" {
  name        = "NBoS_Frontend"
  description = "Front end Angular application for deployment of services."

  appversion_lifecycle {
    service_role          = aws_iam_role.beanstalk_service.arn
    max_count             = 3
    delete_source_from_s3 = true
  }
}

data "aws_iam_policy_document" "beanstalk_service" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "beanstalk_service" {
  name               = "test_role"
  assume_role_policy = data.aws_iam_policy_document.beanstalk_service.json

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
  identifier         = "nbos-docdb-cluster-${count.index}"
  availability_zone  = var.azs[count.index]
  cluster_identifier = aws_docdb_cluster.NBoS.cluster_identifier
  instance_class     = "db.t3.medium"
}

# RDS
resource "aws_db_instance" "NBoS" {

  count = length(data.aws_subnets.NBoS_private_subnets.ids)

  allocated_storage         = 10
  max_allocated_storage     = 25
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t3.micro"
  name                      = "nbos-db-${count.index}"
  availability_zone         = var.azs[count.index]
  username                  = "foo"
  password                  = "foobarbaz"
  parameter_group_name      = "default.mysql5.7"
  skip_final_snapshot       = false
  final_snapshot_identifier = "NBoS-final-rds-snap"
}

# LAMBDA

# Archiving to zip for code to run in function
data "archive_file" "hello_world" {
  type        = "zip"
  source_file = "${path.module}/hello_world.py"
  output_path = "${path.module}/lambda_package/hello_world.zip"
}

# Creating the policy that permissions lambda service
data "aws_iam_policy_document" "lambda_service" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Assigning IAM role using created policy
resource "aws_iam_role" "iam_for_lambda" {
  name               = "NBoS_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_service.json
}

resource "aws_lambda_function" "NBoS_lambda" {
  # s3_bucket        = data.aws_s3_bucket.NBoS_bucket.bucket
  function_name    = "HelloWorld"
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = data.archive_file.hello_world.output_path
  source_code_hash = data.archive_file.hello_world.output_base64sha256

  runtime     = "python3.9"
  handler     = "hello_world.hello_world"
  timeout     = 900
  memory_size = 1024

  environment {
    variables = {
      environment = "test"
    }
  }

  # vpc_config would go here to restrict access

}

# Establishes permission to initiate lambda code from the RDS instance
resource "aws_lambda_permission" "hello_world" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.NBoS_lambda.function_name
  principal     = "rds.amazonaws.com"
}