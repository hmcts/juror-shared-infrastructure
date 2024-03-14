#Generate random password for admin user
resource "random_password" "admin" {
  count       = var.env == "prod" || var.env == "stg" ? 1 : 0
  length      = 32
  lower       = true
  min_lower   = 3
  upper       = true
  min_upper   = 3
  numeric     = true
  min_numeric = 3
  special     = false
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
  env                     = "prod"
  vm_resource_group       = azurerm_resource_group.juror_resource_group.name
  vm_location             = var.location
  vm_admin_name           = "juror-admin"
  vm_admin_password       = random_password.admin[0].result
  vm_availabilty_zones    = "1"
  vm_subnet_id            = "/subscriptions/${var.aks_subscription_id}/resourceGroups/ss-${var.env}-network-rg/providers/Microsoft.Network/virtualNetworks/ss-${var.env}-vnet/subnets/iaas"
  privateip_allocation    = "Dynamic"
  vm_publisher_name       = "canonical"
  vm_offer                = "0001-com-ubuntu-server-jammy"
  vm_sku                  = "22_04-lts-gen2"
  vm_size                 = "Standard_E4ds_v5"
  vm_version              = "latest"
  systemassigned_identity = true
  os_disk_size_gb         = 500

  install_azure_monitor      = true
  install_dynatrace_oneagent = true
  install_splunk_uf          = true
  nessus_install             = true

  #custom_script_extension_name = "HMCTSVMBootstrap"
  tags = var.common_tags
}

resource "azurerm_virtual_machine_extension" "configure_vm" {
  count                      = var.env == "prod" || var.env == "stg" ? 1 : 0
  name                       = "ConfigureVM"
  virtual_machine_id         = module.virtual_machine[0].vm_id
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  protected_settings = jsonencode({
    script = base64encode(templatefile("${path.module}/configure-migration-vm.sh", {
      ORACLE_USERNAME   = data.azurerm_key_vault_secret.oracle_user[0].value
      ORACLE_PASSWORD   = data.azurerm_key_vault_secret.oracle_pass[0].value
      POSTGRES_USERNAME = data.azurerm_key_vault_secret.postgres_user[0].value
      POSTGRES_PASSWORD = data.azurerm_key_vault_secret.postgres_pass[0].value
    }))
  })

  tags = var.common_tags
}

#Store admin password in keyvault
resource "azurerm_key_vault_secret" "migration_vm_password" {
  count        = var.env == "prod" || var.env == "stg" ? 1 : 0
  name         = "migration-vm-password"
  value        = random_password.admin[0].result
  key_vault_id = module.juror-vault.key_vault_id
}

module "migration_vm" {
  providers = {
    azurerm     = azurerm
    azurerm.cnp = azurerm.cnp
    azurerm.soc = azurerm.soc
  }

  source                  = "git@github.com:hmcts/terraform-module-virtual-machine.git?ref=feat%2Fsupport-image-id"
  count                   = var.env == "prod" || var.env == "stg" ? 1 : 0
  vm_type                 = "linux"
  vm_name                 = "juror-db-migration-${var.env}-vm02"
  env                     = "prod"
  vm_resource_group       = azurerm_resource_group.juror_resource_group.name
  vm_location             = var.location
  vm_admin_name           = "juror-admin"
  vm_admin_password       = random_password.admin[0].result
  vm_availabilty_zones    = "1"
  vm_subnet_id            = "/subscriptions/${var.aks_subscription_id}/resourceGroups/ss-${var.env}-network-rg/providers/Microsoft.Network/virtualNetworks/ss-${var.env}-vnet/subnets/iaas"
  privateip_allocation    = "Dynamic"
  vm_image_id             = "/subscriptions/5ca62022-6aa2-4cee-aaa7-e7536c8d566c/resourceGroups/darts-migration-prod-rg/providers/Microsoft.Compute/galleries/darts_migration/images/darts-migration-oracle/versions/0.0.1"
  vm_size                 = "Standard_E4ds_v5"
  systemassigned_identity = true
  os_disk_size_gb         = 500

  install_azure_monitor      = true
  install_dynatrace_oneagent = true
  install_splunk_uf          = true
  nessus_install             = true

  #custom_script_extension_name = "HMCTSVMBootstrap"
  tags = var.common_tags
}
