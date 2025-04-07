data "azurerm_lb" "aks_load_balancer" {
  name                = "kubernetes"
  resource_group_name = "MC_thesis-25-hdm-stuttgart_thesis-aks-cluster-hdm-25_westeurope"
  depends_on          = [kubernetes_service.ci_agent_service]
}

resource "azurerm_monitor_diagnostic_setting" "lb_monitoring" {
  name                       = "lb-monitoring"
  target_resource_id         = data.azurerm_lb.aks_load_balancer.id
  log_analytics_workspace_id = data.terraform_remote_state.infrastructure.outputs.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}