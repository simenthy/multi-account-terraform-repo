# =============================================================================
# Consolidated root — one state file for the whole devops account
# =============================================================================
# Mirrors accounts/nft/main.tf exactly — same module shape, same cross-module
# wiring pattern. See that file's header comment for the full rationale
# (direct module references, no SSM hand-off, the "every variable must
# reach its module" golden rule). This is a second, independent environment
# in the same AWS account, proving the module shape (and the CI pipeline)
# generalizes beyond nft — not a copy of nft's data, its own VPC and a
# minimal one-of-each-type resource set per other domain.
# =============================================================================

module "networking" {
  source      = "../../modules/networking"
  common_tags = var.common_tags

  vpcs                     = var.vpcs
  subnets                  = var.subnets
  internet_gateways        = var.internet_gateways
  eips                     = var.eips
  nat_gateways             = var.nat_gateways
  route_tables             = var.route_tables
  route_table_associations = var.route_table_associations
  network_acls             = var.network_acls
  network_acl_associations = var.network_acl_associations
  security_group_lookups   = var.security_group_lookups
  security_groups          = var.security_groups
  vpc_endpoints            = var.vpc_endpoints
}

module "security" {
  source      = "../../modules/security"
  common_tags = var.common_tags

  kms_keys    = var.kms_keys
  kms_aliases = var.kms_aliases
  web_acls    = var.web_acls
}

module "compute" {
  source      = "../../modules/compute"
  common_tags = var.common_tags

  # Launch templates: SG keys -> ids (direct from the networking module).
  launch_templates = {
    for k, lt in var.launch_templates : k => merge(lt, {
      vpc_security_group_ids = [for sg in lt.security_group_keys : module.networking.security_group_ids[sg]]
    })
  }

  # Target groups: vpc_key -> vpc id.
  target_groups = {
    for k, tg in var.target_groups : k => merge(tg, {
      vpc_id = module.networking.vpc_ids[tg.vpc_key]
    })
  }

  # Load balancers: SG keys -> ids, subnet keys -> ids.
  load_balancers = {
    for k, lb in var.load_balancers : k => merge(lb, {
      security_group_ids = [for sg in lb.security_group_keys : module.networking.security_group_ids[sg]]
      subnet_ids         = [for s in lb.subnet_keys : module.networking.subnet_ids[s]]
    })
  }

  # ASGs: subnet keys -> vpc_zone_identifier.
  auto_scaling_groups = {
    for k, asg in var.auto_scaling_groups : k => merge(asg, {
      vpc_zone_identifier = [for s in asg.subnet_keys : module.networking.subnet_ids[s]]
    })
  }

  # Intra-module keys only (lb_key / target_group_key / asg_key are resolved
  # inside the module) or no references at all — pass straight through.
  lb_listeners = var.lb_listeners
  asg_policies = var.asg_policies
  ecs_clusters = var.ecs_clusters
}

module "data" {
  source      = "../../modules/data"
  common_tags = var.common_tags

  # Subnet groups: subnet_keys -> real subnet IDs from the networking module.
  db_subnet_groups = {
    for k, sg in var.db_subnet_groups : k => merge(sg, {
      subnet_ids = [for s in sg.subnet_keys : module.networking.subnet_ids[s]]
    })
  }

  elasticache_subnet_groups = {
    for k, sg in var.elasticache_subnet_groups : k => merge(sg, {
      subnet_ids = [for s in sg.subnet_keys : module.networking.subnet_ids[s]]
    })
  }

  # No cross-domain references — pass straight through. backup_plans resolves
  # its vault_key against backup_vaults inside the module.
  db_parameter_groups          = var.db_parameter_groups
  rds_cluster_parameter_groups = var.rds_cluster_parameter_groups
  db_option_groups             = var.db_option_groups
  elasticache_parameter_groups = var.elasticache_parameter_groups
  backup_vaults                = var.backup_vaults
  backup_plans                 = var.backup_plans
  s3_buckets                   = var.s3_buckets
}

module "observability" {
  source      = "../../modules/observability"
  common_tags = var.common_tags

  sns_topics     = var.sns_topics
  event_rules    = var.event_rules
  event_patterns = var.event_patterns
  metric_alarms  = var.metric_alarms
}

module "pipeline" {
  source      = "../../../modules/pipeline"
  common_tags = var.common_tags

  github_oidc_provider       = var.github_oidc_provider
  github_actions_plan_roles  = var.github_actions_plan_roles
  github_actions_apply_roles = var.github_actions_apply_roles
}