provider_role = "[PROVIDER-ROLE]" #provider role will be replaced here
business_unit = "digital"
project       = "sre"
environment   = "sit"

sqs = {
  name                      = "sqs-queue"
  delay_seconds             = 60
  max_message_size          = 8000
  message_retention_seconds = 172800
  receive_wait_time_seconds = 15
}

lambda = {
  name             = "my-lambda-function"
  output_path      = "./tmps/lambda_function.zip"
  runtime          = "python3.9"
  path_source_code = "lambda_function"
  log_retention    = 1
}

kinesis = {
  name             = "my-kinesis-stream"
  retention_period = 48
  shard_count      = 1
}
