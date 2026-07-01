# ---------------------------------------------------------------------------
# Nginx pod
#
# A single Nginx pod deployed to the cluster. Creation blocks until the pod is
# scheduled and enters the Running phase (see timeouts below). Readiness is then
# asserted explicitly by the verify step in verify.tf.
# ---------------------------------------------------------------------------

resource "kubernetes_pod" "nginx" {
  metadata {
    name      = "nginx"
    namespace = var.namespace
    labels = {
      app = "nginx"
    }
  }

  spec {
    container {
      name  = "nginx"
      image = var.nginx_image

      port {
        container_port = 80
      }
    }
  }

  # Block until the pod is scheduled and running.
  timeouts {
    create = "5m"
  }
}
