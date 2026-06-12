// Create Resource group

resource "azurerm_resource_group" "rg" {
  name     = "rg-webtier"
  location = var.location
}

######################################################
// Create public IP

resource "azurerm_public_ip" "pip_lb" {
  name                = "pip-lb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "Production"
    AppName     = "TestApp"
    CostCode    = "C00001"
  }
}

#####################################################
//Create Load Balancer

resource "azurerm_lb" "lb" {
  name                = "lb-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "fip_public"
    public_ip_address_id = azurerm_public_ip.pip_lb.id
  }
}

#####################################################
//Create Backend pool for load balancer

resource "azurerm_lb_backend_address_pool" "bepool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "bepool"
}


#####################################################
//Create health probe for load balancer

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "http-probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
}

#####################################################
//Create load balancer rule

resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "fip_public"
  probe_id                       = azurerm_lb_probe.probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
}

#####################################################
//Create VM scale set


resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = "vmss-web"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  sku                             = var.vm_size
  instances                       = 2
  admin_username                  = "adminuser"
  admin_password                  = "Password1234#"    //this 
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool.id]
      subnet_id                              = azurerm_subnet.subnet.id
    }
  }

  custom_data = base64encode(file("${path.module}/cloud-init.yaml"))
# custom_data = base64encode(file("${path.module}/cloud-init-container.yaml"))   // we need to use this for container app.currently commented
  health_probe_id = azurerm_lb_probe.probe.id
  upgrade_mode    = "Automatic"
  automatic_instance_repair {
    enabled      = true
    grace_period = "PT10M"
  }

}





















