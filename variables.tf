variable "subscription_id" {
  description = "Azure Subscription to deploy to."
  type        = string
}

variable "az_region" {
  description = "Azure region to deploy in."
  type        = string
  default     = "germanywestcentral"
}

variable "admin_username" {
  description = "username for the admin user"
  type        = string
}

variable "ssh_key" {
  description = "Admin SSH key location"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B1ls"
}
