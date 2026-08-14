# Outputs are the module's "receipt": the only supported way for code outside
# the module (the root folder, or other domains via SSM export) to read the
# IDs/ARNs of what the module built. Each is a map keyed by the same local
# names used in the input variables.

output "launch_template_ids" {
  description = "Launch template IDs, keyed by local name."
  value       = { for k, v in aws_launch_template.this : k => v.id }
}

output "target_group_arns" {
  description = "Target group ARNs, keyed by local name."
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}

output "load_balancer_arns" {
  description = "Load balancer ARNs, keyed by local name."
  value       = { for k, v in aws_lb.this : k => v.arn }
}

output "autoscaling_group_names" {
  description = "Auto Scaling group names, keyed by local name."
  value       = { for k, v in aws_autoscaling_group.this : k => v.name }
}

output "ecs_cluster_arns" {
  description = "ECS cluster ARNs, keyed by local name."
  value       = { for k, v in aws_ecs_cluster.this : k => v.arn }
}
