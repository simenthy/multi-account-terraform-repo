# The module's "receipt": ID/ARN maps keyed by the same local names used in the
# input variables.

output "sns_topic_arns" {
  description = "SNS topic ARNs, keyed by local name. Wire alarm actions to these in the root."
  value       = { for k, v in aws_sns_topic.this : k => v.arn }
}

output "event_rule_arns" {
  description = "CloudWatch Events rule ARNs, keyed by local name."
  value       = { for k, v in aws_cloudwatch_event_rule.this : k => v.arn }
}

output "metric_alarm_arns" {
  description = "CloudWatch metric alarm ARNs, keyed by local name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn }
}
