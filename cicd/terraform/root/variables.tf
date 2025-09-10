variable "aws_region" {
    type = string
    default = "ap-southeast-1"
}
variable "project" {
    type = string
    default = "demo-ecommerce-api"
}
variable "env" {
    type = string
    default = "dev" 
}


# Jenkins will pass the built zip path
variable "lambda_zip_path"{
    type = string
}


# Simple DynamoDB table name
variable "ddb_table_name" {
    type = string
    default = "demo-ecommerce-api-dynamodb"
}

variable "stage_name" {
    type = string
    default = "v1"
}