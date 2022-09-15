terraform {
  required_version = "= 1.1.3"
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      course = "dynamodb-nosql-database-driven-apps "
    }
  }
}

resource "aws_dynamodb_table" "dragons_table" {
  name     = "dragons"
  hash_key = "dragon_name"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "dragon_name"
    type = "S"
  }
}
