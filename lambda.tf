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
  handler          = var.lambda.handler
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  runtime          = var.lambda.runtime
  timeout          = 10
  memory_size      = 1024
  environment {
    variables = {
      stream = var.kinesis.name
      region = data.aws_region.current.name
    }
  }
  tags = local.common_tags
}

# Policy for lambda function to expose logs into CW
resource "aws_iam_role_policy" "lambda_send_logs_cloudwatch" {
  name   = "${var.lambda.name}-lambda-policy"
  role   = aws_iam_role.iam_role_for_lambda.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "lambda:InvokeFunction"
          ],
          "Resource": "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
      },
      {
        "Effect": "Allow",
        "Resource": [
          "*"
        ],
        "Action": [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        "Effect": "Allow",
        "Resource": [
          "${aws_sqs_queue.sqs.arn}",
          "${aws_sqs_queue.sqs.arn}*"
        ],
        "Action": [
          "sqs:*"
        ]
      },
      {
        "Effect": "Allow",
        "Resource": [
          "${aws_kinesis_stream.streaming.arn}"
        ],
        "Action": [
          "kinesis:Put*"
        ]
      }
    ]
}
EOF
}

# Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping_lambda" {
  event_source_arn = aws_sqs_queue.sqs.arn
  enabled          = true
  function_name    = aws_lambda_function.triggered_lambda.arn
  batch_size       = 1
}

# lambda function DLQ
resource "aws_lambda_function" "dlq_triggered_lambda" {
  filename         = var.lambda.output_path
  function_name    = "dlq-${var.lambda.name}"
  role             = aws_iam_role.iam_role_for_lambda.arn
  handler          = "dql.lambda_handler"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  runtime          = var.lambda.runtime
  timeout          = 10
  memory_size      = 1024
  tags             = local.common_tags
}

resource "aws_lambda_event_source_mapping" "dlq_event_source_mapping_lambda" {
  event_source_arn = aws_sqs_queue.deadletter_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.dlq_triggered_lambda.arn
  batch_size       = 1
}
