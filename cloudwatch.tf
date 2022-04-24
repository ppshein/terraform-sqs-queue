# Cloudwatch configuration and its properties
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda.name}"
  retention_in_days = var.lambda.log_retention
}

resource "aws_cloudwatch_log_subscription_filter" "streaming_data" {
  name            = "${var.lambda.name}-logfilter"
  role_arn        = aws_iam_role.iam_role_for_lambda.arn
  log_group_name  = "/aws/lambda/${var.lambda.name}"
  filter_pattern  = "logtype"
  destination_arn = aws_kinesis_stream.streaming.arn
  depends_on = [
    aws_kinesis_stream.streaming
  ]
}
