resource "aws_rds_cluster_parameter_group" "this" {
  for_each = var.rds_cluster_parameter_groups

  name        = each.value.name
  family      = each.value.family
  description = each.value.description

  tags = merge(var.common_tags, each.value.tags)

  dynamic "parameter" {
    for_each = each.value.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    ignore_changes = [parameter]
  }
}
