variable "lambda_handler" {
    type = string
    default = "DemoEcommerceApiLambda::DemoEcommerceApiLambda.LambdaEntryPoint::FunctionHandlerAsync"
}

############################################
# Locals
############################################
locals {
  name = "${var.project}-${var.env}"
  tags = {
    Project = var.project
    Env     = var.env
  }
}

############################################
# DynamoDB table
############################################
resource "aws_dynamodb_table" "items" {
  name         = var.ddb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  tags = local.tags
}

############################################
# IAM for Lambda
############################################
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${local.name}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid     = "Logs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid = "DDBAccess"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem"
    ]
    resources = [aws_dynamodb_table.items.arn]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${local.name}-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

############################################
# Lambda function
############################################
resource "aws_lambda_function" "api" {
  function_name = "${local.name}-fn"
  role          = aws_iam_role.lambda_exec.arn
  filename      = var.lambda_zip_path
  handler       = var.lambda_handler     # "MyApi" for Hosting; or "Asm::Namespace.LambdaEntryPoint::FunctionHandlerAsync" for classic
  runtime       = "dotnet8"
  timeout       = 10
  memory_size   = 512
  publish       = true

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.items.name
    }
  }

  tags = local.tags

  # so TF plan doesn't constantly change if the zip path has the same content
  lifecycle {
    ignore_changes = [filename]
  }
}

############################################
# API Gateway REST API
############################################
resource "aws_api_gateway_rest_api" "rest" {
  name = "${local.name}-rest"
  tags = local.tags
}

# /{proxy+} resource (greedy)
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.rest.id
  parent_id   = aws_api_gateway_rest_api.rest.root_resource_id
  path_part   = "{proxy+}"
}

# ANY on /
resource "aws_api_gateway_method" "root_any" {
  rest_api_id   = aws_api_gateway_rest_api.rest.id
  resource_id   = aws_api_gateway_rest_api.rest.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.rest.id
  resource_id             = aws_api_gateway_rest_api.rest.root_resource_id
  http_method             = aws_api_gateway_method.root_any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

# ANY on /{proxy+}
resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.rest.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.rest.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

# Deployment & Stage
resource "aws_api_gateway_deployment" "dep" {
  rest_api_id = aws_api_gateway_rest_api.rest.id

  # re-deploy when integrations change
  triggers = {
    redeploy = sha1(jsonencode({
      root_integration  = aws_api_gateway_integration.root_lambda.id
      proxy_integration = aws_api_gateway_integration.proxy_lambda.id
    }))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.rest.id
  deployment_id = aws_api_gateway_deployment.dep.id
  stage_name    = var.stage_name
  tags          = local.tags
}

# Permission for API Gateway to invoke the Lambda on any stage/method/path
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest.execution_arn}/*/*/*"
}
