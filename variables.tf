#Variables with values passed in by Jenkins

variable "env" {
  description = "The deployment environment (sandbox, aat, prod etc..)"
}

variable "product" {
  description = "The name of the application"
}

variable "subscription" {
  description = "The subscription ID"
}

variable "aks_subscription_id" {
  description = "The aks subscription ID"
}

variable "tenant_id" {
  description = "The Azure AD tenant ID for authenticating to key vault"
}

variable "jenkins_AAD_objectId" {
  description = "The object ID of the user to be granted access to the key vault"
}

variable "common_tags" {
  type = map(string)
}

# Variables with default values or values specified in an {env}.tfvars file

variable "location" {
  default = "UK South"
}

variable "hub" {
}

variable "cnp_sub_id" {
  description = "The ID of the CNP subscription that contains the Key Vault to use for Dynatrace and Nessus secrets."
}