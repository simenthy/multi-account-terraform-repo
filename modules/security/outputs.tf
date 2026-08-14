output "kms_key_arns" { value = { for k, v in aws_kms_key.this : k => v.arn } }
output "kms_key_ids" { value = { for k, v in aws_kms_key.this : k => v.key_id } }
