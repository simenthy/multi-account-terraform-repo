variable "common_tags" {
  description = "Tags added to every taggable resource. Empty during migration."
  type        = map(string)
  default     = {}
}


variable "kms_keys" {
  description = "Map of KMS Keys"
  type = map(object({
    customer_master_key_spec = optional(string)
    enable_key_rotation      = optional(bool, false)
    rotation_period_in_days  = optional(number)
    key_usage                = optional(string)
    tags                     = optional(map(string))
  }))

  validation {
    condition = alltrue([
      for k, v in var.kms_keys :
      (
        try(v.rotation_period_in_days, null) == null ||
        try(v.enable_key_rotation, false) == true
      )
    ])

    error_message = "enable_key_rotation must be true when rotation_period_in_days is specified."
  }
  default = {}
}

variable "kms_aliases" {
  description = "Map of KMS Aliases"
  type = map(object({
    name       = string
    key_id_key = string
  }))
  default = {}
}

variable "web_acls" {
  description = "Map of AWS WAFv2 Web ACL configurations"

  type = map(object({
    name          = string
    scope         = string
    tags          = optional(map(string))
    token_domains = list(string)

    default_action = object({
      type = string
    })

    visibility_config = object({
      cloudwatch_metrics_enabled = bool
      metric_name                = string
      sampled_requests_enabled   = bool
    })

    rules = optional(list(object({
      name     = string
      priority = number

      action = object({
        type = string
      })

      rate_based_statement = object({
        aggregate_key_type    = string
        evaluation_window_sec = number
        limit                 = number

        scope_down_statement = object({
          positional_constraint = string
          search_string         = string
          field_to_match        = string

          text_transformation = object({
            priority = number
            type     = string
          })
        })
      })

      visibility_config = object({
        cloudwatch_metrics_enabled = bool
        metric_name                = string
        sampled_requests_enabled   = bool
      })
    })))
  }))
}