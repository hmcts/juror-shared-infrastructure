#First populate the vault with parameters that are not actually secret
resource "azurerm_key_vault_secret" "fixed_secrets" {
  for_each     = local.fixed_secrets
  name         = each.key
  value        = each.value
  key_vault_id = module.juror-vault.key_vault_id
}

#Now create secrets
resource "random_password" "generated" {
  for_each     = local.generated_secrets
  length       = each.value.secret_length
  lower        = true
  upper        = true
  numeric      = true
  special      = false
}

#Store secret if store parameter is true
resource "azurerm_key_vault_secret" "stored" {
  for_each     = {
    for key, value in local.generated_secrets:
    key => value.store
    if key != false
  }  
  name         = each.key
  value        = random_password.generated[each.value].result 
  key_vault_id = module.juror-vault.key_vault_id
}

#Now create base64 encoded version of secrets and store if store_64 parameter is true
resource "azurerm_key_vault_secret" "encoded" {
  for_each     = local.generated_secrets
  name         = "${each.key}-encoded"  
  value        = base64encode(random_password.generated[each.value].result) 
  key_vault_id = module.juror-vault.key_vault_id
}