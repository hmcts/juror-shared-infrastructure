#First populate the vault with parameters that are not actually secret
resource "azurerm_key_vault_secret" "bureau_jwtTTL" {
  name         = "bureau-jwtTTL"
  value        = local.bureau.jwtTTL
  key_vault_id = module.juror-vault.key_vault_id
}

resource "azurerm_key_vault_secret" "public_jwtTTL" {
  name         = "public-jwtTTL"
  value        = local.public.jwtTTL
  key_vault_id = module.juror-vault.key_vault_id
}

#Now create secrets
resource "random_password" "generated" {
  for_each     = local.generated_secrets
  length       = 32
  lower        = true
  upper        = true
  numeric      = true
  special      = false
}

resource "azurerm_key_vault_secret" "generated" {
  for_each     = local.generated_secrets  
  name         = "${each.value}"  
  value        = random_password.generated[each.value].result 
  key_vault_id = module.juror-vault.key_vault_id
}

#Now create base64 encoded version of secrets
resource "azurerm_key_vault_secret" "encoded" {
  for_each     = local.generated_secrets  
  name         = "${each.value}-encoded"  
  value        = base64encode(random_password.generated[each.value].result) 
  key_vault_id = module.juror-vault.key_vault_id
}