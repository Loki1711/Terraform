provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "RGname" {}
variable "location" {}
variable "tags" {
  type = map(any)
}
variable "VNET" {}
variable "address_space" {}
variable "subnet" {}
variable "PIP" {}
variable "NIC" {}
variable "NSG" {}
variable "VM" {}
variable "hostname" {}
variable "username" {}
variable "passwd" {}
