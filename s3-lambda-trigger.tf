resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = "project-${var.env}-multi-desc-search-batch"
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "Input/"
    filter_suffix       = ".csv"
  }
}
resource "aws_lambda_permission" "permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::project-${var.env}-multi-desc-search-batch"
}