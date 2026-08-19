# COST NOTE: no load balancer and no listener here. An Application Load
# Balancer is ~$0.0225/hr (~$0.54/day) plus LCU charges, which would be
# over half this workspace's entire budget for a resource nothing is
# routing traffic through.
#
# Everything below is free: launch templates, target groups, ECS clusters
# with no tasks, and an Auto Scaling group pinned to desired_capacity = 0
# so no EC2 instances ever launch. The target group is kept (it costs
# nothing standalone) so the ASG's traffic_sources wiring and the root's
# vpc_key -> vpc_id resolution still get exercised.

#------------------------------------------------
# Launch Templates (free — billing starts only when instances launch)
#------------------------------------------------
launch_templates = {
  devops_lt01 = {
    name                = "fra-devops-lt-devops01"
    image_id            = "ami-0332d564d76dbd8d6"
    instance_type       = "t3.micro"
    security_group_keys = ["sg_devops_default"]
    tags = {
      Name        = "fra-devops-lt-devops01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}

#------------------------------------------------
# Target Groups (free)
#------------------------------------------------
target_groups = {
  devops_tg01 = {
    name        = "fra-devops-tg-01"
    port        = 80
    protocol    = "HTTP"
    target_type = "instance"
    vpc_key     = "devops01_vpc"
    tags = {
      Name        = "fra-devops-tg-01"
      Environment = "devops"
      Application = "Platform"
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
  devops_asg01 = {
    name                = "fra-devops-asg-01"
    max_size            = 1
    min_size            = 0
    desired_capacity    = 0
    launch_template_key = "devops_lt01"
    subnet_keys         = ["pvt_sub_devops01", "pvt_sub_devops02"]
    traffic_sources = [
      {
        target_group_key = "devops_tg01"
        type             = "elbv2"
      }
    ]
    tags = [
      {
        key                 = "Name"
        value               = "fra-devops-asg-01"
        propagate_at_launch = true
      },
      {
        key                 = "Environment"
        value               = "devops"
        propagate_at_launch = true
      },
      {
        key                 = "Application"
        value               = "Platform"
        propagate_at_launch = true
      },
    ]
  }
}

#------------------------------------------------
# Auto Scaling Policies (free)
#------------------------------------------------
asg_policies = {
  devops_asg_policy01 = {
    name        = "fra-devops-asg-policy-01"
    asg_key     = "devops_asg01"
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
  devops_ecs01 = {
    name = "fra-devops-ecs-01"
    tags = {
      Name        = "fra-devops-ecs-01"
      Environment = "devops"
      Application = "Platform"
    }
  }
}
