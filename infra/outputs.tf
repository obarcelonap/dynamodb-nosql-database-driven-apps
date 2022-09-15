output "dragons_website_endpoint" {
  value = aws_s3_bucket.dragons_bucket.website_endpoint
}

output "dragons_api_url" {
  value = aws_api_gateway_deployment.dragons_search_api_deployment.invoke_url
}
