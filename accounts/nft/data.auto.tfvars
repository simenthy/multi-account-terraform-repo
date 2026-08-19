# TRIMMED FOR COST (2026-08-14) — see networking.auto.tfvars for the full
# context. Every resource here is free. Parameter/option/subnet groups
# cost nothing on their own; they only matter once an RDS instance or
# ElastiCache cluster uses them, and this workspace has neither (an RDS
# instance alone would be ~$0.35+/day).
#
# The S3 bucket is free while empty. The backup vault is free with no
# recovery points, and the backup plan is free because no resources are
# selected into it — a plan without a selection never runs.

#------------------------------------------------
# DB Parameter Groups
#------------------------------------------------
db_parameter_groups = {
  nft_db_pg01 = {
    name   = "fra-nft-db-pg-01"
    family = "postgres15"
    tags = {
      Name        = "fra-nft-db-pg-01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}

#------------------------------------------------
# RDS Cluster Parameter Groups
#------------------------------------------------
rds_cluster_parameter_groups = {
  nft_rds_cluster_pg01 = {
    name   = "fra-nft-rds-cluster-pg-01"
    family = "aurora-postgresql15"
    tags = {
      Name        = "fra-nft-rds-cluster-pg-01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}

#------------------------------------------------
# DB Option Groups
#------------------------------------------------
db_option_groups = {
  nft_db_og01 = {
    name                 = "fra-nft-db-og-01"
    engine_name          = "mysql"
    major_engine_version = "8.0"
    tags = {
      Name        = "fra-nft-db-og-01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}

#------------------------------------------------
# DB Subnet Groups
#------------------------------------------------
db_subnet_groups = {
  nft_db_sng01 = {
    name        = "fra-nft-db-sng-01"
    subnet_keys = ["pvt_sub_nft01", "pvt_sub_nft02"]
    tags = {
      Name        = "fra-nft-db-sng-01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}

#------------------------------------------------
# ElastiCache Parameter Groups
#------------------------------------------------
elasticache_parameter_groups = {
  nft_ec_pg01 = {
    name   = "fra-nft-ec-pg-01"
    family = "redis7"
    tags = {
      Name        = "fra-nft-ec-pg-01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}

#------------------------------------------------
# ElastiCache Subnet Groups
#------------------------------------------------
elasticache_subnet_groups = {
  nft_ec_sng01 = {
    name        = "fra-nft-ec-sng-01"
    subnet_keys = ["pvt_sub_nft01", "pvt_sub_nft02"]
    tags = {
      Name        = "fra-nft-ec-sng-01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}

#------------------------------------------------
# Backup Vaults (free with no recovery points)
#------------------------------------------------
backup_vaults = {
  nft_backup_vault01 = {
    name = "fra-nft-backup-vault-01"
    tags = {
      Name        = "fra-nft-backup-vault-01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}

#------------------------------------------------
# Backup Plans (free — no selections, so nothing is ever backed up)
#------------------------------------------------
backup_plans = {
  nft_backup_plan01 = {
    name = "fra-nft-backup-plan-01"
    tags = {
      Name        = "fra-nft-backup-plan-01"
      Environment = "Dev"
      Application = "NFT"
    }
    rules = [
      {
        rule_name = "daily"
        vault_key = "nft_backup_vault01"
        schedule  = "cron(0 5 * * ? *)"
      }
    ]
  }
}

#------------------------------------------------
# S3 Buckets (free while empty)
#------------------------------------------------
# NOTE: bucket names are globally unique across all of AWS. This one uses
# the nft test account's ID (873135413574).
s3_buckets = {
  nft_bucket01 = {
    bucket = "star-alliance-terraform-nft-873135413574"
    tags = {
      Name        = "star-alliance-terraform-nft"
      Environment = "Dev"
      Application = "NFT"
    }
  }
    nft_artifacts_bucket01 = {
    bucket = "artifacts-nft-873135413574"
    tags = {
      Name        = "star-alliance-terraform-nft"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}
