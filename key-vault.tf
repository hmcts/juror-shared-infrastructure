data "azurerm_user_assigned_identity" "jenkins" {
  name                = "jenkins-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}

module "juror-vault" {
  source                   = "git@github.com:hmcts/cnp-module-key-vault?ref=DTSPO-31965/remove-jenkins-ptl-access"
  name                     = format("%s-%s", var.product, var.env)
  product                  = var.product
  env                      = var.env
  tenant_id                = var.tenant_id
  object_id                = var.jenkins_AAD_objectId
  resource_group_name      = azurerm_resource_group.juror_resource_group.name
  product_group_name       = "DTS Juror"
  developers_group         = local.admin_group_map[var.env]
  common_tags              = var.common_tags
  create_managed_identity  = true
  grant_dev_jenkins_access = var.env == "stg"
  jenkins_object_id        = data.azurerm_user_assigned_identity.jenkins.principal_id
}
