resource "aws_sns_topic" "this" {
  for_each = var.sns_topics

  name         = each.value.name
  display_name = each.value.display_name

  fifo_topic                  = each.value.fifo_topic
  content_based_deduplication = each.value.content_based_deduplication
  tracing_config              = each.value.tracing_config

  tags = merge(var.common_tags, each.value.tags)
}

# NOTE: no `policy` argument and no aws_sns_topic_policy resource.
# Every topic here carries AWS's default topic policy, which AWS recreates
# identically — keeping it would hardcode the account id and region into a
# reusable module for no behavioural gain (terraform-policies-guide.md §6).
#
# If a custom policy is needed later it must be a SEPARATE aws_sns_topic_policy
# resource: an inline `policy` that references aws_sns_topic.this[...].arn is a
# self-referential cycle and will fail (§4 of that guide). Build the document
# with aws_iam_policy_document — it validates at plan time — and take the account
# id from data.aws_caller_identity rather than a literal (§5).
#
# Delivery-status logging (*_feedback_role_arn + *_success_feedback_sample_rate)
# is deliberately not exposed. No topic in this account uses it, and a sample
# rate without a role ARN does nothing. If it is ever needed, add it as ONE
# paired object per protocol so the two halves cannot drift apart.
