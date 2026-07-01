# A network security group plus its rules and, optionally, its subnet and network interface
# associations. Rules are standalone azurerm_network_security_rule resources (NOT inline security_rule
# blocks) keyed by rule name: standalone rules are non-authoritative, so a rule added out of band (for
# example a temporary "allow my IP" rule from an operational dance) coexists rather than being wiped on
# the next apply. Secure default rules (an explicit inbound deny plus curated outbound service-tag
# allows) are merged in by default and can be overridden per name or turned off entirely. Subnets and
# NICs are owned elsewhere; this module associates them by id, keyed by name (static keys) so the ids
# may be computed in the same apply. The resource group is passed by id and parsed.
locals {
  rg                  = provider::azurerm::parse_resource_id(var.resource_group_id)
  resource_group_name = local.rg.resource_group_name

  # Custom rules win over defaults of the same name; drop the defaults entirely when disabled.
  security_rules = merge(var.apply_default_rules ? var.default_rules : {}, var.security_rules)
}

resource "azurerm_network_security_group" "this" {
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags

  name = var.name
}

resource "azurerm_network_security_rule" "this" {
  for_each = local.security_rules

  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name

  name                                       = each.key
  priority                                   = each.value.priority
  direction                                  = each.value.direction
  access                                     = each.value.access
  protocol                                   = each.value.protocol
  description                                = each.value.description
  source_port_range                          = each.value.source_port_range
  source_port_ranges                         = each.value.source_port_ranges
  destination_port_range                     = each.value.destination_port_range
  destination_port_ranges                    = each.value.destination_port_ranges
  source_address_prefix                      = each.value.source_address_prefix
  source_address_prefixes                    = each.value.source_address_prefixes
  destination_address_prefix                 = each.value.destination_address_prefix
  destination_address_prefixes               = each.value.destination_address_prefixes
  source_application_security_group_ids      = each.value.source_application_security_group_ids
  destination_application_security_group_ids = each.value.destination_application_security_group_ids
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnet_associations

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_network_interface_security_group_association" "this" {
  for_each = var.network_interface_associations

  network_interface_id      = each.value
  network_security_group_id = azurerm_network_security_group.this.id
}
