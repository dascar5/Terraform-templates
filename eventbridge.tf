resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge-role-${var.env}-company"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
          ]
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_role_policy" {
  name = "eventbridge-role-policy-${var.env}-company"
  role = aws_iam_role.eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "states:StartExecution",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:states:us-east-1:${var.account_id}:stateMachine:tcm-${var.env}-companymicroservice-export2s3"
      },
    ]
  })
}

resource "aws_cloudwatch_event_rule" "cron-rule" {
  name        = "tcm-${var.env}-reporting-companymicroservice-export-cron"
  description = "Scheduled Event"
  schedule_expression = "cron(0 17,23 * * ? *)"
  role_arn = aws_iam_role.eventbridge_role.arn
}

resource "aws_cloudwatch_event_rule" "cron-rule-1" {
  name        = "tcm-${var.env}-reporting-companymicroservice-export-cron-1"
  description = "Scheduled Event"
  schedule_expression = "cron(0 17,23 * * ? *)"
  role_arn = aws_iam_role.eventbridge_role.arn
}


resource "aws_cloudwatch_event_target" "target1" {
  arn = "arn:aws:states:us-east-1:${var.account_id}:stateMachine:tcm-${var.env}-companymicroservice-export2s3"
  role_arn = aws_iam_role.eventbridge_role.arn
  rule = aws_cloudwatch_event_rule.cron-rule.id
  input = <<JSON
{"param_name": "/tcm/${var.env}/companymicroservice/clientsupplier-export2s3/lastExecutedDateTime","config": "/tcm/${var.env}/companymicroservice/clientsupplier-export2s3/config"}
JSON
}

resource "aws_cloudwatch_event_target" "target2" {
  role_arn = aws_iam_role.eventbridge_role.arn
  arn = "arn:aws:states:us-east-1:${var.account_id}:stateMachine:tcm-${var.env}-companymicroservice-export2s3"
  rule = aws_cloudwatch_event_rule.cron-rule.id
  input = <<JSON
{"param_name": "/tcm/${var.env}/companymicroservice/clientsuppliercontact-export2s3/lastExecutedDateTime","config": "/tcm/${var.env}/companymicroservice/clientsuppliercontact-export2s3/config"}
JSON
}

resource "aws_cloudwatch_event_target" "target3" {
  role_arn = aws_iam_role.eventbridge_role.arn
  arn = "arn:aws:states:us-east-1:${var.account_id}:stateMachine:tcm-${var.env}-companymicroservice-export2s3"
  rule = aws_cloudwatch_event_rule.cron-rule.id
  input = <<JSON
{"param_name": "/tcm/${var.env}/companymicroservice/clientapplicableagreement-export2s3/lastExecutedDateTime","config": "/tcm/${var.env}/companymicroservice/clientapplicableagreement-export2s3/config"}
JSON
}

resource "aws_cloudwatch_event_target" "target4" {
  role_arn = aws_iam_role.eventbridge_role.arn
  arn = "arn:aws:states:us-east-1:${var.account_id}:stateMachine:tcm-${var.env}-companymicroservice-export2s3"
  rule = aws_cloudwatch_event_rule.cron-rule.id
  input = <<JSON
{"param_name": "/tcm/${var.env}/companymicroservice/division-export2s3/lastExecutedDateTime","config": "/tcm/${var.env}/companymicroservice/division-export2s3/config"}
JSON
}

resource "aws_cloudwatch_event_target" "target5" {
  role_arn = aws_iam_role.eventbridge_role.arn
  arn = "arn:aws:states:us-east-1:${var.account_id}:stateMachine:tcm-${var.env}-companymicroservice-export2s3"
  rule = aws_cloudwatch_event_rule.cron-rule.id
  input = <<JSON
{"param_name": "/tcm/${var.env}/companymicroservice/company-export2s3/lastExecutedDateTime","config": "/tcm/${var.env}/companymicroservice/company-export2s3/config"}
JSON
}

resource "aws_cloudwatch_event_target" "target6" {
  role_arn = aws_iam_role.eventbridge_role.arn
  arn = "arn:aws:states:us-east-1:${var.account_id}:stateMachine:tcm-${var.env}-companymicroservice-export2s3"
  rule = aws_cloudwatch_event_rule.cron-rule-1.id
  input = <<JSON
{"param_name": "/tcm/${var.env}/companymicroservice/address-export2s3/lastExecutedDateTime","config": "/tcm/${var.env}/companymicroservice/address-export2s3/config"}
JSON
}

