# COST NOTE: SNS topics are free to exist (you pay per message published,
# and nothing publishes here). EventBridge rules are free — including
# scheduled ones. The single CloudWatch metric alarm is $0.10/month, the
# only billable resource in this file.

#------------------------------------------------
# SNS Topics (free)
#------------------------------------------------
sns_topics = {
  devops_sns01 = {
    name = "fra-devops-sns-01"
    tags = {
      Name        = "fra-devops-sns-01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}

#------------------------------------------------
# EventBridge Rules (free)
#------------------------------------------------
# Uses schedule_expression rather than an event pattern, so this domain
# doesn't need an event_patterns entry too — see modules/observability/
# variables.tf for why patterns live in that separate untyped map.
event_rules = {
  devops_event_rule01 = {
    name                = "fra-devops-event-rule-01"
    schedule_expression = "rate(1 day)"
    state               = "ENABLED"
    tags = {
      Name        = "fra-devops-event-rule-01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}

#------------------------------------------------
# CloudWatch Metric Alarms ($0.10/month each)
#------------------------------------------------
metric_alarms = {
  devops_alarm01 = {
    alarm_name          = "fra-devops-cpu-high"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 1
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    threshold           = 80
    tags = {
      Name        = "fra-devops-cpu-high"
      Environment = "devops"
      Application = "Platform"
    }
  }
}
