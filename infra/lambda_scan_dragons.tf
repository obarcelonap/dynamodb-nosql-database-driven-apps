resource "null_resource" "zip_dragon_search_dependencies" {
  provisioner "local-exec" {
    command = "cd ${path.module}/scan_dragons && npm install --target_arch=x64 --target_platform=linux --target_libc=glibc"
  }

  triggers = {
    search  = sha256(file("${path.module}/scan_dragons/protected_dragon_search.js"))
    package = sha256(file("${path.module}/scan_dragons/package.json"))
    lock    = sha256(file("${path.module}/scan_dragons/package-lock.json"))
  }
}

data "archive_file" "zip_dragon_search_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/scan_dragons/"
  output_path = "${path.module}/scan_dragons.zip"

  depends_on = [null_resource.zip_dragon_search_dependencies]
}

resource "aws_lambda_function" "dragon_search_lambda" {
  filename      = data.archive_file.zip_dragon_search_lambda.output_path
  function_name = "DragonSearch"
  role          = aws_iam_role.dragon_call_dynamodb_role.arn
  handler       = "protected_dragon_search.handler"

  source_code_hash = data.archive_file.zip_dragon_search_lambda.output_base64sha256
  runtime          = "nodejs16.x"
  timeout          = 10
}

resource "aws_iam_role" "dragon_call_dynamodb_role" {
  name               = "call-dynamodb-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "dragon_call_dynamodb_role_AmazonDynamoDBFullAccess_policy_attach" {
  role       = aws_iam_role.dragon_call_dynamodb_role.name
  policy_arn = data.aws_iam_policy.AmazonDynamoDBFullAccess_policy.arn
}

resource "aws_iam_role_policy_attachment" "dragon_call_dynamodb_role_AWSLambdaBasicExecutionRole_policy_attach" {
  role       = aws_iam_role.dragon_call_dynamodb_role.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole_policy.arn
}

resource "aws_iam_role_policy_attachment" "dragon_call_dynamodb_role_AWSXrayWriteOnlyAccess_policy_attach" {
  role       = aws_iam_role.dragon_call_dynamodb_role.name
  policy_arn = data.aws_iam_policy.AWSXrayWriteOnlyAccess_policy.arn
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess_policy_attach" {
  role       = aws_iam_role.dragon_call_dynamodb_role.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess_policy.arn
}
