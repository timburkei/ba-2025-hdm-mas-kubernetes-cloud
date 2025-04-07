resource "kubernetes_namespace" "keda" {
  metadata {
    name = "keda"
  }
}

resource "helm_release" "keda" {
  name          = "keda"
  repository    = "https://kedacore.github.io/charts"
  chart         = "keda"
  namespace     = kubernetes_namespace.keda.metadata[0].name
  wait          = true
  wait_for_jobs = true
  timeout       = 300
}