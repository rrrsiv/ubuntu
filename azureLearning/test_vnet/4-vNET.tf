resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-${var.env_name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [ var.vnet_cidr ]
#   dns_servers         = ["10.10.0.4", "10.10.0.5"]

  tags = {
    environment = var.env_name
  }
}
resource "azurerm_subnet" "subnet1" {
  name                 = "${var.project_name}-${var.env_name}-subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [ var.subnet1_cidr ]

}
resource "azurerm_subnet" "subnet2" {
  name                 = "${var.project_name}-${var.env_name}-subnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [ var.subnet2_cidr ]

}