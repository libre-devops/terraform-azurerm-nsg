variable "apply_default_rules" {
  description = "Whether to merge the module's secure default rules (default_rules) in with your security_rules. Custom rules of the same name override a default. Set to false to manage the rule set entirely yourself."
  type        = bool
  default     = true
}

variable "default_rules" {
  description = "The module's secure default rules, merged in when apply_default_rules is true: an explicit inbound deny (priority 4096) plus curated outbound allows to essential Azure service tags. Override an individual default by giving a security_rules entry the same key, or replace this whole map to change the baseline."
  type = map(object({
    priority                                   = number
    direction                                  = string
    access                                     = string
    protocol                                   = string
    description                                = optional(string)
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    source_application_security_group_ids      = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
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
      description                = "Explicit catch-all inbound deny; allow only what you need above it."
    }
    "AllowAzureActiveDirectoryOutbound" = {
      priority                   = 4050
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureActiveDirectory"
    }
    "AllowAzureBackupOutbound" = {
      priority                   = 4045
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureBackup"
    }
    "AllowAzureCloudOutbound" = {
      priority                   = 4040
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureCloud"
    }
    "AllowAzureKeyVaultOutbound" = {
      priority                   = 4035
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureKeyVault"
    }
    "AllowAzureLoadBalancerOutbound" = {
      priority                   = 4030
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureLoadBalancer"
    }
    "AllowAzureMonitorOutbound" = {
      priority                   = 4025
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureMonitor"
    }
    "AllowStorageOutbound" = {
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

  validation {
    condition     = alltrue([for r in values(var.default_rules) : r.priority >= 100 && r.priority <= 4096])
    error_message = "Each default rule priority must be between 100 and 4096."
  }
}

variable "location" {
  description = "Azure region for the network security group."
  type        = string
}

variable "name" {
  description = "Name of the network security group."
  type        = string
}

variable "network_interface_associations" {
  description = "Network interfaces to associate this NSG with, keyed by a logical name with the NIC id as the value (ids may be computed in the same apply; the static keys keep for_each valid). Prefer subnet associations where you can."
  type        = map(string)
  default     = {}
}

variable "resource_group_id" {
  description = "Resource id of the resource group to create the NSG in. The name and subscription are parsed from it (pass the rg module's ids output)."
  type        = string

  validation {
    condition     = try(provider::azurerm::parse_resource_id(var.resource_group_id).resource_type, "") == "resourceGroups"
    error_message = "resource_group_id must be a resource group id of the form /subscriptions/<sub>/resourceGroups/<name>."
  }
}

variable "security_rules" {
  description = "Your NSG rules, keyed by rule name. Merged over default_rules (a rule here with the same name as a default overrides it). Each rule needs priority (100 to 4096, unique within the NSG), direction (Inbound/Outbound), access (Allow/Deny), and protocol (Tcp/Udp/Icmp/Esp/Ah/*); set exactly one of the singular or plural form for each of source_port, destination_port, source_address, and destination_address."
  type = map(object({
    priority                                   = number
    direction                                  = string
    access                                     = string
    protocol                                   = string
    description                                = optional(string)
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    source_application_security_group_ids      = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.security_rules) : r.priority >= 100 && r.priority <= 4096])
    error_message = "Each rule priority must be between 100 and 4096."
  }

  validation {
    condition     = alltrue([for r in values(var.security_rules) : contains(["Inbound", "Outbound"], r.direction)])
    error_message = "Each rule direction must be Inbound or Outbound."
  }

  validation {
    condition     = alltrue([for r in values(var.security_rules) : contains(["Allow", "Deny"], r.access)])
    error_message = "Each rule access must be Allow or Deny."
  }

  validation {
    condition     = alltrue([for r in values(var.security_rules) : contains(["Tcp", "Udp", "Icmp", "Esp", "Ah", "*"], r.protocol)])
    error_message = "Each rule protocol must be one of Tcp, Udp, Icmp, Esp, Ah, or *."
  }
}

variable "subnet_associations" {
  description = "Subnets to associate this NSG with, keyed by subnet name with the subnet id as the value (ids may be computed in the same apply; the static keys keep for_each valid). Leave empty to associate the NSG elsewhere, for example from the network or subnet module."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the network security group."
  type        = map(string)
  default     = {}
}
