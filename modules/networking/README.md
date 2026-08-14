# Networking module

Builds the network layer of an AWS account: VPCs, subnets, internet/NAT
gateways, route tables, network ACLs, and VPC endpoints.

## The idea, in plain words

Think of this module as a **cookie cutter** and the account folder
(`account/nft/networking/`) as the **baker**:

- The module holds the *shape* — "this is what a subnet looks like, this is
  how it attaches to a VPC."
- The account folder holds the *ingredients list* (`terraform.tfvars`) —
  "I want 10 subnets, with these names, these CIDR ranges, in these VPCs."
- Terraform presses the cutter once per ingredient and produces one real
  AWS resource per entry.

The same cutter can be reused by every other AWS account in the
organization — only the ingredients list changes.

## How one resource block builds many resources (`for_each`)

```
terraform.tfvars (the data)          module (the template)              AWS (the result)
---------------------------          ---------------------              ----------------
subnets = {
  pub_sub_nft01 = { ... }  ───►  resource "aws_subnet" "this" {  ───►  subnet for nft01
  pub_sub_nft02 = { ... }  ───►    for_each = var.subnets        ───►  subnet for nft02
  ...                              ...                                  ...
}                                }
```

`for_each = var.subnets` means: *run this block once per entry in the map*.
Inside the block:

- `each.key` is the entry's name, e.g. `"pub_sub_nft01"`
- `each.value` is the entry's data, e.g. `each.value.cidr_block`

Each copy gets a state address containing its key:
`aws_subnet.this["pub_sub_nft01"]`. Keys are **names, not numbers**, so
adding or removing one entry never renumbers (and never rebuilds) the others.

## How resources find each other (`*_key`)

A subnet needs the ID of its VPC — but the ID (`vpc-0abc...`) only exists
after AWS creates it. So the subnet entry carries a *name reference*
instead:

```hcl
# terraform.tfvars
pub_sub_nft01 = {
  vpc_key = "nft01_vpc"     # "I belong to the VPC named nft01_vpc"
  ...
}

# subnets.tf inside the module
vpc_id = aws_vpc.this[each.value.vpc_key].id
#        └── "look up the VPC entry named by vpc_key and take its id"
```

It's addressing an envelope by the person's *name* rather than "the third
house on the street" — so it keeps working even when names don't line up
in sequence (e.g. route-table association `pvt_rtbassoc_nft04` genuinely
belongs to subnet `pvt_sub_nft05`; the data says so, and that's all that
matters).

## Files

| File | Builds |
|---|---|
| `vpc.tf` | The private networks themselves (the "buildings") |
| `subnets.tf` | Slices of a VPC's IP space (the "floors") |
| `internet_gateways.tf` | The VPC's door to the internet |
| `eips.tf` | Fixed public IP addresses (used by the NAT gateways) |
| `nat_gateways.tf` | One-way doors: private subnets can reach out, nothing can reach in |
| `route_tables.tf` | The signposts deciding where traffic goes |
| `route_table_associations.tf` | Which subnet follows which signposts |
| `network_acls.tf` | Subnet-level firewalls |
| `network_acl_associations.tf` | Which subnet is filtered by which firewall |
| `vpc_endpoints.tf` | Private, internal connections to specific services (no internet) |
| `variables.tf` | The order form (inputs) |
| `outputs.tf` | The receipt (IDs, for use outside the module) |
| `versions.tf` | Terraform/provider version requirements — no provider config, no backend |

## Inputs

| Variable | What it is |
|---|---|
| `common_tags` | Tags stamped on everything (empty during migration so imported tags stay untouched) |
| `vpcs` | Map of VPCs |
| `subnets` | Map of subnets (`vpc_key`) |
| `internet_gateways` | Map of IGWs (`vpc_key`) |
| `eips` | Map of Elastic IPs |
| `nat_gateways` | Map of NAT gateways (`eip_key`, `subnet_key`) |
| `route_tables` | Map of route tables (`vpc_key`) |
| `route_table_associations` | Subnet ↔ route table links (`subnet_key`, `route_table_key`) |
| `network_acls` | Map of NACLs (`vpc_key`) |
| `network_acl_associations` | Subnet ↔ NACL links (`network_acl_key`, `subnet_key`) |
| `security_group_lookups` | Existing security groups to look up by name (read-only) |
| `vpc_endpoints` | Map of interface endpoints (`vpc_key`, `security_group_keys`, pinned IPs per subnet) |

## Outputs

`vpc_ids`, `subnet_ids`, `internet_gateway_ids`, `eip_allocation_ids`,
`nat_gateway_ids`, `route_table_ids`, `network_acl_ids`,
`vpc_endpoint_ids` — each a map keyed by local name:

```hcl
module.networking.vpc_ids["nft01_vpc"]        # => "vpc-0abc..."
module.networking.subnet_ids["pvt_sub_nft03"] # => "subnet-0def..."
```

## Safety rails & deliberate gaps

- **`prevent_destroy = true`** on VPCs, subnets, and IGWs: Terraform refuses
  any plan that would delete them. A temporary backstop for the migration —
  remove it afterwards (keeping it on VPCs is a reasonable permanent choice).
- **Routes inside route tables are NOT managed yet** — they were never
  imported. Import them later as standalone `aws_route` resources; the
  route-table block deliberately has no inline `route {}`.
- **NACL rules (ingress/egress) are NOT managed yet** — same story. The
  live firewall rules exist in AWS but Terraform neither sees nor protects
  them until they are imported.
- **Not everything takes tags**: route-table associations and NACL
  associations have no `tags` argument in AWS at all.
