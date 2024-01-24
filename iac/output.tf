output "id" {
  description = "The virtual machine ID."
  value       = azurerm_linux_virtual_machine.linux_virtual_machine.id
}

output "name" {
  description = "The virtual machine name."
  value       = azurerm_linux_virtual_machine.linux_virtual_machine.name
}

output "computer_name" {
  description = "The virtual machine computer name."
  value       = azurerm_linux_virtual_machine.linux_virtual_machine.computer_name
}

output "private_ip_address" {
  description = "The virtual machine private IP address."
  value       = azurerm_linux_virtual_machine.linux_virtual_machine.private_ip_address
}

output "public_ip_address" {
  description = "The virtual machine public IP address."
  value       = azurerm_linux_virtual_machine.linux_virtual_machine.public_ip_address
  #value       = coalesce(azurerm_linux_virtual_machine.linux_virtual_machine.public_ip_address, "null")
}

output "network_interface_ids" {
  description = "The virtual machine network interface IDs."
  value       = azurerm_linux_virtual_machine.linux_virtual_machine.network_interface_ids
}

# output "data_disks_name" {
#   description = "Name of the data disks of the VM"
#   value = merge([for key, value in var.virtualmachinedata : { for disk_key, disk_value in azurerm_managed_disk.data_disks : disk_key =>
#     disk_value.name
#   }]...)
# }