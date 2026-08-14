resource "aws_db_parameter_group" "this" {
  for_each = var.db_parameter_groups

  name        = each.value.name
  family      = each.value.family
  description = each.value.description

  skip_destroy = each.value.skip_destroy

  tags = merge(var.common_tags, each.value.tags)

  # Repeatable optional block: one `parameter {}` per list entry. An empty list
  # (the default) emits nothing.
  dynamic "parameter" {
    for_each = each.value.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  # Parameters are frequently adjusted directly in the RDS console during tuning.
  # Carried over verbatim from the imported configuration.
  lifecycle {
    ignore_changes = [parameter]
  }
}
