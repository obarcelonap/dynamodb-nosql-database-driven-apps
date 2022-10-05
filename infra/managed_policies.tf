data "aws_iam_policy" "AmazonDynamoDBFullAccess_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "AWSXrayWriteOnlyAccess_policy" {
  arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

data "aws_iam_policy" "AmazonS3FullAccess_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
