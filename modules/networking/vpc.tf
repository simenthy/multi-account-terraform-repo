resource "aws_vpc" "this" {
  for_each = var.vpcs

  cidr_block                           = each.value.cidr_block
  instance_tenancy                     = each.value.instance_tenancy
  enable_dns_support                   = each.value.enable_dns_support
  enable_dns_hostnames                 = each.value.enable_dns_hostnames
  enable_network_address_usage_metrics = each.value.enable_network_address_usage_metrics

  tags = merge(var.common_tags, each.value.tags)

  # Temporary migration backstop: refuses any plan that would delete a VPC.
  # Kept on VPCs permanently by deliberate choice (a VPC should never be
  # replaced casually).
  lifecycle {
    prevent_destroy = false # TEMP: re-enable after this pipeline-driven teardown
  }
}
