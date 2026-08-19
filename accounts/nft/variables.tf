# =============================================================================
# Root variable declarations for the CONSOLIDATED nft account.
# =============================================================================
# One root, one state file. These are the merged declarations from the former
# per-domain roots (networking + security + compute). aws_region and common_tags
# are declared ONCE here; every other variable is unique to its domain.
#
# Values arrive from the auto-loaded data files:
#   common.auto.tfvars  networking.auto.tfvars  security.auto.tfvars
#   compute.auto.tfvars
# =============================================================================

variable "aws_region" {
  description = "AWS region for this account."
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Tags added to every taggable resource. Empty during migration."
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# NETWORKING
# ---------------------------------------------------------------------------

# Root-level variable declarations. Types mirror the module's variables
# exactly — the root just receives values from terraform.tfvars and passes
# them through in main.tf.

variable "vpcs" {
  type = map(object({
    cidr_block                           = string
    instance_tenancy                     = optional(string, "default")
    enable_dns_support                   = optional(string, true)
    enable_dns_hostnames                 = optional(string, true)
    enable_network_address_usage_metrics = optional(string, false)
    tags                                 = optional(map(string), {})
  }))
  default = {}
}

variable "subnets" {
  description = "Map of subnets, keyed by local name, vpc_key points at an entry in var.vpcs"
  type = map(object({
    vpc_key                             = string
    cidr_block                          = string
    availability_zone                   = optional(string)
    map_public_ip_on_launch             = optional(bool, false)
    private_dns_hostname_type_on_launch = optional(string, "ip-name")
    tags                                = optional(map(string), {})
  }))
  default = {}
}

variable "internet_gateways" {
  description = "Map of internet gateways, keyed by local name, vpc_key points at an entry in var.vpcs"
  type = map(object({
    vpc_key = string
    tags    = optional(map(string), {})
  }))
  default = {}
}

variable "eips" {
  description = "Map of Elastic IPs(used by NAT Gateways), keyed by local name"
  type = map(object({
    domain = string
    tags   = optional(map(string), {})
  }))
  default = {}
}

variable "nat_gateways" {
  description = "Map of NAT Gateways, keyed by local name, eip_key -> var.eips entry, subnet_key -> var.subnets entry"
  type = map(object({
    eip_key    = string
    subnet_key = string
    tags       = optional(map(string), {})
  }))
  default = {}
}

variable "route_tables" {
  description = "Map of route tables, keyed by local name, vpc_key points at an entry in var.vpcs"
  type = map(object({
    vpc_key = string
    tags    = optional(map(string), {})
  }))
  default = {}
}

variable "route_table_associations" {
  description = "Which subnet uses which route table, keyed by local name, subnet_key -> var.subnets entry, route_table_key -> var.route_tables. No tags"
  type = map(object({
    subnet_key      = string
    route_table_key = string
  }))
  default = {}
}

variable "network_acls" {
  description = "Map of network ACLs, keyed by local name, vpc_key points at an entry in var.vpcs"
  type = map(object({
    vpc_key = string
    tags    = optional(map(string), {})
  }))
  default = {}
}

variable "network_acl_associations" {
  type = map(object({
    network_acl_key = string
    subnet_key      = string
  }))
  default = {}
}

variable "security_group_lookups" {
  type = map(object({
    name    = string
    vpc_key = string
  }))
  default = {}
}

variable "vpc_endpoints" {
  type = map(object({
    vpc_key             = string
    service_name        = string
    vpc_endpoint_type   = string
    private_dns_enabled = optional(bool, false)
    security_group_keys = list(string)
    subnet_configurations = list(object({
      ipv4       = string
      subnet_key = string
    }))
    tags = optional(map(string))
  }))
  default = {}
}

variable "security_groups" {
  description = "Map of security groups, keyed by local name, vpc_key points at an entry in var.vpcs"
  type = map(object({
    vpc_key     = string
    name        = optional(string)
    description = optional(string)
    tags        = optional(map(string), {})
  }))
  default = {}
}

# ---------------------------------------------------------------------------
# SECURITY
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# COMPUTE
# ---------------------------------------------------------------------------

# Root-level variable declarations. Schemas mirror the module's variables
# exactly EXCEPT for the cross-domain fields: the root receives *_key(s)
# (security_group_keys / subnet_keys / vpc_key / iam_instance_profile_key)
# from terraform.tfvars and resolves them to real IDs/ARNs in main.tf before
# passing plain values into the module. Everything else is identical.

variable "launch_templates" {
  description = "Map of launch templates, keyed by local name. security_group_keys -> networking SGs; iam_instance_profile_key -> IAM instance profile."
  type = map(object({
    name                    = string
    image_id                = optional(string)
    instance_type           = optional(string)
    key_name                = optional(string)
    description             = optional(string)
    disable_api_stop        = optional(bool)
    disable_api_termination = optional(bool)
    ebs_optimized           = optional(string)
    # cross-domain keys (resolved in main.tf):
    security_group_keys      = optional(list(string), [])
    iam_instance_profile_key = optional(string)
    tags                     = optional(map(string), {})
    tag_specifications = optional(list(object({
      resource_type = optional(string)
      tags          = optional(map(string), {})
    })), [])
  }))
  default = {}
}

variable "target_groups" {
  description = "Map of aws_lb_target_group, keyed by local name. vpc_key -> networking VPC."
  type = map(object({
    name                              = string
    port                              = number
    protocol                          = string
    target_type                       = string
    protocol_version                  = optional(string)
    deregistration_delay              = optional(string)
    ip_address_type                   = optional(string)
    load_balancing_algorithm_type     = optional(string)
    load_balancing_cross_zone_enabled = optional(string)
    preserve_client_ip                = optional(string)
    proxy_protocol_v2                 = optional(bool)
    vpc_key                           = string # cross-domain key (resolved in main.tf)
    tags                              = optional(map(string), {})

    health_check = optional(object({
      enabled             = optional(bool)
      healthy_threshold   = optional(number)
      interval            = optional(number)
      matcher             = optional(string)
      path                = optional(string)
      port                = optional(string)
      protocol            = optional(string)
      timeout             = optional(number)
      unhealthy_threshold = optional(number)
    }))

    stickiness = optional(object({
      type            = string
      enabled         = optional(bool)
      cookie_duration = optional(number)
      cookie_name     = optional(string)
    }))

    target_group_health = optional(object({
      dns_failover = optional(object({
        minimum_healthy_targets_count      = optional(string)
        minimum_healthy_targets_percentage = optional(string)
      }))
      unhealthy_state_routing = optional(object({
        minimum_healthy_targets_count      = optional(number)
        minimum_healthy_targets_percentage = optional(string)
      }))
    }))

    target_health_state = optional(object({
      enable_unhealthy_connection_termination = optional(bool)
      unhealthy_draining_interval             = optional(number)
    }))
  }))
  default = {}
}

variable "load_balancers" {
  description = "Map of aws_lb, keyed by local name. security_group_keys -> networking SGs; subnet_keys -> networking subnets."
  type = map(object({
    name                             = string
    load_balancer_type               = optional(string)
    internal                         = optional(bool)
    ip_address_type                  = optional(string)
    enable_deletion_protection       = optional(bool)
    enable_cross_zone_load_balancing = optional(bool)
    enable_zonal_shift               = optional(bool)
    dns_record_client_routing_policy = optional(string)
    # cross-domain keys (resolved in main.tf):
    security_group_keys = optional(list(string), [])
    subnet_keys         = list(string)
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "lb_listeners" {
  description = "Map of aws_lb_listener, keyed by local name. Intra-domain keys only — passed through to the module unchanged."
  type = map(object({
    lb_key                   = string
    port                     = optional(number)
    protocol                 = optional(string)
    ssl_policy               = optional(string)
    certificate_arn          = optional(string)
    tcp_idle_timeout_seconds = optional(number)
    tags                     = optional(map(string), {})
    default_action = object({
      type             = string
      order            = optional(number)
      target_group_key = optional(string)
      forward = optional(object({
        target_groups = list(object({
          target_group_key = string
          weight           = optional(number)
        }))
        stickiness = optional(object({
          duration = number
          enabled  = optional(bool)
        }))
      }))
    })
  }))
  default = {}
}

variable "auto_scaling_groups" {
  description = "Map of aws_autoscaling_group, keyed by local name. subnet_keys -> networking subnets; service_linked_role_arn is injected in main.tf."
  type = map(object({
    name                    = string
    max_size                = number
    min_size                = number
    desired_capacity        = optional(number)
    launch_template_key     = string
    launch_template_version = optional(string, "$Latest")

    capacity_rebalance        = optional(bool)
    default_cooldown          = optional(number)
    default_instance_warmup   = optional(number)
    health_check_type         = optional(string)
    health_check_grace_period = optional(number)
    max_instance_lifetime     = optional(number)
    protect_from_scale_in     = optional(bool)
    enabled_metrics           = optional(list(string), [])

    # cross-domain key (resolved in main.tf):
    subnet_keys = optional(list(string), [])

    availability_zone_distribution = optional(object({
      capacity_distribution_strategy = string
    }))
    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = string
    }))
    instance_maintenance_policy = optional(object({
      min_healthy_percentage = number
      max_healthy_percentage = number
    }))
    traffic_sources = optional(list(object({
      target_group_key = string
      type             = string
    })), [])
    tags = optional(list(object({
      key                 = string
      value               = string
      propagate_at_launch = bool
    })), [])
  }))
  default = {}
}

variable "asg_policies" {
  description = "Map of aws_autoscaling_policy, keyed by local name. Intra-domain keys only — passed through to the module unchanged."
  type = map(object({
    name        = string
    asg_key     = string
    policy_type = optional(string)
    enabled     = optional(bool)

    target_tracking_configuration = optional(object({
      target_value     = number
      disable_scale_in = optional(bool)
      predefined_metric_specification = optional(object({
        predefined_metric_type = string
      }))
    }))
    predictive_scaling_configuration = optional(object({
      max_capacity_breach_behavior = optional(string)
      mode                         = optional(string)
      scheduling_buffer_time       = optional(string)
      metric_specification = object({
        target_value = number
        predefined_metric_pair_specification = optional(object({
          predefined_metric_type = string
        }))
      })
    }))
  }))
  default = {}
}

variable "ecs_clusters" {
  description = "Map of aws_ecs_cluster, keyed by local name. No references — passed through to the module unchanged."
  type = map(object({
    name = string
    tags = optional(map(string), {})
    configuration = optional(object({
      execute_command_configuration = optional(object({
        logging    = optional(string)
        kms_key_id = optional(string)
      }))
    }))
    settings = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  default = {}
}


# ---------------------------------------------------------------------------
# DATA
# ---------------------------------------------------------------------------
# Schemas mirror modules/data/variables.tf exactly, EXCEPT the subnet groups:
# the root takes subnet_keys (names) and resolves them to real subnet IDs in
# main.tf via module.networking.subnet_ids.

variable "db_parameter_groups" {
  description = "Map of aws_db_parameter_group, keyed by local name."
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
  description = "Map of aws_rds_cluster_parameter_group, keyed by local name."
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
  description = "Map of aws_db_option_group, keyed by local name."
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
  description = "Map of aws_db_subnet_group, keyed by local name. subnet_keys -> networking subnets."
  type = map(object({
    name        = string
    description = optional(string)
    subnet_keys = list(string)
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "elasticache_parameter_groups" {
  description = "Map of aws_elasticache_parameter_group, keyed by local name."
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
  description = "Map of aws_elasticache_subnet_group, keyed by local name. subnet_keys -> networking subnets."
  type = map(object({
    name        = string
    description = optional(string)
    subnet_keys = list(string)
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "backup_vaults" {
  description = "Map of aws_backup_vault, keyed by local name. kms_key_arn null => keep the AWS-managed key (ForceNew if changed)."
  type = map(object({
    name          = string
    kms_key_arn   = optional(string)
    force_destroy = optional(bool)
    tags          = optional(map(string), {})
  }))
  default = {}
}

variable "backup_plans" {
  description = "Map of aws_backup_plan, keyed by local name. rules[*].vault_key -> a backup_vaults entry."
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
  description = "Map of aws_s3_bucket, keyed by local name."
  type = map(object({
    bucket              = string
    bucket_namespace    = optional(string)
    force_destroy       = optional(bool)
    object_lock_enabled = optional(bool)
    tags                = optional(map(string), {})
  }))
  default = {}
}

# ---------------------------------------------------------------------------
# OBSERVABILITY
# ---------------------------------------------------------------------------

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
  description = "Map of aws_cloudwatch_event_rule, keyed by local name. Patterns live in var.event_patterns under the same key."
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

# Untyped by necessity: patterns have differing shapes, so a map(object(...))
# constraint cannot unify them. See modules/observability/variables.tf.
variable "event_patterns" {
  description = "EventBridge patterns as native HCL, keyed to match var.event_rules."
  type        = any
  default     = {}
}

variable "metric_alarms" {
  description = "Map of aws_cloudwatch_metric_alarm, keyed by local name."
  type = map(object({
    alarm_name                = string
    comparison_operator       = optional(string)
    evaluation_periods        = optional(number)
    datapoints_to_alarm       = optional(number)
    metric_name               = optional(string)
    namespace                 = optional(string)
    period                    = optional(number)
    statistic                 = optional(string)
    threshold                 = optional(number)
    unit                      = optional(string)
    treat_missing_data        = optional(string)
    actions_enabled           = optional(bool)
    alarm_description         = optional(string)
    dimensions                = optional(map(string), {})
    alarm_actions             = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    tags                      = optional(map(string), {})
  }))
  default = {}
}

# ---------------------------------------------------------------------------
# Pipeline
# ---------------------------------------------------------------------------


variable "github_oidc_provider" {
  description = "GitHub Actions OIDC identity provider for this account. null = don't create one."
  type = object({
    tags = optional(map(string), {})
  })
  default = null
}

variable "github_actions_plan_roles" {
  description = "IAM roles GitHub Actions plan workflows can assume via OIDC (read-only), keyed by local role name."
  type = map(object({
    repo           = string
    default_branch = optional(string, "main")
    state_bucket   = string
    state_key      = string
    tags           = optional(map(string), {})
  }))
  default = {}
}

variable "github_actions_apply_roles" {
  description = "IAM roles GitHub Actions apply workflows can assume via OIDC (environment-gated), keyed by local role name."
  type = map(object({
    repo               = string
    github_environment = string
    tags               = optional(map(string), {})
  }))
  default = {}
}