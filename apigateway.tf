# APIGateway configuration and its properties
resource "aws_iam_role" "iam_role_for_apigateway" {
  name               = "iam_role_for_apigateway"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "APIGatewayRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_apigateway" {
  name   = "iam_policy_for_apigateway"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility",
          "sqs:ListDeadLetterSourceQueues",
          "sqs:SendMessageBatch",
          "sqs:PurgeQueue",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:CreateQueue",
          "sqs:ListQueueTags",
          "sqs:ChangeMessageVisibilityBatch",
          "sqs:SetQueueAttributes"
        ],
        "Resource": "${aws_sqs_queue.sqs.arn}"
      },
      {
        "Effect": "Allow",
        "Action": "sqs:ListQueues",
        "Resource": "*"
      }      
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach_for_apigateway" {
  role       = aws_iam_role.iam_role_for_apigateway.name
  policy_arn = aws_iam_policy.iam_policy_for_apigateway.arn
}

resource "aws_api_gateway_rest_api" "apigateway_rest_api" {
  name = "${var.environment}-${var.project}-${var.business_unit}-api"
}

resource "aws_api_gateway_request_validator" "apigateway_validator" {
  rest_api_id           = aws_api_gateway_rest_api.apigateway_rest_api.id
  name                  = "${var.environment}-${var.project}-${var.business_unit}-api-validator"
  validate_request_body = true
}

resource "aws_api_gateway_model" "apigateway_model" {
  rest_api_id  = aws_api_gateway_rest_api.apigateway_rest_api.id
  name         = "${var.environment}${var.project}${var.business_unit}apimodel"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "required": [ "id", "docs"],
  "properties": {
    "id": { "type": "string" },
    "docs": {
      "minItems": 1,
      "type": "array",
      "items": {
        "type": "object"
      }
    }
  }
}
EOF
}

resource "aws_api_gateway_method" "apigateway_method" {
  rest_api_id          = aws_api_gateway_rest_api.apigateway_rest_api.id
  resource_id          = aws_api_gateway_rest_api.apigateway_rest_api.root_resource_id
  api_key_required     = false
  http_method          = "POST"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.apigateway_validator.id

  request_models = {
    "application/json" = aws_api_gateway_model.apigateway_model.name
  }
}

resource "aws_api_gateway_integration" "apigateway_integration" {
  rest_api_id             = aws_api_gateway_rest_api.apigateway_rest_api.id
  resource_id             = aws_api_gateway_rest_api.apigateway_rest_api.root_resource_id
  http_method             = "POST"
  type                    = "AWS"
  integration_http_method = "POST"
  passthrough_behavior    = "NEVER"
  credentials             = aws_iam_role.iam_role_for_apigateway.arn
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:path/${aws_sqs_queue.sqs.name}"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
}

resource "aws_api_gateway_integration_response" "successful_response" {
  rest_api_id       = aws_api_gateway_rest_api.apigateway_rest_api.id
  resource_id       = aws_api_gateway_rest_api.apigateway_rest_api.root_resource_id
  http_method       = aws_api_gateway_method.apigateway_method.http_method
  status_code       = aws_api_gateway_method_response.successful_response.status_code
  selection_pattern = "^2[0-9][0-9]"
  response_templates = {
    "application/json" = "{\"message\": \"great success!\"}"
  }
  depends_on = [
    aws_api_gateway_integration.apigateway_integration
  ]
}

resource "aws_api_gateway_method_response" "successful_response" {
  rest_api_id = aws_api_gateway_rest_api.apigateway_rest_api.id
  resource_id = aws_api_gateway_rest_api.apigateway_rest_api.root_resource_id
  http_method = aws_api_gateway_method.apigateway_method.http_method
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [
    aws_api_gateway_integration.apigateway_integration
  ]
}

resource "aws_api_gateway_deployment" "apigateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.apigateway_rest_api.id
  stage_name  = var.environment

  depends_on = [
    aws_api_gateway_integration.apigateway_integration
  ]
}

resource "aws_api_gateway_api_key" "apiKey" {
  name = "${var.environment}-${var.project}-${var.business_unit}-apiKey"
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.apigateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.apigateway_rest_api.id
  stage_name    = "${var.environment}-stage"
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "${var.environment}-${var.project}-${var.business_unit}-usage-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.apigateway_rest_api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }
}
