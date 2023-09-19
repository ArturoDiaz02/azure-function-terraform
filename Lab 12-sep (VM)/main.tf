# Definición del provider que ocuparemos
provider "azurerm" {
  features {}
}

# Se crea el grupo de recursos, al cual se asociarán los demás recursos
resource "azurerm_resource_group" "resource_group" {
  name     = var.name_function
  location = var.location
}

#Se crea el grupo de seguridad
resource "azurerm_network_security_group" "network_security_group" {
  name                = "example-security-group"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

#Se crea la regla de seguridad para el puerto 22
resource "azurerm_network_security_rule" "ssh" {
  name                        = "AllowSSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.network_security_group.name
}

#Se crea la red virtual
resource "azurerm_virtual_network" "virtual_network" {
  name                = "example-network"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  tags = {
    environment = "Production"
  }
}

#Se crea el subred
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

#Se crea la ip publica
resource "azurerm_public_ip" "public_ip" {
  name                = "example-public-ip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
}

#Se crea la interfaz de red
resource "azurerm_network_interface" "network_interface" {
  name                = "example-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.public_ip.id
  }
}

#Se crea la maquina virtual
resource "azurerm_linux_virtual_machine" "VM" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_F2"
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.network_interface.id,
  ]

  #Se crea la llave ssh
  admin_ssh_key {
    username   = var.username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  #Se crea el disco duro
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  #Se crea la imagen de la maquina virtual
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}