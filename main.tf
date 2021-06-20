terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "networkrg" {
  name     = "rg-network"
  location = var.az_region
}

resource "azurerm_virtual_network" "vnet-network" {
  name                = "vnet-network"
  location            = azurerm_resource_group.networkrg.location
  resource_group_name = azurerm_resource_group.networkrg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "snet-app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.networkrg.name
  virtual_network_name = azurerm_virtual_network.vnet-network.name
  address_prefixes     = ["10.0.1.0/29"]
}

resource "azurerm_network_security_group" "nsg-app" {
  name                = "nsg-app"
  resource_group_name = azurerm_resource_group.networkrg.name
  location            = azurerm_resource_group.networkrg.location

  security_rule = []
}

resource "azurerm_network_security_rule" "nsg-rule-SSH" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.networkrg.name
  network_security_group_name = azurerm_network_security_group.nsg-app.name
}

resource "azurerm_public_ip" "pubip-app" {
  name                = "pubip-app"
  resource_group_name = azurerm_resource_group.networkrg.name
  location            = azurerm_resource_group.networkrg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic-app" {
  name                = "nic-app"
  location            = azurerm_resource_group.networkrg.location
  resource_group_name = azurerm_resource_group.networkrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet-app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubip-app.id
  }
}

resource "azurerm_network_interface_security_group_association" "snet-app-nsg-asoc" {
  network_interface_id      = azurerm_network_interface.nic-app.id
  network_security_group_id = azurerm_network_security_group.nsg-app.id
}

resource "azurerm_linux_virtual_machine" "app" {
  name                  = "vm-app"
  resource_group_name   = azurerm_resource_group.networkrg.name
  location              = azurerm_resource_group.networkrg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic-app.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
