variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
  validation {
    condition     = length(var.rg_name) > 1 && length(var.rg_name) <= 24
    error_message = "Resource group name is not valid."
  }
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "tags" {
  description = "The tags assigned to the resource"
  type        = map(string)
}

variable "nsg_name" {
  description = "The name of the resource to be created"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for the NSG to be attached to"
  type        = string
}
