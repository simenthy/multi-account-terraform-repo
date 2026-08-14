terraform {
  # >= 1.5.0 because the backend uses native S3 locking (use_lockfile).
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
