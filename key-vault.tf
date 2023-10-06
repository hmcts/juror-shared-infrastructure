module "juror-vault" {
  source                     = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                       = format("%s-%s", var.product, var.env)
  product                    = var.product
  env                        = var.env
  tenant_id                  = var.tenant_id
  object_id                  = var.jenkins_AAD_objectId
  resource_group_name        = azurerm_resource_group.juror_resource_group.name
  product_group_name         = "Juror"
  common_tags                = var.common_tags
  create_managed_identity    = true
}