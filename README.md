<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Network Security Group

Creates an Azure network security group with secure default rules, your own rules, and optional subnet and NIC associations.

[![CI](https://github.com/libre-devops/terraform-azurerm-nsg/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-nsg/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-nsg?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-nsg/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-nsg)](./LICENSE)

---

## Overview

A network security group with a secure baseline out of the box: an explicit catch-all inbound deny
plus curated outbound allows to essential Azure service tags (`apply_default_rules`, on by default).
Add your own rules in `security_rules`, keyed by name; a custom rule with a default's name overrides
it. Rules are **standalone** `azurerm_network_security_rule` resources rather than inline
`security_rule` blocks, so they are non-authoritative: a rule added out of band (for example a
temporary "allow my IP" rule) is left in place rather than wiped on the next apply. Optionally attach
the NSG to subnets and/or NICs: those are owned elsewhere, and this module **associates them by id**,
keyed by name so the ids can be **computed in the same apply** without breaking `for_each`. Composes
naturally with the `network`/`subnet` modules.

## Usage

```hcl
module "nsg" {
  source  = "libre-devops/nsg/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids["rg-ldo-uks-prd-001"]
  location          = "uksouth"
  tags              = module.tags.tags

  name = "nsg-ldo-uks-prd-001"

  # Merged on top of the secure defaults (an inbound deny + Azure service-tag outbound allows).
  security_rules = {
    "AllowHttpsInbound" = {
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
    }
  }

  subnet_associations = { "snet-app-vnet-ldo-uks-prd-001" = module.network.subnet_ids["snet-app-vnet-ldo-uks-prd-001"] }
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - an NSG with the secure defaults, associated with one
  subnet.
- [`examples/complete`](./examples/complete) - an NSG with several custom rules (including one that
  overrides a default and one using an application security group), associated with multiple subnets
  from a `subnet-calculator`-driven network.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the recipes
wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh` (install or force-update LibreDevOpsHelpers from
PSGallery), `just validate`, `just scan` (Trivy only), `just pwsh-analyze` (PSScriptAnalyzer only),
`just plan`, `just apply`, `just destroy`, `just e2e`, `just test`, and `just docs` (the
plan/apply/destroy recipes mirror the action, including the storage firewall dance; `just e2e`
applies an example then always destroys it, defaulting to `minimal`, so nothing is left running).
Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) (the
machine-applied source of truth, passed to Trivy with `--ignorefile`) and are mirrored in the table
below so the reason is auditable.

| Trivy ID | Resource | Finding | Justification |
|----------|----------|---------|---------------|
| _None_   |          |         |               |

To add an exception: add an entry to `.trivyignore.yaml` (`id`, optional `paths` to scope it, and a
`statement` recording why), then add a matching row here. Where the finding is out of this module's
scope, point the justification at the Libre DevOps module that does address it (for example the
private-endpoint module). Both the file and this table are reviewed in the pull request.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_default_rules"></a> [apply\_default\_rules](#input\_apply\_default\_rules) | Whether to merge the module's secure default rules (default\_rules) in with your security\_rules. Custom rules of the same name override a default. Set to false to manage the rule set entirely yourself. | `bool` | `true` | no |
| <a name="input_default_rules"></a> [default\_rules](#input\_default\_rules) | The module's secure default rules, merged in when apply\_default\_rules is true: an explicit inbound deny (priority 4096) plus curated outbound allows to essential Azure service tags. Override an individual default by giving a security\_rules entry the same key, or replace this whole map to change the baseline. | <pre>map(object({<br/>    priority                                   = number<br/>    direction                                  = string<br/>    access                                     = string<br/>    protocol                                   = string<br/>    description                                = optional(string)<br/>    source_port_range                          = optional(string)<br/>    source_port_ranges                         = optional(list(string))<br/>    destination_port_range                     = optional(string)<br/>    destination_port_ranges                    = optional(list(string))<br/>    source_address_prefix                      = optional(string)<br/>    source_address_prefixes                    = optional(list(string))<br/>    destination_address_prefix                 = optional(string)<br/>    destination_address_prefixes               = optional(list(string))<br/>    source_application_security_group_ids      = optional(list(string))<br/>    destination_application_security_group_ids = optional(list(string))<br/>  }))</pre> | <pre>{<br/>  "AllowAzureActiveDirectoryOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureActiveDirectory",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4050,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowAzureBackupOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureBackup",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4045,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowAzureCloudOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureCloud",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4040,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowAzureKeyVaultOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureKeyVault",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4035,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowAzureLoadBalancerOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureLoadBalancer",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4030,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowAzureMonitorOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "AzureMonitor",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4025,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "AllowStorageOutbound": {<br/>    "access": "Allow",<br/>    "destination_address_prefix": "Storage",<br/>    "destination_port_range": "*",<br/>    "direction": "Outbound",<br/>    "priority": 4020,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  },<br/>  "DenyAllInbound": {<br/>    "access": "Deny",<br/>    "description": "Explicit catch-all inbound deny; allow only what you need above it.",<br/>    "destination_address_prefix": "*",<br/>    "destination_port_range": "*",<br/>    "direction": "Inbound",<br/>    "priority": 4096,<br/>    "protocol": "*",<br/>    "source_address_prefix": "*",<br/>    "source_port_range": "*"<br/>  }<br/>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the network security group. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the network security group. | `string` | n/a | yes |
| <a name="input_network_interface_associations"></a> [network\_interface\_associations](#input\_network\_interface\_associations) | Network interfaces to associate this NSG with, keyed by a logical name with the NIC id as the value (ids may be computed in the same apply; the static keys keep for\_each valid). Prefer subnet associations where you can. | `map(string)` | `{}` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource id of the resource group to create the NSG in. The name and subscription are parsed from it (pass the rg module's ids output). | `string` | n/a | yes |
| <a name="input_security_rules"></a> [security\_rules](#input\_security\_rules) | Your NSG rules, keyed by rule name. Merged over default\_rules (a rule here with the same name as a default overrides it). Each rule needs priority (100 to 4096, unique within the NSG), direction (Inbound/Outbound), access (Allow/Deny), and protocol (Tcp/Udp/Icmp/Esp/Ah/*); set exactly one of the singular or plural form for each of source\_port, destination\_port, source\_address, and destination\_address. | <pre>map(object({<br/>    priority                                   = number<br/>    direction                                  = string<br/>    access                                     = string<br/>    protocol                                   = string<br/>    description                                = optional(string)<br/>    source_port_range                          = optional(string)<br/>    source_port_ranges                         = optional(list(string))<br/>    destination_port_range                     = optional(string)<br/>    destination_port_ranges                    = optional(list(string))<br/>    source_address_prefix                      = optional(string)<br/>    source_address_prefixes                    = optional(list(string))<br/>    destination_address_prefix                 = optional(string)<br/>    destination_address_prefixes               = optional(list(string))<br/>    source_application_security_group_ids      = optional(list(string))<br/>    destination_application_security_group_ids = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_subnet_associations"></a> [subnet\_associations](#input\_subnet\_associations) | Subnets to associate this NSG with, keyed by subnet name with the subnet id as the value (ids may be computed in the same apply; the static keys keep for\_each valid). Leave empty to associate the NSG elsewhere, for example from the network or subnet module. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the network security group. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The id of the network security group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the network security group. |
| <a name="output_network_interface_association_ids"></a> [network\_interface\_association\_ids](#output\_network\_interface\_association\_ids) | Map of logical name to network interface NSG association id (only the associations this module creates). |
| <a name="output_network_security_group"></a> [network\_security\_group](#output\_network\_security\_group) | The full azurerm\_network\_security\_group resource. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name parsed from resource\_group\_id. |
| <a name="output_security_rule_ids"></a> [security\_rule\_ids](#output\_security\_rule\_ids) | Map of rule name to network security rule id (the effective merged rule set). |
| <a name="output_security_rules"></a> [security\_rules](#output\_security\_rules) | The effective merged rule set (defaults plus custom), keyed by rule name. |
| <a name="output_subnet_association_ids"></a> [subnet\_association\_ids](#output\_subnet\_association\_ids) | Map of subnet name to subnet NSG association id (only the associations this module creates). |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | Subscription id parsed from resource\_group\_id. |
<!-- END_TF_DOCS -->
