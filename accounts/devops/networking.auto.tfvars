# COST NOTE: this workspace exists only to exercise the CI/CD pipeline, so
# it deliberately contains no billable networking. In particular there is
# NO NAT gateway and NO Elastic IP:
#   - a NAT gateway is ~$0.045/hr (~$1.08/day) plus data processing, which
#     alone would blow the entire budget for this workspace;
#   - every public IPv4 address (including an EIP attached to a NAT
#     gateway) bills at ~$0.005/hr (~$0.12/day) since Feb 2024.
# The private subnets therefore have no outbound internet path. That is
# fine here — nothing runs in them. Add a NAT gateway back only in an
# account where something actually needs egress.
#
# Everything below (VPC, subnets, IGW, route tables, NACLs, security
# group) is free of charge.

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------
vpcs = {
  devops01_vpc = {
    cidr_block                           = "10.135.0.0/16"
    instance_tenancy                     = "default"
    enable_dns_support                   = true
    enable_dns_hostnames                 = true
    enable_network_address_usage_metrics = false
    tags = {
      Name        = "fra-devops-vpc-devops01"
      Application = "Platform"
      Environment = "devops"
    }
  }
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------
subnets = {
  pub_sub_devops01 = {
    vpc_key                             = "devops01_vpc"
    cidr_block                          = "10.135.0.0/22"
    availability_zone                   = "us-east-1a"
    map_public_ip_on_launch             = false
    private_dns_hostname_type_on_launch = "ip-name"
    tags = {
      Application = "Platform"
      Environment = "devops"
      Name        = "fra-devops-pub-sub-devops01"
    }
  }
  pub_sub_devops02 = {
    vpc_key                             = "devops01_vpc"
    cidr_block                          = "10.135.4.0/22"
    availability_zone                   = "us-east-1b"
    map_public_ip_on_launch             = false
    private_dns_hostname_type_on_launch = "ip-name"
    tags = {
      Application = "Platform"
      Environment = "devops"
      Name        = "fra-devops-pub-sub-devops02"
    }
  }
  pvt_sub_devops01 = {
    vpc_key                             = "devops01_vpc"
    cidr_block                          = "10.135.8.0/22"
    availability_zone                   = "us-east-1a"
    map_public_ip_on_launch             = false
    private_dns_hostname_type_on_launch = "ip-name"
    tags = {
      Application = "Platform"
      Environment = "devops"
      Name        = "fra-devops-pvt-sub-devops01"
    }
  }
  pvt_sub_devops02 = {
    vpc_key                             = "devops01_vpc"
    cidr_block                          = "10.135.12.0/22"
    availability_zone                   = "us-east-1b"
    map_public_ip_on_launch             = false
    private_dns_hostname_type_on_launch = "ip-name"
    tags = {
      Application = "Platform"
      Environment = "devops"
      Name        = "fra-devops-pvt-sub-devops02"
    }
  }
}

# ---------------------------------------------------------------------------
# Internet Gateway (free — only NAT gateways bill)
# ---------------------------------------------------------------------------
internet_gateways = {
  igw_devops = {
    vpc_key = "devops01_vpc"
    tags = {
      Name        = "fra-devops-igw-devops01"
      Application = "Platform"
      Environment = "devops"
    }
  }
}

# ---------------------------------------------------------------------------
# Route Tables
# ---------------------------------------------------------------------------
route_tables = {
  pub_rtb_devops = {
    vpc_key = "devops01_vpc"
    tags = {
      Name        = "fra-devops-pub-rtb-devops01"
      Application = "Platform"
      Environment = "devops"
    }
  }
  pvt_rtb_devops = {
    vpc_key = "devops01_vpc"
    tags = {
      Name        = "fra-devops-pvt-rtb-devops01"
      Application = "Platform"
      Environment = "devops"
    }
  }
}

# ---------------------------------------------------------------------------
# Route Table Associations (no tags — AWS does not support tags on this type)
# ---------------------------------------------------------------------------
route_table_associations = {
  pub_rtbassoc_devops01 = {
    subnet_key      = "pub_sub_devops01"
    route_table_key = "pub_rtb_devops"
  }
  pub_rtbassoc_devops02 = {
    subnet_key      = "pub_sub_devops02"
    route_table_key = "pub_rtb_devops"
  }
  pvt_rtbassoc_devops01 = {
    subnet_key      = "pvt_sub_devops01"
    route_table_key = "pvt_rtb_devops"
  }
  pvt_rtbassoc_devops02 = {
    subnet_key      = "pvt_sub_devops02"
    route_table_key = "pvt_rtb_devops"
  }
}

# ---------------------------------------------------------------------------
# Network ACLs
# ---------------------------------------------------------------------------
network_acls = {
  pub_nacl_devops = {
    vpc_key = "devops01_vpc"
    tags = {
      Name        = "fra-devops-pub-nacl-devops01"
      Application = "Platform"
      Environment = "devops"
    }
  }
  pvt_nacl_devops = {
    vpc_key = "devops01_vpc"
    tags = {
      Name        = "fra-devops-pvt-nacl-devops01"
      Application = "Platform"
      Environment = "devops"
    }
  }
}

# ---------------------------------------------------------------------------
# Network ACL Associations (no tags — AWS does not support tags on this type)
# ---------------------------------------------------------------------------
network_acl_associations = {
  pub_naclassoc_devops01 = {
    network_acl_key = "pub_nacl_devops"
    subnet_key      = "pub_sub_devops01"
  }
  pub_naclassoc_devops02 = {
    network_acl_key = "pub_nacl_devops"
    subnet_key      = "pub_sub_devops02"
  }
  pvt_naclassoc_devops01 = {
    network_acl_key = "pvt_nacl_devops"
    subnet_key      = "pvt_sub_devops01"
  }
  pvt_naclassoc_devops02 = {
    network_acl_key = "pvt_nacl_devops"
    subnet_key      = "pvt_sub_devops02"
  }
}

# ---------------------------------------------------------------------------
# Security Groups
# ---------------------------------------------------------------------------
security_groups = {
  sg_devops_default = {
    vpc_key     = "devops01_vpc"
    name        = "devops-default-sg"
    description = "Default security group for the devops environment"
    tags = {
      Name        = "fra-devops-default-sg"
      Application = "Platform"
      Environment = "devops"
    }
  }
}
