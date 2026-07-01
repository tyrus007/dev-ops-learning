output "cluster_name" {
  description = "Name of the Minikube profile/cluster."
  value       = var.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint the provider connects to."
  value       = data.external.kube.result.host
}

output "nginx_pod_name" {
  description = "Name of the deployed Nginx pod."
  value       = kubernetes_pod.nginx.metadata[0].name
}

output "nginx_namespace" {
  description = "Namespace the Nginx pod is deployed into."
  value       = kubernetes_pod.nginx.metadata[0].namespace
}

output "verify_command" {
  description = "Command to manually inspect the running pod."
  value       = "kubectl --context=${var.cluster_name} get pod nginx -n ${var.namespace} -o wide"
}
