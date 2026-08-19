# TRIMMED FOR COST (2026-08-14) — see networking.auto.tfvars for the full
# context. Removed from this domain:
#   - 2 network load balancers (~$0.0225/hr each -> ~$1.08/day)
#   - the LB listener that fronted them
#   - ~30 target groups (free, but pointless without a load balancer)
#   - the second launch template / ASG / ECS cluster
#
# Everything below is free: launch templates, one target group, an ECS
# cluster with no tasks, and an ASG pinned to desired_capacity = 0 so no
# EC2 instances ever launch.

#------------------------------------------------
# Launch Templates (free — billing starts only when instances launch)
#------------------------------------------------
launch_templates = {
  nft_lt01 = {
    name                = "fra-nft-lt-nft01"
    image_id            = "ami-0332d564d76dbd8d6"
    instance_type       = "t3.micro"
    security_group_keys = ["sg_nft_default"]
    tags = {
      Name        = "fra-nft-lt-nft01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}

#------------------------------------------------
# Target Groups (free)
#------------------------------------------------
target_groups = {
  nft_tg01 = {
    name        = "fra-nft-tg-01"
    port        = 80
    protocol    = "HTTP"
    target_type = "instance"
    vpc_key     = "nft01_vpc"
    tags = {
      Name        = "fra-nft-tg-01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}

#------------------------------------------------
# Load Balancers / Listeners — intentionally empty, see the cost note above.
#------------------------------------------------
load_balancers = {}
lb_listeners   = {}

#------------------------------------------------
# Auto Scaling Groups (free at desired_capacity = 0)
#------------------------------------------------
auto_scaling_groups = {
  nft_asg01 = {
    name                = "fra-nft-asg-01"
    max_size            = 1
    min_size            = 0
    desired_capacity    = 0
    launch_template_key = "nft_lt01"
    subnet_keys         = ["pvt_sub_nft01", "pvt_sub_nft02"]
    traffic_sources = [
      {
        target_group_key = "nft_tg01"
        type             = "elbv2"
      }
    ]
    tags = [
      {
        key                 = "Name"
        value               = "fra-nft-asg-01"
        propagate_at_launch = true
      },
      {
        key                 = "Environment"
        value               = "Dev"
        propagate_at_launch = true
      },
      {
        key                 = "Application"
        value               = "NFT"
        propagate_at_launch = true
      },
    ]
  }
}

#------------------------------------------------
# Auto Scaling Policies (free)
#------------------------------------------------
asg_policies = {
  nft_asg_policy01 = {
    name        = "fra-nft-asg-policy-01"
    asg_key     = "nft_asg01"
    policy_type = "TargetTrackingScaling"

    target_tracking_configuration = {
      target_value = 50
      predefined_metric_specification = {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
    }
  }
}

#------------------------------------------------
# ECS Clusters (free with no running tasks)
#------------------------------------------------
ecs_clusters = {
  nft_ecs01 = {
    name = "fra-nft-ecs-01"
    tags = {
      Name        = "fra-nft-ecs-01"
      Environment = "Dev"
      Application = "NFT"
    }
  }
}
