resource "aws_autoscaling_group" "this" {
  for_each = var.auto_scaling_groups

  name             = each.value.name
  max_size         = each.value.max_size
  min_size         = each.value.min_size
  desired_capacity = each.value.desired_capacity

  capacity_rebalance        = each.value.capacity_rebalance
  default_cooldown          = each.value.default_cooldown
  default_instance_warmup   = each.value.default_instance_warmup
  health_check_type         = each.value.health_check_type
  health_check_grace_period = each.value.health_check_grace_period
  max_instance_lifetime     = each.value.max_instance_lifetime
  protect_from_scale_in     = each.value.protect_from_scale_in
  enabled_metrics           = each.value.enabled_metrics

  # cross-domain: service_linked_role_arn and vpc_zone_identifier are resolved
  # by the root (IAM local / subnet_keys) before reaching the module.
  service_linked_role_arn = each.value.service_linked_role_arn
  vpc_zone_identifier     = each.value.vpc_zone_identifier

  # intra-domain: ASG → launch template.
  # NOTE: this block is a plain (static) block, NOT dynamic — every ASG in this
  # workspace has exactly one launch_template, so there's nothing to make
  # conditional. Contrast it with the `dynamic` blocks below, which exist
  # precisely because those blocks are optional or repeatable across entries.
  launch_template {
    id      = aws_launch_template.this[each.value.launch_template_key].id
    version = each.value.launch_template_version
  }

  # PATTERN A (zero-or-one optional block) — see target_groups.tf for the full
  # `dynamic` explanation. The next three blocks each appear at most once and
  # only if the tfvars entry supplied them.
  dynamic "availability_zone_distribution" {
    for_each = each.value.availability_zone_distribution == null ? [] : [each.value.availability_zone_distribution]
    content {
      capacity_distribution_strategy = availability_zone_distribution.value.capacity_distribution_strategy
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = each.value.capacity_reservation_specification == null ? [] : [each.value.capacity_reservation_specification]
    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference
    }
  }

  dynamic "instance_maintenance_policy" {
    for_each = each.value.instance_maintenance_policy == null ? [] : [each.value.instance_maintenance_policy]
    content {
      min_healthy_percentage = instance_maintenance_policy.value.min_healthy_percentage
      max_healthy_percentage = instance_maintenance_policy.value.max_healthy_percentage
    }
  }

  # PATTERN B (repeatable block): one `traffic_source {}` per element of the
  # list. An ASG can attach to several target groups, so this loops over a real
  # list (empty list -> no blocks). intra-domain: each element's target_group_key
  # is resolved here against the module's own aws_lb_target_group.this resources.
  dynamic "traffic_source" {
    for_each = each.value.traffic_sources
    content {
      identifier = aws_lb_target_group.this[traffic_source.value.target_group_key].arn
      type       = traffic_source.value.type
    }
  }

  # PATTERN B (repeatable block): ASGs express tags as repeated `tag {}` blocks
  # (key/value/propagate_at_launch), NOT as a `tags = {}` map like other
  # resources — so we loop and emit one block per tag.
  dynamic "tag" {
    for_each = each.value.tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
