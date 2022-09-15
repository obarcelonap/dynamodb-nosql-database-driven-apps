data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

locals {
  ip = data.http.ip.response_body
}

resource "aws_s3_bucket" "dragons_bucket" {
  bucket = "obarcelonap-dndda-dragons"
}

resource "aws_s3_bucket_policy" "dragons_access_only_from_local_policy" {
  bucket = aws_s3_bucket.dragons_bucket.bucket
  policy = data.aws_iam_policy_document.dragons_access_only_from_local_policy_document.json
}

resource "aws_s3_bucket_website_configuration" "dragons_website_config" {
  bucket = aws_s3_bucket.dragons_bucket.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

data "aws_iam_policy_document" "dragons_access_only_from_local_policy_document" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.dragons_bucket.arn}/*"]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = [local.ip]
    }
  }
}


resource "local_file" "dragons_replace_api_config_file" {
  content  = "var API_ENDPOINT_URL_STR = \"${aws_api_gateway_deployment.dragons_search_api_deployment.invoke_url}\";"
  filename = "${path.module}/../website/config.js"
}

locals {
  mime_types = {
    ".html" = "text/html"
    ".js"   = "text/javascript"
    ".css"  = "text/css"
    ".png"  = "image/png"
  }
}

resource "aws_s3_object" "s3_upload" {
  for_each = fileset("${path.module}/../website", "**/*")

  bucket = aws_s3_bucket.dragons_bucket.bucket
  key    = each.value
  source = "${path.module}/../website/${each.value}"

  etag         = filemd5("${path.module}/../website/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)

  depends_on = [local_file.dragons_replace_api_config_file]
}
