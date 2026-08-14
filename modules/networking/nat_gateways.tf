resource "aws_nat_gateway" "this" {
  for_each = var.nat_gateways

  # For an aws_eip, .id IS the allocation id NAT gateways expect.
  allocation_id = aws_eip.this[each.value.eip_key].id
  subnet_id     = aws_subnet.this[each.value.subnet_key].id

  tags = merge(var.common_tags, each.value.tags)
}
