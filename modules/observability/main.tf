resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  create_namespace = false
  wait             = true
  timeout          = 900

  values = [yamlencode({
    grafana = {
      adminUser     = var.grafana_admin_user
      service = merge(
        {
          type = "LoadBalancer"
        },
        length(var.grafana_lb_source_cidrs) > 0 ? {
          loadBalancerSourceRanges = var.grafana_lb_source_cidrs
        } : {}
      )
      persistence = merge(
        {
          enabled = var.grafana_persistence_enabled
          size    = var.grafana_persistence_size
        },
        var.storage_class_name != "" ? {
          storageClassName = var.storage_class_name
        } : {}
      )
    }
    prometheus = {
      prometheusSpec = {
        retention = var.prometheus_retention
        storageSpec = {
          volumeClaimTemplate = {
            spec = merge(
              {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "${var.prometheus_storage_gi}Gi"
                  }
                }
              },
              var.storage_class_name != "" ? {
                storageClassName = var.storage_class_name
              } : {}
            )
          }
        }
      }
    }
  })]

  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }
}
