# Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.provider_role
  }
}

# To collect AWS IAM role/account information
data "aws_iam_account_alias" "current" {}

# To collect AWS Caller Identity information.
data "aws_caller_identity" "current" {}

# To collect AWS Region information
data "aws_region" "current" {}
