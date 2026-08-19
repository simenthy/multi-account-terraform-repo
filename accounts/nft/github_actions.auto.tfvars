github_oidc_provider = {
  tags = {
    Name        = "github-actions-oidc"
    Environment = "Shared"
    Application = "CI"
  }
}

github_actions_plan_roles = {
  github-actions-nft-terraform-plan = {
    repo         = "simenthy/multi-account-terraform-repo"
    state_bucket = "tfstate-nft-873135413574"
    state_key    = "nft/us-east-1/terraform.tfstate"
    tags = {
      Name        = "github-actions-nft-terraform-plan"
      Environment = "Shared"
      Application = "CI"
    }
  }
}

github_actions_apply_roles = {
  github-actions-nft-terraform-apply = {
    repo               = "simenthy/multi-account-terraform-repo"
    github_environment = "nft-apply"
    tags = {
      Name        = "github-actions-nft-terraform-apply"
      Environment = "Shared"
      Application = "CI"
    }
  }
}