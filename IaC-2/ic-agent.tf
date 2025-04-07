resource "kubernetes_namespace" "ic_agent_namespace" {
  metadata {
    name = "ic-agent-namespace"
  }
}

resource "kubernetes_deployment" "ic_agent" {
  metadata {
    name      = "ic-agent"
    namespace = kubernetes_namespace.ic_agent_namespace.metadata[0].name
    labels    = { app = "ic-agent" }
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "ic-agent" }
    }

    template {
      metadata {
        labels = { app = "ic-agent" }
      }

      spec {
        toleration {
          key      = "virtual-kubelet.io/provider"
          operator = "Equal"
          value    = "azure"
          effect   = "NoSchedule"
        }

        toleration {
          key      = "node.kubernetes.io/unreachable"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        toleration {
          key      = "node.kubernetes.io/unreachable"
          operator = "Exists"
          effect   = "NoExecute"
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
                    values   = ["ic-agent"] 
                  }
                }
              }
            }
          }
        }


        container {
          image = "ghcr.io/timburkei/ic-agent:latest"
          name  = "ic-agent"

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
          env {
            name  = "COMPRESSION_PERCENTAGE"
            value = "30"
          }
          env {
            name  = "MAX_MESSAGE_COUNT"
            value = "1"
          }
          env {
            name  = "OUTPUT_AZURE_BLOB_STORAGE_CONTAINER_NAME"
            value = data.terraform_remote_state.infrastructure.outputs.output_azure_blob_storage_container_name
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "ic_agent_scaledobject" {
  depends_on = [helm_release.keda]
  manifest = {
    apiVersion = "keda.sh/v1alpha1"
    kind       = "ScaledObject"
    metadata = {
      name      = "ic-agent-scaler"
      namespace = kubernetes_namespace.ic_agent_namespace.metadata[0].name
    }
    spec = {
      scaleTargetRef = {
        name = kubernetes_deployment.ic_agent.metadata[0].name
      }
      pollingInterval = 15
      minReplicaCount = 1
      maxReplicaCount = 10
      triggers = [
        {
          type = "azure-servicebus"
          metadata = {
            queueName    = data.terraform_remote_state.infrastructure.outputs.input_service_bus_queue_name
            messageCount = "5"
          }
          authenticationRef = {
            name = "azure-servicebus-auth"
          }
        }
      ]
    }
  }
  #depends_on = [null_resource.wait_for_keda_crds]
}

resource "kubernetes_manifest" "azure_servicebus_auth" {
  manifest = {
    apiVersion = "keda.sh/v1alpha1"
    kind       = "TriggerAuthentication"
    metadata = {
      name      = "azure-servicebus-auth"
      namespace = kubernetes_namespace.ic_agent_namespace.metadata[0].name
    }
    spec = {
      secretTargetRef = [
        {
          parameter = "connection"
          name      = "servicebus-connection-secret"
          key       = "connection-string"
        }
      ]
    }
  }

}

resource "kubernetes_secret" "servicebus_connection_secret" {
  metadata {
    name      = "servicebus-connection-secret"
    namespace = kubernetes_namespace.ic_agent_namespace.metadata[0].name
  }
  data = {
    "connection-string" = data.terraform_remote_state.infrastructure.outputs.input_service_bus_connection_string
  }
}
