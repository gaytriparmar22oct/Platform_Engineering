############################
# Common interface (matches aks/gke)
############################
variable "name" {
  type = string
}

variable "location" {
  description = "AWS region."
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
  default = "m6i.large"
}

variable "system_node_count" {
  type    = number
  default = 2
}

variable "user_node_vm_size" {
  type    = string
  default = "m6i.xlarge"
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
# AWS-specific
############################
variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.40.0.0/20", "10.40.16.0/20", "10.40.32.0/20"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.40.48.0/22", "10.40.52.0/22", "10.40.56.0/22"]
}

variable "availability_zones" {
  type = list(string)
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = true
}

variable "enable_irsa" {
  type    = bool
  default = true
}
