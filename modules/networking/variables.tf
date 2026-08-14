# These variables are the module's "order form": the calling root folder
# fills them in (from terraform.tfvars) and the module builds exactly what
# was ordered. Every variable is a MAP whose keys are the resource local
# names — that key becomes the resource's identity in state, e.g.
# aws_subnet.this["pub_sub_nft01"].
#
# Relationships between resources are expressed with *_key fields
# ("vpc_key = \"nft01_vpc\"") — a name lookup, never a position in a list,
# so nothing breaks when names don't line up in sequence.

variable "common_tags" {
  description = "Tags added to every taggable resource on top of each resource's own tags. Kept empty ({}) during migration so imported tags stay byte-identical."
  type        = map(string)
  default     = {}
}

variable "vpcs" {
  description = "Map of VPCs, keyed by local name."
  type = map(object({
    cidr_block                           = string
    instance_tenancy                     = optional(string, "default")
    enable_dns_support                   = optional(bool, true)
    enable_dns_hostnames                 = optional(bool, true)
    enable_network_address_usage_metrics = optional(bool, false)
    tags                                 = optional(map(string), {})
  }))
  default = {}
}

variable "subnets" {
  description = "Map of subnets, keyed by local name. vpc_key points at an entry in var.vpcs."
  type = map(object({
    vpc_key                             = string
    cidr_block                          = string
    availability_zone                   = optional(string)
    map_public_ip_on_launch             = optional(bool, false)
    private_dns_hostname_type_on_launch = optional(string, "ip-name")
    tags                                = optional(map(string), {})
  }))
  default = {}
}

variable "internet_gateways" {
  description = "Map of internet gateways, keyed by local name. vpc_key points at an entry in var.vpcs."
  type = map(object({
    vpc_key = string
    tags    = optional(map(string), {})
  }))
  default = {}
}

variable "eips" {
  description = "Map of Elastic IPs (used by the NAT gateways), keyed by local name."
  type = map(object({
    domain = string
    tags   = optional(map(string), {})
  }))
  default = {}
}

variable "nat_gateways" {
  description = "Map of NAT gateways, keyed by local name. eip_key -> var.eips entry, subnet_key -> var.subnets entry."
  type = map(object({
    eip_key    = string
    subnet_key = string
    tags       = optional(map(string), {})
  }))
  default = {}
}

variable "route_tables" {
  description = "Map of route tables, keyed by local name. vpc_key points at an entry in var.vpcs."
  type = map(object({
    vpc_key = string
    tags    = optional(map(string), {})
  }))
  default = {}
}

variable "route_table_associations" {
  description = "Which subnet uses which route table. No tags — AWS does not support tags on this type."
  type = map(object({
    subnet_key      = string
    route_table_key = string
  }))
  default = {}
}

variable "network_acls" {
  description = "Map of network ACLs, keyed by local name. vpc_key points at an entry in var.vpcs. Rules are currently NOT managed here (see network_acls.tf)."
  type = map(object({
    vpc_key = string
    tags    = optional(map(string), {})
  }))
  default = {}
}

variable "network_acl_associations" {
  description = "Which subnet is filtered by which network ACL. No tags — AWS does not support tags on this type."
  type = map(object({
    network_acl_key = string
    subnet_key      = string
  }))
  default = {}
}

variable "security_group_lookups" {
  description = "Existing security groups (created outside this module) to look up by name, so VPC endpoints can reference them."
  type = map(object({
    name    = string
    vpc_key = string
  }))
  default = {}
}

variable "vpc_endpoints" {
  description = "Map of interface VPC endpoints, keyed by local name. security_group_keys -> var.security_group_lookups entries; each subnet_configuration pins a fixed private IP in one subnet."
  type = map(object({
    vpc_key             = string
    service_name        = string
    vpc_endpoint_type   = string
    private_dns_enabled = optional(bool, false)
    security_group_keys = list(string)
    subnet_configurations = list(object({
      ipv4       = string
      subnet_key = string
    }))
    tags = optional(map(string))
  }))
  default = {}
}

variable "security_groups" {
  description = "Map of security groups, keyed by local name, vpc_key points at an entry in var.vpcs"
  type = map(object({
    vpc_key     = string
    name        = optional(string)
    description = optional(string)
    tags        = optional(map(string), {})
  }))
  default = {}
}
