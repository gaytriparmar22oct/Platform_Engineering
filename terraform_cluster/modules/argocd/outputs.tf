output "namespace" {
  value = kubernetes_namespace.argocd.metadata[0].name
}

output "release_name" {
  value = helm_release.argocd.name
}

output "port_forward_cmd" {
  value = "kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} port-forward svc/argocd-server 8081:80"
}

output "initial_admin_secret_cmd" {
  value = "kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
