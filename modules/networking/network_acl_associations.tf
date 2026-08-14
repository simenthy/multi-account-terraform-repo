# Links a subnet to the network ACL (subnet-level firewall) that filters
# its traffic.
resource "aws_network_acl_association" "this" {
  for_each       = var.network_acl_associations
  network_acl_id = aws_network_acl.this[each.value.network_acl_key].id
  subnet_id      = aws_subnet.this[each.value.subnet_key].id
}
