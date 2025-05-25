# Dashboard principal para monitoreo de infraestructura
resource "datadog_dashboard" "infrastructure_dashboard" {
  title       = "Infraestructura AWS"
  description = "Dashboard para monitorear la infraestructura AWS"
  layout_type = "free"

  widget {
    widget_layout {
      x      = 0
      y      = 0
      width  = 47
      height = 15
    }
    timeseries_definition {
      title = "Uso de CPU por Instancia"
      request {
        q = "avg:aws.ec2.cpuutilization{*} by {instance-id}"
        display_type = "line"
      }
    }
  }

  widget {
    widget_layout {
      x      = 47
      y      = 0
      width  = 47
      height = 15
    }
    timeseries_definition {
      title = "Uso de Memoria por Instancia"
      request {
        q = "avg:system.mem.used{*} by {host}"
        display_type = "line"
      }
    }
  }

  widget {
    widget_layout {
      x      = 0
      y      = 15
      width  = 47
      height = 15
    }
    timeseries_definition {
      title = "Uso de Disco por Instancia"
      request {
        q = "avg:system.disk.used{*} by {host}"
        display_type = "line"
      }
    }
  }

#  widget {
#    widget_layout {
#      x      = 47
#      y      = 15
#      width  = 47
#      height = 15
#    }
    #group_definition {
    #  title = "Estado de Contenedores Docker"
    #  layout_type = "ordered"
    #  widget {
    #    timeseries_definition {
    #      request {
    #        q = "sum:docker.containers.running{*} by {host}"
    #        display_type = "line"
    #      }
    #    }
    #  }
    #}
 # }

  widget {
    widget_layout {
      x      = 0
      y      = 30
      width  = 94
      height = 15
    }
    log_stream_definition {
      title = "Logs de Aplicación"
      query = "service:docker"
      indexes = ["*"]
    }
  }

  widget {
    widget_layout {
      x      = 0
      y      = 45
      width  = 94
      height = 15
    }
    alert_graph_definition {
      title = "Alertas Activas"
      alert_id = datadog_monitor.cpu_usage.id
      viz_type = "timeseries"
    }
  }

  template_variable {
    name    = "environment"
    prefix  = "env"
    defaults = [var.environment]
  }

  template_variable {
    name    = "service"
    prefix  = "service"
    defaults = ["all"]
  }

  # Tags para el dashboard
 # tags = [
  #  "team:ai4devs",
  #  "env:development",
  #  "managed-by:terraform",
  #  "service:monitoring"
  #]
} 

# Output de debug temporal para ver cómo se están generando los tags
output "dashboard_tags" {
  value = [
    "team:ai4devs",
    "env:development",
    "managed-by:terraform",
    "service:monitoring"
  ]
}