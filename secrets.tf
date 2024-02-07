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
  min_lower    = 3
  upper        = true
  min_upper    = 3
  numeric      = true
  min_numeric  = 3
  special      = false
}

#Store secret if name parameter is supplied
resource "azurerm_key_vault_secret" "stored" {
  for_each     = {
    for key, params in local.generated_secrets:
    key => params.name
    if params.name != null
  }  
  name         = each.key.name
  value        = random_password.generated[each.key].result 
  key_vault_id = module.juror-vault.key_vault_id
}

#Store secret if name2 parameter is supplied (creates copy of secret effectively)
resource "azurerm_key_vault_secret" "stored2" {
  for_each     = {
    for key, params in local.generated_secrets:
    key => params.name2
    if params.name2 != null
  }  
  name         = each.key.name2
  value        = random_password.generated[each.key].result 
  key_vault_id = module.juror-vault.key_vault_id
}

#Store secret after encoding if name64 parameter is supplied
resource "azurerm_key_vault_secret" "stored64" {
  for_each     = {
    for key, params in local.generated_secrets:
    key => params.name64
    if params.name64 != null
  }  
  name         = each.key.name64
  value        = base64encode(random_password.generated[each.key].result) 
  key_vault_id = module.juror-vault.key_vault_id
}