github_oidc_provider = {
  tags = {
    Name        = "github-actions-oidc"
    Environment = "Shared"
    Application = "CI"
  }
}

github_actions_plan_roles = {
  github-actions-devops-terraform-plan = {
    repo         = "simenthy/multi-account-terraform-repo"
    state_bucket = "tfstate-devops-882862137128"
    state_key    = "devops/us-east-1/terraform.tfstate"
    tags = {
      Name        = "github-actions-devops-terraform-plan"
      Environment = "Shared"
      Application = "CI"
    }
  }
}

github_actions_apply_roles = {
  github-actions-devops-terraform-apply = {
    repo               = "simenthy/multi-account-terraform-repo"
    github_environment = "devops-apply"
    tags = {
      Name        = "github-actions-devops-terraform-apply"
      Environment = "Shared"
      Application = "CI"
    }
  }
}