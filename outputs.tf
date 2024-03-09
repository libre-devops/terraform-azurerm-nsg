output "final_nsg_rules" {
  value       = local.final_nsg_rules
  description = "The NSG rules list assigned as a variable"
}

output "nsg_id" {
  value       = azurerm_network_security_group.nsg.id
  description = "The ID of the NSG"
}

output "nsg_name" {
  value       = azurerm_network_security_group.nsg.name
  description = "The name of the NSG"
}

output "nsg_network_interface_security_group_association_ids" {
  description = "The IDs of the Network Interface Security Group Associations"
  value       = azurerm_network_interface_security_group_association.this.*.id
}

output "nsg_rg_name" {
  value       = azurerm_network_security_group.nsg.resource_group_name
  description = "The name of the resource group the nsg is in"
}

output "nsg_subnet_association_ids" {
  description = "The IDs of the Subnet Network Security Group Associations"
  value       = azurerm_subnet_network_security_group_association.this.*.id
}
