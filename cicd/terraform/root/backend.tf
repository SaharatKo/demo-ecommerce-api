terraform {
    backend "s3" {
        bucket = "demo-ecommerce-api-s3"
        key = "demo-ecommerce-api-s3/terraform.tfstate"
        region = "ap-southeast-1"
        dynamodb_table = "demo-ecommerce-api-tf-locks"
        encrypt = true
    }
}