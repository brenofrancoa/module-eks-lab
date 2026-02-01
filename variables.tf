variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "eks-lab"
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_min" {
  type    = number
  default = 1
}

variable "node_max" {
  type    = number
  default = 3
}

variable "grafana_admin_user" {
  type    = string
  default = "admin"
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "grafana_lb_source_cidrs" {
  type    = list(string)
  default = []
}

variable "prometheus_storage_gi" {
  type    = number
  default = 20
}

variable "prometheus_retention" {
  type    = string
  default = "7d"
}

variable "grafana_persistence_enabled" {
  type    = bool
  default = false
}

variable "grafana_persistence_size" {
  type    = string
  default = "10Gi"
}

variable "storage_class_name" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
