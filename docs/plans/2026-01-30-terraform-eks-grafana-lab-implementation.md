# Terraform EKS + Grafana Lab Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Provision an AWS EKS lab with Terraform and deploy kube-prometheus-stack (Prometheus + Grafana) in-cluster for metrics visualization.

**Architecture:** Root Terraform config wires VPC, EKS, and observability modules. Observability uses Helm + Kubernetes providers configured from EKS outputs to install kube-prometheus-stack and expose Grafana via LoadBalancer.

**Tech Stack:** Terraform, terraform-aws-modules/vpc, terraform-aws-modules/eks, Helm provider, Kubernetes provider, kube-prometheus-stack chart.

Use @superpowers:executing-plans for execution and @superpowers:verification-before-completion before declaring completion.

---

### Task 1: Repository layout scaffolding

**Files:**
- Create: `scripts/check-layout.sh`
- Create: `modules/vpc/`
- Create: `modules/eks/`
- Create: `modules/observability/`

**Step 1: Write the failing test**

Create `scripts/check-layout.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

missing=0
for dir in modules/vpc modules/eks modules/observability; do
  if [ ! -d "$dir" ]; then
    echo "Missing directory: $dir"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "Layout OK"
```

Make it executable:

```bash
chmod +x scripts/check-layout.sh
```

**Step 2: Run test to verify it fails**

Run: `bash scripts/check-layout.sh`
Expected: FAIL with missing directory messages.

**Step 3: Write minimal implementation**

Create directories:

```bash
mkdir -p modules/vpc modules/eks modules/observability
```

**Step 4: Run test to verify it passes**

Run: `bash scripts/check-layout.sh`
Expected: PASS with "Layout OK".

**Step 5: Commit**

```bash
git add scripts/check-layout.sh modules

git commit -m "chore: scaffold module directories"
```

### Task 2: VPC module

**Files:**
- Create: `scripts/validate-vpc.sh`
- Create: `modules/vpc/main.tf`
- Create: `modules/vpc/variables.tf`
- Create: `modules/vpc/outputs.tf`

**Step 1: Write the failing test**

Create `scripts/validate-vpc.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

terraform -chdir=modules/vpc init -backend=false -upgrade=false
terraform -chdir=modules/vpc validate
```

Make it executable:

```bash
chmod +x scripts/validate-vpc.sh
```

**Step 2: Run test to verify it fails**

Run: `bash scripts/validate-vpc.sh`
Expected: FAIL with "No configuration files".

**Step 3: Write minimal implementation**

Create `modules/vpc/variables.tf`:

```hcl
variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

Create `modules/vpc/main.tf`:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = var.name
  cidr = var.cidr
  azs  = var.availability_zones

  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = var.tags
}
```

Create `modules/vpc/outputs.tf`:

```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}
```

**Step 4: Run test to verify it passes**

Run: `bash scripts/validate-vpc.sh`
Expected: PASS.

**Step 5: Commit**

```bash
git add scripts/validate-vpc.sh modules/vpc

git commit -m "feat: add VPC module"
```

### Task 3: EKS module

**Files:**
- Create: `scripts/validate-eks.sh`
- Create: `modules/eks/main.tf`
- Create: `modules/eks/variables.tf`
- Create: `modules/eks/outputs.tf`

**Step 1: Write the failing test**

Create `scripts/validate-eks.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

terraform -chdir=modules/eks init -backend=false -upgrade=false
terraform -chdir=modules/eks validate
```

Make it executable:

```bash
chmod +x scripts/validate-eks.sh
```

**Step 2: Run test to verify it fails**

Run: `bash scripts/validate-eks.sh`
Expected: FAIL with "No configuration files".

**Step 3: Write minimal implementation**

Create `modules/eks/variables.tf`:

```hcl
variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "node_instance_type" {
  type = string
}

variable "node_min" {
  type = number
}

variable "node_max" {
  type = number
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

Create `modules/eks/main.tf`:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.11.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  enable_irsa                                 = true
  enable_cluster_creator_admin_permissions    = true
  cluster_endpoint_public_access              = true

  cluster_addons = {
    coredns   = {}
    kube-proxy = {}
    vpc-cni   = {}
  }

  eks_managed_node_groups = {
    default = {
      name           = "default"
      instance_types = [var.node_instance_type]
      min_size       = var.node_min
      max_size       = var.node_max
      desired_size   = var.node_min
      subnet_ids     = var.private_subnet_ids
    }
  }

  tags = var.tags
}
```

Create `modules/eks/outputs.tf`:

```hcl
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
```

**Step 4: Run test to verify it passes**

Run: `bash scripts/validate-eks.sh`
Expected: PASS.

**Step 5: Commit**

```bash
git add scripts/validate-eks.sh modules/eks

git commit -m "feat: add EKS module"
```

### Task 4: Observability module (kube-prometheus-stack)

