## GLOBAL
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the resources."
}

variable "location" {
  type        = string
  description = "The Azure Region where the resources should exist."
}

variable "resource_group_tags" {
  type        = map(string)
  description = "A mapping of tags which should be assigned to the resource group."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags which should be assigned to this Virtual Machine."
  default     = {}
}


## NAMING
variable "prefix" {
  type        = list(string)
  default     = []
  description = "It is not recommended that you use prefix by azure you should be using a suffix for your resources."
}

variable "suffix" {
  type        = list(string)
  default     = []
  description = "It is recommended that you specify a suffix for consistency. please use only lowercase characters when possible"
}

variable "unique_seed" {
  description = "Custom value for the random characters to be used"
  type        = string
  default     = ""
}

variable "unique_length" {
  description = "Max length of the uniqueness suffix to be added"
  type        = number
  default     = 4
}

variable "unique_include_numbers" {
  description = "If you want to include numbers in the unique generation"
  type        = bool
  default     = true
}


## PUBLIC IP
variable "public_ip_enabled" {
  type        = bool
  description = "Should Public IP be Enabled for this Virtual Machine?"
  default     = false
}

variable "public_ip_name" {
  type        = string
  description = "Specifies the name of the Public IP. Changing this forces a new Public IP to be created."
  default     = ""
}

variable "public_ip_sku" {
  type        = string
  description = "The SKU of the Public IP. Accepted values are Basic and Standard."
  default     = "Basic"
}

variable "public_ip_allocation_method" {
  type        = string
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic."
  default     = "Dynamic"
}

variable "public_ip_sku_tier" {
  type        = string
  description = "The SKU Tier that should be used for the Public IP. Possible values are Regional and Global."
  default     = "Regional"
}


## NIC
variable "network_interface_name" {
  type        = string
  description = "The name of the Network Interface."
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet where this Network Interface should be located in."
  default     = ""
}

variable "subnet_name" {
  type        = string
  description = "The name of the Subnet where this Network Interface should be located in."
  default     = ""
}

variable "subnet_rg" {
  type        = string
  description = "The resource group of the Subnet where this Network Interface should be located in."
  default     = ""
}

variable "virtual_network_name" {
  type        = string
  description = "The virtual network of the Subnet where this Network Interface should be located in."
  default     = ""
}

variable "private_ip_address" {
  type        = string
  description = "The Static IP Address which should be used."
  default     = ""
}

variable "dns_servers" {
  type        = list(any)
  description = "A list of IP Addresses defining the DNS Servers which should be used for this Network Interface."
  default     = []
}

variable "ip_configuration_name" {
  type        = string
  description = "The name of the IP configuration of the nic."
  default     = "internal"
}

variable "private_ip_address_allocation" {
  type        = string
  description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static."
  default     = "Dynamic"
}


## VIRTUAL MACHINE
variable "name" {
  type        = string
  description = "The name of the Windows Virtual Machine."
  default     = ""
}

variable "computer_name" {
  type        = string
  description = "Specifies the Hostname which should be used for this Virtual Machine. If unspecified this defaults to the value for the name field. If the value of the name field is not a valid computer_name, then you must specify computer_name."
  default     = ""
}

variable "allow_extension_operations" {
  type        = bool
  description = "Should Extension Operations be allowed on this Virtual Machine?"
  default     = true
}

variable "provision_vm_agent" {
  type        = bool
  description = "Should the Azure VM Agent be provisioned on this Virtual Machine?"
  default     = true
}

variable "update_management_enabled" {
  type        = bool
  description = "(Preview) Specifies if Update Center is enabled for the Windows Virtual Machine."
  default     = false
}

variable "bypass_platform_safety_checks_on_user_schedule_enabled" {
  type        = bool
  description = "Specifies whether to skip platform scheduled patching when a user schedule is associated with the VM."
  default     = false
}

variable "size" {
  type        = string
  description = "The SKU which should be used for this Virtual Machine, such as Standard_F2."
  default     = "Standard_F2"
}

variable "zone" {
  type        = string
  description = "Specifies the Availability Zones in which this Linux Virtual Machine should be located."
  default     = ""
}

variable "ultra_ssd_enabled" {
  type        = bool
  description = "Should the capacity to enable Data Disks of the UltraSSD_LRS storage account type be supported on this Virtual Machine?"
  default     = false
}

variable "source_image_id" {
  type        = string
  description = "The ID of the Image which this Virtual Machine should be created from. Possible Image ID types include Image IDs, Shared Image IDs, Shared Image Version IDs, Community Gallery Image IDs, Community Gallery Image Version IDs, Shared Gallery Image IDs and Shared Gallery Image Version IDs."
  default     = ""
}

