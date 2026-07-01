# Terraform → Minikube → Nginx

Terraform project that stands up a local 2-node Minikube cluster, connects the
Kubernetes provider to it, deploys an Nginx pod, and verifies the pod is running
— all in a single `terraform apply`.

## What it does

1. **Creates a 2-node Minikube cluster** (`null_resource.minikube_cluster`) by
   shelling out to `minikube start --nodes=2`. Terraform has no native Minikube
   resource, so the CLI is driven via a `local-exec` provisioner. The step also
   waits for the nodes and the `default` service account to exist before the
   provider is used.
2. **Configures the Kubernetes provider** (`providers.tf`) from the cluster's
   kubeconfig entries. A small helper script (`scripts/kubeconfig.sh`) reads the
   API server host and cert paths for the profile and returns them via an
   `external` data source, so nothing is hardcoded.
3. **Deploys an Nginx pod** (`kubernetes_pod.nginx`) into the `default`
   namespace.
4. **Verifies the pod is running** (`null_resource.verify_nginx`) with
   `kubectl wait --for=condition=Ready pod/nginx`. If the pod never becomes
   ready, the apply fails.
5. **Exposes outputs** (`outputs.tf`) so callers can immediately retrieve the
   cluster API endpoint, pod name, namespace, and the exact `kubectl wait`
   command used for verification — no manual inspection required.
6. **Cleans up completely on destroy** — `terraform destroy` tears down the
   Nginx pod and then deletes the Minikube cluster, leaving no leftover
   containers or kubeconfig entries on the host.

## Files

| File                              | Purpose                                                                          |
|-----------------------------------|----------------------------------------------------------------------------------|
| `versions.tf`                     | Terraform and provider version constraints                                       |
| `variables.tf`                    | Input variables: cluster name, node count, driver, namespace, and image          |
| `cluster.tf`                      | Minikube cluster lifecycle and kubeconfig external data source                   |
| `providers.tf`                    | Kubernetes provider wired dynamically to the Minikube profile                    |
| `nginx.tf`                        | Kubernetes pod resource running the Nginx container                              |
| `verify.tf`                       | `kubectl wait` check that confirms the pod reaches the `Ready` condition         |
| `outputs.tf`                      | Exposes cluster endpoint, pod name, namespace, and the verify command            |
| `scripts/kubeconfig.sh`           | Shell script that reads the Minikube profile and emits connection details as JSON |
| `proof of work/image copy.png`    | Screenshot evidence of the cluster and pod running successfully                  |
| [`issues_faced.md`](issues_faced.md) | Problems encountered during development and how they were resolved            |
| [`pre_requisit_installation.md`](pre_requisit_installation.md) | Step-by-step install guide for Docker, Minikube, kubectl, and Terraform |

## Prerequisites

Docker, Minikube, kubectl, Terraform, and `jq` on the host. (Install steps for
the first four are in [pre_requisit_installation.md](pre_requisit_installation.md).)

## Usage

```bash
terraform init
terraform apply      # creates cluster + pod, then verifies
terraform destroy    # deletes the pod and the Minikube cluster
```

## Verify manually

```bash
kubectl --context=tf-minikube get nodes
kubectl --context=tf-minikube get pod nginx -o wide
```
