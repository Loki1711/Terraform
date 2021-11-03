resource "azurerm_resource_group" "RG" {
  name     = var.RGname
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "VNET" {
  name                = join("", var.VNET)
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  address_space       = [element(var.address_space, 0)]
}

resource "azurerm_subnet" "subnet" {
  name                 = join("", var.subnet)
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = [element(var.address_space, 3)]
}

resource "azurerm_public_ip" "PIP" {
  name                = join("", var.PIP)
  resource_group_name = azurerm_resource_group.RG.name
  allocation_method   = "Static"
  location            = azurerm_resource_group.RG.location
}

resource "azurerm_network_interface" "NIC" {
  name                = join("", var.NIC)
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PIP.id
  }
}

resource "azurerm_network_security_group" "NSG" {

  name                = join("", var.NSG)
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WEB"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Resource Creation to associate nsg with subnet
resource "azurerm_subnet_network_security_group_association" "NSG-association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}


resource "azurerm_windows_virtual_machine" "VM" {
  name                  = join("", var.VM)
  resource_group_name   = azurerm_resource_group.RG.name
  location              = azurerm_resource_group.RG.location
  network_interface_ids = [azurerm_network_interface.NIC.id]
  size                  = "Standard_DS1_V2"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                 = "TF-Disk-1"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  computer_name  = var.hostname
  admin_username = var.username
  admin_password = var.passwd

}
resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.VM.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS
}


resource "azurerm_virtual_machine_extension" "azure_policy" {
  name                       = "azurepolicy"
  virtual_machine_id         = azurerm_windows_virtual_machine.VM.id
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "mma" {
  name                       = "log-analytics"
  virtual_machine_id         = azurerm_windows_virtual_machine.VM.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}



