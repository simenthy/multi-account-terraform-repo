# Outputs are the module's "receipt": the only supported way for code
# OUTSIDE the module (the root folder, or other domains via remote state)
# to read the IDs of what the module built. Each output is a map keyed by
# the same local names used in the input variables, e.g.
# module.networking.subnet_ids["pub_sub_nft01"].

output "vpc_ids" {
  description = "VPC IDs, keyed by local name."
  value       = { for k, v in aws_vpc.this : k => v.id }
}

output "subnet_ids" {
  description = "Subnet IDs, keyed by local name."
  value       = { for k, v in aws_subnet.this : k => v.id }
}

output "internet_gateway_ids" {
  description = "Internet gateway IDs, keyed by local name."
  value       = { for k, v in aws_internet_gateway.this : k => v.id }
}

output "eip_allocation_ids" {
  description = "Elastic IP allocation IDs, keyed by local name."
  value       = { for k, v in aws_eip.this : k => v.id }
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs, keyed by local name."
  value       = { for k, v in aws_nat_gateway.this : k => v.id }
}

output "route_table_ids" {
  description = "Route table IDs, keyed by local name."
  value       = { for k, v in aws_route_table.this : k => v.id }
}

output "network_acl_ids" {
  description = "Network ACL IDs, keyed by local name."
  value       = { for k, v in aws_network_acl.this : k => v.id }
}

output "vpc_endpoint_ids" {
  description = "VPC endpoint IDs, keyed by local name."
  value       = { for k, v in aws_vpc_endpoint.this : k => v.id }
}

output "security_group_ids" {
  description = "Security group IDs, keyed by local name. Consumed cross-domain (e.g. compute LBs / launch templates) via terraform_remote_state."
  value       = { for k, v in aws_security_group.this : k => v.id }
}
