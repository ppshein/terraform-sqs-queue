resource "aws_s3_bucket" "log" {
  bucket = "${var.kinesis.name}-s3"
  lifecycle {
    prevent_destroy = false
  }
}

# let's encrypt it
resource "aws_s3_bucket_server_side_encryption_configuration" "log_encrypt" {
  bucket = aws_s3_bucket.log.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = data.aws_kms_alias.kms_encryption.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# There should be an S3 bucket referenced in Terraform as bucket and named upload-bucket. 
# The ACL should be private.
resource "aws_s3_bucket_acl" "s3_policy" {
  bucket = aws_s3_bucket.log.id
  acl    = "private"
}

# let's hide it
resource "aws_s3_bucket_public_access_block" "log" {
  depends_on              = [aws_s3_bucket.log]
  bucket                  = aws_s3_bucket.log.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
