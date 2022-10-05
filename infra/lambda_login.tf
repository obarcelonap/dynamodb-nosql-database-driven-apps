resource "null_resource" "zip_login_dependencies" {
  provisioner "local-exec" {
    command = "cd ${path.module}/login && npm install --target_arch=x64 --target_platform=linux --target_libc=glibc"
  }

  triggers = {
    login   = sha256(file("${path.module}/login/login.js"))
    package = sha256(file("${path.module}/login/package.json"))
    lock    = sha256(file("${path.module}/login/package-lock.json"))
  }
}

data "archive_file" "zip_login_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/login/"
  output_path = "${path.module}/login.zip"

  depends_on = [null_resource.zip_login_dependencies]
}

resource "aws_lambda_function" "login_lambda" {
  filename      = data.archive_file.zip_login_lambda.output_path
  function_name = "LoginEdXDragonGame"
  description   = "Login functionality"
  role          = aws_iam_role.login_for_dragons_role.arn
  handler       = "login.handler"

  source_code_hash = data.archive_file.zip_login_lambda.output_base64sha256
  runtime          = "nodejs16.x"
  timeout          = 30
}

resource "aws_iam_role" "login_for_dragons_role" {
  name               = "login-for-dragons-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "login_for_dragons_role_AmazonDynamoDBFullAccess_policy_attach" {
  role       = aws_iam_role.login_for_dragons_role.name
  policy_arn = data.aws_iam_policy.AmazonDynamoDBFullAccess_policy.arn
}

resource "aws_iam_role_policy_attachment" "login_for_dragons_role_AWSLambdaBasicExecutionRole_policy_attach" {
  role       = aws_iam_role.login_for_dragons_role.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole_policy.arn
}

resource "aws_iam_role_policy_attachment" "login_for_dragons_role_AWSXrayWriteOnlyAccess_policy_attach" {
  role       = aws_iam_role.login_for_dragons_role.name
  policy_arn = data.aws_iam_policy.AWSXrayWriteOnlyAccess_policy.arn
}
