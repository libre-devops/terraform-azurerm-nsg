# Plan-time tests for the module. The azurerm provider is mocked, so no credentials, no
# features block, and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001"
  location          = "uksouth"
  name              = "nsg-ldo-uks-tst-001"
}

run "creates_nsg_with_secure_defaults" {
  command = plan

  # The eight secure default rules are applied out of the box.
  assert {
    condition     = length(azurerm_network_security_rule.this) == 8
    error_message = "The eight default rules should be created when apply_default_rules is true and no custom rules are given."
  }

  assert {
    condition     = azurerm_network_security_rule.this["DenyAllInbound"].access == "Deny" && azurerm_network_security_rule.this["DenyAllInbound"].priority == 4096
    error_message = "The default set should include an explicit inbound deny at priority 4096."
  }

  assert {
    condition     = output.resource_group_name == "rg-ldo-uks-tst-001"
    error_message = "resource_group_name should be parsed from resource_group_id."
  }
}

run "custom_rule_merges_with_defaults" {
  command = plan

  variables {
    security_rules = {
      "AllowHttpsInbound" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }

  assert {
    condition     = length(azurerm_network_security_rule.this) == 9
    error_message = "A custom rule should merge on top of the eight defaults (nine total)."
  }
}

run "custom_rule_overrides_default_by_name" {
  command = plan

  variables {
    security_rules = {
      # Same key as a default: overrides it rather than adding, so the count stays at eight.
      "DenyAllInbound" = {
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }
    }
  }

  assert {
    condition     = length(azurerm_network_security_rule.this) == 8 && azurerm_network_security_rule.this["DenyAllInbound"].access == "Allow"
    error_message = "A custom rule with a default's name should override it, keeping the count at eight."
  }
}

run "defaults_can_be_disabled" {
  command = plan

  variables {
    apply_default_rules = false
    security_rules = {
      "AllowHttpsInbound" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }

  assert {
    condition     = length(azurerm_network_security_rule.this) == 1
    error_message = "With apply_default_rules = false, only the custom rules should be created."
  }
}

run "associations_created_from_maps" {
  command = plan

  variables {
    subnet_associations = {
      "snet-app" = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-app"
    }
    network_interface_associations = {
      "nic-app" = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/networkInterfaces/nic-app"
    }
  }

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.this) == 1 && length(azurerm_network_interface_security_group_association.this) == 1
    error_message = "Subnet and NIC associations should be created from the maps."
  }
}

run "rejects_priority_out_of_range" {
  command = plan

  variables {
    security_rules = {
      "bad" = {
        priority                   = 5000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }

  expect_failures = [var.security_rules]
}

run "rejects_invalid_protocol" {
  command = plan

  variables {
    security_rules = {
      "bad" = {
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "HTTP"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }

  expect_failures = [var.security_rules]
}

run "rejects_invalid_direction" {
  command = plan

  variables {
    security_rules = {
      "bad" = {
        priority                   = 300
        direction                  = "Sideways"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }

  expect_failures = [var.security_rules]
}
