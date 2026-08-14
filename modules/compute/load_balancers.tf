# BEGINNER NOTE: notice there is NOT a single `dynamic` block in this file.
# Every field an aws_lb needs in this workspace is a simple ARGUMENT (name,
# internal, subnets, security_groups, ...), and arguments accept a value or
# `null` directly — no nested optional/repeatable blocks are involved. So this
# resource is just a flat list of `argument = each.value.x` lines. `dynamic` is
# only needed when you must generate BLOCKS conditionally or repeatedly (see the
# other files in this module for those cases).
resource "aws_lb" "this" {
  for_each = var.load_balancers

  name               = each.value.name
  load_balancer_type = each.value.load_balancer_type
  internal           = each.value.internal
  ip_address_type    = each.value.ip_address_type

  enable_deletion_protection       = each.value.enable_deletion_protection
  enable_cross_zone_load_balancing = each.value.enable_cross_zone_load_balancing
  enable_zonal_shift               = each.value.enable_zonal_shift
  dns_record_client_routing_policy = each.value.dns_record_client_routing_policy

  # cross-domain: security_groups / subnets are resolved by the root from
  # security_group_keys / subnet_keys before reaching the module.
  security_groups = each.value.security_group_ids
  subnets         = each.value.subnet_ids

  tags = merge(var.common_tags, each.value.tags)
}
