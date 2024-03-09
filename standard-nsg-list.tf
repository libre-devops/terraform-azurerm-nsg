locals {
  standard_nsg_list = {
    "DenyAllInbound" = {
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    "AllowAzureActiveDirectoryOutbound" = {
      priority                   = 4050
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureActiveDirectory"
    },
    "AllowAzureBackupOutbound" = {
      priority                   = 4045
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureBackup"
    },
    "AllowAzureCloudOutbound" = {
      priority                   = 4040
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureCloud"
    },
    "AllowAzureKeyVaultOutbound" = {
      priority                   = 4035
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureKeyVault"
    },
    "AllowAzureLoadBalancerOutbound" = {
      priority                   = 4030
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureLoadBalancer"
    },
    "AllowAzureMonitorOutbound" = {
      priority                   = 4025
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureMonitor"
    },
    "AllowAzureStorageOutbound" = {
      priority                   = 4020
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Storage"
    }
  }
  final_nsg_rules = var.apply_standard_rules ? merge(local.standard_nsg_list, var.custom_nsg_rules) : var.custom_nsg_rules
}
