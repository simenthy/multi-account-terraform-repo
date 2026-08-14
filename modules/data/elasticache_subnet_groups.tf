resource "aws_elasticache_subnet_group" "this" {
  for_each = var.elasticache_subnet_groups

  name        = each.value.name
  description = each.value.description

  # cross-domain: resolved by the ROOT from subnet_keys.
  subnet_ids = each.value.subnet_ids

  tags = merge(var.common_tags, each.value.tags)
}
