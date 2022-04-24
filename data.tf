# All data source should be defined here resuable purpose

data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    sid    = "AllowInvokingLambda"
    effect = "Allow"
    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
    ]
    actions = [
      "lambda:InvokeFunction"
    ]
  }
  statement {
    sid    = "AllowCreatingLogGroups"
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
      "logs:CreateLogGroup"
    ]
  }
  statement {
    sid    = "AllowWritingLogs"
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
  statement {
    sid    = "AllowReadSQS"
    effect = "Allow"
    resources = [
      aws_sqs_queue.sqs.arn
    ]
    actions = [
      "sqs:*"
    ]
  }
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_dir  = var.lambda.path_source_code
  output_path = var.lambda.output_path
}
