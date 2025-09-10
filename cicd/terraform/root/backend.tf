terraform {
    backend "s3" {
        bucket = "demo-ecommerce-api-s3"
        key = "myapi/terraform.tfstate"
        region = "ap-southeast-1"
        dynamodb_table = "demo-ecommerce-api-tf-locks" # for state locking
        encrypt = true
    }
}