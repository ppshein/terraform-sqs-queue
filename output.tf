output "endpoint" {
  value = aws_api_gateway_deployment.apigateway_deployment.invoke_url
}

output "apiKey" {
  value = aws_api_gateway_api_key.apiKey.value
}
