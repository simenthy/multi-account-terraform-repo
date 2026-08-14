terraform {
  backend "s3" {
    # NOTE: devops is a SEPARATE AWS account from nft. This bucket must
    # live in (or be readable/writable cross-account by) the devops
    # account — the nft account's state bucket will not work here without
    # an explicit cross-account bucket policy. Create a bucket in the
    # devops account and put its name here before the first init.
    bucket = "tfstate-devops-882862137128"

    # ONE state file for the whole devops account.
    key = "devops/us-east-1/terraform.tfstate"

    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
