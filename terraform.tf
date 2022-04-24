terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  # Stores the state as a given key in a given bucket on Amazon S3. 
  # This backend also supports state locking and consistency checking via Dynamo DB, 
  # which can be enabled by setting the dynamodb_table field to an existing DynamoDB table name. 
  # A single DynamoDB table can be used to lock multiple remote state files. 
  # Terraform generates key names that include the values of the bucket and key variables.
  backend "s3" {
    region         = "ap-southeast-1"
    role_arn       = "[ARN-ROLE]"
    bucket         = "mytest-devops-tfstate-ap"
    key            = "pps-terraform.tfstate"
    dynamodb_table = "mytest-devops-tfstate-ap-lock"
    encrypt        = true
  }
}
