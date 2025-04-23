locals {
  final_nsg_rules = var.apply_standard_rules == true ? merge(var.standard_nsg_rules, var.custom_nsg_rules) : merge(var.custom_nsg_rules, {})
}