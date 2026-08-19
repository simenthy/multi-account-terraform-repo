# CI/OIDC resources for one account's GitHub Actions pipeline. Kept in a
# dedicated module (and a dedicated root/state per account — see
# accounts/<name>/pipeline/), because these
# resources have a different blast radius and a different owner (the
# pipeline itself) than the environment resources the other domain modules
# manage.

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable github_oidc_provider {
  description = "GitHub Actions OIDC Provider for this account. null = don't create one. Only one is needeed per account, no matter how many roles trust it."
  type        = object({
    tags                      = optional(map(string), {})
  })
  default = null
}

variable "github_actions_plan_roles" {
  description = <<-EOT
    IAM roles GitHub Actions plan workflows can assume via OIDC, keyed by
    local role name. Trusted for any pull_request or default-branch push on
    the repo, and read-only: a plan must see everything and change nothing.
    Requires github_oidc_provider to be set.
  EOT
  type = map(object({
    repo           = string # "org/repo-name"
    default_branch = optional(string, "main")
    state_bucket   = string # must match this account's environment-resources backend.tf bucket
    state_key      = string # must match this account's environment-resources backend.tf key
    tags           = optional(map(string), {})
  }))
  default = {}
}

variable "github_actions_apply_roles" {
  description = <<-EOT
    IAM roles GitHub Actions apply workflows can assume via OIDC, keyed by
    local role name. Unlike github_actions_plan_roles (trusted for any
    pull_request/push on the repo, read-only), these are trusted ONLY for
    jobs running under a specific GitHub Environment (the "environment:"
    claim in the OIDC token) — i.e. only after that Environment's required
    reviewers have approved the job. Gets full account access, since it's
    the one actually allowed to create/change/destroy things. Requires
    github_oidc_provider to be set.
  EOT

  type = map(object({
    repo = string
    github_environment = string          # eg: nft-plan or nft-apply
    tags                      = optional(map(string), {})
  }))
  default = {}
}

