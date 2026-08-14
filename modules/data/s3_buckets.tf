resource "aws_s3_bucket" "this" {
  for_each = var.s3_buckets

  bucket = each.value.bucket

  # bucket_namespace is a genuine AWS provider v6 argument (Optional+Computed),
  # not an import artifact — "global" is the ordinary S3 namespace.
  bucket_namespace = each.value.bucket_namespace

  force_destroy       = each.value.force_destroy
  object_lock_enabled = each.value.object_lock_enabled

  tags = merge(var.common_tags, each.value.tags)
}

# NOTE: no aws_s3_bucket_policy here — none of these buckets carries a
# non-default policy today, and importing AWS's default would hardcode the
# account id (terraform-policies-guide.md §6).
# When a policy IS needed it must be a SEPARATE aws_s3_bucket_policy resource
# built from an aws_iam_policy_document data source: an inline policy that
# references aws_s3_bucket.this[...].arn creates a self-referential dependency
# cycle (§4 of that guide), and the data source validates the document at plan
# time instead of failing at apply.
