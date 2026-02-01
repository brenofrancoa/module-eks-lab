variable "namespace" {
  description = "Kubernetes namespace for observability stack"
  type    = string
  default = "monitoring"
}

variable "chart_version" {
  description = "kube-prometheus-stack Helm chart version"
  type    = string
  default = "58.2.0"
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type    = string
  default = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type      = string
  sensitive = true
}

variable "grafana_lb_source_cidrs" {
  description = "Allowed source CIDRs for Grafana load balancer"
  type    = list(string)
  default = []
}

variable "grafana_persistence_enabled" {
  description = "Enable persistent storage for Grafana"
  type    = bool
  default = false
}

variable "grafana_persistence_size" {
  description = "Grafana persistent volume size"
  type    = string
  default = "10Gi"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type    = string
  default = "7d"
}

variable "prometheus_storage_gi" {
  description = "Prometheus persistent volume size in Gi"
  type    = number
  default = 20
}

variable "storage_class_name" {
  description = "Storage class name for persistent volumes"
  type    = string
  default = ""
}
