# Auto-Healing Web Tier
Azure + Terraform

This solution deploys web tier with high availability
using : Azure VM Scale Set (VMSS)
        Azure Load Balancer

using Azure bacause Azure VM Scale Sets provide Native self-healing via instance health monitoring + automatic repair, Built-in scaling and integration with Load Balancer probes

Self-healing: unhealthy or deleted vMs are automatically replaced
self provisioning: Infra will be provisioned by terrafrom. Terraform apply command will build the infrastructure
as Infra is managed by terraform state files, a 2nd run will make no change to infrastructure
we have created minimum 2 instances for azure vm scale set (N+1)
Load balancing across 2 instances
command to deploy:
for initialization of plugins - terraform init
to plan - terraform plan
to apply - terraform apply -auto-approve


diagram:
attached
