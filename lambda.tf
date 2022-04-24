# Lambda configuration and its properties
resource "aws_iam_role" "iam_role_for_lambda" {
  name               = "iam_role_for_lambda"
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
      "Sid": "TriggerRole"
    }
  ]
}
EOF
}

# lambda function
resource "aws_lambda_function" "triggered_lambda" {
  filename         = var.lambda.output_path
  function_name    = var.lambda.name
  role             = aws_iam_role.iam_role_for_lambda.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  runtime          = var.lambda.runtime
  timeout          = 10
  memory_size      = 1024
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]
  tags = local.common_tags
}

# Policy for lambda function to expose logs into CW
resource "aws_iam_policy" "lambda_send_logs_cloudwatch" {
  name        = "${var.business_unit}_lambda_iam_policy_${var.lambda.name}"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_policy_doc.json
}

# attach policy and role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_role_for_lambda.name
  policy_arn = aws_iam_policy.lambda_send_logs_cloudwatch.arn
}

# Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping_lambda" {
  event_source_arn = aws_sqs_queue.sqs.arn
  enabled          = true
  function_name    = aws_lambda_function.triggered_lambda.arn
  batch_size       = 1
}
