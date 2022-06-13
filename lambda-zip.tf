data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "${var.env}/ldi-mult-desc-srch-process/RDS"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

resource "aws_lambda_function" "lambda" {
  function_name = "ldi-${var.env}-multi-desc-search-input"
  role          = aws_iam_role.iam_for_lambda.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.8"
  memory_size = 128
  timeout = 15

  s3_bucket = var.bucket_id
  s3_key = "azure/${var.env}/ldi-multi-desc-search-input.zip"

  vpc_config {
    subnet_ids         = [var.subnet1, var.subnet2]
    security_group_ids = [aws_security_group.allow_egress.id]
  }
  environment {
    variables = {
      DB_NAME = "job_schema",
      PASSWORD = local.db_creds.password,
      RDS_HOST = "${module.db.db_instance_address}",
      S3_BUCKET = "${aws_s3_bucket.b.bucket}",
      USERNAME = local.db_creds.username
    }
  }
}