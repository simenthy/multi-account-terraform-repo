# TRIMMED FOR COST (2026-08-14) — see networking.auto.tfvars for the full
# context. Removed from this domain:
#   - 10 of the 11 imported KMS keys ($1/month each -> ~$0.36/day total)
#   - the WAFv2 Web ACL ($5/month even with zero rules and no association)
#
# The single KMS key below is the only billable resource in this file
# (~$1/month) and exists so the security module's key + alias wiring still
# gets exercised by a plan.

#------------------------------------------------
# KMS Keys
#------------------------------------------------
kms_keys = {
  nft_kms_key = {
    customer_master_key_spec = "SYMMETRIC_DEFAULT"
    enable_key_rotation      = false
    key_usage                = "ENCRYPT_DECRYPT"
    tags = {
      Name        = "fra-nft-kms-key-01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}

#------------------------------------------------
# KMS Aliases (free)
#------------------------------------------------
kms_aliases = {
  nft_kms_key = {
    name       = "alias/fra-nft-kms-key-01"
    key_id_key = "nft_kms_key"
  }
}

#------------------------------------------------
# Web ACLs — intentionally empty, see the cost note above.
#------------------------------------------------
web_acls = {}
