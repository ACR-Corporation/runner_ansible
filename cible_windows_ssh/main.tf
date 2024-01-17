resource "azurerm_resource_group" "rg_cible" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet_cible" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg_cible.location
  resource_group_name = azurerm_resource_group.rg_cible.name
}

resource "azurerm_subnet" "subnet_cible" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg_cible.name
  virtual_network_name = azurerm_virtual_network.vnet_cible.name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_network_security_group" "nsg_cible" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg_cible.location
  resource_group_name = azurerm_resource_group.rg_cible.name
}

resource "azurerm_network_security_rule" "nsg_rule_ssh" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_cible.name
  network_security_group_name = azurerm_network_security_group.nsg_cible.name
}

resource "azurerm_network_security_rule" "nsg_rule_rdp" {
  name                        = "RDP"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_cible.name
  network_security_group_name = azurerm_network_security_group.nsg_cible.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet_cible.id
  network_security_group_id = azurerm_network_security_group.nsg_cible.id
}

resource "azurerm_public_ip" "pip_cible" {
  name                = "pip_cible"
  location            = azurerm_resource_group.rg_cible.location
  resource_group_name = azurerm_resource_group.rg_cible.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic_cible" {
  name                = "nic_cible"
  location            = azurerm_resource_group.rg_cible.location
  resource_group_name = azurerm_resource_group.rg_cible.name

  ip_configuration {
    name                          = "ipconfig_cible"
    subnet_id                     = azurerm_subnet.subnet_cible.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.4"
    public_ip_address_id          = azurerm_public_ip.pip_cible.id
  }
}

resource "azurerm_windows_virtual_machine" "vm_cible" {
  name                  = var.vm_name
  resource_group_name   = azurerm_resource_group.rg_cible.name
  location              = azurerm_resource_group.rg_cible.location
  size                  = var.vm_size
  admin_username        = var.vm_username
  admin_password        = var.vm_username_password
  network_interface_ids = [azurerm_network_interface.nic_cible.id]
  computer_name         = var.vm_name
  os_disk {
    name                 = "osdisk_cible"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  additional_unattend_content {
    setting = "AutoLogon"
    content = "<AutoLogon><Password><Value>${var.vm_username_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.vm_username}</Username></AutoLogon>"
  }

}

resource "azurerm_virtual_machine_extension" "vm_extension_cible" {
  name                 = "vm_extension_cible"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm_cible.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings           = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -encodedCommand ${textencodebase64(file("./ssh.ps1") , "UTF-16LE")}"       
    }
    SETTINGS
}


