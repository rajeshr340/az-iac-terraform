terraform {
  #  backend "remote" {
  #  hostname = "app.terraform.io"
  #  organization = "Kyndryl-CIO"

  #   workspaces {
  #     name = "vm-drift-testing-1"
  #   }
  #  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.52.0"
    }
    }
}


provider "azurerm" {
  features {}

  #  client_id       = var.client_id
  #  client_secret   = var.client_secret
  #  tenant_id       = var.tenant_id
  #  subscription_id = var.subscription_id
}

# Get Resources from a Resource Group
data "azurerm_resources" "rgname" {
  resource_group_name = var.rgname
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rgname
}

output "subnet_id" {
  value = data.azurerm_subnet.subnet.id
}

resource "azurerm_kubernetes_cluster" "sn-cluster" {

  name                = var.K8S_CLUSTERNAME
  location            = var.location
  resource_group_name = var.rgname
  dns_prefix          = var.dns_prefix
  azure_policy_enabled = true

  network_profile {
    network_plugin = "azure"
    service_cidr   = var.service_cidrs
    dns_service_ip = var.dns_service_ip
  }

  identity {
    type = "SystemAssigned"
  }
  tags = var.tags

  default_node_pool {
    name       = "starter"
    vm_size    = var.default_nodepool_vm_size
    node_count = var.default_nodepool_node_count
    type       = var.default_nodepool_node_type
    vnet_subnet_id        = data.azurerm_subnet.subnet.id

  }

}



resource "azurerm_kubernetes_cluster_node_pool" "aks-pool" {
  name                  = var.akspool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.sn-cluster.id
  vm_size               = var.akspool_vm_size
  max_count             = var.akspool_max_count
  min_count             = var.akspool_min_count
  os_disk_size_gb       = var.akspool_os_disk_size_gb
  os_type               = var.akspool_os_type
  enable_auto_scaling   = var.akspool_enable_auto_scaling
  vnet_subnet_id        = data.azurerm_subnet.subnet.id
  tags = var.tags
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.sn-cluster.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.sn-cluster.kube_config_raw

  sensitive = true
}
