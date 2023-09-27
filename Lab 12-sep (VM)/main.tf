# Definición del provider que ocuparemos
provider "azurerm" {
  features {}
}

# Se crea el grupo de recursos, al cual se asociarán los demás recursos
resource "azurerm_resource_group" "vm" {
  name     = var.name_machine
  location = var.location
}


#Se crea la red
resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.name_machine}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm.location
  resource_group_name = azurerm_resource_group.vm.name
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  tags = {
    environment = "Production"
  }
}

#Se crea la subred
resource "azurerm_subnet" "internal_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.vm.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

module "vm" {
  source = "./modules/vm"
  name_machine = var.name_machine
  location = azurerm_resource_group.vm.location
  resource_group_name = azurerm_resource_group.vm.name
  subnet_id = azurerm_subnet.internal_subnet.id
  username = var.username
}