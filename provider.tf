# Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.provider_role
  }
}
