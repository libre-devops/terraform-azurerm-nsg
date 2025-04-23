```hcl
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
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.rules_custom](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_standard_rules"></a> [apply\_standard\_rules](#input\_apply\_standard\_rules) | Whether to apply the standard NSG rules or not. | `bool` | `true` | no |
| <a name="input_associate_with_nic"></a> [associate\_with\_nic](#input\_associate\_with\_nic) | Whether the NSG should be associated with a nic | `bool` | `false` | no |
| <a name="input_associate_with_subnet"></a> [associate\_with\_subnet](#input\_associate\_with\_subnet) | Whether the NSG should be associated with a subnet | `bool` | `false` | no |
| <a name="input_custom_nsg_rules"></a> [custom\_nsg\_rules](#input\_custom\_nsg\_rules) | Custom NSG rules to apply if apply\_standard\_rules is set to false. | <pre>map(object({<br/>    name                                       = optional(string)<br/>    priority                                   = optional(number)<br/>    direction                                  = optional(string)<br/>    access                                     = optional(string)<br/>    protocol                                   = optional(string)<br/>    source_port_range                          = optional(string)<br/>    sources_port_ranges                        = optional(list(string))<br/>    destination_port_range                     = optional(string)<br/>    destination_port_ranges                    = optional(list(string))<br/>    source_address_prefix                      = optional(string)<br/>    source_address_prefixes                    = optional(list(string))<br/>    destination_address_prefix                 = optional(string)<br/>    destination_address_prefixes               = optional(list(string))<br/>    source_application_security_group_ids      = optional(list(string))<br/>    destination_application_security_group_ids = optional(list(string))<br/>    description                                = optional(string)<br/>    resource_group_name                        = optional(string)<br/>    network_security_group_name                = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_nic_id"></a> [nic\_id](#input\_nic\_id) | The ID of a NIC if the association is triggered | `string` | `null` | no |
| <a name="input_nsg_name"></a> [nsg\_name](#input\_nsg\_name) | The name of the resource to be created | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_standard_nsg_rules"></a> [standard\_nsg\_rules](#input\_standard\_nsg\_rules) | Standard NSG rules supplied by the module, these are applied by default | <pre>map(object({<br/>    name                                       = optional(string)<br/>    priority                                   = optional(number)<br/>    direction                                  = optional(string)<br/>    access                                     = optional(string)<br/>    protocol                                   = optional(string)<br/>    source_port_range                          = optional(string)<br/>    sources_port_ranges                        = optional(list(string))<br/>    destination_port_range                     = optional(string)<br/>    destination_port_ranges                    = optional(list(string))<br/>    source_address_prefix                      = optional(string)<br/>    source_address_prefixes                    = optional(list(string))<br/>    destination_address_prefix                 = optional(string)<br/>    destination_address_prefixes               = optional(list(string))<br/>    source_application_security_group_ids      = optional(list(string))<br/>    destination_application_security_group_ids = optional(list(string))<br/>    description                                = optional(string)<br/>    resource_group_name                        = optional(string)<br/>    network_security_group_name                = optional(string)<br/>  }))</pre> | <pre>{<br/>  "AllowAzureActiveDirectoryOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureActiveDirectory",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4050,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowAzureBackupOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureBackup",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4045,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowAzureCloudOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureCloud",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4040,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowAzureKeyVaultOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureKeyVault",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4035,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowAzureLoadBalancerOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureLoadBalancer",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4030,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowAzureMonitorOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureMonitor",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4025,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowAzureStorageOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "Storage",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4020,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "DenyAllInbound": {<br/>    "access": "Deny",<br/>    "destination_address_prefix": "*",<br/>    "destination_port_range": "*",<br/>    "direction": "Inbound",<br/>    "priority": 4096,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  }<br/>}</pre> | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A map of subnet ids to pass | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags assigned to the resource | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_final_nsg_rules"></a> [final\_nsg\_rules](#output\_final\_nsg\_rules) | The NSG rules list assigned as a variable |
| <a name="output_nsg_id"></a> [nsg\_id](#output\_nsg\_id) | The ID of the NSG |
| <a name="output_nsg_name"></a> [nsg\_name](#output\_nsg\_name) | The name of the NSG |
| <a name="output_nsg_network_interface_security_group_association_ids"></a> [nsg\_network\_interface\_security\_group\_association\_ids](#output\_nsg\_network\_interface\_security\_group\_association\_ids) | The IDs of the Network Interface Security Group Associations |
| <a name="output_nsg_rg_name"></a> [nsg\_rg\_name](#output\_nsg\_rg\_name) | The name of the resource group the NSG is in |
| <a name="output_nsg_subnet_association_ids"></a> [nsg\_subnet\_association\_ids](#output\_nsg\_subnet\_association\_ids) | The IDs of the Subnet Network Security Group Associations |
