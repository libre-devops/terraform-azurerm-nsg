resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  timeouts {
    create = "5m"
    delete = "10m"
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  count                     = var.associate_with_nic && var.nic_id != null ? 1 : 0
  network_interface_id      = var.nic_id
  network_security_group_id = azurerm_network_security_group.nsg.id

  timeouts {
    create = "5m"
    delete = "10m"
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = var.associate_with_subnet == true ? 1 : 0
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id

  timeouts {
    create = "5m"
    delete = "10m"
  }
}

resource "azurerm_network_security_rule" "rules" {
  for_each = local.final_nsg_rules

  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_network_security_group.nsg.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