**Files:**
- Create: `scripts/validate-observability.sh`
- Create: `modules/observability/main.tf`
- Create: `modules/observability/variables.tf`
- Create: `modules/observability/outputs.tf`

**Step 1: Write the failing test**

Create `scripts/validate-observability.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

terraform -chdir=modules/observability init -backend=false -upgrade=false
terraform -chdir=modules/observability validate
```

Make it executable:

```bash
chmod +x scripts/validate-observability.sh
```

**Step 2: Run test to verify it fails**

Run: `bash scripts/validate-observability.sh`
Expected: FAIL with "No configuration files".

**Step 3: Write minimal implementation**

Create `modules/observability/variables.tf`:

```hcl
variable "namespace" {
  type    = string
  default = "monitoring"
}

variable "chart_version" {
  type    = string
  default = "58.2.0"
}

variable "grafana_admin_user" {
  type    = string
  default = "admin"
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "grafana_lb_source_cidrs" {
  type    = list(string)
  default = []
}

variable "grafana_persistence_enabled" {
  type    = bool
  default = false
}

variable "grafana_persistence_size" {
  type    = string
  default = "10Gi"
}

variable "prometheus_retention" {
  type    = string
  default = "7d"
}

variable "prometheus_storage_gi" {
  type    = number
  default = 20
}

variable "storage_class_name" {
  type    = string
  default = ""
}
```

Create `modules/observability/main.tf`:

```hcl
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
      adminPassword = var.grafana_admin_password
      service = {
        type = "LoadBalancer"
        loadBalancerSourceRanges = var.grafana_lb_source_cidrs
      }
      persistence = {
        enabled          = var.grafana_persistence_enabled
        size             = var.grafana_persistence_size
        storageClassName = var.storage_class_name != "" ? var.storage_class_name : null
      }
    }
    prometheus = {
      prometheusSpec = {
        retention = var.prometheus_retention
        storageSpec = {
          volumeClaimTemplate = {
            spec = {
              storageClassName = var.storage_class_name != "" ? var.storage_class_name : null
              accessModes = ["ReadWriteOnce"]
              resources = {
                requests = {
                  storage = "${var.prometheus_storage_gi}Gi"
                }
              }
            }
          }
        }
      }
    }
  })]
}
```

Create `modules/observability/outputs.tf`:

```hcl
output "namespace" {
  value = kubernetes_namespace.monitoring.metadata[0].name
}

output "release_name" {
  value = helm_release.kube_prometheus_stack.name
}
```

**Step 4: Run test to verify it passes**

Run: `bash scripts/validate-observability.sh`
Expected: PASS.

**Step 5: Commit**

```bash
git add scripts/validate-observability.sh modules/observability

git commit -m "feat: add observability module"
```

### Task 5: Root wiring and outputs

**Files:**
- Create: `scripts/validate-root.sh`
- Create: `versions.tf`
- Create: `providers.tf`
- Create: `variables.tf`
- Create: `locals.tf`
- Create: `main.tf`
- Create: `outputs.tf`
- Create: `terraform.tfvars.example`

**Step 1: Write the failing test**

Create `scripts/validate-root.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

terraform fmt -check
terraform init -backend=false -upgrade=false
terraform validate
```

Make it executable:

```bash
chmod +x scripts/validate-root.sh
```

**Step 2: Run test to verify it fails**

Run: `bash scripts/validate-root.sh`
Expected: FAIL with missing Terraform configuration.

**Step 3: Write minimal implementation**

Create `versions.tf`:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
```

Create `variables.tf`:

```hcl
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
```

Create `providers.tf`:

```hcl
provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
```

Create `locals.tf`:

```hcl
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
```

Create `main.tf`:

```hcl
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

  grafana_admin_user            = var.grafana_admin_user
  grafana_admin_password        = local.grafana_admin_password
  grafana_lb_source_cidrs        = var.grafana_lb_source_cidrs
  grafana_persistence_enabled    = var.grafana_persistence_enabled
  grafana_persistence_size       = var.grafana_persistence_size
  prometheus_retention           = var.prometheus_retention
  prometheus_storage_gi          = var.prometheus_storage_gi
  storage_class_name             = var.storage_class_name

  depends_on = [module.eks]
}

data "kubernetes_service" "grafana" {
  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = module.observability.namespace
  }

  depends_on = [module.observability]
}
```

Create `outputs.tf`:

```hcl
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
```

Create `terraform.tfvars.example`:

```hcl
region = "us-east-1"
cluster_name = "eks-lab"

public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

node_instance_type = "t3.medium"
node_min = 1
node_max = 3

grafana_lb_source_cidrs = ["203.0.113.10/32"]
```

**Step 4: Run test to verify it passes**

Run: `bash scripts/validate-root.sh`
Expected: PASS.

**Step 5: Commit**

```bash
git add scripts/validate-root.sh versions.tf providers.tf variables.tf locals.tf main.tf outputs.tf terraform.tfvars.example

git commit -m "feat: wire root Terraform configuration"
```
