package main

import rego.v1

# Required-tags gate, shared by every accounts/<name> root the dynamic
# terraform-plan.yml / terraform-apply.yml workflows run against.
#
# Runs against `terraform show -json` plan output via conftest. A resource
# is checked only if the AWS provider schema actually gives it a `tags`
# argument — that's what makes the "after" object contain a "tags" key at
# all. Resource types with no tagging support (route table associations,
# autoscaling groups, KMS aliases, ...) never carry that key, so they're
# skipped rather than flagged.

required_tags := ["Name", "Environment", "Application"]

relevant_actions := {"create", "update"}

is_relevant(rc) if {
	some action in rc.change.actions
	action in relevant_actions
}

supports_tags(rc) if {
	object.get(rc.change.after, "tags", "__absent__") != "__absent__"
}

missing_tags(tags) := [t |
	some t in required_tags
	object.get(tags, t, "") == ""
]

deny contains msg if {
	some rc in input.resource_changes
	is_relevant(rc)
	supports_tags(rc)
	tags := rc.change.after.tags
	tags != null
	missing := missing_tags(tags)
	count(missing) > 0
	msg := sprintf("%s (%s): missing required tag(s) %v", [rc.address, rc.type, missing])
}

deny contains msg if {
	some rc in input.resource_changes
	is_relevant(rc)
	supports_tags(rc)
	rc.change.after.tags == null
	msg := sprintf("%s (%s): tags is null — requires %v", [rc.address, rc.type, required_tags])
}