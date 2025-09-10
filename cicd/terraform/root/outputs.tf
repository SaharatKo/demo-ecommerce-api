output "rest_api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.rest.id}.execute-api.${var.aws_region}.amazonaws.com/${var.stage_name}"
}


output "lambda_name" {
    value = aws_lambda_function.api.function_name
}


output "ddb_table" {
    value = aws_dynamodb_table.items.name
}