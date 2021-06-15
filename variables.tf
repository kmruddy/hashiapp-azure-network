variable "subscription_id" {
  description = "The subscription ID of the Azure resources to be used."
}

variable "client_id" {
  description = "The client ID of the Azure user to be used."
}

variable "client_secret" {
  description = "The client secret or password of the Azure user to be used."
}

variable "tenant_id" {
  description = "The tenant ID of the Azure resources to be used."
}

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "tfver" {
  description = "Terraform version in use."
}
