resource "aws_iam_role" "lambda_execution_role" {
  name = "WildRydesLambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole",
    }]
  })
}

resource "aws_iam_policy" "dynamodb_write_access_policy" {
  name        = "DynamoDBWriteAccess"
  description = "Policy for DynamoDB write access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "dynamodb:PutItem",
      Resource = "arn:aws:dynamodb:ap-south-1:390755846846:table/Rides"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy" {
  policy_arn = aws_iam_policy.dynamodb_write_access_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_lambda_function" "wildrydes_lambda" {
  function_name = "RequestUnicorn"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.handler"
  runtime       = "nodejs16.x"
  filename      = "lambda_function.zip"
}