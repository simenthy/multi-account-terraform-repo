resource "aws_security_group" "this" {
  for_each = var.security_groups

  # each.value.vpc_key names the VPC entry this subnet belongs to,
  # e.g. "nft01_vpc" -> aws_vpc.this["nft01_vpc"].id
  vpc_id = aws_vpc.this[each.value.vpc_key].id

  name        = each.value.name
  description = each.value.description

  tags = merge(var.common_tags, each.value.tags)

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }
}
