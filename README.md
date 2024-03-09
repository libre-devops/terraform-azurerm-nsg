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
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_standard_rules"></a> [apply\_standard\_rules](#input\_apply\_standard\_rules) | Whether to apply the standard NSG rules or not. | `bool` | `true` | no |
| <a name="input_associate_with_nic"></a> [associate\_with\_nic](#input\_associate\_with\_nic) | Whether the NSG should be associated with a nic | `bool` | `false` | no |
| <a name="input_associate_with_subnet"></a> [associate\_with\_subnet](#input\_associate\_with\_subnet) | Whether the NSG should be associated with a subnet | `bool` | `false` | no |
| <a name="input_custom_nsg_rules"></a> [custom\_nsg\_rules](#input\_custom\_nsg\_rules) | Custom NSG rules to apply if apply\_standard\_rules is set to false. | <pre>map(object({<br>    priority                   = number<br>    direction                  = string<br>    access                     = string<br>    protocol                   = string<br>    source_port_range          = string<br>    destination_port_range     = string<br>    source_address_prefix      = string<br>    destination_address_prefix = string<br>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_nic_id"></a> [nic\_id](#input\_nic\_id) | The ID of a NIC if the association is triggered | `string` | `null` | no |
| <a name="input_nsg_name"></a> [nsg\_name](#input\_nsg\_name) | The name of the resource to be created | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet for the NSG to be attached to | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags assigned to the resource | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_final_nsg_rules"></a> [final\_nsg\_rules](#output\_final\_nsg\_rules) | The NSG rules list assigned as a variable |
| <a name="output_nsg_id"></a> [nsg\_id](#output\_nsg\_id) | The ID of the NSG |
| <a name="output_nsg_name"></a> [nsg\_name](#output\_nsg\_name) | The name of the NSG |
| <a name="output_nsg_network_interface_security_group_association_ids"></a> [nsg\_network\_interface\_security\_group\_association\_ids](#output\_nsg\_network\_interface\_security\_group\_association\_ids) | The IDs of the Network Interface Security Group Associations |
| <a name="output_nsg_rg_name"></a> [nsg\_rg\_name](#output\_nsg\_rg\_name) | The name of the resource group the nsg is in |
| <a name="output_nsg_subnet_association_ids"></a> [nsg\_subnet\_association\_ids](#output\_nsg\_subnet\_association\_ids) | The IDs of the Subnet Network Security Group Associations |
