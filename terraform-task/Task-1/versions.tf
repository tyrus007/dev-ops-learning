terraform {
  required_version = ">= 1.3.0"

  required_providers {
    # Manages Kubernetes resources (the Nginx pod) once the cluster exists.
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }

    # Used only to shell out to `minikube` and `kubectl`, since there is no
    # native Terraform resource for standing up a Minikube cluster.
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    # Reads the profile's kubeconfig entries (host + certs) via a helper script
    # so the Kubernetes provider can be configured explicitly.
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}
