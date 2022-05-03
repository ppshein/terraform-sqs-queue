# Kinesis configuration and its properties

resource "aws_iam_role" "firehose_role" {
  name               = "${var.kinesis.name}-firehose-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "read_policy" {
  name   = "${var.kinesis.name}-read-policy"
  role   = aws_iam_role.firehose_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords"
            ],
            "Resource": [
                "arn:aws:kinesis:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stream/${aws_kinesis_stream.streaming.name}"
            ]
        },
        {
          "Effect": "Allow",
          "Action": [
              "s3:AbortMultipartUpload",
              "s3:GetBucketLocation",
              "s3:GetObject",
              "s3:ListBucket",
              "s3:ListBucketMultipartUploads",
              "s3:PutObject"
          ],
          "Resource": [
              "${aws_s3_bucket.log.arn}"
          ]
      },
      {
          "Effect": "Allow",
          "Action": [
              "glue:GetTableVersions"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

# kinesis stream
resource "aws_kinesis_stream" "streaming" {
  name             = var.kinesis.name
  shard_count      = var.kinesis.shard_count
  retention_period = var.kinesis.retention_period
  tags             = local.common_tags
}

# it's for glue database but you can query with athena
resource "aws_glue_catalog_database" "aws_glue_database" {
  name = "${var.glue.name}-glue-database"
}

# it's for glue table but you can query with athena
resource "aws_glue_catalog_table" "aws_glue_table" {
  name          = "${var.glue.name}-glue-table"
  database_name = aws_glue_catalog_database.aws_glue_database.name
  storage_descriptor {
    location      = "s3://${var.kinesis.name}-glue-s3"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    ser_de_info {
      name                  = "${var.glue.name}-glue-table-serdeinfo"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }
    columns {
      name = "information"
      type = "string"
    }
  }
}

# it's for firehost that integrate with kinesis stream
resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
  name        = "${var.kinesis.name}-firehose"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.streaming.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  extended_s3_configuration {
    role_arn        = aws_iam_role.firehose_role.arn
    bucket_arn      = aws_s3_bucket.log.arn
    buffer_size     = 100
    buffer_interval = "300"
    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        database_name = aws_glue_catalog_table.aws_glue_table.database_name
        role_arn      = aws_iam_role.firehose_role.arn
        table_name    = aws_glue_catalog_table.aws_glue_table.name
        region        = data.aws_region.current.name
      }
    }
  }
  tags = local.common_tags
}
