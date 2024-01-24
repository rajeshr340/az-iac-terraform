variable "rgname" {
  type        = string
  default     = "rg-MOCPEDemo-kcl-eastus-001"
  description = "Name of our Resource group"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "location"
}

variable "pgname" {
  type        = string
  default     = "bntest"
  description = "Name of our Project (tag value)"
}

variable "K8S_CLUSTERNAME" {
  type        = string
  description = "Name of the Cluster."
  default = "aks-cluster-demo"

}

variable "dns_prefix" {
  type        = string
  description = "DNS Prefix of the Cluster."
  default = "demo"
}

variable "tags" {
  type    = map
  default = {
    application = "k8s Cluster"
    ApplicationId = "MJIL-Sandbox"
    service_area = "devops"
    project_id = "P001"
    owner = "MOCPE"
    creator = "MOCPE"
    environment = "azure-dev"
    managed_by = "GitHub Actions - Terraform"
    repo_change_code = "GIT_URL"
    account_name = "MOCPE-Demo"
    teamorproject = "Modern Ops Customer Adoption "
    repo_change_code = "GIT_URL"
    practice = "cloud"
    accountid = "cloud"
    }
}

variable "default_nodepool_vm_size" {
  type = string
  description = ""
  default = "Standard_DS2_v2"
}


variable "default_nodepool_node_count" {
  type = string
  description = ""
  default = "2"
}

variable "default_nodepool_node_type" {
  type = string
  description = ""
  default = "VirtualMachineScaleSets"
}

variable "akspool_name" {
  type = string
  description = ""
  default = "aks"
}

variable "akspool_vm_size" {
  type = string
  description = ""
  default = "Standard_DS2_v2"
}

variable "akspool_max_count" {
  type = string
  description = ""
  default = "5"
}

variable "akspool_min_count" {
  type = string
  description = ""
  default = "1"
}

variable "akspool_os_disk_size_gb" {
  type = string
  description = ""
  default = "128"
}

variable "akspool_os_type" {
  type = string
  description = ""
  default = "Linux"
}

variable "akspool_enable_auto_scaling" {
  type = string
  description = ""
  default = "true"
}

variable "subnet" {
  type = string
  description = ""
  default = "node_subnet"
}

variable "vnet_name" {
  type = string
  description = ""
  default = "aro-vnet-demo"
}

variable "service_cidrs" {
  type = string
  description = ""
  default = "10.1.4.0/23"
}

variable "dns_service_ip" {
  type = string
  description = ""
  default = "10.1.4.10"
}

  # variable "client_id" { 
  #   type = string
  #       }
  # variable "client_secret" {  
  #   type = string
  #  }
  # variable "tenant_id" {
  #   type = string
  #        } 
  # variable "subscription_id" {
  #   type = string
  #  }