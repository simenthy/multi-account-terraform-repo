# Merges the three flat files (alb_/instance_/ip_lb_target_groups.tf) — all are
# aws_lb_target_group.
#
# ============================================================================
# BEGINNER NOTE — why this file is full of `dynamic` blocks
# ============================================================================
# This ONE resource block builds EVERY target group in terraform.tfvars, via
# `for_each` (one aws_lb_target_group per map entry). But those entries are not
# identical: some have a `stickiness {}` block, some don't; some have a
# `target_health_state {}` block, some don't. A normal nested block (like
# `health_check { ... }`) is either written or not — you cannot put an `if` in
# front of it, and you cannot assign it from a variable. `dynamic` is how we
# generate a nested block CONDITIONALLY or REPEATEDLY from data.
#
# A `dynamic "X"` block loops (`for_each`) and emits one real `X {}` block per
# element of the collection:
#   * loop over an EMPTY list []  -> zero blocks (the block is omitted)
#   * loop over a ONE-item list   -> exactly one block
#   * loop over an N-item list    -> N blocks
# Inside `content {}`, the iterator object `X.value` is the current element.
#
# PATTERN A — "zero-or-one optional block" (used throughout this file):
#     for_each = each.value.thing == null ? [] : [each.value.thing]
#   Reads as: "no `thing` in the tfvars entry? loop over [] -> emit nothing.
#   Otherwise loop over a single-item list -> emit exactly one block." Omitting
#   an absent block is what keeps imported infrastructure at ZERO DIFF: a target
#   group that never had a stickiness block still gets none.
# ============================================================================
resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  target_type = each.value.target_type

  protocol_version                  = each.value.protocol_version
  deregistration_delay              = each.value.deregistration_delay
  ip_address_type                   = each.value.ip_address_type
  load_balancing_algorithm_type     = each.value.load_balancing_algorithm_type
  load_balancing_cross_zone_enabled = each.value.load_balancing_cross_zone_enabled
  preserve_client_ip                = each.value.preserve_client_ip
  proxy_protocol_v2                 = each.value.proxy_protocol_v2

  # cross-domain: vpc_id is resolved by the root from vpc_key.
  vpc_id = each.value.vpc_id

  tags = merge(var.common_tags, each.value.tags)

  # PATTERN A: emit one `health_check {}` block only if the entry supplied one.
  # `health_check.value` below is the loop iterator (the object from tfvars),
  # NOT the AWS attribute — it just happens to share the block's name.
  dynamic "health_check" {
    for_each = each.value.health_check == null ? [] : [each.value.health_check]
    content {
      enabled             = health_check.value.enabled
      healthy_threshold   = health_check.value.healthy_threshold
      interval            = health_check.value.interval
      matcher             = health_check.value.matcher
      path                = health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      timeout             = health_check.value.timeout
      unhealthy_threshold = health_check.value.unhealthy_threshold
    }
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness == null ? [] : [each.value.stickiness]
    content {
      type            = stickiness.value.type
      enabled         = stickiness.value.enabled
      cookie_duration = stickiness.value.cookie_duration
      cookie_name     = stickiness.value.cookie_name
    }
  }

  # PATTERN A, but NESTED: the outer `target_group_health {}` block itself
  # contains two more optional sub-blocks. Each level repeats the same null-gate
  # idiom. Note the iterator changes at each level: inside the outer content we
  # read `target_group_health.value.dns_failover`, and inside the inner content
  # we read `dns_failover.value.*`.
  dynamic "target_group_health" {
    for_each = each.value.target_group_health == null ? [] : [each.value.target_group_health]
    content {
      dynamic "dns_failover" {
        for_each = target_group_health.value.dns_failover == null ? [] : [target_group_health.value.dns_failover]
        content {
          minimum_healthy_targets_count      = dns_failover.value.minimum_healthy_targets_count
          minimum_healthy_targets_percentage = dns_failover.value.minimum_healthy_targets_percentage
        }
      }
      dynamic "unhealthy_state_routing" {
        for_each = target_group_health.value.unhealthy_state_routing == null ? [] : [target_group_health.value.unhealthy_state_routing]
        content {
          minimum_healthy_targets_count      = unhealthy_state_routing.value.minimum_healthy_targets_count
          minimum_healthy_targets_percentage = unhealthy_state_routing.value.minimum_healthy_targets_percentage
        }
      }
    }
  }

  dynamic "target_health_state" {
    for_each = each.value.target_health_state == null ? [] : [each.value.target_health_state]
    content {
      enable_unhealthy_connection_termination = target_health_state.value.enable_unhealthy_connection_termination
      unhealthy_draining_interval             = target_health_state.value.unhealthy_draining_interval
    }
  }
}
