# SQS configuration and its properties
resource "aws_kms_key" "kms" {
  description             = "This key is used to encrypt SQS"
  deletion_window_in_days = 10
  tags                    = local.common_tags
}

resource "aws_sqs_queue" "deadletter_queue" {
  name                              = "${var.sqs.name}-DLQ"
  message_retention_seconds         = var.sqs.message_retention_seconds
  receive_wait_time_seconds         = var.sqs.receive_wait_time_seconds
  kms_master_key_id                 = aws_kms_key.kms.arn
  kms_data_key_reuse_period_seconds = 300
}

resource "aws_sqs_queue" "sqs" {
  name                              = var.sqs.name
  delay_seconds                     = var.sqs.delay_seconds
  max_message_size                  = var.sqs.max_message_size
  message_retention_seconds         = var.sqs.message_retention_seconds
  receive_wait_time_seconds         = var.sqs.receive_wait_time_seconds
  kms_master_key_id                 = aws_kms_key.kms.arn
  kms_data_key_reuse_period_seconds = 300
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter_queue.arn
    maxReceiveCount     = 4
  })
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.deadletter_queue.arn]
  })
  tags = local.common_tags
}
