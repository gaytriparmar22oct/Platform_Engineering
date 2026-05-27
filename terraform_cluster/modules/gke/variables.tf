############################
# Common interface (matches aks/eks)
############################
variable "name" {
  type = string
}

variable "location" {
  description = "GCP region."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "system_node_vm_size" {
  type    = string
  default = "e2-standard-2"
}

variable "system_node_count" {
  type    = number
  default = 2
}

variable "user_node_vm_size" {
  type    = string
  default = "e2-standard-4"
}

variable "user_node_min_count" {
  type    = number
  default = 3
}

variable "user_node_max_count" {
  type    = number
  default = 6
}

variable "user_node_max_pods" {
  type    = number
  default = 60
}

variable "authorized_ip_ranges" {
  type    = list(string)
  default = []
}

############################
# GCP-specific
############################
variable "project_id" {
  type = string
}

variable "network_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.40.0.0/22"
}

variable "pod_cidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "service_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "enable_private_nodes" {
  type    = bool
  default = true
}

variable "enable_private_endpoint" {
  type    = bool
  default = false
}

variable "enable_workload_identity" {
  type    = bool
  default = true
}
