output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

output "grafana_url" {
  value = local.grafana_url
}

output "grafana_admin_password" {
  value     = local.grafana_admin_password
  sensitive = true
}
