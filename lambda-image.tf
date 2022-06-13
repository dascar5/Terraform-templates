
data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "${var.env}/ldi-mult-desc-srch-process/RDS"
}

data "aws_ssm_parameter" "hostname" {
  name = "/ldi/rds/${var.env}/hostname"
}

data "aws_ssm_parameter" "bucket_name" {
  name = "/ldi/bucket/${var.env}/name"
}

data "aws_ssm_parameter" "upc_arn" {
  name = "/lii-ldi/${var.env}/lambda/upcservice/arn"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

locals{
  aws_env = length(regexall("dev|qa", var.env)) > 0 ? "mlnonprod" : "mlprod"
}

resource "aws_lambda_function" "lambda" {
  function_name = "ldi-${var.env}-multi-desc-search-process"
  role          = aws_iam_role.iam_for_lambda.arn
  memory_size = 4096
  timeout = 300

  image_uri    = "${var.imageuri}"
  package_type = "Image"

  vpc_config {
    subnet_ids         = [var.subnet1, var.subnet2]
    security_group_ids = [aws_security_group.allow_egress.id]
  }
  environment {
    variables = {
      JOB_DB_NAME = "job_schema",
      LOG_DB_NAME =	"log_schema",
      MULTI_SEARCH_URL = "https://${var.env}.${local.aws_env}.liiaws.net/api/Search/multi-description-search",
      PASSWORD = local.db_creds.password,
      RDS_HOST = "${data.aws_ssm_parameter.hostname.value}",
      S3_BUCKET = "${data.aws_ssm_parameter.bucket_name.value}",
      UPC_LAMBDA_ARN = "${data.aws_ssm_parameter.upc_arn.value}",
      UPC_LAMBDA_REGION = "us-east-1"
      USERNAME = local.db_creds.username
    }
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 0
}
