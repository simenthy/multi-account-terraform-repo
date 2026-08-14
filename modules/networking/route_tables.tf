resource "aws_route_table" "this" {
  for_each = var.route_tables

  vpc_id = aws_vpc.this[each.value.vpc_key].id

  # Deliberately NO inline `route {}` blocks here. Routes are not yet under
  # Terraform management (they are still to be imported, as standalone
  # aws_route resources).

  tags = merge(var.common_tags, each.value.tags)
}


