resource "aws_backup_vault" "this" {
  for_each = var.backup_vaults

  name = each.value.name

  # POLICY / ENCRYPTION NOTE (see terraform-policies-guide.md §5, §6):
  # kms_key_arn is Optional+Computed and ForceNew. Left null it means "keep the
  # key AWS already uses" — here the AWS-managed alias/aws/backup key — which is
  # the zero-diff, zero-risk position for an imported vault. It is NOT hardcoded
  # to an ARN because that would embed the account id and region, and changing
  # the key REPLACES the vault (orphaning recovery points).
  # A caller that genuinely wants a customer-managed key sets it in tfvars and
  # accepts the replacement consciously.
  kms_key_arn = each.value.kms_key_arn

  force_destroy = each.value.force_destroy

  tags = merge(var.common_tags, each.value.tags)
}

# NOTE: no aws_backup_vault_policy here. The vaults carry AWS's default access
# policy, which AWS recreates identically; managing it would hardcode the account
# id for no behavioural gain (terraform-policies-guide.md §6). If a cross-account
# restore grant is ever needed, add it as a SEPARATE aws_backup_vault_policy
# resource built from aws_iam_policy_document — never inline, to avoid the
# self-referential cycle described in §4 of that guide.
