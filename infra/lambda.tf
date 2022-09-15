data "archive_file" "zip_dragon_search_lambda" {
  type        = "zip"
  source_file = "scan_dragons.js"
  output_path = "scan_dragons.zip"
}

resource "aws_lambda_function" "dragon_search_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.zip_dragon_search_lambda.output_path
  function_name = "DragonSearch"
  role          = aws_iam_role.dragon_call_dynamodb_role.arn

    handler = "scan_dragons.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  #  source_code_hash = filebase64sha256("scan_dragons.js")
  source_code_hash = data.archive_file.zip_dragon_search_lambda.output_base64sha256
  runtime          = "nodejs16.x"
  timeout          = 10
}

resource "aws_iam_role" "dragon_call_dynamodb_role" {
  name               = "call-dynamodb-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_doc.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AmazonDynamoDBFullAccess_policy_attach" {
  role       = aws_iam_role.dragon_call_dynamodb_role.name
  policy_arn = data.aws_iam_policy.AmazonDynamoDBFullAccess_policy.arn
}

data "aws_iam_policy" "AmazonDynamoDBFullAccess_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_policy_attach" {
  role       = aws_iam_role.dragon_call_dynamodb_role.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole_policy.arn
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "AWSXrayWriteOnlyAccess_policy_attach" {
  role       = aws_iam_role.dragon_call_dynamodb_role.name
  policy_arn = data.aws_iam_policy.AWSXrayWriteOnlyAccess_policy.arn
}

data "aws_iam_policy" "AWSXrayWriteOnlyAccess_policy" {
  arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess_policy_attach" {
  role       = aws_iam_role.dragon_call_dynamodb_role.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess_policy.arn
}

data "aws_iam_policy" "AmazonS3FullAccess_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
