resource "aws_launch_template" "this" {
  for_each = var.launch_templates

  name                    = each.value.name
  description             = each.value.description
  image_id                = each.value.image_id
  instance_type           = each.value.instance_type
  key_name                = each.value.key_name
  disable_api_stop        = each.value.disable_api_stop
  disable_api_termination = each.value.disable_api_termination
  ebs_optimized           = each.value.ebs_optimized

  # cross-domain: security group IDs are resolved by the root from
  # security_group_keys before reaching the module.
  vpc_security_group_ids = each.value.vpc_security_group_ids

  tags = merge(var.common_tags, each.value.tags)

  # PATTERN A (zero-or-one optional block). See target_groups.tf for the full
  # explanation of `dynamic`. Here the loop is over the ARN string itself: if it
  # is null we loop over [] (no block); otherwise over a single-item list (one
  # block). `iam_instance_profile.value` is that single element — the ARN.
  # cross-domain: the ARN is resolved by the root from iam_instance_profile_key.
  dynamic "iam_instance_profile" {
    for_each = each.value.iam_instance_profile_arn == null ? [] : [each.value.iam_instance_profile_arn]
    content {
      arn = iam_instance_profile.value
    }
  }

  # PATTERN B (repeatable block): loop directly over a LIST and emit one
  # `tag_specifications {}` block per element. An empty list (the default in the
  # variable schema) simply produces no blocks — no null check needed here.
  dynamic "tag_specifications" {
    for_each = each.value.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  lifecycle {
    ignore_changes = [
      user_data,
      placement
    ]
  }
}
