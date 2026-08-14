# Account-wide values. Declared once here; the per-domain *.auto.tfvars files
# carry only their own resource maps.
#
# Terraform automatically loads EVERY *.auto.tfvars file in this directory, so
# the data stays split per domain for readability while feeding a single root.

aws_region = "us-east-1"
common_tags = {
  ManagedBy = "terraform"
}
