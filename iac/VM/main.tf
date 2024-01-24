module "naming" {
  source                 = "Azure/naming/azurerm"
  version                = "0.3.0"
  prefix                 = var.prefix
  suffix                 = var.suffix
  unique-length          = var.unique_length
  unique-seed            = var.unique_seed
  unique-include-numbers = var.unique_include_numbers
}

########
#===================================================================
# CREATE NETWORK INTERFACE DATA TO BE USED TO CREATE VIRTUAL MACHINE
#===================================================================
data "azurerm_subnet" "nic_subnet" {
  count                = var.subnet_name == "" ? 0 : 1
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.subnet_rg == "" ? var.resource_group_name : var.subnet_rg
}

resource "azurerm_public_ip" "public_ip" {
  count               = var.public_ip_enabled ? 1 : 0
  name                = var.public_ip_name == "" ? module.naming.public_ip.name_unique : var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.public_ip_sku
  allocation_method   = var.public_ip_allocation_method
  sku_tier            = var.public_ip_sku_tier
  tags                = var.resource_group_tags == {} ? var.tags : merge(var.resource_group_tags, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_interface" "nic" {
  name                = var.network_interface_name == "" ? module.naming.network_interface.name_unique : var.network_interface_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_servers = var.dns_servers

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = var.subnet_id == "" ? data.azurerm_subnet.nic_subnet[0].id : var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address_allocation == "Dynamic" ? null : var.private_ip_address
    #checkov:skip=CKV_AZURE_119:Let user decide to use public ip
    public_ip_address_id = var.public_ip_enabled ? azurerm_public_ip.public_ip[0].id : null
  }
  tags = var.resource_group_tags == {} ? var.tags : merge(var.resource_group_tags, var.tags)
}


#===================================================================
# MANAGES A LINUX VIRTUAL MACHINE
#===================================================================
resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
  #checkov:skip=CKV_AZURE_149:Let user decide to use password
  #checkov:skip=CKV_AZURE_1:Let user decide to use password
  #checkov:skip=CKV_AZURE_179:Let user decide to install VM agent
  #checkov:skip=CKV_AZURE_50:Let user decide to allow extension operations
  name                            = var.name == "" ? module.naming.linux_virtual_machine.name_unique : var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  computer_name                   = var.computer_name == "" ? null : var.computer_name
  network_interface_ids           = [azurerm_network_interface.nic.id]
  size                            = var.size
  zone                            = var.zone == "" ? null : var.zone
  availability_set_id             = var.zone == "" ? azurerm_availability_set.this.id : null
  admin_username                  = var.admin_username
  disable_password_authentication = var.disable_password_authentication # IF SET as TRUE key vault is needed
  admin_password                  = var.admin_password == "" ? random_password.password[0].result : var.admin_password
  custom_data                     = var.custom_data_path == "" ? null : base64encode(file(var.custom_data_path))

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication == true ? [1] : []
    content {
      username   = var.admin_username
      public_key = tls_private_key.this[0].public_key_openssh
    }
  }

  patch_assessment_mode = var.update_management_enabled == true ? "AutomaticByPlatform" : var.patch_assessment_mode
  patch_mode            = var.update_management_enabled == true ? "AutomaticByPlatform" : var.patch_mode

  bypass_platform_safety_checks_on_user_schedule_enabled = var.update_management_enabled == true ? true : var.bypass_platform_safety_checks_on_user_schedule_enabled

  #checkov:skip=CKV_AZURE_179:Let user decide to install VM agent
  provision_vm_agent = var.provision_vm_agent
  #checkov:skip=CKV_AZURE_50:Let user decide to allow extension operations
  allow_extension_operations = var.allow_extension_operations

  os_disk {
    name                      = var.os_disk_name
    caching                   = var.caching
    storage_account_type      = var.storage_account_type
    disk_size_gb              = var.disk_size_gb
    write_accelerator_enabled = var.write_accelerator_enabled
  }

  identity {
    identity_ids = []
    type         = "SystemAssigned"
  }

  source_image_id = var.source_image_id == "" ? null : var.source_image_id

  dynamic "source_image_reference" {
    for_each = var.source_image_id == "" ? [1] : []
    content {
      offer     = lookup(var.image, "offer", null)
      publisher = lookup(var.image, "publisher", null)
      sku       = lookup(var.image, "sku", null)
      version   = lookup(var.image, "version", null)
    }
  }

  additional_capabilities {
    ultra_ssd_enabled = var.ultra_ssd_enabled
  }

  tags = var.resource_group_tags == {} ? var.tags : merge(var.resource_group_tags, var.tags)
}


#=========================================================================================================
#  At least one `admin_ssh_key` must be specified when `disable_password_authentication` is set to `true`
#=========================================================================================================
data "azurerm_key_vault" "vm_key_vault" {
  count               = var.key_vault_name == "" ? 0 : 1
  name                = var.key_vault_name
  resource_group_name = var.key_vault_rg == "" ? var.resource_group_name : var.key_vault_rg
}

