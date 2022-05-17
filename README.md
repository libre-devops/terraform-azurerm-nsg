```hcl
module "rg" {
  source = "registry.terraform.io/libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-build" // rg-ldo-euw-dev-build
  location = local.location                                            // compares var.loc with the var.regions var to match a long-hand name, in this case, "euw", so "westeurope"
  tags     = local.tags

  #  lock_level = "CanNotDelete" // Do not set this value to skip lock
}

module "network" {
  source = "registry.terraform.io/libre-devops/network/azurerm"

  rg_name  = module.rg.rg_name // rg-ldo-euw-dev-build
  location = module.rg.rg_location
  tags     = local.tags

  vnet_name     = "vnet-${var.short}-${var.loc}-${terraform.workspace}-01" // vnet-ldo-euw-dev-01
  vnet_location = module.network.vnet_location

  address_space   = ["10.0.0.0/16"]
  subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names    = ["sn1-${module.network.vnet_name}", "sn2-${module.network.vnet_name}", "sn3-${module.network.vnet_name}"] //sn1-vnet-ldo-euw-dev-01
  subnet_service_endpoints = {
    "sn1-${module.network.vnet_name}" = ["Microsoft.Storage"] // Adds extra subnet endpoints to sn1-vnet-ldo-euw-dev-01
    "sn2-${module.network.vnet_name}" = ["Microsoft.Storage", "Microsoft.Sql"], // Adds extra subnet endpoints to sn2-vnet-ldo-euw-dev-01
    "sn3-${module.network.vnet_name}" = ["Microsoft.AzureActiveDirectory"] // Adds extra subnet endpoints to sn3-vnet-ldo-euw-dev-01
  }
}

module "nsg" {
  source = "registry.terraform.io/libre-devops/network/azurerm"

  rg_name   = module.rg.rg_name
  location  = module.rg.rg_location
  nsg_name  = "nsg-${var.short}-${var.loc}-${terraform.workspace}"
  subnet_id = element(module.network.subnets_ids, 0)

  tags = module.rg.rg_tags
}
```

For a full example build, check out the [Libre DevOps Website](https://www.libredevops.org/quickstart/utils/terraform/using-lbdo-tf-modules-example.html)****

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
