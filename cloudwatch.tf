# Cloudwatch configuration and its properties
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda.name}"
  retention_in_days = var.lambda.log_retention
}

resource "aws_cloudwatch_log_group" "dlq_lambda_log_group" {
  name              = "/aws/lambda/dlq-${var.lambda.name}"
  retention_in_days = var.lambda.log_retention
}
