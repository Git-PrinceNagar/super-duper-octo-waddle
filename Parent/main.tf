module "rg" {
  source              = "../Modules/azurerm_resource_group"
  resource_group_name = "rg"
  location            = "centralus"
}

module "vnet" {
  source     = "../Modules/azurerm_virtual_network"
  depends_on = [module.rg]

  vnet_name           = "vnet"
  location            = "centralus"
  resource_group_name = "rg"
  address_space       = ["10.0.0.0/16"]
}


module "frontend_subnet" {
  source              = "../Modules/azurerm_subnet"
  depends_on          = [module.vnet]
  subnet_name         = "subnet-frontend"
  resource_group_name = "rg"
  vnet_name           = "vnet"
  address_prefixes    = ["10.0.1.0/24"]
}

module "public_ip_frontend" {
  source     = "../Modules/azurerm_public_ip"
  depends_on = [module.rg]

  public_ip_name      = "pip-frontend"
  resource_group_name = "rg"
  location            = "centralus"
  allocation_method   = "Static"
}

module "vm_frontend" {
  source                          = "../Modules/azurerm_linux_virtual_machine"
  depends_on                      = [module.frontend_subnet, module.public_ip_frontend]
  vm_name                         = "vm-frontend"
  resource_group_name             = "rg"
  location                        = "centralus"
  vm_size                         = "Standard_F2"
  admin_username                  = "pvm-username"
  admin_password                  = "password-PVM" #Required when disable_password_authentication = false
  image_publisher                 = "Canonical"
  image_offer                     = "0001-com-ubuntu-server-jammy"
  image_sku                       = "22_04-lts"
  image_version                   = "latest"
  network_interface_name          = "nic-frontend"
  vnet_name                       = "vnet"
  subnet_name                     = "subnet-frontend"
  public_ip_name                  = "pip-frontend"
  os_disk_caching                 = "ReadWrite"
  os_disk_storage_account_type    = "Standard_LRS"
  disable_password_authentication = false
}



# module "backend_subnet" {
#   source              = "../Modules/azurerm_subnet"
#   depends_on          = [module.vnet]
#   subnet_name         = "subnet-backend"
#   resource_group_name = "rg"
#   vnet_name           = "vnet"
#   address_prefixes    = ["10.0.2.0/24"]
# }

# module "public_ip_backend" {
#   source     = "../Modules/azurerm_public_ip"
#   depends_on = [module.rg]

#   pip_name            = "pip-backend"
#   resource_group_name = "rg"
#   location            = "centralus"
#   allocation_method   = "Static"

# }

# module "vm_backend" {
#   source     = "../Modules/azurerm_linux_virtual_machine"
#   depends_on = [module.vnet]

#   nic_name                        = "nic-backend"
#   ip_configuration_name           = "ip-backend"
#   private_ip_address_allocation   = "Dynamic"
#   vm_name                         = "vm-backend"
#   vm_size                         = "Standard_F2"
#   admin_username                  = "adminuser"
#   admin_password                  = "DevOps!2025" #Required when disable_password_authentication = false
#   disable_password_authentication = false
#   os_disk_caching                 = "ReadWrite"
#   os_disk_storage_account_type    = "Standard_LRS"
#   image_publisher                 = "Canonical"
#   image_offer                     = "0001-com-ubuntu-server-jammy"
#   image_sku                       = "22_04-lts"
#   image_version                   = "latest"
#   resource_group_name             = "rg"
#   location                        = "centralus"
#   vnet_name                       = "vnet"
#   b_subnet_name                   = "subnet-backend"
#   b_pip_name                      = "pip-backend"
# }


module "sql_server" {
  source                       = "../Modules/sql_server"
  depends_on                   = [module.rg]
  sql_server_name              = "sql-server-name"
  resource_group_name          = "rg"
  location                     = "centralus"
  administrator_login          = "sqldb-username"
  administrator_login_password = "password-PVM" 
}

module "sql_database" {
  source              = "../Modules/sql_database"
  depends_on          = [module.sql_server]
  db_name             = "sql_db"
  server_name         = "sql-server-name"
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  license_type        = "LicenseIncluded"
  max_size_gb         = 2
  sku_name            = "S0"
  resource_group_name = "rg"
}


