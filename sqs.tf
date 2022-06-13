resource "aws_sqs_queue" "inbound-sqs-dlq" {
  name                  = "lii-gdm-ms-${var.env}-inbound-sqs-dlq.fifo"
  fifo_queue            = true
  visibility_timeout_seconds = 30
  message_retention_seconds = 1209600
  delay_seconds = 0
  max_message_size = 262144 
  receive_wait_time_seconds = 20
  content_based_deduplication = false

  # "byQueue" won't work because of this:
  #  https://github.com/hashicorp/terraform-provider-aws/issues/22577

  # redrive_allow_policy = jsonencode({
  #   redrivePermission = "byQueue",
  #   sourceQueueArns   = [aws_sqs_queue.inbound-sqs-q1.arn, aws_sqs_queue.inbound-sqs-q2.arn]
  # })

  redrive_allow_policy = jsonencode({
    redrivePermission = "allowAll",
  })
  
}

resource "aws_sqs_queue" "inbound-sqs-q1" {
  name                  = "lii-gdm-ms-${var.env}-inbound-sqs-q1.fifo"
  fifo_queue            = true
  visibility_timeout_seconds = 1200
  message_retention_seconds = 864000
  delay_seconds = 0
  max_message_size = 262144 
  receive_wait_time_seconds = 20
  content_based_deduplication = true
  deduplication_scope   = "queue"
  fifo_throughput_limit = "perQueue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.inbound-sqs-dlq.arn
    maxReceiveCount     = 1
  })
}

resource "aws_sqs_queue" "inbound-sqs-q2" {
  name                  = "lii-gdm-ms-${var.env}-inbound-sqs-q2.fifo"
  fifo_queue            = true
  visibility_timeout_seconds = 1200
  message_retention_seconds = 864000
  delay_seconds = 0
  max_message_size = 262144 
  receive_wait_time_seconds = 20
  content_based_deduplication = true
  deduplication_scope   = "queue"
  fifo_throughput_limit = "perQueue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.inbound-sqs-dlq.arn
    maxReceiveCount     = 1
  })
}

#-----------------------------------------------------------------------------------------

resource "aws_sqs_queue" "pa-sqs-dlq" {
  name                  = "lii-gdm-ms-${var.env}-pa-sqs-dlq.fifo"
  fifo_queue            = true
  visibility_timeout_seconds = 30
  message_retention_seconds = 1209600
  delay_seconds = 0
  max_message_size = 262144 
  receive_wait_time_seconds = 20
  content_based_deduplication = false
  redrive_allow_policy = jsonencode({
    redrivePermission = "allowAll",
  })
}

resource "aws_sqs_queue" "pa-sqs-q1" {
  name                  = "lii-gdm-ms-${var.env}-pa-sqs-q1.fifo"
  fifo_queue            = true
  visibility_timeout_seconds = 2700
  message_retention_seconds = 864000
  delay_seconds = 0
  max_message_size = 262144 
  receive_wait_time_seconds = 20
  content_based_deduplication = true
  deduplication_scope   = "queue"
  fifo_throughput_limit = "perQueue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.pa-sqs-dlq.arn
    maxReceiveCount     = 1
  })
}

resource "aws_sqs_queue" "pa-sqs-q2" {
  name                  = "lii-gdm-ms-${var.env}-pa-sqs-q2.fifo"
  fifo_queue            = true
  visibility_timeout_seconds = 2700
  message_retention_seconds = 864000
  delay_seconds = 0
  max_message_size = 262144 
  receive_wait_time_seconds = 20
  content_based_deduplication = true
  deduplication_scope   = "queue"
  fifo_throughput_limit = "perQueue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.pa-sqs-dlq.arn
    maxReceiveCount     = 1
  })
}

#-----------------------------------------------------------------------------------------

resource "aws_sqs_queue" "outbound-sqs-dlq" {
  name                  = "lii-gdm-ms-${var.env}-outbound-sqs-dlq.fifo"
  fifo_queue            = true
  visibility_timeout_seconds = 30
  message_retention_seconds = 1209600
  delay_seconds = 0
  max_message_size = 262144 
  receive_wait_time_seconds = 20
  content_based_deduplication = false
  redrive_allow_policy = jsonencode({
    redrivePermission = "allowAll",
  })
}

resource "aws_sqs_queue" "outbound-sqs-q1" {
  name                  = "lii-gdm-ms-${var.env}-outbound-sqs-q1.fifo"
  fifo_queue            = true
  visibility_timeout_seconds = 1800
  message_retention_seconds = 864000
  delay_seconds = 0
  max_message_size = 262144 
  receive_wait_time_seconds = 20
  content_based_deduplication = true
  deduplication_scope   = "queue"
  fifo_throughput_limit = "perQueue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.outbound-sqs-dlq.arn
    maxReceiveCount     = 1
  })
}

resource "aws_sqs_queue" "outbound-sqs-q2" {
  name                  = "lii-gdm-ms-${var.env}-outbound-sqs-q2.fifo"
  fifo_queue            = true
  visibility_timeout_seconds = 1800
  message_retention_seconds = 864000
  delay_seconds = 0
  max_message_size = 262144 
  receive_wait_time_seconds = 20
  content_based_deduplication = true
  deduplication_scope   = "queue"
  fifo_throughput_limit = "perQueue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.outbound-sqs-dlq.arn
    maxReceiveCount     = 1
  })
}

#-----------------------------------------------------------------------------------------

resource "aws_sqs_queue" "integration-sqs" {
  name                  = "lii-gdm-ms-${var.env}-integration-sqs.fifo"
  fifo_queue            = true
  visibility_timeout_seconds = 60
  message_retention_seconds = 1209600
  delay_seconds = 0
  max_message_size = 262144 
  receive_wait_time_seconds = 20
  content_based_deduplication = false
  fifo_throughput_limit = "perQueue"
}


