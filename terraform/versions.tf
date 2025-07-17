terraform {
    required_version = ">= 1.5.0"
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.100"
      }
     }
    backend "azurerm" {
      resource_group_name   = "tfstate-rg"
      storage_account_name  = "mytfstateacctpoent"
      container_name        = "tfstate"
      key                   = "terraform.tfstate"
    }
}
provider "azurerm" {
    features {}
}