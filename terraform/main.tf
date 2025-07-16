resource "azurerm_resource_group" "main" {
    name = var.resource_group_name
    location = var.location
}

resource "azurerm_virtual_network" "main" {
    name = "${var.resource_group_name}-vnet"
    address_space = ["10.0.0.0/16"]
    location = var.location
    resource_group_name =  azurerm_resource_group.main.name

}

# 省略　サブネット・ネットワークインターフェース・ネットワーク・セキュリティグループ

resource "azurerm_linux_virtual_machine" "main" {
    name = var.vm_name
    resource_group_name = azurerm_resource_group.main.name
    location = var.location
    size = "Standard B1s"
    admin_username = "adminuser"

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
        public_key = file("~/.ssh/id_ed25519.pub")
    }

    custom_data = filebase64("${path.module}/scripts/install_docker-fastapi.sh")
}

