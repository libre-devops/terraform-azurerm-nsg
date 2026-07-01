locals {
  location   = lookup(var.regions, var.loc, "uksouth")
  rg_name    = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
  vnet_name  = "vnet-${var.short}-${var.loc}-${terraform.workspace}-002"
  nsg_name   = "nsg-${var.short}-${var.loc}-${terraform.workspace}-002"
  asg_name   = "asg-${var.short}-${var.loc}-${terraform.workspace}-002"
  nic_name   = "nic-${var.short}-${var.loc}-${terraform.workspace}-002"
  subnet_app = "snet-app-${local.vnet_name}"
  subnet_web = "snet-web-${local.vnet_name}"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  environment     = "prd"
  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
  additional_tags = { Application = "terraform-azurerm-nsg" }
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

# Carve the subnets from one base CIDR: app and web pack sequentially.
module "subnet_calculator" {
  source  = "libre-devops/subnet-calculator/azurerm"
  version = "~> 4.0"

  base_cidr = "10.70.0.0/16"
  vnet_name = local.vnet_name
  subnets = [
    { purpose = "app", size = 24 },
    { purpose = "web", size = 24 },
  ]
}

module "network" {
  source  = "libre-devops/network/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  vnet_name     = local.vnet_name
  address_space = [module.subnet_calculator.base_cidr]
  subnets       = module.subnet_calculator.network_subnets
}

# An application security group so a rule can target a workload by ASG rather than by address.
resource "azurerm_application_security_group" "this" {
  resource_group_name = module.rg.names[local.rg_name]
  location            = local.location
  tags                = module.tags.tags

  name = local.asg_name
}

# A standalone NIC in the app subnet, so the NSG can also be associated at the NIC level
# (exercising network_interface_associations alongside the subnet associations).
resource "azurerm_network_interface" "this" {
  resource_group_name = module.rg.names[local.rg_name]
  location            = local.location
  tags                = module.tags.tags

  name = local.nic_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.subnet_ids[local.subnet_app]
    private_ip_address_allocation = "Dynamic"
  }
}

# Complete call: the secure defaults plus custom rules that exercise the fuller surface (a plural
# destination_port_ranges, an application security group destination, and an override of a default
# rule by name), associated with both subnets.
module "nsg" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  name = local.nsg_name

  # Merge the module's secure defaults in with the rules below (this is the default). Set it to false
  # to drop the module defaults and manage the entire rule set yourself via security_rules.
  apply_default_rules = true

  security_rules = {
    # HTTPS in from the VNet only.
    "AllowHttpsInbound" = {
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow HTTPS from within the virtual network."
    }
    # Web ports to a workload identified by application security group (plural ports).
    "AllowWebToAsgInbound" = {
      priority                                   = 210
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_ranges                    = ["80", "443", "8080"]
      source_address_prefix                      = "VirtualNetwork"
      destination_application_security_group_ids = [azurerm_application_security_group.this.id]
      description                                = "Allow web ports to the application security group."
    }
    # Override a default by name: relax the catch-all inbound deny to permit intra-VNet traffic.
    "DenyAllInbound" = {
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      description                = "Overrides the default catch-all deny to allow intra-VNet traffic."
    }
  }

  subnet_associations = {
    (local.subnet_app) = module.network.subnet_ids[local.subnet_app]
    (local.subnet_web) = module.network.subnet_ids[local.subnet_web]
  }

  network_interface_associations = {
    (local.nic_name) = azurerm_network_interface.this.id
  }
}
