data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  name               = var.cluster_name
  cidr               = var.vpc_cidr
  availability_zones = local.azs

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  node_instance_type = var.node_instance_type
  node_min           = var.node_min
  node_max           = var.node_max

  tags = local.common_tags
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

module "observability" {
  source = "./modules/observability"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  grafana_admin_user         = var.grafana_admin_user
  grafana_admin_password     = local.grafana_admin_password
  grafana_lb_source_cidrs     = var.grafana_lb_source_cidrs
  grafana_persistence_enabled = var.grafana_persistence_enabled
  grafana_persistence_size    = var.grafana_persistence_size
  prometheus_retention        = var.prometheus_retention
  prometheus_storage_gi       = var.prometheus_storage_gi
  storage_class_name          = var.storage_class_name

  depends_on = [module.eks]
}

data "kubernetes_service" "grafana" {
  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = module.observability.namespace
  }

  depends_on = [module.observability]
}
