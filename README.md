# module-eks-lab

Minimal lab to provision EKS with Terraform and explore Grafana dashboards
from kube-prometheus-stack.

## Architecture
- VPC with public and private subnets
- EKS cluster with managed node group
- Prometheus scraping cluster metrics
- Grafana visualizing Prometheus data

## Data flow
- Exporters and Kubernetes components emit metrics
- Prometheus scrapes and stores metrics
- Grafana queries Prometheus and renders dashboards

## Quick usage
```bash
terraform init
terraform apply
terraform output -raw grafana_url
terraform output -raw grafana_admin_password
```

Check pods:
```bash
kubectl get pods -n monitoring
```

## Validation
```bash
terraform fmt -check
terraform validate
```

## Docs
- Full lab guide: `docs/lab-eks-grafana.md`
- Implementation plan: `docs/plans/2026-01-30-terraform-eks-grafana-lab-implementation.md`

## Cleanup
```bash
terraform destroy
```
