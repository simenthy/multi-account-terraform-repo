resource "aws_kms_alias" "this" {
  for_each      = var.kms_aliases
  name          = each.value.name
  target_key_id = aws_kms_key.this[each.value.key_id_key].key_id

  lifecycle {
    prevent_destroy = false # TEMP: re-enable after this pipeline-driven teardown
  }
}