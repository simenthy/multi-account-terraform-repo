resource "aws_vpc_endpoint" "this" {
  for_each = var.vpc_endpoints

  vpc_id              = aws_vpc.this[each.value.vpc_key].id
  service_name        = each.value.service_name
  vpc_endpoint_type   = each.value.vpc_endpoint_type
  private_dns_enabled = each.value.private_dns_enabled

  security_group_ids = [
    for sg_key in each.value.security_group_keys : aws_security_group.this[sg_key].id
  ]

  # `dynamic` = a for_each for NESTED blocks: one subnet_configuration
  # block is generated per entry in the list.
  dynamic "subnet_configuration" {
    for_each = each.value.subnet_configurations
    content {
      ipv4      = subnet_configuration.value.ipv4
      subnet_id = aws_subnet.this[subnet_configuration.value.subnet_key].id
    }
  }

  tags = merge(var.common_tags, each.value.tags)
}
