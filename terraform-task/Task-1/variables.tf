variable "cluster_name" {
  description = "Name of the Minikube profile/cluster to create."
  type        = string
  default     = "tf-minikube"
}

variable "node_count" {
  description = "Number of nodes in the Minikube cluster."
  type        = number
  default     = 2
}

variable "driver" {
  description = "Minikube driver to use (docker is the simplest for local learning)."
  type        = string
  default     = "docker"
}

variable "minikube_memory" {
  description = "Memory (in MiB) to allocate to the Minikube VM/container. Requires enough RAM+swap to be available to Docker."
  type        = string
  default     = "1800mb"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the Minikube cluster. Empty means Minikube's default."
  type        = string
  default     = ""
}

variable "namespace" {
  description = "Namespace to deploy the Nginx pod into."
  type        = string
  default     = "default"
}

variable "nginx_image" {
  description = "Nginx container image to deploy."
  type        = string
  default     = "nginx:1.27"
}
