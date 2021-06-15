terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "1.44.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

data "terraform_remote_state" "haarg" {
  backend = "remote"

  config = {
    organization = "TPMM-Org"
    workspaces = {
      name = "hashiapp-azure-resourcegroup"
    }
  }
}

data "azurerm_resource_group" "demo_rg" {
  name = data.terraform_remote_state.haarg.outputs.rg_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${data.terraform_remote_state.haarg.outputs.prefix}-vnet"
  location            = data.azurerm_resource_group.demo_rg.location
  address_space       = [var.address_space]
  resource_group_name = data.azurerm_resource_group.demo_rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${data.terraform_remote_state.haarg.outputs.prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.demo_rg.name
  address_prefix       = var.subnet_prefix
}

resource "azurerm_network_security_group" "happ_sg" {
  name                = "${data.terraform_remote_state.haarg.outputs.prefix}-sg"
  location            = data.azurerm_resource_group.demo_rg.location
  resource_group_name = data.azurerm_resource_group.demo_rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "happ_nic" {
  name                      = "${data.terraform_remote_state.haarg.outputs.prefix}-happ-nic"
  location                  = data.azurerm_resource_group.demo_rg.location
  resource_group_name       = data.azurerm_resource_group.demo_rg.name
  network_security_group_id = azurerm_network_security_group.happ_sg.id

  ip_configuration {
    name                          = "${data.terraform_remote_state.haarg.outputs.prefix}ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.happ_pip.id
  }
}

resource "azurerm_public_ip" "happ_pip" {
  name                = "${data.terraform_remote_state.haarg.outputs.prefix}-ip"
  location            = data.azurerm_resource_group.demo_rg.location
  resource_group_name = data.azurerm_resource_group.demo_rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${data.terraform_remote_state.haarg.outputs.prefix}-app"
}
