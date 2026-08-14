resource "aws_internet_gateway" "this" {
  for_each = var.internet_gateways

  vpc_id = aws_vpc.this[each.value.vpc_key].id

  tags = merge(var.common_tags, each.value.tags)

  # Temporary migration backstop — remove after the migration is complete.
  lifecycle {
    prevent_destroy = false # TEMP: re-enable after this pipeline-driven teardown
  }
}
