terraform {
  required_version = ">= 1.0"
  backend "local" {
    path = "/tmp/terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.54"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    azapi = {
      source  = "azure/azapi"
      version = "1.6.0"
    }
  }
}