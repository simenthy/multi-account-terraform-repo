resource "aws_autoscaling_policy" "this" {
  for_each = var.asg_policies

  name        = each.value.name
  policy_type = each.value.policy_type
  enabled     = each.value.enabled

  # intra-domain: policy → auto scaling group name.
  autoscaling_group_name = aws_autoscaling_group.this[each.value.asg_key].name

  # A scaling policy is EITHER target-tracking OR predictive — never both. Both
  # are modelled as PATTERN A (zero-or-one optional block, see target_groups.tf):
  # whichever one the tfvars entry fills in gets emitted; the other's for_each is
  # [] and produces nothing. This is how `dynamic` expresses "one of these".
  dynamic "target_tracking_configuration" {
    for_each = each.value.target_tracking_configuration == null ? [] : [each.value.target_tracking_configuration]
    content {
      target_value     = target_tracking_configuration.value.target_value
      disable_scale_in = target_tracking_configuration.value.disable_scale_in
      dynamic "predefined_metric_specification" {
        for_each = target_tracking_configuration.value.predefined_metric_specification == null ? [] : [target_tracking_configuration.value.predefined_metric_specification]
        content {
          predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
        }
      }
    }
  }

  dynamic "predictive_scaling_configuration" {
    for_each = each.value.predictive_scaling_configuration == null ? [] : [each.value.predictive_scaling_configuration]
    content {
      max_capacity_breach_behavior = predictive_scaling_configuration.value.max_capacity_breach_behavior
      mode                         = predictive_scaling_configuration.value.mode
      scheduling_buffer_time       = predictive_scaling_configuration.value.scheduling_buffer_time
      # Static block, not dynamic: when a predictive policy exists, AWS REQUIRES
      # exactly one metric_specification, so there is nothing conditional here.
      metric_specification {
        target_value = predictive_scaling_configuration.value.metric_specification.target_value
        dynamic "predefined_metric_pair_specification" {
          for_each = predictive_scaling_configuration.value.metric_specification.predefined_metric_pair_specification == null ? [] : [predictive_scaling_configuration.value.metric_specification.predefined_metric_pair_specification]
          content {
            predefined_metric_type = predefined_metric_pair_specification.value.predefined_metric_type
          }
        }
      }
    }
  }
}
