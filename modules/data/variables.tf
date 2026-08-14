# The data module's "order form". Every variable is a MAP keyed by the resource's
# local name — that key becomes the resource's identity in state, e.g.
# aws_db_parameter_group.this["fra_prod_baghub_aurora_postgresql_db_12"].
#
# Optionality rule: an attribute is optional() unless the AWS provider marks it
# Required (verified against the provider schema, not the website). A null
# optional renders nothing, so the provider default holds and imported state
# stays zero-diff.
#
# Cross-domain values arrive already resolved: subnet_ids are plain IDs that the
# ROOT produced from subnet_keys. The module never looks anything up itself.

variable "common_tags" {
  description = "Tags added to every taggable resource on top of each resource's own tags. Kept empty ({}) during migration so imported tags stay byte-identical."
  type        = map(string)
  default     = {}
}

variable "db_parameter_groups" {
  description = "Map of aws_db_parameter_group, keyed by local name. `family` is provider-Required."
  type = map(object({
    name         = string
    family       = string
    description  = optional(string)
    skip_destroy = optional(bool)
    tags         = optional(map(string), {})
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string)
    })), [])
  }))
  default = {}
}

variable "rds_cluster_parameter_groups" {
  description = "Map of aws_rds_cluster_parameter_group, keyed by local name. `family` is provider-Required."
  type = map(object({
    name        = string
    family      = string
    description = optional(string)
    tags        = optional(map(string), {})
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string)
    })), [])
  }))
  default = {}
}

variable "db_option_groups" {
  description = "Map of aws_db_option_group, keyed by local name. `engine_name` and `major_engine_version` are provider-Required."
  type = map(object({
    name                     = string
    engine_name              = string
    major_engine_version     = string
    option_group_description = optional(string)
    skip_destroy             = optional(bool)
    tags                     = optional(map(string), {})
    options = optional(list(object({
      option_name                    = string
      port                           = optional(number)
      version                        = optional(string)
      db_security_group_memberships  = optional(list(string), [])
      vpc_security_group_memberships = optional(list(string), [])
      option_settings = optional(list(object({
        name  = string
        value = string
      })), [])
    })), [])
  }))
  default = {}
}

variable "db_subnet_groups" {
  description = "Map of aws_db_subnet_group, keyed by local name. subnet_ids are resolved cross-domain by the root from subnet_keys."
  type = map(object({
    name        = string
    description = optional(string)
    subnet_ids  = list(string)
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "elasticache_parameter_groups" {
  description = "Map of aws_elasticache_parameter_group, keyed by local name. `family` and `name` are provider-Required."
  type = map(object({
    name        = string
    family      = string
    description = optional(string)
    tags        = optional(map(string), {})
    parameters = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  default = {}
}

variable "elasticache_subnet_groups" {
  description = "Map of aws_elasticache_subnet_group, keyed by local name. subnet_ids are resolved cross-domain by the root from subnet_keys."
  type = map(object({
    name        = string
    description = optional(string)
    subnet_ids  = list(string)
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "backup_vaults" {
  description = "Map of aws_backup_vault, keyed by local name."
  type = map(object({
    name = string
    # kms_key_arn is Optional+Computed AND ForceNew. Leaving it null means "keep
    # whatever key AWS already uses" (for these vaults, the AWS-managed
    # alias/aws/backup key). Setting it to a different key REPLACES the vault,
    # which can orphan recovery points — so set it only deliberately.
    kms_key_arn   = optional(string)
    force_destroy = optional(bool)
    tags          = optional(map(string), {})
  }))
  default = {}
}

variable "backup_plans" {
  description = "Map of aws_backup_plan, keyed by local name. Each rule's vault_key is an intra-module reference to a backup_vaults entry."
  type = map(object({
    name = string
    tags = optional(map(string), {})
    rules = list(object({
      rule_name                    = string
      vault_key                    = string
      schedule                     = optional(string)
      schedule_expression_timezone = optional(string)
      start_window                 = optional(number)
      completion_window            = optional(number)
      enable_continuous_backup     = optional(bool)
      recovery_point_tags          = optional(map(string), {})
      # AWS's own lifecycle block (cold storage / delete after) — NOT Terraform's
      # lifecycle meta-argument. Named backup_lifecycle here to keep that clear.
      backup_lifecycle = optional(object({
        cold_storage_after                        = optional(number)
        delete_after                              = optional(number)
        opt_in_to_archive_for_supported_resources = optional(bool)
      }))
    }))
  }))
  default = {}
}

variable "s3_buckets" {
  description = "Map of aws_s3_bucket, keyed by local name. Bucket policies are deliberately NOT managed here — see s3_buckets.tf."
  type = map(object({
    bucket              = string
    bucket_namespace    = optional(string)
    force_destroy       = optional(bool)
    object_lock_enabled = optional(bool)
    tags                = optional(map(string), {})
  }))
  default = {}
}
