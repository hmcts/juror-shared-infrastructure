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

#Now handle secrets