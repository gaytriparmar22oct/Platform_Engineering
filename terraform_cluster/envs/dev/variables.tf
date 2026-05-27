variable "name" {
  description = "Base name for the platform (e.g. idp-dev)."
  type        = string
  default     = "idp-dev"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "rg-idp-dev"
}

variable "admin_group_object_ids" {
  description = "Entra ID group object IDs granted cluster-admin."
  type        = list(string)
  default     = []
}

variable "authorized_ip_ranges" {
  description = "CIDRs allowed to reach API server. Leave empty for dev (open)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default = {
    environment = "dev"
    owner       = "platform-team"
  }
}
