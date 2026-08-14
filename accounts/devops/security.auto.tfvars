# COST NOTE: no WAFv2 Web ACL here. A Web ACL bills at $5/month even with
# zero rules and no association — the single largest line item this
# workspace could carry, for a resource type that adds little beyond what
# the KMS key already proves about the security module's wiring. Add
# `web_acls` back if the WAF path specifically needs testing; the module
# supports it and an empty map renders nothing.
#
# The KMS key below is the only billable resource in this account:
# ~$1/month for the key itself.

#------------------------------------------------
# KMS Keys
#------------------------------------------------
kms_keys = {
  devops_kms_key = {
    customer_master_key_spec = "SYMMETRIC_DEFAULT"
    enable_key_rotation      = false
    key_usage                = "ENCRYPT_DECRYPT"
    tags = {
      Name        = "fra-devops-kms-key-01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}

#------------------------------------------------
# KMS Aliases (free)
#------------------------------------------------
kms_aliases = {
  devops_kms_key = {
    name       = "alias/fra-devops-kms-key-01"
    key_id_key = "devops_kms_key"
  }
}

#------------------------------------------------
# Web ACLs — intentionally empty, see the cost note above.
#------------------------------------------------
web_acls = {}