resource "azurerm_key_vault_secret" "this" {
  count           = var.key_vault_name == "" ? 0 : 1
  name            = var.key_vault_secret_name == "" ? azurerm_linux_virtual_machine.linux_virtual_machine.name : var.key_vault_secret_name
  value           = var.disable_password_authentication == true ? tls_private_key.this[0].public_key_openssh : ((var.admin_password != "" && var.admin_password != "") ? var.admin_password : random_password.password[0].result)
  key_vault_id    = var.key_vault_id == "" ? data.azurerm_key_vault.vm_key_vault[0].id : var.key_vault_id
  content_type    = var.disable_password_authentication == true ? "ssh_private_key" : "password"
  expiration_date = var.expiration_time_hours != "" ? timeadd(timestamp(), var.expiration_time_hours) : null
  tags            = var.resource_group_tags == {} ? var.tags : merge(var.resource_group_tags, var.tags)

  lifecycle {
    ignore_changes = all
  }
}

resource "random_password" "password" {
  count            = var.admin_password == "" ? 1 : 0
  length           = 21
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 2
}


#=========================================================================================================
# - Generate Private/Public SSH Key for Linux Virtual Machine
#=========================================================================================================
resource "tls_private_key" "this" {
  count     = var.disable_password_authentication == true ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}


#=========================================================================================================
# Added: AEC - 2022-07-29 - Managed Data Disk - dd
#=========================================================================================================
resource "azurerm_managed_disk" "data_disks" {
  #checkov:skip=CKV_AZURE_93:Low severity, skipping
  for_each             = var.managed_disks
  location             = var.location
  resource_group_name  = var.resource_group_name
  name                 = each.value.name == "" ? module.naming.managed_disk[each.key].name_unique : each.value.name
  storage_account_type = each.value.storage_account_type
  disk_size_gb         = each.value.disk_size_gb
  create_option        = each.value.create_option
  zone                 = var.zone == "" ? null : var.zone
  tags                 = var.resource_group_tags == {} ? var.tags : merge(var.resource_group_tags, var.tags)
}


#=========================================================================================================
# Added: AEC - 2022-07-29 - Data Disk attached a Virtual Machine
#=========================================================================================================
resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each                  = var.managed_disks
  virtual_machine_id        = azurerm_linux_virtual_machine.linux_virtual_machine.id
  managed_disk_id           = azurerm_managed_disk.data_disks[each.key].id
  lun                       = each.value.lun
  caching                   = each.value.caching
  write_accelerator_enabled = each.value.write_accelerator_enabled
}


#=========================================================================================================
# 2022-08-22 - Availability set
#=========================================================================================================
resource "azurerm_availability_set" "this" {
  name                         = var.availability_set_name == "" ? module.naming.availability_set.name_unique : var.availability_set_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_update_domain_count = var.platform_update_domain_count
  platform_fault_domain_count  = var.platform_fault_domain_count
  tags                         = var.resource_group_tags == {} ? var.tags : merge(var.resource_group_tags, var.tags)
}


#=========================================================================================================
# 2023-03-13 - Backup
#=========================================================================================================
data "azurerm_backup_policy_vm" "vm_backup_policy" {
  count               = var.backup_policy_name == "" ? 0 : 1
  name                = var.backup_policy_name
  recovery_vault_name = var.recovery_vault_name
  resource_group_name = var.backup_policy_rg == "" ? var.resource_group_name : var.backup_policy_rg
}

resource "azurerm_backup_protected_vm" "this" {
  count               = var.backup_policy_name == "" ? 0 : 1
  resource_group_name = var.recovery_vault_rg == "" ? var.resource_group_name : var.recovery_vault_rg
  recovery_vault_name = var.recovery_vault_name
  source_vm_id        = azurerm_linux_virtual_machine.linux_virtual_machine.id
  backup_policy_id    = var.backup_policy_id == "" ? data.azurerm_backup_policy_vm.vm_backup_policy[0].id : var.backup_policy_id
  depends_on = [
    azurerm_linux_virtual_machine.linux_virtual_machine
  ]
}


#=========================================================================================================
# 2023-03-24 - Data Collection Rule
#=========================================================================================================
data "azurerm_monitor_data_collection_rule" "vm_data_collection_rule" {
  count               = var.monitor_data_collection_rule_name == "" ? 0 : 1
  name                = var.monitor_data_collection_rule_name
  resource_group_name = var.monitor_data_collection_rule_rg == "" ? var.resource_group_name : var.monitor_data_collection_rule_rg
}

resource "azurerm_monitor_data_collection_rule_association" "this" {
  count                   = var.monitor_data_collection_rule_name == "" ? 0 : 1
  name                    = var.dcr_association_name == "" ? "dcr-vm-association" : var.dcr_association_name
  target_resource_id      = azurerm_linux_virtual_machine.linux_virtual_machine.id
  data_collection_rule_id = var.monitor_data_collection_rule_id == "" ? data.azurerm_monitor_data_collection_rule.vm_data_collection_rule[0].id : var.monitor_data_collection_rule_id
}


#=========================================================================================================
# 2023-06-05 - Azure Monitor Agent
#=========================================================================================================
resource "azurerm_virtual_machine_extension" "ama" {
  count                      = var.provision_ama == true ? 1 : 0
  name                       = var.vm_extension_ama_name == "" ? "AzureMonitorLinuxAgent" : var.vm_extension_ama_name
  virtual_machine_id         = azurerm_linux_virtual_machine.linux_virtual_machine.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.26"
  automatic_upgrade_enabled  = var.automatic_upgrade_enabled
  auto_upgrade_minor_version = var.auto_upgrade_minor_version
  tags                       = var.resource_group_tags == "" ? var.tags : merge(var.resource_group_tags, var.tags)

  # settings = jsonencode({
  #   GCS_AUTO_CONFIG = true
  # })
}
