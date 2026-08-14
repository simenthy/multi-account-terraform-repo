# Account-wide values. Declared once here; the per-domain *.auto.tfvars files
# carry only their own resource maps.

aws_region = "us-east-1"
common_tags = {
  ManagedBy = "terraform"
}
