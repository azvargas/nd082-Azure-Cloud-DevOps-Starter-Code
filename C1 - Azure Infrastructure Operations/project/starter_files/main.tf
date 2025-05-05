# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  features {}
}

# Create resource group
# If this script will run using a Udacity subscription, the "data" object defined below should be used
# instead of the "resource" object, as Udacity does not allow the creation os new resource groups.

resource "azurerm_resource_group" "main" {
  name     = "Azuredevops"
  location = var.location
}

#data "azurerm_resource_group" "main" {
#  name     = "Azuredevops"
#  location = var.location
#}

# Create virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.id
  tags                = { 
    project = var.item_tag
  }
}

# Create a subnet
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.id
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a network security group
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  resource_group_name = azurerm_resource_group.main.id
  location            = var.location
  security_rule {
    name = "BlockInternetTraffic"
    priority = 100
    direction = "Inbound"
    access = "Deny"
    protocol = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"    
  }
  security_rule {
    name = "AllowLocalTrafficInbound"
    priority = 101
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"    
  }
  security_rule {
    name = "AllowLocalTrafficOutbound"
    priority = 102
    direction = "Outbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"    
  }
  security_rule {
    name = "HttpLoadBalancer"
    priority = 103
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.2.0/24"    
  }
  tags                = { 
    project = var.item_tag
  }
}

# Create a network interface
resource "azurerm_network_interface" "main" {
  count               = var.count_vms
  name                = "${var.prefix}-nic${count.index}"
  resource_group_name = azurerm_resource_group.main.id
  location            = var.location
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
  tags                = { 
    project = var.item_tag
  }
}

# Associate the NICs to the NSG
resource "azurerm_network_interface_security_group_association" "main" {
  count = var.count_vms
  network_interface_id = azurerm_network_interface.main[count.index].id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Create a public IP
resource "azurerm_public_ip" "main" {
	name				        = "${var.prefix}-publicip"
	resource_group_name = azurerm_resource_group.main.id
	location			      = var.location
	allocation_method   = "Static"
  tags                = { 
    project = var.item_tag
  }
}

# Create a load balancer
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  resource_group_name = azurerm_resource_group.main.id
  location            = var.location
  frontend_ip_configuration {
    name                 = "LBPublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
  tags                = { 
    project = var.item_tag
  }
}

# Create a load balancer backend pool
resource "azurerm_lb_backend_address_pool" "main" {
  name = "${var.prefix}-lb-backpool"
  loadbalancer_id = azurerm_lb.main.id
}

# Associate NICs with the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count = var.count_vms
  network_interface_id = azurerm_network_interface.main[count.index].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  ip_configuration_name = "internal"
}

# Create an availavility set
resource "azurerm_availability_set" "main" {
  name = "${var.prefix}-avset"
  resource_group_name = azurerm_resource_group.main.id
  location            = var.location
  tags                = { 
    project = var.item_tag
  }
}

data "azurerm_image" "main" {
  name                = "myPackerImage"
  resource_group_name = "Azuredevops"
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.count_vms
  name                            = "${var.prefix}-vm${count.index}"
  resource_group_name             = azurerm_resource_group.main.id
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  source_image_id                 = data.azurerm_image.main.id
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags                = { 
    project = var.item_tag
  }
}