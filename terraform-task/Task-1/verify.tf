# ---------------------------------------------------------------------------
# Verification
#
# Explicitly confirm the pod reached the Running phase using `kubectl wait`.
# This runs after the pod is created and fails the apply if the condition is
# not met within the timeout, making "the pod is running" an enforced outcome.
# ---------------------------------------------------------------------------

resource "null_resource" "verify_nginx" {
  depends_on = [kubernetes_pod.nginx]

  triggers = {
    pod_uid = kubernetes_pod.nginx.metadata[0].uid
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      kubectl --context="${var.cluster_name}" \
        wait --for=condition=Ready pod/nginx \
        --namespace="${var.namespace}" --timeout=120s
      echo "---"
      kubectl --context="${var.cluster_name}" \
        get pod nginx --namespace="${var.namespace}" -o wide
    EOT
  }
}
