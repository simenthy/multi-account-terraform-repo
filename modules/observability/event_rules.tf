resource "aws_cloudwatch_event_rule" "this" {
  for_each = var.event_rules

  name           = each.value.name
  description    = each.value.description
  event_bus_name = each.value.event_bus_name

  # A rule is EITHER pattern-driven or schedule-driven, never both.
  #
  # The pattern is authored as native HCL in var.event_patterns under this same
  # key, and encoded here — once, in one place. jsonencode() is the right tool:
  # an EventBridge pattern is not an IAM policy, so the "prefer
  # aws_iam_policy_document" rule does not apply (there is no equivalent data
  # source for event patterns).
  #
  # try(...) yields null when the rule has no pattern entry, which renders the
  # attribute as absent — correct for the schedule-driven rules.
  event_pattern       = try(jsonencode(var.event_patterns[each.key]), null)
  schedule_expression = each.value.schedule_expression

  state         = each.value.state
  force_destroy = each.value.force_destroy

  tags = merge(var.common_tags, each.value.tags)
}

# VALIDATION REMINDER: Terraform only checks that the encoded string is valid
# JSON. A pattern that is syntactically valid but matches no event applies
# cleanly and then fails silently. Verify any pattern you change with:
#   aws events test-event-pattern --event-pattern file://p.json --event file://e.json
#
# AUTHORING NOTE: pattern keys containing a hyphen — "detail-type" above all —
# are written quoted in the tfvars, because a bare hyphen reads as subtraction
# everywhere else in HCL. See the explanation at the top of the event_patterns
# map in accounts/nft/observability.auto.tfvars.
