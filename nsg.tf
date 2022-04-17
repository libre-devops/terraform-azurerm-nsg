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

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id

  timeouts {
    create = "5m"
    delete = "10m"
  }
}

resource "azurerm_network_security_rule" "nsg" {
  for_each = var.standard_nsg_list

  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# call module with standard_nsg_list = {} to disable standard rules
variable "standard_nsg_list" {
  default = {
    "DenyAllInbound"                    = { priority = "4096", direction = "Inbound", access = "Deny", destination_address_prefix = "*" },
    "AllowAzureActiveDirectoryOutbound" = { priority = "4050", direction = "Outbound", access = "Allow", destination_address_prefix = "AzureActiveDirectory" },
    "AllowAzureBackupOutbound"          = { priority = "4045", direction = "Outbound", access = "Allow", destination_address_prefix = "AzureBackup" },
    "AllowAzureCloudOutbound"           = { priority = "4040", direction = "Outbound", access = "Allow", destination_address_prefix = "AzureCloud" },
    "AllowAzureKeyVaultOutbound"        = { priority = "4035", direction = "Outbound", access = "Allow", destination_address_prefix = "AzureKeyVault" },
    "AllowAzureLoadBalancerOutbound"    = { priority = "4030", direction = "Outbound", access = "Allow", destination_address_prefix = "AzureLoadBalancer" },
    "AllowAzureMonitorOutbound"         = { priority = "4025", direction = "Outbound", access = "Allow", destination_address_prefix = "AzureMonitor" },
    "AllowAzureStorageOutbound"         = { priority = "4020", direction = "Outbound", access = "Allow", destination_address_prefix = "Storage" },
  }
}