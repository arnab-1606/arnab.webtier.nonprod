// create vNet

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Production"
    AppName     = "TestApp"
    CostCode    = "C000001"
  }
}

//create subnet

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/28"]
}
