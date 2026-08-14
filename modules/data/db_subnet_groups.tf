resource "aws_db_subnet_group" "this" {
  for_each = var.db_subnet_groups

  name        = each.value.name
  description = each.value.description

  # cross-domain: the ROOT resolved subnet_keys -> real subnet IDs via
  # module.networking.subnet_ids before these values reached the module.
  subnet_ids = each.value.subnet_ids

  tags = merge(var.common_tags, each.value.tags)
}
