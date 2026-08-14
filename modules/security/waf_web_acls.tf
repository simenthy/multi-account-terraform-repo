resource "aws_wafv2_web_acl" "this" {
  for_each = var.web_acls

  name          = each.value.name
  scope         = each.value.scope
  tags          = each.value.tags
  token_domains = each.value.token_domains

  default_action {
    dynamic "allow" {
      for_each = each.value.default_action.type == "allow" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = each.value.default_action.type == "block" ? [1] : []
      content {}
    }
  }

  dynamic "rule" {
    for_each = each.value.rules

    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action.type == "allow" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action.type == "block" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action.type == "count" ? [1] : []
          content {}
        }
      }

      statement {
        rate_based_statement {
          aggregate_key_type    = rule.value.rate_based_statement.aggregate_key_type
          evaluation_window_sec = rule.value.rate_based_statement.evaluation_window_sec
          limit                 = rule.value.rate_based_statement.limit

          scope_down_statement {
            byte_match_statement {
              positional_constraint = rule.value.rate_based_statement.scope_down_statement.positional_constraint
              search_string         = rule.value.rate_based_statement.scope_down_statement.search_string

              field_to_match {
                uri_path {}
              }

              text_transformation {
                priority = rule.value.rate_based_statement.scope_down_statement.text_transformation.priority
                type     = rule.value.rate_based_statement.scope_down_statement.text_transformation.type
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.visibility_config.cloudwatch_metrics_enabled
        metric_name                = rule.value.visibility_config.metric_name
        sampled_requests_enabled   = rule.value.visibility_config.sampled_requests_enabled
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = each.value.visibility_config.cloudwatch_metrics_enabled
    metric_name                = each.value.visibility_config.metric_name
    sampled_requests_enabled   = each.value.visibility_config.sampled_requests_enabled
  }
}