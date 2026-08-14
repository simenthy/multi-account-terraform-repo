# COST NOTE: every resource here is free. Parameter/option/subnet groups
# cost nothing on their own — they only matter once an RDS instance or
# ElastiCache cluster uses them, and this workspace deliberately has
# neither (an RDS instance would be ~$0.35+/day on its own).
#
# The S3 bucket is free while empty (storage and requests bill, existence
# does not). The backup vault is free with no recovery points, and the
# backup plan is free because no resources are selected into it — a plan
# without a selection never runs.

#------------------------------------------------
# DB Parameter Groups
#------------------------------------------------
db_parameter_groups = {
  devops_db_pg01 = {
    name   = "fra-devops-db-pg-01"
    family = "postgres15"
    tags = {
      Name        = "fra-devops-db-pg-01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}

#------------------------------------------------
# RDS Cluster Parameter Groups
#------------------------------------------------
rds_cluster_parameter_groups = {
  devops_rds_cluster_pg01 = {
    name   = "fra-devops-rds-cluster-pg-01"
    family = "aurora-postgresql15"
    tags = {
      Name        = "fra-devops-rds-cluster-pg-01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}

#------------------------------------------------
# DB Option Groups
#------------------------------------------------
db_option_groups = {
  devops_db_og01 = {
    name                 = "fra-devops-db-og-01"
    engine_name          = "mysql"
    major_engine_version = "8.0"
    tags = {
      Name        = "fra-devops-db-og-01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}

#------------------------------------------------
# DB Subnet Groups
#------------------------------------------------
db_subnet_groups = {
  devops_db_sng01 = {
    name        = "fra-devops-db-sng-01"
    subnet_keys = ["pvt_sub_devops01", "pvt_sub_devops02"]
    tags = {
      Name        = "fra-devops-db-sng-01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}

#------------------------------------------------
# ElastiCache Parameter Groups
#------------------------------------------------
elasticache_parameter_groups = {
  devops_ec_pg01 = {
    name   = "fra-devops-ec-pg-01"
    family = "redis7"
    tags = {
      Name        = "fra-devops-ec-pg-01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}

#------------------------------------------------
# ElastiCache Subnet Groups
#------------------------------------------------
elasticache_subnet_groups = {
  devops_ec_sng01 = {
    name        = "fra-devops-ec-sng-01"
    subnet_keys = ["pvt_sub_devops01", "pvt_sub_devops02"]
    tags = {
      Name        = "fra-devops-ec-sng-01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}

#------------------------------------------------
# Backup Vaults (free with no recovery points)
#------------------------------------------------
backup_vaults = {
  devops_backup_vault01 = {
    name = "fra-devops-backup-vault-01"
    tags = {
      Name        = "fra-devops-backup-vault-01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}

#------------------------------------------------
# Backup Plans (free — no selections, so nothing is ever backed up)
#------------------------------------------------
backup_plans = {
  devops_backup_plan01 = {
    name = "fra-devops-backup-plan-01"
    tags = {
      Name        = "fra-devops-backup-plan-01"
      Environment = "devops"
      Application = "Platform"
    }
    rules = [
      {
        rule_name = "daily"
        vault_key = "devops_backup_vault01"
        schedule  = "cron(0 5 * * ? *)"
      }
    ]
  }
}

#------------------------------------------------
# S3 Buckets (free while empty)
#------------------------------------------------
# NOTE: bucket names are globally unique across all of AWS. Replace the
# suffix with the devops account ID before the first apply.
s3_buckets = {
  devops_bucket01 = {
    bucket = "star-alliance-terraform-devops-REPLACE_ME_ACCOUNT_ID"
    tags = {
      Name        = "star-alliance-terraform-devops"
      Environment = "devops"
      Application = "Platform"
    }
  }
}
