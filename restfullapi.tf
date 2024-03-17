resource "aws_api_gateway_rest_api" "WildRydes" {
  name = "WildRydes"

  endpoint_configuration {
    types = ["EDGE"]
  }
  
}

resource "aws_api_gateway_authorizer" "Authorizer" {
  name = "WildRydes"
  rest_api_id = aws_api_gateway_rest_api.WildRydes.id
  type = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.pool.arn] 
  
}

resource "aws_api_gateway_resource" "ride" {
  rest_api_id = aws_api_gateway_rest_api.WildRydes.id
  parent_id = aws_api_gateway_rest_api.WildRydes.root_resource_id
  path_part = "ride"
  
}

module "api-gateway-enable-cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.WildRydes.id
  api_resource_id = aws_api_gateway_resource.ride.id
}


resource "aws_api_gateway_method" "post_method" {
  rest_api_id = aws_api_gateway_rest_api.WildRydes.id
  resource_id = aws_api_gateway_resource.ride.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.Authorizer.id
  request_parameters = {
    "method.request.header.Authorization" = true
  }
  
  depends_on = [ aws_api_gateway_authorizer.Authorizer ]
}

resource "aws_api_gateway_integration" "post_method_integration" {
  rest_api_id = aws_api_gateway_rest_api.WildRydes.id
  resource_id = aws_api_gateway_resource.ride.id
  http_method = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.wildrydes_lambda.invoke_arn

  depends_on = [ aws_api_gateway_method.post_method]  
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.wildrydes_lambda.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${"ap-south-1"}:${"390755846846"}:${aws_api_gateway_rest_api.WildRydes.id}/*/${aws_api_gateway_method.post_method.http_method}${aws_api_gateway_resource.ride.path}"

}

resource "aws_api_gateway_method_response" "post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.WildRydes.id
  resource_id = aws_api_gateway_resource.ride.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"
  
  depends_on = [ aws_api_gateway_method.post_method ]
}

resource "aws_api_gateway_deployment" "api_dep" {
  rest_api_id = aws_api_gateway_rest_api.WildRydes.id

  depends_on = [ aws_api_gateway_rest_api.WildRydes, aws_api_gateway_method.post_method, aws_api_gateway_integration.post_method_integration]
  
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_dep.id
  rest_api_id = aws_api_gateway_rest_api.WildRydes.id
  stage_name = "Prod"

  depends_on = [ aws_api_gateway_deployment.api_dep ]
}