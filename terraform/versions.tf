terraform {
    required_version = ">= 1.5.0"
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.100"
      }
     }
    backend "azurerm" {} # 必要に応じて後で記述
}
provider "azurerm" {
    features {}
}