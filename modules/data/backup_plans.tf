resource "aws_backup_plan" "this" {
  for_each = var.backup_plans

  name = each.value.name
  tags = merge(var.common_tags, each.value.tags)

  # `rule` is provider-Required (min_items = 1) and repeatable.
  dynamic "rule" {
    for_each = each.value.rules
    content {
      rule_name = rule.value.rule_name

      # intra-module reference: the plan points at a vault built by this same
      # module, so the name comes from the resource rather than a literal.
      target_vault_name = aws_backup_vault.this[rule.value.vault_key].name

      schedule                     = rule.value.schedule
      schedule_expression_timezone = rule.value.schedule_expression_timezone
      start_window                 = rule.value.start_window
      completion_window            = rule.value.completion_window
      enable_continuous_backup     = rule.value.enable_continuous_backup
      recovery_point_tags          = rule.value.recovery_point_tags

      # AWS's lifecycle block (retention), not Terraform's meta-argument. The
      # iterator is renamed to `lc` so the two can never be confused.
      dynamic "lifecycle" {
        for_each = rule.value.backup_lifecycle == null ? [] : [rule.value.backup_lifecycle]
        iterator = lc
        content {
          cold_storage_after                        = lc.value.cold_storage_after
          delete_after                              = lc.value.delete_after
          opt_in_to_archive_for_supported_resources = lc.value.opt_in_to_archive_for_supported_resources
        }
      }
    }
  }
}
