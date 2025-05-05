# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "East US"
}

variable "admin_username" {
  description = "The admin username for the VM being created."
}

variable "admin_password" {
  description = "The password for the VM being created."
}

variable "count_vms" {
  description = "Number of virtual machines to deploy"
  default = 2
  validation {
    condition = var.count_vms < 6
    error_message = "No more than 5 VMs can be deployed"
  }
}

variable "item_tag" {
  description = "Label used for 'Project' tag"
  default = "Course2proj"
}

variable "subscription_id" {
  description = "Subscription ID to deploy"
}