variable "image" {
  description = "Virtual Machine source image information. See https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html#storage_image_reference. This variable cannot be used if `vm_image_id` is already defined."
  type        = map(string)
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

variable "write_accelerator_enabled" {
  type        = bool
  description = "Should Write Accelerator be Enabled for this OS Disk?"
  default     = false
}

variable "disk_size_gb" {
  type        = number
  description = "The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from."
  default     = 32
}

variable "storage_account_type" {
  type        = string
  description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values are Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS and Premium_ZRS."
  default     = "Standard_LRS"
}

variable "os_disk_name" {
  type        = string
  description = "The name which should be used for the Internal OS Disk."
  default     = ""
}

variable "caching" {
  type        = string
  description = "The Type of Caching which should be used for the Internal OS Disk. Possible values are None, ReadOnly and ReadWrite."
  default     = "ReadWrite"
}

variable "custom_data_path" {
  type        = string
  description = "The path to Custom Data which should be used for this Virtual Machine. (Base64-Encoded)"
  default     = ""
}

variable "admin_password" {
  type        = string
  description = "The Password which should be used for the local-administrator on this Virtual Machine."
  default     = ""
}

variable "admin_username" {
  type        = string
  description = "The username of the local administrator used for the Virtual Machine."
  default     = "opsadmin"
}

variable "disable_password_authentication" {
  type        = bool
  description = "Should Password Authentication be disabled on this Virtual Machine?"
  default     = false
}

variable "patch_assessment_mode" {
  type        = string
  description = "Specifies the mode of VM Guest Patching for the Virtual Machine. Possible values are AutomaticByPlatform or ImageDefault."
  default     = "ImageDefault"
}

variable "patch_mode" {
  type        = string
  description = "Specifies the mode of in-guest patching to this Linux Virtual Machine. Possible values are AutomaticByPlatform and ImageDefault."
  default     = "ImageDefault"
}


## VAULT
variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault where the Secret should be created."
  default     = ""
}

variable "key_vault_name" {
  type        = string
  description = "The name of the Key Vault where the Secret should be created."
  default     = ""
}

variable "key_vault_rg" {
  type        = string
  description = "The resource group of the Key Vault where the Secret should be created."
  default     = ""
}

variable "key_vault_secret_name" {
  type        = string
  description = "Specifies the name of the Key Vault Secret."
  default     = ""
}

variable "expiration_time_hours" {
  type        = string
  description = "Key Vault secret expiration in hours."
  default     = ""
}


## MANAGED DISK
variable "managed_disks" {
  type = map(object({
    name                      = string
    storage_account_type      = string
    disk_size_gb              = number
    create_option             = string
    lun                       = number
    caching                   = string
    write_accelerator_enabled = bool
    #data_disk_disk_encryption_set_id     = string
  }))
  description = "."
  default     = {}
}


## AVAILABILITY SET
variable "availability_set_name" {
  type        = string
  description = "Specifies the name of the availability set."
  default     = ""
}

variable "platform_update_domain_count" {
  type        = number
  description = "Specifies the number of fault domains that are used."
  default     = 5
}

variable "platform_fault_domain_count" {
  type        = number
  description = " Specifies the number of update domains that are used."
  default     = 3
}


## BACKUP
variable "backup_policy_id" {
  type        = string
  description = "Specifies the ID of the backup policy to use."
  default     = ""
}

variable "backup_policy_name" {
  type        = string
  description = "Specifies the name of the backup policy to use."
  default     = ""
}

variable "backup_policy_rg" {
  type        = string
  description = "Specifies the resource group of the backup policy to use."
  default     = ""
}

variable "recovery_vault_name" {
  type        = string
  description = "Specifies the name of the Recovery Services Vault to use."
  default     = ""
}

variable "recovery_vault_rg" {
  type        = string
  description = "The name of the resource group in which to create the Recovery Services Vault."
  default     = ""
}


## MONITORING
variable "monitor_data_collection_rule_id" {
  type        = string
  description = " The ID of the Data Collection Rule which will be associated to the target resource."
  default     = ""
}

variable "monitor_data_collection_rule_name" {
  type        = string
  description = "The name of the Data Collection Rule which will be associated to the target resource."
  default     = ""
}

variable "monitor_data_collection_rule_rg" {
  type        = string
  description = "The resource group of the Data Collection Rule which will be associated to the target resource."
  default     = ""
}

variable "dcr_association_name" {
  type        = string
  description = "The name which should be used for this Data Collection Rule Association. Defaults to configurationAccessEndpoint."
  default     = ""
}


## AZUR MONITOR AGENT (EXTENSION).
variable "vm_extension_ama_name" {
  type        = string
  description = "The name of the virtual machine extension for Azure Monitor Agent."
  default     = ""
}

variable "provision_ama" {
  type        = bool
  description = "Should Azure Monitor Agent be installed for this Virtual Machine?"
  default     = true
}

variable "auto_upgrade_minor_version" {
  type        = bool
  description = "Specifies if the platform deploys the latest minor version update to the type_handler_version specified."
  default     = true
}

variable "automatic_upgrade_enabled" {
  type        = bool
  description = " Should the Extension be automatically updated whenever the Publisher releases a new version of this VM Extension?"
  default     = true
}