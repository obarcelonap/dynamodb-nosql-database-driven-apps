resource "aws_sns_topic" "user_errors_notifications" {
  name = "edx-ddb-monitor"
}

variable "email_address" {
  type = string
}

resource "aws_sns_topic_subscription" "user_errors_email_subscription" {
  protocol  = "email"
  topic_arn = aws_sns_topic.user_errors_notifications.arn
  endpoint  = var.email_address
}
