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
