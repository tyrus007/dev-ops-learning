# ---------------------------------------------------------------------------
# Kubernetes provider
#
# Configured from the Minikube profile's kubeconfig entries (read via the
# external data source in cluster.tf). Minikube writes certificate *file paths*
# into kubeconfig, so we point the provider at those files directly.
# ---------------------------------------------------------------------------

provider "kubernetes" {
  host = data.external.kube.result.host

  cluster_ca_certificate = file(data.external.kube.result.cluster_ca_certificate)
  client_certificate     = file(data.external.kube.result.client_certificate)
  client_key             = file(data.external.kube.result.client_key)
}
