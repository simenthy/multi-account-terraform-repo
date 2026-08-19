# If OIDC Provider per url per account exists

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.github_oidc_provider != null ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]    

  tags = merge(var.common_tags, var.github_oidc_provider.tags)
}

# Else

data "aws_iam_openid_connect_provider" "existing" {
  count = var.github_oidc_provider == null ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

# Assign the OIDC provider ARN to a local variable, whether it was created or already existed

locals {
  github_oidc_provider_arn = coalesce(                           # coalesce() returns the first non-null value in the list
    one(aws_iam_openid_connect_provider.github_actions[*].arn),  # one(...)	Collapses a 0-or-1 element list into either that single value or null. Errors if given 2+ elements
    one(data.aws_iam_openid_connect_provider.existing[*].arn),
  )
}




locals {
  github_actions_plan_repo_parts = {
    for k, v in var.github_actions_plan_roles : k => split("/", v.repo)
  }
}

# ----------------------------------------------------------------
# ----------------------------------------------------------------
#                           PLAN ROLES
# ----------------------------------------------------------------
# ----------------------------------------------------------------

resource "aws_iam_role" "github_actions_plan" {
  for_each = var.github_actions_plan_roles

  name = each.key

  # The trust policy
  # ----------------------------------------------------------------
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.github_oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Covers both triggers the plan workflow uses — pull_request runs
          # and pushes to the default branch — in both subject-claim
          # shapes. Nothing else (other branches, other event types, other
          # repos) can assume this role.
          "token.actions.githubusercontent.com:sub" = [
            "repo:${each.value.repo}:pull_request",
            "repo:${each.value.repo}:ref:refs/heads/${each.value.default_branch}",
            "repo:${local.github_actions_plan_repo_parts[each.key][0]}@*/${local.github_actions_plan_repo_parts[each.key][1]}@*:pull_request",
            "repo:${local.github_actions_plan_repo_parts[each.key][0]}@*/${local.github_actions_plan_repo_parts[each.key][1]}@*:ref:refs/heads/${each.value.default_branch}",
          ]
        }
      }
    }]
  })
  # ----------------------------------------------------------------

  tags = merge(var.common_tags, each.value.tags)
}

# The role's policies
# ----------------------------------------------------------------

# The managed policy attachment for read-only access
resource "aws_iam_role_policy_attachment" "github_actions_plan_read_only" {
  for_each = var.github_actions_plan_roles

  role       = aws_iam_role.github_actions_plan[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# The inline policy for state locking
resource "aws_iam_role_policy" "github_actions_plan_state_lock" {
  for_each = var.github_actions_plan_roles

  name = "terraform-state-lock"
  role = aws_iam_role.github_actions_plan[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "StateLock"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "arn:aws:s3:::${each.value.state_bucket}/${each.value.state_key}.tflock"
      },
    ]
  })
}

# ----------------------------------------------------------------
# ----------------------------------------------------------------
#                           APPLY ROLES
# ----------------------------------------------------------------
# ----------------------------------------------------------------

locals {
  github_actions_apply_repo_parts = {
    for k, v in var.github_actions_apply_roles : k => split("/", v.repo)
  }
}

resource "aws_iam_role" "github_actions_apply" {
  for_each = var.github_actions_apply_roles

  name = each.key

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.github_oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:${each.value.repo}:environment:${each.value.github_environment}",
            "repo:${local.github_actions_apply_repo_parts[each.key][0]}@*/${local.github_actions_apply_repo_parts[each.key][1]}@*:environment:${each.value.github_environment}",
          ]
        }
      }
    }]
  })

  tags = merge(var.common_tags, each.value.tags)
}

# The role's Administrator policy
# ----------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "github_actions_apply_admin" {
  for_each = var.github_actions_apply_roles

  role       = aws_iam_role.github_actions_apply[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}