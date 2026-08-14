resource "aws_ecs_cluster" "this" {
  for_each = var.ecs_clusters

  name = each.value.name
  tags = merge(var.common_tags, each.value.tags)

  # PATTERN A NESTED (see target_groups.tf for the full explanation): the outer
  # `configuration {}` is optional, and inside it `execute_command_configuration
  # {}` is also optional — so each level uses the same `== null ? [] : [...]`
  # null-gate to emit zero or one block.
  dynamic "configuration" {
    for_each = each.value.configuration == null ? [] : [each.value.configuration]
    content {
      dynamic "execute_command_configuration" {
        for_each = configuration.value.execute_command_configuration == null ? [] : [configuration.value.execute_command_configuration]
        content {
          logging    = execute_command_configuration.value.logging
          kms_key_id = execute_command_configuration.value.kms_key_id
        }
      }
    }
  }

  # PATTERN B (repeatable block): a cluster can carry several `setting {}` blocks
  # (e.g. containerInsights), so loop over the list — one block per element.
  dynamic "setting" {
    for_each = each.value.settings
    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }
}
