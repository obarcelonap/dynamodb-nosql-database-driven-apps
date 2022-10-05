resource "aws_api_gateway_rest_api" "dragons_search_api" {
  name = "DragonSearchAPI"
}

resource "aws_api_gateway_deployment" "dragons_search_api_deployment" {
  rest_api_id       = aws_api_gateway_rest_api.dragons_search_api.id
  stage_name        = "prod"
  stage_description = "prod"
  triggers          = {
    redeployment = filesha1("${path.module}/apig.tf")
  }
}

resource "aws_api_gateway_stage" "dragons_search_api_stage" {
  deployment_id        = aws_api_gateway_deployment.dragons_search_api_deployment.id
  rest_api_id          = aws_api_gateway_rest_api.dragons_search_api.id
  stage_name           = aws_api_gateway_deployment.dragons_search_api_deployment.stage_name
  xray_tracing_enabled = true
  depends_on           = [aws_api_gateway_deployment.dragons_search_api_deployment]
}

resource "aws_api_gateway_method" "dragons_search_api_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id   = aws_api_gateway_rest_api.dragons_search_api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "dragons_search_api_post_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id             = aws_api_gateway_rest_api.dragons_search_api.root_resource_id
  http_method             = aws_api_gateway_method.dragons_search_api_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.dragon_search_lambda.invoke_arn
  timeout_milliseconds    = 10000
}


resource "aws_api_gateway_method_response" "dragons_search_api_post_method_response" {
  rest_api_id         = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id         = aws_api_gateway_rest_api.dragons_search_api.root_resource_id
  http_method         = aws_api_gateway_method.dragons_search_api_post_method.http_method
  status_code         = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "dragons_search_api_post_integration_response" {
  rest_api_id         = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id         = aws_api_gateway_rest_api.dragons_search_api.root_resource_id
  http_method         = aws_api_gateway_method.dragons_search_api_post_method.http_method
  status_code         = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_lambda_permission" "dragons_search_api_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dragon_search_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.dragons_search_api.id}/*/${aws_api_gateway_method.dragons_search_api_post_method.http_method}/*"
}

# CORS
resource "aws_api_gateway_method" "dragons_search_api_options_method" {
  rest_api_id      = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id      = aws_api_gateway_rest_api.dragons_search_api.root_resource_id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method_response" "dragons_search_api_options_method_response" {
  rest_api_id     = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id     = aws_api_gateway_rest_api.dragons_search_api.root_resource_id
  http_method     = aws_api_gateway_method.dragons_search_api_options_method.http_method
  status_code     = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "dragons_search_api_options_integration" {
  rest_api_id          = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id          = aws_api_gateway_rest_api.dragons_search_api.root_resource_id
  http_method          = "OPTIONS"
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates    = {
    "application/json" : "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "dragons_search_api_options_integration_response" {
  rest_api_id         = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id         = aws_api_gateway_rest_api.dragons_search_api.root_resource_id
  http_method         = aws_api_gateway_method.dragons_search_api_options_method.http_method
  status_code         = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_resource" "dragons_search_api_login_resource" {
  parent_id   = aws_api_gateway_rest_api.dragons_search_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.dragons_search_api.id
  path_part   = "login"
}

resource "aws_api_gateway_method" "dragons_search_api_login_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id   = aws_api_gateway_resource.dragons_search_api_login_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "dragons_search_api_login_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id             = aws_api_gateway_resource.dragons_search_api_login_resource.id
  http_method             = aws_api_gateway_method.dragons_search_api_login_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.login_lambda.invoke_arn
  timeout_milliseconds    = 10000
}

resource "aws_api_gateway_method_response" "dragons_search_api_login_method_response" {
  rest_api_id         = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id         = aws_api_gateway_resource.dragons_search_api_login_resource.id
  http_method         = aws_api_gateway_method.dragons_search_api_login_post_method.http_method
  status_code         = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "dragons_search_api_login_integration_response" {
  rest_api_id         = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id         = aws_api_gateway_resource.dragons_search_api_login_resource.id
  http_method         = aws_api_gateway_method.dragons_search_api_login_post_method.http_method
  status_code         = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_lambda_permission" "dragons_search_api_login_post_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.login_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.dragons_search_api.id}/*/${aws_api_gateway_method.dragons_search_api_login_post_method.http_method}/login"
}

# CORS
resource "aws_api_gateway_method" "dragons_search_api_login_options_method" {
  rest_api_id      = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id      = aws_api_gateway_resource.dragons_search_api_login_resource.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method_response" "dragons_search_api_login_options_method_response" {
  rest_api_id     = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id     = aws_api_gateway_resource.dragons_search_api_login_resource.id
  http_method     = aws_api_gateway_method.dragons_search_api_login_options_method.http_method
  status_code     = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "dragons_search_api_login_options_integration" {
  rest_api_id          = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id          = aws_api_gateway_resource.dragons_search_api_login_resource.id
  http_method          = "OPTIONS"
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates    = {
    "application/json" : "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "dragons_search_api_login_options_integration_response" {
  rest_api_id         = aws_api_gateway_rest_api.dragons_search_api.id
  resource_id         = aws_api_gateway_resource.dragons_search_api_login_resource.id
  http_method         = aws_api_gateway_method.dragons_search_api_login_options_method.http_method
  status_code         = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
