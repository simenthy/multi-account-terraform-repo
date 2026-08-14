# TRIMMED FOR COST (2026-08-14). This account previously described the
# full imported nft estate (~265 resources across all domains: 2 NAT
# gateways, 2 network load balancers, interface VPC endpoints, 11 KMS
# keys, a WAF ACL and more). Everything in that AWS account was destroyed,
# and this workspace now exists only to exercise the CI/CD pipeline — so
# the config was cut down to a free/near-free resource set mirroring
# accounts/devops, giving two comparable accounts to test the
# multi-account matrix against.
#
# What was removed from networking, and why:
#   - NAT gateways (2)        ~$0.045/hr each  -> ~$2.16/day
#   - Elastic IPs             ~$0.005/hr each  -> ~$0.12/day each
#   - Interface VPC endpoints ~$0.01/hr each   -> ~$0.24/day each
# Everything kept below (VPC, subnets, IGW, route tables, NACLs, security
# group) is free of charge. The private subnets have no outbound internet
# path as a result; nothing runs in them, so that is fine here.

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------
vpcs = {
  nft01_vpc = {
    cidr_block                           = "10.134.0.0/16"
    instance_tenancy                     = "default"
    enable_dns_support                   = true
    enable_dns_hostnames                 = true
    enable_network_address_usage_metrics = false
    tags = {
      Name        = "fra-nft-vpc-nft01"
      Application = "NFT"
      Environment = "Dev"
    }
  }
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------
subnets = {
  pub_sub_nft01 = {
    vpc_key                             = "nft01_vpc"
    cidr_block                          = "10.134.0.0/22"
    availability_zone                   = "us-east-1a"
    map_public_ip_on_launch             = false
    private_dns_hostname_type_on_launch = "ip-name"
    tags = {
      Application = "NFT"
      Environment = "Dev"
      Name        = "fra-nft-pub-sub-nft01"
    }
  }
  pub_sub_nft02 = {
    vpc_key                             = "nft01_vpc"
    cidr_block                          = "10.134.4.0/22"
    availability_zone                   = "us-east-1b"
    map_public_ip_on_launch             = false
    private_dns_hostname_type_on_launch = "ip-name"
    tags = {
      Application = "NFT"
      Environment = "Dev"
      Name        = "fra-nft-pub-sub-nft02"
    }
  }
  pvt_sub_nft01 = {
    vpc_key                             = "nft01_vpc"
    cidr_block                          = "10.134.8.0/22"
    availability_zone                   = "us-east-1a"
    map_public_ip_on_launch             = false
    private_dns_hostname_type_on_launch = "ip-name"
    tags = {
      Application = "NFT"
      Environment = "Dev"
      Name        = "fra-nft-pvt-sub-nft01"
    }
  }
  pvt_sub_nft02 = {
    vpc_key                             = "nft01_vpc"
    cidr_block                          = "10.134.12.0/22"
    availability_zone                   = "us-east-1b"
    map_public_ip_on_launch             = false
    private_dns_hostname_type_on_launch = "ip-name"
    tags = {
      Application = "NFT"
      Environment = "Dev"
      Name        = "fra-nft-pvt-sub-nft02"
    }
  }
}

# ---------------------------------------------------------------------------
# Internet Gateway (free — only NAT gateways bill)
# ---------------------------------------------------------------------------
internet_gateways = {
  igw_nft = {
    vpc_key = "nft01_vpc"
    tags = {
      Name        = "fra-nft-igw-nft01"
      Application = "NFT"
      Environment = "Dev"
    }
  }
}

# ---------------------------------------------------------------------------
# Route Tables
# ---------------------------------------------------------------------------
route_tables = {
  pub_rtb_nft = {
    vpc_key = "nft01_vpc"
    tags = {
      Name        = "fra-nft-pub-rtb-nft01"
      Application = "NFT"
      Environment = "Dev"
    }
  }
  pvt_rtb_nft = {
    vpc_key = "nft01_vpc"
    tags = {
      Name        = "fra-nft-pvt-rtb-nft01"
      Application = "NFT"
      Environment = "Dev"
    }
  }
}

# ---------------------------------------------------------------------------
# Route Table Associations (no tags — AWS does not support tags on this type)
# ---------------------------------------------------------------------------
route_table_associations = {
  pub_rtbassoc_nft01 = {
    subnet_key      = "pub_sub_nft01"
    route_table_key = "pub_rtb_nft"
  }
  pub_rtbassoc_nft02 = {
    subnet_key      = "pub_sub_nft02"
    route_table_key = "pub_rtb_nft"
  }
  pvt_rtbassoc_nft01 = {
    subnet_key      = "pvt_sub_nft01"
    route_table_key = "pvt_rtb_nft"
  }
  pvt_rtbassoc_nft02 = {
    subnet_key      = "pvt_sub_nft02"
    route_table_key = "pvt_rtb_nft"
  }
}

# ---------------------------------------------------------------------------
# Network ACLs
# ---------------------------------------------------------------------------
network_acls = {
  pub_nacl_nft = {
    vpc_key = "nft01_vpc"
    tags = {
      Name        = "fra-nft-pub-nacl-nft01"
      Application = "NFT"
      Environment = "Dev"
    }
  }
  pvt_nacl_nft = {
    vpc_key = "nft01_vpc"
    tags = {
      Name        = "fra-nft-pvt-nacl-nft01"
      Application = "NFT"
      Environment = "Dev"
    }
  }
}

# ---------------------------------------------------------------------------
# Network ACL Associations (no tags — AWS does not support tags on this type)
# ---------------------------------------------------------------------------
network_acl_associations = {
  pub_naclassoc_nft01 = {
    network_acl_key = "pub_nacl_nft"
    subnet_key      = "pub_sub_nft01"
  }
  pub_naclassoc_nft02 = {
    network_acl_key = "pub_nacl_nft"
    subnet_key      = "pub_sub_nft02"
  }
  pvt_naclassoc_nft01 = {
    network_acl_key = "pvt_nacl_nft"
    subnet_key      = "pvt_sub_nft01"
  }
  pvt_naclassoc_nft02 = {
    network_acl_key = "pvt_nacl_nft"
    subnet_key      = "pvt_sub_nft02"
  }
}

# ---------------------------------------------------------------------------
# Security Groups
# ---------------------------------------------------------------------------
security_groups = {
  sg_nft_default = {
    vpc_key     = "nft01_vpc"
    name        = "nft-default-sg"
    description = "Default security group for the nft test environment"
    tags = {
      Name        = "fra-nft-default-sg"
      Application = "NFT"
      Environment = "Dev"
    }
  }
}
