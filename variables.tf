variable "apply_standard_rules" {
  description = "Whether to apply the standard NSG rules or not."
  type        = bool
  default     = true
}

variable "associate_with_nic" {
  type        = bool
  description = "Whether the NSG should be associated with a nic"
  default     = false
}

variable "associate_with_subnet" {
  type        = bool
  description = "Whether the NSG should be associated with a subnet"
  default     = false
}

variable "custom_nsg_rules" {
  description = "Custom NSG rules to apply if apply_standard_rules is set to false."
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {}
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "nic_id" {
  type        = string
  description = "The ID of a NIC if the association is triggered"
  default     = null
}

variable "nsg_name" {
  description = "The name of the resource to be created"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for the NSG to be attached to"
  type        = string
  default     = null
}

variable "tags" {
  description = "The tags assigned to the resource"
  type        = map(string)
}
