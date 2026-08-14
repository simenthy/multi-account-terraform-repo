# TRIMMED FOR COST (2026-08-14) — see networking.auto.tfvars for the full
# context. The imported estate had ~20 SNS topics, ~10 EventBridge rules
# and a large set of metric alarms; this keeps one of each.
#
# SNS topics are free to exist (you pay per message published, and nothing
# publishes here). EventBridge rules are free, including scheduled ones.
# The single CloudWatch metric alarm is $0.10/month — the only billable
# resource in this file.

#------------------------------------------------
# SNS Topics (free)
#------------------------------------------------
sns_topics = {
  nft_sns01 = {
    name = "fra-nft-sns-01"
    tags = {
      Name        = "fra-nft-sns-01"
      Environment = "Dev"
      Application = "NFT"
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
  nft_event_rule01 = {
    name                = "fra-nft-event-rule-01"
    schedule_expression = "rate(1 day)"
    state               = "ENABLED"
    tags = {
      Name        = "fra-nft-event-rule-01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}

#------------------------------------------------
# CloudWatch Metric Alarms ($0.10/month each)
#------------------------------------------------
metric_alarms = {
  nft_alarm01 = {
    alarm_name          = "fra-nft-cpu-high"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 1
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    threshold           = 80
    tags = {
      Name        = "fra-nft-cpu-high"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}
