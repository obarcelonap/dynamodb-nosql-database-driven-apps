resource "aws_cloudwatch_metric_alarm" "alarm_on_user_errors" {
  alarm_name          = "DDB-UserErrors"
  alarm_description   = "Alarm when UserErrors in DynamoDB exceeds 0"
  namespace           = "AWS/DynamoDB"
  metric_name         = "UserErrors"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  unit                = "Count"
  alarm_actions       = [aws_sns_topic.user_errors_notifications.arn]
}
