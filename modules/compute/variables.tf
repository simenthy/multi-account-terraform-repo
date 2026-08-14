# These variables are the module's "order form": the calling root folder
# fills them in (from terraform.tfvars, after resolving cross-domain *_key
# fields to real IDs/ARNs) and the module builds exactly what was ordered.
# Every variable is a MAP whose keys are the resource local names — that key
# becomes the resource's identity in state, e.g.
# aws_lb_target_group.this["alb_target_check"].
#
# Intra-domain relationships are expressed with *_key fields resolved INSIDE
# this module against sibling `this` resources (launch_template_key, lb_key,
# target_group_key, asg_key). Cross-domain values (VPC/subnet/SG ids, IAM
# ARNs) arrive already resolved to plain IDs — the module never does SSM or
# IAM lookups.
#
# Optionality rule: an attribute is optional() unless the AWS provider
# registry marks it Required. A null optional renders nothing, so the
# provider default holds and imported state stays zero-diff.

variable "common_tags" {
  description = "Tags added to every taggable resource on top of each resource's own tags. Kept empty ({}) during migration so imported tags stay byte-identical."
  type        = map(string)
  default     = {}
}

variable "launch_templates" {
  description = "Map of launch templates, keyed by local name. Cross-domain fields (vpc_security_group_ids, iam_instance_profile_arn) are resolved by the root before reaching the module."
  type = map(object({
    name                    = string
    image_id                = optional(string)
    instance_type           = optional(string)
    key_name                = optional(string)
    description             = optional(string)
    disable_api_stop        = optional(bool)
    disable_api_termination = optional(bool)
    ebs_optimized           = optional(string) # provider takes "true"/"false" here
    # cross-domain (resolved to real values by the ROOT before reaching the module):
    vpc_security_group_ids   = optional(list(string), [])
    iam_instance_profile_arn = optional(string)
    tags                     = optional(map(string), {})
    tag_specifications = optional(list(object({
      resource_type = optional(string)
      tags          = optional(map(string), {})
    })), [])
  }))
  default = {}
}

variable "target_groups" {
  description = "Map of aws_lb_target_group, keyed by local name. vpc_id is resolved cross-domain by the root."
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
    vpc_id                            = string # cross-domain: root resolves vpc_key
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
      type            = string # registry-Required
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
  description = "Map of aws_lb, keyed by local name. security_group_ids and subnet_ids are resolved cross-domain by the root."
  type = map(object({
    name                             = string
    load_balancer_type               = optional(string)
    internal                         = optional(bool)
    ip_address_type                  = optional(string)
    enable_deletion_protection       = optional(bool)
    enable_cross_zone_load_balancing = optional(bool)
    enable_zonal_shift               = optional(bool)
    dns_record_client_routing_policy = optional(string)
    # cross-domain (resolved by ROOT):
    security_group_ids = optional(list(string), [])
    subnet_ids         = list(string)
    tags               = optional(map(string), {})
  }))
  default = {}
}

variable "lb_listeners" {
  description = "Map of aws_lb_listener, keyed by local name. lb_key and target_group_key are intra-domain references resolved inside the module."
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
  description = "Map of aws_autoscaling_group, keyed by local name. launch_template_key and traffic_sources[*].target_group_key are intra-domain; vpc_zone_identifier and service_linked_role_arn are resolved cross-domain by the root."
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
    service_linked_role_arn   = optional(string) # cross-domain: root injects the IAM local

    # cross-domain (resolved by ROOT from subnet_keys):
    vpc_zone_identifier = optional(list(string), [])

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
  description = "Map of aws_autoscaling_policy, keyed by local name. asg_key is an intra-domain reference to an auto_scaling_groups entry."
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
  description = "Map of aws_ecs_cluster, keyed by local name."
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
