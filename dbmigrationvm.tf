#Generate random password for admin user
resource "random_password" "admin" {
  length       = 32
  lower        = true
  min_lower    = 3
  upper        = true
  min_upper    = 3
  numeric      = true
  min_numeric  = 3
  special      = false
}

module "virtual_machine" {
  providers = {
    azurerm     = azurerm
    azurerm.cnp = azurerm.cnp
    azurerm.soc = azurerm.soc
  }

  source                  = "git@github.com:hmcts/terraform-module-virtual-machine.git?ref=master"
  count                   = var.env == "prod" || var.env == "stg" ? 1 : 0
  vm_type                 = "linux"
  vm_name                 = "juror-db-migration-${var.env}-vm01"
  env                     = var.env
  vm_resource_group       = azurerm_resource_group.juror_resource_group.name
  vm_location             = var.location
  vm_admin_name           = "juror-admin"
  vm_admin_password       = random_password.admin.result
  vm_availabilty_zones    = "1"
  vm_subnet_id            = "/subscriptions/${var.subscription}/resourceGroups/ss-${var.env}-network-rg/providers/Microsoft.Network/virtualNetworks/ss-$var.env}-vnet/subnets/iaas"
  privateip_allocation    = "Dynamic"
  vm_publisher_name       = "Canonical"
  vm_offer                = "UbuntuServer"
  vm_sku                  = "22.04-LTS"
  vm_size                 = "Standard_E4-2s_v3"
  vm_version              = "latest"
  systemassigned_identity = true
  os_disk_size_gb         = 500

  install_azure_monitor      = true
  install_dynatrace_oneagent = true
  install_splunk_uf          = true
  nessus_install             = true

  custom_script_extension_name = "HMCTSVMBootstrap"
  tags                         = var.common_tags
}

#Store admin password in keyvault
resource "azurerm_key_vault_secret" "migration_vm_password" {
  count        = var.env == "prod" || var.env == "stg" ? 1 : 0
  name         = "migration-vm-password"
  value        = random_password.admin.result
  key_vault_id = module.juror-vault.key_vault_id
}

resource "azurerm_virtual_machine_extension" "AADSSHLoginForLinux" {
  count                      = var.env == "prod" || var.env == "stg" ? 1 : 0
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = module.virtual_machines.vm_id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = var.common_tags
}

resource "azurerm_virtual_machine_extension" "install_docker" {
  count                      = var.env == "prod" || var.env == "stg" ? 1 : 0
  name                       = "InstallDocker"
  virtual_machine_id         = module.virtual_machines.vm_id
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  protected_settings = <<PROTECTED_SETTINGS
  {
    "script": "${filebase64("${path.module}/install-docker.sh")}"
  }
  PROTECTED_SETTINGS

  tags = var.common_tags
}