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

resource "azurerm_subnet" "gatewaysubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [ var.gatewaysubnet_cidr ]
}

resource "azurerm_public_ip" "example" {
  name                = "test"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "example" {
  name                = "dev-vng"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.example.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gatewaysubnet.id
  }

}
