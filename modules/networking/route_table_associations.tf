# Links a subnet to the route table that decides where its traffic goes.
# This resource type does not support tags.
resource "aws_route_table_association" "this" {
  for_each = var.route_table_associations

  subnet_id      = aws_subnet.this[each.value.subnet_key].id
  route_table_id = aws_route_table.this[each.value.route_table_key].id
}
