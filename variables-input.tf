variable "env" {
  description = "The deployment environment - passed in by Jenkins (sandbox, aat, prod etc..)"
}

variable "product" {
  description = "The name of the application - passed in by Jenkins (juror)"
}

variable "subscription" {
  description = "The subscription ID - passed in by Jenkins"
}

variable "tenant_id" {
  description = "The Azure AD tenant ID for authenticating to key vault - passed in by Jenkins"
}

variable "jenkins_AAD_objectId" {
  description = "The object ID of the user to be granted access to the key vault"
}
