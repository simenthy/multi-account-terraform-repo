resource "aws_eip" "this" {
  for_each = var.eips

  domain = each.value.domain

  tags = merge(var.common_tags, each.value.tags)
}
