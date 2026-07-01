output "id" {
  description = "The id of the network security group."
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "The name of the network security group."
  value       = azurerm_network_security_group.this.name
}

output "network_interface_association_ids" {
  description = "Map of logical name to network interface NSG association id (only the associations this module creates)."
  value       = { for k, a in azurerm_network_interface_security_group_association.this : k => a.id }
}

output "network_security_group" {
  description = "The full azurerm_network_security_group resource."
  value       = azurerm_network_security_group.this
}

output "resource_group_name" {
  description = "Resource group name parsed from resource_group_id."
  value       = local.resource_group_name
}

output "security_rule_ids" {
  description = "Map of rule name to network security rule id (the effective merged rule set)."
  value       = { for k, r in azurerm_network_security_rule.this : k => r.id }
}

output "security_rules" {
  description = "The effective merged rule set (defaults plus custom), keyed by rule name."
  value       = local.security_rules
}

output "subnet_association_ids" {
  description = "Map of subnet name to subnet NSG association id (only the associations this module creates)."
  value       = { for k, a in azurerm_subnet_network_security_group_association.this : k => a.id }
}

output "subscription_id" {
  description = "Subscription id parsed from resource_group_id."
  value       = local.rg.subscription_id
}

output "tags" {
  description = "The tags applied to the network security group."
  value       = azurerm_network_security_group.this.tags
}
