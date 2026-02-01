output "namespace" {
  description = "Namespace where the observability stack is deployed."
  value = kubernetes_namespace.monitoring.metadata[0].name
}

output "release_name" {
  description = "Helm release name for the kube-prometheus-stack deployment."
  value = helm_release.kube_prometheus_stack.name
}
