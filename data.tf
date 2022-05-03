# All data source should be defined here resuable purpose

# To collect AWS IAM role/account information
data "aws_iam_account_alias" "current" {}

# To collect AWS Caller Identity information.
data "aws_caller_identity" "current" {}

# To collect AWS Region information
data "aws_region" "current" {}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_dir  = var.lambda.path_source_code
  output_path = var.lambda.output_path
}

data "aws_kms_alias" "kms_encryption" {
  name = "alias/aws/s3"
}
