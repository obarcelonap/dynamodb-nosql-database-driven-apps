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
