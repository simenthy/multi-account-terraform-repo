terraform {
  backend "s3" {
    bucket = "tfstate-nft-873135413574"

    # ONE state file for the whole account.
    key = "nft/us-east-1/terraform.tfstate"

    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
