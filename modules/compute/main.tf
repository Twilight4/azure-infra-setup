# Example: Virtual Machine Scale Set for application tier. VMSS is a
# straightforward choice for VM-based services; for containers prefer AKS.
resource "azurerm_linux_virtual_machine_scale_set" "app_vmss" {
  name                = "${var.prefix}-app-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location

  # VM size and instance count — instance_count drives the initial
  # number of VMs. Use an autoscale resource (azurerm_monitor_autoscale_setting)
  # to scale based on metrics.
  sku            = var.vm_sku
  instances      = var.instance_count
  admin_username = var.admin_username

  # Image source — use managed images or marketplace images; version
  # set to "latest" pulls the most recent image, which can vary.
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }

  # Basic network interface configuration — attach to the provided
  # application subnet (should be a spoke subnet). For more advanced
  # setups, consider using load balancer backend pools and customizing
  # health probes.
  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name      = "ipconfig"
      subnet_id = var.app_subnet_id
    }
  }

  # Keep upgrade_mode manual for explicit control; you can switch to
  # automatic for image-based rolling upgrades, or use platform images
  # with managed upgrades via VMSS rolling upgrades feature.
  upgrade_mode = "Manual"

  # Enable OS disk ephemeral settings, caching, or extensions via
  # additional blocks if needed (omitted here for brevity).
}

# Note: autoscale settings are configured using azurerm_monitor_autoscale_setting
# in a separate resource so teams can manage scaling policies independently.
