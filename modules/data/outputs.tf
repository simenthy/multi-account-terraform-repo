# The module's "receipt": ID/ARN maps keyed by the same local names used in the
# input variables, so the root (or another module, wired in main.tf) can read
# what was built.

output "db_parameter_group_names" {
  description = "DB parameter group names, keyed by local name."
  value       = { for k, v in aws_db_parameter_group.this : k => v.name }
}

output "rds_cluster_parameter_group_names" {
  description = "RDS cluster parameter group names, keyed by local name."
  value       = { for k, v in aws_rds_cluster_parameter_group.this : k => v.name }
}

output "db_option_group_names" {
  description = "DB option group names, keyed by local name."
  value       = { for k, v in aws_db_option_group.this : k => v.name }
}

output "db_subnet_group_names" {
  description = "DB subnet group names, keyed by local name."
  value       = { for k, v in aws_db_subnet_group.this : k => v.name }
}

output "elasticache_parameter_group_names" {
  description = "ElastiCache parameter group names, keyed by local name."
  value       = { for k, v in aws_elasticache_parameter_group.this : k => v.name }
}

output "elasticache_subnet_group_names" {
  description = "ElastiCache subnet group names, keyed by local name."
  value       = { for k, v in aws_elasticache_subnet_group.this : k => v.name }
}

output "backup_vault_arns" {
  description = "Backup vault ARNs, keyed by local name."
  value       = { for k, v in aws_backup_vault.this : k => v.arn }
}

output "backup_plan_arns" {
  description = "Backup plan ARNs, keyed by local name."
  value       = { for k, v in aws_backup_plan.this : k => v.arn }
}

output "s3_bucket_ids" {
  description = "S3 bucket names, keyed by local name."
  value       = { for k, v in aws_s3_bucket.this : k => v.id }
}

output "s3_bucket_arns" {
  description = "S3 bucket ARNs, keyed by local name."
  value       = { for k, v in aws_s3_bucket.this : k => v.arn }
}
