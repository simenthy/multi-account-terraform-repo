resource "aws_network_acl" "this" {
  for_each = var.network_acls

  vpc_id = aws_vpc.this[each.value.vpc_key].id

  # Deliberately NO inline `ingress`/`egress` rules and NO `subnet_ids`:
  #  - The imported flat HCL did not manage the rules, so the live NACL
  #    rules are currently UNMANAGED by Terraform (change them in Terraform
  #    later by adding aws_network_acl_rule resources or inline rules —
  #    a deliberate, separate piece of work).
  #  - Subnet membership is managed by the standalone
  #    aws_network_acl_association resources below; mixing that with
  #    inline `subnet_ids` makes Terraform fight itself.

  tags = merge(var.common_tags, each.value.tags)
}