# The observability module's "order form". Every variable is a MAP keyed by the
# resource's local name — that key becomes the resource's identity in state.
#
# Optionality rule: an attribute is optional() unless the AWS provider marks it
# Required (verified against the provider schema). A null optional renders
# nothing, so the provider default holds and imported state stays zero-diff.

variable "common_tags" {
  description = "Tags added to every taggable resource on top of each resource's own tags. Kept empty ({}) during migration so imported tags stay byte-identical."
  type        = map(string)
  default     = {}
}

variable "sns_topics" {
  description = "Map of aws_sns_topic, keyed by local name."
  type = map(object({
    name                        = string
    display_name                = optional(string)
    fifo_topic                  = optional(bool)
    content_based_deduplication = optional(bool)
    tracing_config              = optional(string)
    tags                        = optional(map(string), {})
  }))
  default = {}
}

variable "event_rules" {
  description = "Map of aws_cloudwatch_event_rule, keyed by local name. A rule uses EITHER schedule_expression OR an entry in var.event_patterns under the same key — never both."
  type = map(object({
    name                = string
    description         = optional(string)
    event_bus_name      = optional(string)
    schedule_expression = optional(string)
    state               = optional(string)
    force_destroy       = optional(bool)
    tags                = optional(map(string), {})
  }))
  default = {}
}

# EventBridge patterns live in their own variable, keyed by the SAME key as the
# rule they belong to.
#
# Why separate, and why `any`: patterns have genuinely different shapes (some are
# just {source}, others nest a whole {detail} object). A map(object(...)) type
# constraint requires every element to share one type, so an `optional(any)`
# field inside var.event_rules fails to unify and Terraform rejects the tfvars.
# Splitting it keeps full type-checking on everything structural (name, state,
# schedule) and confines the untyped escape hatch to the pattern body.
#
# Patterns stay native HCL here — diffable and composable — and jsonencode() is
# applied once, inside the module (see event_rules.tf). Callers never write
# pre-stringified JSON; tfvars files cannot call jsonencode() anyway.
variable "event_patterns" {
  description = "EventBridge patterns as native HCL, keyed by the matching var.event_rules key. jsonencode() is applied inside the module."
  type        = any
  default     = {}
}

variable "metric_alarms" {
  description = "Map of aws_cloudwatch_metric_alarm, keyed by local name. Only alarm_name is provider-Required; the rest are required by the API for static-metric alarms."
  type = map(object({
    alarm_name          = string
    comparison_operator = optional(string)
    evaluation_periods  = optional(number)
    datapoints_to_alarm = optional(number)
    metric_name         = optional(string)
    namespace           = optional(string)
    period              = optional(number)
    statistic           = optional(string)
    threshold           = optional(number)
    unit                = optional(string)
    treat_missing_data  = optional(string)
    actions_enabled     = optional(bool)
    alarm_description   = optional(string)
    dimensions          = optional(map(string), {})
    # Kept as [] rather than omitted so the rendered config matches imported
    # state exactly (null and [] are not the same in a diff).
    alarm_actions             = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    tags                      = optional(map(string), {})
  }))
  default = {}
}
