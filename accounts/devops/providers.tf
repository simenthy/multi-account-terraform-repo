# Provider configuration lives ONLY here in the root, never in the module.
# Credentials come from the environment (EC2 instance role locally,
# OIDC-assumed role in CI) — no keys in code, ever.
provider "aws" {
  region = var.aws_region
}
