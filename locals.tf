resource "random_password" "grafana_admin" {
  length  = 20
  special = true
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))

  common_tags = merge(
    {
      Project   = var.cluster_name
      ManagedBy = "Terraform"
    },
    var.tags
  )

  grafana_admin_password = var.grafana_admin_password != "" ? var.grafana_admin_password : random_password.grafana_admin.result

  grafana_hostname = try(data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname, "")
  grafana_ip       = try(data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].ip, "")
  grafana_url      = local.grafana_hostname != "" ? "http://${local.grafana_hostname}" : (local.grafana_ip != "" ? "http://${local.grafana_ip}" : "")
}
