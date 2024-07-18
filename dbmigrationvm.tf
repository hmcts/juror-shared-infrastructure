#Generate random password for admin user
resource "random_password" "admin" {
  count       = var.env == "prod" ? 1 : 0
  length      = 32
  lower       = true
  min_lower   = 3
  upper       = true
  min_upper   = 3
  numeric     = true
  min_numeric = 3
  special     = false
}

#Store admin password in keyvault
resource "azurerm_key_vault_secret" "migration_vm_password" {
  count        = var.env == "prod" ? 1 : 0
  name         = "migration-vm-password"
  value        = random_password.admin[0].result
  key_vault_id = module.juror-vault.key_vault_id
}
