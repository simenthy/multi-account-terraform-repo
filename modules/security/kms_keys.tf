resource "aws_kms_key" "this" {

  for_each                 = var.kms_keys
  customer_master_key_spec = each.value.customer_master_key_spec
  enable_key_rotation      = each.value.enable_key_rotation
  key_usage                = each.value.key_usage


  rotation_period_in_days = each.value.rotation_period_in_days
  tags                    = merge(var.common_tags, each.value.tags)

  lifecycle {
    prevent_destroy = false # TEMP: re-enable after this pipeline-driven teardown
  }

}