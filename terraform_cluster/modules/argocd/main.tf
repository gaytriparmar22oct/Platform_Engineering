resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/part-of" = "argocd"
      "managed-by"                = "terraform"
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  # Sensible defaults: HA off in dev, server type ClusterIP (port-forward to reach UI).
  values = [
    var.values != "" ? var.values : yamlencode({
      global = {
        domain = "argocd.local"
      }
      server = {
        service = { type = "ClusterIP" }
        extraArgs = ["--insecure"] # serve UI over HTTP; port-forward in dev
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
      controller = {
        resources = {
          requests = { cpu = "100m", memory = "256Mi" }
          limits   = { cpu = "500m", memory = "512Mi" }
        }
      }
      repoServer = {
        resources = {
          requests = { cpu = "50m", memory = "128Mi" }
          limits   = { cpu = "300m", memory = "256Mi" }
        }
      }
    })
  ]

  timeout = 600
  atomic  = true
}
