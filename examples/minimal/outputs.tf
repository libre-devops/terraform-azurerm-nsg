output "nsg_id" {
  description = "The id of the network security group."
  value       = module.nsg.id
}

output "security_rule_ids" {
  description = "The ids of the NSG rules (the effective merged set)."
  value       = module.nsg.security_rule_ids
}

output "subnet_association_ids" {
  description = "The subnet NSG association ids."
  value       = module.nsg.subnet_association_ids
}
