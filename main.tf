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
  for_each                  = var.associate_with_subnet && var.subnet_ids != null ? var.subnet_ids : {}
  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.nsg.id

  timeouts {
    create = "5m"
    delete = "10m"
  }
}
resource "azurerm_network_security_rule" "rules" {
  for_each = var.apply_standard_rules == true ? local.final_nsg_rules : tomap({})

  name      = each.key
  priority  = each.value.priority
  direction = each.value.direction
  access    = each.value.access
  protocol  = each.value.protocol

  source_port_range                          = try(each.value.source_port_range, null)
  source_port_ranges                         = try(each.value.source_port_ranges, null)
  destination_port_range                     = try(each.value.destination_port_range, null)
  destination_port_ranges                    = try(each.value.destination_port_ranges, null)
  source_address_prefix                      = try(each.value.source_address_prefix, null)
  source_address_prefixes                    = try(each.value.source_address_prefixes, null)
  destination_address_prefix                 = try(each.value.destination_address_prefix, null)
  destination_address_prefixes               = try(each.value.destination_address_prefixes, null)
  source_application_security_group_ids      = try(each.value.source_application_security_group_ids, null)
  destination_application_security_group_ids = try(each.value.destination_application_security_group_ids, null)
  description                                = try(each.value.description, null)

  resource_group_name         = azurerm_network_security_group.nsg.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "rules_custom" {
  for_each = var.custom_nsg_rules != null && var.apply_standard_rules == false ? var.custom_nsg_rules : tomap({})

  name      = each.key
  priority  = each.value.priority
  direction = each.value.direction
  access    = each.value.access
  protocol  = each.value.protocol

  source_port_range                          = try(each.value.source_port_range, null)
  source_port_ranges                         = try(each.value.source_port_ranges, null)
  destination_port_range                     = try(each.value.destination_port_range, null)
  destination_port_ranges                    = try(each.value.destination_port_ranges, null)
  source_address_prefix                      = try(each.value.source_address_prefix, null)
  source_address_prefixes                    = try(each.value.source_address_prefixes, null)
  destination_address_prefix                 = try(each.value.destination_address_prefix, null)
  destination_address_prefixes               = try(each.value.destination_address_prefixes, null)
  source_application_security_group_ids      = try(each.value.source_application_security_group_ids, null)
  destination_application_security_group_ids = try(each.value.destination_application_security_group_ids, null)
  description                                = try(each.value.description, null)

  resource_group_name         = azurerm_network_security_group.nsg.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}