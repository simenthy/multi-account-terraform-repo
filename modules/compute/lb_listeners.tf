resource "aws_lb_listener" "this" {
  for_each = var.lb_listeners

  # intra-domain: listener → load balancer.
  load_balancer_arn        = aws_lb.this[each.value.lb_key].arn
  port                     = each.value.port
  protocol                 = each.value.protocol
  ssl_policy               = each.value.ssl_policy
  certificate_arn          = each.value.certificate_arn
  tcp_idle_timeout_seconds = each.value.tcp_idle_timeout_seconds

  tags = merge(var.common_tags, each.value.tags)

  # `default_action` is REQUIRED and always appears exactly once, so it is a
  # plain static block (not dynamic). Its INSIDE, however, mixes both patterns.
  default_action {
    type  = each.value.default_action.type
    order = each.value.default_action.order

    # This is an ARGUMENT (not a block), so we make it conditional the easy way:
    # a ternary that assigns null when there's no target_group_key. Assigning
    # null tells Terraform to omit the argument. (You only need `dynamic` for
    # BLOCKS — arguments like this one can just take a conditional expression.)
    # intra-domain: default action → target group arn.
    target_group_arn = (
      each.value.default_action.target_group_key == null
      ? null
      : aws_lb_target_group.this[each.value.default_action.target_group_key].arn
    )

    # PATTERN A (zero-or-one optional block): emit a `forward {}` block only if
    # the entry has one. See target_groups.tf for the full explanation.
    dynamic "forward" {
      for_each = each.value.default_action.forward == null ? [] : [each.value.default_action.forward]
      content {
        # PATTERN B (repeatable) NESTED inside forward: a forward action can
        # spread traffic across several target groups, so loop over the list and
        # emit one `target_group {}` block each. Iterator is `target_group`;
        # note we read `forward.value.target_groups` (the outer iterator) to get
        # the list.
        dynamic "target_group" {
          for_each = forward.value.target_groups
          content {
            arn    = aws_lb_target_group.this[target_group.value.target_group_key].arn
            weight = target_group.value.weight
          }
        }
        # PATTERN A NESTED inside forward: optional session stickiness.
        dynamic "stickiness" {
          for_each = forward.value.stickiness == null ? [] : [forward.value.stickiness]
          content {
            duration = stickiness.value.duration
            enabled  = stickiness.value.enabled
          }
        }
      }
    }
  }
}
