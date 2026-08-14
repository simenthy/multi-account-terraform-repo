resource "aws_elasticache_parameter_group" "this" {
  for_each = var.elasticache_parameter_groups

  name        = each.value.name
  family      = each.value.family
  description = each.value.description

  tags = merge(var.common_tags, each.value.tags)

  dynamic "parameter" {
    for_each = each.value.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    ignore_changes = [parameter]
  }
}
