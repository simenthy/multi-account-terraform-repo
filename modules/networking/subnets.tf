resource "aws_subnet" "this" {
  for_each = var.subnets

  # each.value.vpc_key names the VPC entry this subnet belongs to,
  # e.g. "nft01_vpc" -> aws_vpc.this["nft01_vpc"].id
  vpc_id = aws_vpc.this[each.value.vpc_key].id

  cidr_block                          = each.value.cidr_block
  availability_zone                   = each.value.availability_zone
  map_public_ip_on_launch             = each.value.map_public_ip_on_launch
  private_dns_hostname_type_on_launch = each.value.private_dns_hostname_type_on_launch

  tags = merge(var.common_tags, each.value.tags)

  # Temporary migration backstop — remove after the migration is complete
  # (it blocks legitimate future changes such as resizing a cidr_block).
  lifecycle {
    prevent_destroy = false # TEMP: re-enable after this pipeline-driven teardown
  }
}
