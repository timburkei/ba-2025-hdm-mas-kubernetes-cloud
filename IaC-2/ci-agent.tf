resource "kubernetes_namespace" "ci_agent_namespace" {
  metadata {
    name = "ci-agent-namespace"
  }
}

resource "kubernetes_deployment" "ci_agent" {
  metadata {
    name      = "ci-agent"
    namespace = kubernetes_namespace.ci_agent_namespace.metadata[0].name
    labels    = { app = "ci-agent" }
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "ci-agent" }
    }

    template {
      metadata {
        labels = { app = "ci-agent" }
      }

      spec {

        toleration {
          key      = "virtual-kubelet.io/provider"
          operator = "Equal"
          value    = "azure"
          effect   = "NoSchedule"
        }

        affinity {
          node_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              preference {
                match_expressions {
                  key      = "node-type"
                  operator = "In"
                  values   = ["aks-vm"]
                }
              }
            }
          }
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 5
              pod_affinity_term {
                topology_key = "kubernetes.io/hostname"
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = ["ci-agent"]
                  }
                }
              }
            }
          }
        }


        container {
          image = "ghcr.io/timburkei/ci-agent:latest"
          name  = "ci-agent"

          resources {
            requests = {
              cpu    = "250m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "128Mi"
            }
          }

          env {
            name  = "AZURE_BLOB_STORAGE_CONNECTION_STRING"
            value = data.terraform_remote_state.infrastructure.outputs.azure_blob_storage_connection_string
          }
          env {
            name  = "INPUT_AZURE_BLOB_STORAGE_CONTAINER_NAME"
            value = data.terraform_remote_state.infrastructure.outputs.input_azure_blob_storage_container_name
          }
          env {
            name  = "INPUT_SERVICE_BUS_CONNECTION_STRING"
            value = data.terraform_remote_state.infrastructure.outputs.input_service_bus_connection_string
          }
          env {
            name  = "INPUT_SERVICE_BUS_QUEUE_NAME"
            value = data.terraform_remote_state.infrastructure.outputs.input_service_bus_queue_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ci_agent_service" {
  metadata {
    name      = "ci-agent-service"
    namespace = kubernetes_namespace.ci_agent_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.ci_agent.metadata[0].labels.app
    }

    port {
      name        = "http"
      port        = 80
      target_port = 5001
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "ci_agent_hpa" {
  metadata {
    name      = "ci-agent-hpa"
    namespace = kubernetes_namespace.ci_agent_namespace.metadata[0].name
  }

  spec {
    max_replicas                      = 10
    min_replicas                      = 1
    target_cpu_utilization_percentage = 5

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.ci_agent.metadata[0].name
    }
  }
}




