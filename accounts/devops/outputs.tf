# Root outputs for the devops account. Mirrors accounts/nft/outputs.tf.

# --- networking ---
output "vpc_ids" {
  description = "VPC IDs, keyed by local name."
  value       = module.networking.vpc_ids
}

output "subnet_ids" {
  description = "Subnet IDs, keyed by local name."
  value       = module.networking.subnet_ids
}

output "internet_gateway_ids" {
  description = "Internet gateway IDs, keyed by local name."
  value       = module.networking.internet_gateway_ids
}

output "eip_allocation_ids" {
  description = "Elastic IP allocation IDs, keyed by local name."
  value       = module.networking.eip_allocation_ids
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs, keyed by local name."
  value       = module.networking.nat_gateway_ids
}

output "route_table_ids" {
  description = "Route table IDs, keyed by local name."
  value       = module.networking.route_table_ids
}

output "network_acl_ids" {
  description = "Network ACL IDs, keyed by local name."
  value       = module.networking.network_acl_ids
}

output "vpc_endpoint_ids" {
  description = "VPC endpoint IDs, keyed by local name."
  value       = module.networking.vpc_endpoint_ids
}

output "security_group_ids" {
  description = "Security group IDs, keyed by local name."
  value       = module.networking.security_group_ids
}

# --- compute ---
output "launch_template_ids" {
  description = "Launch template IDs, keyed by local name."
  value       = module.compute.launch_template_ids
}

output "target_group_arns" {
  description = "Target group ARNs, keyed by local name."
  value       = module.compute.target_group_arns
}

output "load_balancer_arns" {
  description = "Load balancer ARNs, keyed by local name."
  value       = module.compute.load_balancer_arns
}

output "autoscaling_group_names" {
  description = "Auto Scaling group names, keyed by local name."
  value       = module.compute.autoscaling_group_names
}

output "ecs_cluster_arns" {
  description = "ECS cluster ARNs, keyed by local name."
  value       = module.compute.ecs_cluster_arns
}

# --- data ---
output "db_subnet_group_names" {
  description = "DB subnet group names, keyed by local name."
  value       = module.data.db_subnet_group_names
}

output "s3_bucket_arns" {
  description = "S3 bucket ARNs, keyed by local name."
  value       = module.data.s3_bucket_arns
}

output "backup_vault_arns" {
  description = "Backup vault ARNs, keyed by local name."
  value       = module.data.backup_vault_arns
}

# --- observability ---
output "sns_topic_arns" {
  description = "SNS topic ARNs, keyed by local name. Use these when wiring alarm actions."
  value       = module.observability.sns_topic_arns
}

output "event_rule_arns" {
  description = "EventBridge rule ARNs, keyed by local name."
  value       = module.observability.event_rule_arns
}
