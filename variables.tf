variable "apply_standard_rules" {
  description = "Whether to apply the standard NSG rules or not."
  type        = bool
  default     = true
}

variable "associate_with_nic" {
  type        = bool
  description = "Whether the NSG should be associated with a nic"
  default     = false
}

variable "associate_with_subnet" {
  type        = bool
  description = "Whether the NSG should be associated with a subnet"
  default     = false
}

variable "custom_nsg_rules" {
  description = "Custom NSG rules to apply if apply_standard_rules is set to false."
  type = map(object({
    name                                       = optional(string)
    priority                                   = optional(number)
    direction                                  = optional(string)
    access                                     = optional(string)
    protocol                                   = optional(string)
    source_port_range                          = optional(string)
    sources_port_ranges                        = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    source_application_security_group_ids      = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
    description                                = optional(string)
    resource_group_name                        = optional(string)
    network_security_group_name                = optional(string)
  }))
  default = {}
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "nic_id" {
  type        = string
  description = "The ID of a NIC if the association is triggered"
  default     = null
}

variable "nsg_name" {
  description = "The name of the resource to be created"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
}

variable "standard_nsg_rules" {
  description = "Standard NSG rules supplied by the module, these are applied by default"
  type = map(object({
    name                                       = optional(string)
    priority                                   = optional(number)
    direction                                  = optional(string)
    access                                     = optional(string)
    protocol                                   = optional(string)
    source_port_range                          = optional(string)
    sources_port_ranges                        = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    source_application_security_group_ids      = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
    description                                = optional(string)
    resource_group_name                        = optional(string)
    network_security_group_name                = optional(string)
  }))
  default = {
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
}

variable "subnet_ids" {
  description = "A map of subnet ids to pass"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "The tags assigned to the resource"
  type        = map(string)
}
