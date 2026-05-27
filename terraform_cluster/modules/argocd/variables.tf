variable "chart_version" {
  description = "Argo CD Helm chart version."
  type        = string
  default     = "7.6.12"
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "values" {
  description = "Optional raw YAML to pass as Helm values."
  type        = string
  default     = ""
}
