resource "aws_lambda_function" "lambda" {
  function_name = "xtracta-ipro-${var.env}"
  handler = "XtractaLambda::XtractaLambda.Function::FunctionHandler"
  runtime = "dotnet6"
  timeout = 30
  memory_size = 256
  role    = "${aws_iam_role.iam_for_lambda.arn}"

  vpc_config {
  	subnet_ids = [var.subnet1, var.subnet2, var.subnet3, var.subnet4]
  	security_group_ids = [aws_security_group.allow_egress.id]
  }

  s3_bucket = var.bucket_id
  s3_key = "azure/${var.env}/xtracta.zip"

  environment {
    variables = {
      x = "0"
    }
  }
}

resource "aws_ssm_parameter" "lambda" {
  name  = "/xtracta/${var.env}/lambda/arn"
  type  = "String"
  value = aws_lambda_function.lambda.arn
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.xtracta_sqs.arn
  function_name    = aws_lambda_function.lambda.arn
  batch_size = 0
}

resource "aws_sqs_queue" "xtracta_sqs_deadletter" {
  name                      = "xtracta-ipro-${var.env}-sqs-deadletter"
  delay_seconds             = 0
  max_message_size          = 0
  message_retention_seconds = 0
  receive_wait_time_seconds = 0
}

resource "aws_sqs_queue" "xtracta_sqs" {
  name                      = "xtracta-ipro-${var.env}-sqs"
  delay_seconds             = 0
  max_message_size          = 0
  message_retention_seconds = 0
  receive_wait_time_seconds = 0
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.xtracta_sqs_deadletter.arn
    maxReceiveCount     = 1
  })
}