terraform {
  # >= 1.5.0 because the backend uses native S3 locking (use_lockfile). Also I had use of removed blocks while building the workspace.
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
