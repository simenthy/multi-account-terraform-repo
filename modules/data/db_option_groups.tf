resource "aws_db_option_group" "this" {
  for_each = var.db_option_groups

  name                     = each.value.name
  engine_name              = each.value.engine_name
  major_engine_version     = each.value.major_engine_version
  option_group_description = each.value.option_group_description
  skip_destroy             = each.value.skip_destroy

  tags = merge(var.common_tags, each.value.tags)

  dynamic "option" {
    for_each = each.value.options
    content {
      option_name                    = option.value.option_name
      port                           = option.value.port
      version                        = option.value.version
      db_security_group_memberships  = option.value.db_security_group_memberships
      vpc_security_group_memberships = option.value.vpc_security_group_memberships

      dynamic "option_settings" {
        for_each = option.value.option_settings
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }
}
