resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.metric_alarms

  alarm_name        = each.value.alarm_name
  alarm_description = each.value.alarm_description

  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  datapoints_to_alarm = each.value.datapoints_to_alarm
  threshold           = each.value.threshold
  treat_missing_data  = each.value.treat_missing_data

  metric_name = each.value.metric_name
  namespace   = each.value.namespace
  period      = each.value.period
  statistic   = each.value.statistic
  unit        = each.value.unit
  dimensions  = each.value.dimensions

  actions_enabled = each.value.actions_enabled

  # Rendered as [] rather than omitted so config matches imported state exactly.
  # These would hold SNS topic ARNs; wire them in the ROOT with
  # module.observability.sns_topic_arns[key] if alarms are ever hooked up to the
  # topics above.
  alarm_actions             = each.value.alarm_actions
  ok_actions                = each.value.ok_actions
  insufficient_data_actions = each.value.insufficient_data_actions

  tags = merge(var.common_tags, each.value.tags)
}
