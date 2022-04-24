variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "provider_role" {
  type = string
}

variable "business_unit" {
  type        = string
  description = "The name of the business unit."
}

variable "project" {
  type        = string
  description = "The name of the project."
}

variable "environment" {
  type        = string
  description = "The name of the environment."
}

# declare SQS attribute here
variable "sqs" {
  description = "The attribute of SQS information"
  type = object({
    name                      = string # sqs name
    delay_seconds             = number # The number of seconds Amazon SQS retains a message. Integer representing seconds.
    max_message_size          = number # The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB)
    message_retention_seconds = number # The time in seconds that the delivery of all messages in the queue will be delayed. Integer representing seconds.
    receive_wait_time_seconds = number # The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. Integer representing seconds.
  })
  default = {
    name                      = "sqs-queue"
    delay_seconds             = 60
    max_message_size          = 8000
    message_retention_seconds = 172800
    receive_wait_time_seconds = 15
  }
}

# declare kinesis attribute here
variable "lambda" {
  description = "The attribute of Lambda information"
  type = object({
    name             = string
    runtime          = string # function runtime
    output_path      = string # output path of after zipping
    path_source_code = string # path of source code
    log_retention    = number # retention period for cloudwatch logs
  })
}

# declare kinesis attribute here
variable "kinesis" {
  description = "The attribute of Kinesis information"
  type = object({
    name             = string
    shard_count      = number # retention period for cloudwatch logs
    retention_period = number # output path of after zipping
  })

  default = {
    name             = ""
    retention_period = 48
    shard_count      = 1
  }
}
