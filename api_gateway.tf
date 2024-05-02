resource "aws_api_gateway_rest_api" "example" {
  name        = "example_api"
  description = "An example API"
}

resource "aws_api_gateway_resource" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "example_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.example.id
  http_method             = aws_api_gateway_method.example.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.http_trigger_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "example_lambda" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  status_code = "200"
  response_templates = {
    "application/json" = "Empty"
  }

  depends_on = [aws_api_gateway_integration.example_lambda]
}

resource "aws_api_gateway_stage" "example" {
  depends_on    = [aws_api_gateway_deployment.example]

  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.example.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [aws_api_gateway_integration.example_lambda]

  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = ""
}

resource "aws_lambda_permission" "apigateway_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.http_trigger_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.example.execution_arn}/*/POST/example"
}

output "api_gateway_url" {
  value = aws_api_gateway_stage.example.invoke_url
}
