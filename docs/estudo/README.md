# EKS + Grafana Lab (README de estudo)

Este documento explica o que foi construido no lab e o por que das escolhas,
para servir como guia de estudo. O README da raiz continua como entrada rapida.

## Objetivo do lab
- Provisionar um cluster EKS com Terraform.
- Instalar o kube-prometheus-stack (Prometheus + Grafana) via Helm.
- Explorar dashboards do Grafana para entender metricas do Kubernetes.

## O que foi construido
- VPC com subnets publicas e privadas, NAT gateway e tags para LB.
- Cluster EKS com managed node group e add-ons basicos.
- Observabilidade com Prometheus, Grafana, node-exporter e kube-state-metrics.
- Saidas Terraform para URL e senha do Grafana.

## Estrutura do Terraform
- Root: `main.tf`, `providers.tf`, `variables.tf`, `locals.tf`, `outputs.tf`.
- Modulos:
  - `modules/vpc`: rede e subnets.
  - `modules/eks`: cluster, OIDC e node group.
  - `modules/observability`: Helm release do kube-prometheus-stack.

## Fluxo de dados (metricas)
1. Componentes do cluster e exporters expõem metricas.
2. Prometheus coleta e armazena essas series.
3. Grafana consulta o Prometheus e renderiza dashboards.

## Decisoes importantes
- `node_instance_type`: padrao `t3.small` para caber o stack.
- `prometheus_storage_gi`: padrao `0` para desabilitar PVC no lab.
- `grafana_lb_source_cidrs`: vazio deixa o LoadBalancer aberto.
- `providers.tf`: Kubernetes/Helm usam `aws eks get-token` (exec) para auth.

## O que estudar primeiro
- `modules/vpc`: como subnets e tags permitem LoadBalancers do K8s.
- `modules/eks`: como o node group e add-ons formam o cluster.
- `modules/observability`: como Helm instala o stack e define valores.
- `outputs.tf`: como expor URL e senha do Grafana.

## Problemas comuns e por que acontecem
- Pods pendentes por capacidade: nodes pequenos nao comportam o stack.
- PVC pendente: sem driver EBS CSI, o storage nao provisiona.
- LB sem IP: o LoadBalancer pode demorar alguns minutos.

## O que mudar depois
- Habilitar persistencia do Prometheus:
  - Instalar EBS CSI driver.
  - Definir `prometheus_storage_gi` e `storage_class_name`.
- Restringir acesso ao Grafana:
  - Definir `grafana_lb_source_cidrs` com seu IP.

## Referencias rapidas
- Validar: `terraform fmt -check` e `terraform validate`.
- Ver pods: `kubectl get pods -n monitoring`.
- Ver URL/senha: `terraform output -raw grafana_url` e `terraform output -raw grafana_admin_password`.

## Limpeza
- `terraform destroy`
