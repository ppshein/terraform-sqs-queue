# Kinesis configuration and its properties
resource "aws_kinesis_stream" "streaming" {
  name             = var.kinesis.name
  shard_count      = var.kinesis.shard_count
  retention_period = var.kinesis.retention_period
  tags             = local.common_tags
}
