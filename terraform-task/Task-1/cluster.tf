# ---------------------------------------------------------------------------
# Minikube cluster
#
# Terraform has no native resource for a Minikube cluster, so we drive the
# `minikube` CLI through a null_resource. `minikube start --nodes 2` creates a
# 2-node cluster and writes credentials into the default kubeconfig
# (~/.kube/config) under a context named after the profile.
# ---------------------------------------------------------------------------

resource "null_resource" "minikube_cluster" {
  # Re-create the cluster if any of these inputs change.
  triggers = {
    cluster_name       = var.cluster_name
    node_count         = var.node_count
    driver             = var.driver
    kubernetes_version = var.kubernetes_version
  }

  # Start the cluster, then wait for the cluster to be fully ready. The
  # `default` service account is created asynchronously by the controller
  # manager shortly after the API server is up; pod creation fails until it
  # exists, so we block on it here.
  provisioner "local-exec" {
    command = <<-EOT
      minikube start \
        --profile="${var.cluster_name}" \
        --nodes=${var.node_count} \
        --driver="${var.driver}" \
        ${var.kubernetes_version != "" ? "--kubernetes-version=${var.kubernetes_version}" : ""}

      echo "Waiting for all nodes to be Ready..."
      kubectl --context="${var.cluster_name}" wait --for=condition=Ready nodes --all --timeout=120s

      echo "Waiting for the default service account..."
      for i in $(seq 1 30); do
        if kubectl --context="${var.cluster_name}" -n "${var.namespace}" get serviceaccount default >/dev/null 2>&1; then
          echo "default service account is present."
          break
        fi
        sleep 2
      done
    EOT
  }

  # Tear the cluster down on `terraform destroy`.
  provisioner "local-exec" {
    when    = destroy
    command = "minikube delete --profile=${self.triggers.cluster_name}"
  }
}

# Read the freshly-written kubeconfig entries for this profile so the
# Kubernetes provider can connect without hardcoding host/certs.
data "external" "kube" {
  depends_on = [null_resource.minikube_cluster]

  program = ["bash", "${path.module}/scripts/kubeconfig.sh", var.cluster_name]
}
