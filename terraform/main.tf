# 1. A Resource Group
resource "azurerm_resource_group" "main" {
    name = var.resource_group_name
    location = var.location
}


# 2. A Virtual Network
resource "azurerm_virtual_network" "main" {
    name = "${var.resource_group_name}-vnet"
    address_space = ["10.0.0.0/16"]
    location = var.location
    resource_group_name =  azurerm_resource_group.main.name

}   

# 3. A Subnet
resource "azurerm_subnet" "main" {
    name = "${var.resource_group_name}-subnet"
    resource_group_name = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes = ["10.0.1.0/24"]
}

# 4. A Public IP Address
resource "azurerm_public_ip" "main" {
    name = "${var.vm_name}-public-ip"
    location = var.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method = "Dynamic"
    sku = "Basic"
}

# 5. A Network Interface Card
resource "azurerm_network_interface" "main" {
    name = "${var.vm_name}-nic"
    location = var.location
    resource_group_name = azurerm_resource_group.main.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.main.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.main.id
    }
}

# 6. A Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
    name = var.vm_name
    resource_group_name = azurerm_resource_group.main.name
    location = var.location
    size = "Standard_B1ls"
    admin_username = "azureuser"

    network_interface_ids = [
        azurerm_network_interface.main.id,
        ]
    
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
        name = "${var.vm_name}-osdisk"
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts"
        version = "latest"
    }

    admin_ssh_key {
        username = "azureuser"
        public_key = file("~/.ssh/id_rsa_azure.pub")
    }

    custom_data = filebase64("${path.module}/scripts/install_docker_fastapi.sh")
}

