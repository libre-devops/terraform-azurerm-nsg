# check blocks run after every plan and apply and emit a warning (without blocking) when an
# invariant is violated. They are the place to enforce module-wide consistency.

# Azure requires every rule priority in a network security group to be unique (across both
# directions). A collision between a custom rule and a default is the usual cause; override the
# default by name, or pick a different priority.
check "unique_rule_priorities" {
  assert {
    condition     = length(local.security_rules) == length(distinct([for r in values(local.security_rules) : r.priority]))
    error_message = "Two or more NSG rules share a priority. Priorities must be unique within the NSG (custom rules merge over defaults by name, so a clash usually means a duplicated priority rather than an overridden default)."
  }
}
