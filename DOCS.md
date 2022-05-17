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
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_subnet_network_security_group_association.nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_nsg_name"></a> [nsg\_name](#input\_nsg\_name) | The name of the resource to be created | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_standard_nsg_list"></a> [standard\_nsg\_list](#input\_standard\_nsg\_list) | call module with standard\_nsg\_list = {} to disable standard rules | `map` | <pre>{<br>  "AllowAzureActiveDirectoryOutbound": {<br>    "access": "Allow",<br>    "destination_address_prefix": "AzureActiveDirectory",<br>    "direction": "Outbound",<br>    "priority": "4050"<br>  },<br>  "AllowAzureBackupOutbound": {<br>    "access": "Allow",<br>    "destination_address_prefix": "AzureBackup",<br>    "direction": "Outbound",<br>    "priority": "4045"<br>  },<br>  "AllowAzureCloudOutbound": {<br>    "access": "Allow",<br>    "destination_address_prefix": "AzureCloud",<br>    "direction": "Outbound",<br>    "priority": "4040"<br>  },<br>  "AllowAzureKeyVaultOutbound": {<br>    "access": "Allow",<br>    "destination_address_prefix": "AzureKeyVault",<br>    "direction": "Outbound",<br>    "priority": "4035"<br>  },<br>  "AllowAzureLoadBalancerOutbound": {<br>    "access": "Allow",<br>    "destination_address_prefix": "AzureLoadBalancer",<br>    "direction": "Outbound",<br>    "priority": "4030"<br>  },<br>  "AllowAzureMonitorOutbound": {<br>    "access": "Allow",<br>    "destination_address_prefix": "AzureMonitor",<br>    "direction": "Outbound",<br>    "priority": "4025"<br>  },<br>  "AllowAzureStorageOutbound": {<br>    "access": "Allow",<br>    "destination_address_prefix": "Storage",<br>    "direction": "Outbound",<br>    "priority": "4020"<br>  },<br>  "DenyAllInbound": {<br>    "access": "Deny",<br>    "destination_address_prefix": "*",<br>    "direction": "Inbound",<br>    "priority": "4096"<br>  }<br>}</pre> | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet for the NSG to be attached to | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags assigned to the resource | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsg_id"></a> [nsg\_id](#output\_nsg\_id) | n/a |
| <a name="output_nsg_name"></a> [nsg\_name](#output\_nsg\_name) | n/a |
