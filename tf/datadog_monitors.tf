# Monitor de uso de CPU
resource "datadog_monitor" "cpu_usage" {
  name    = "CPU Usage Alert"
  type    = "metric alert"
  query   = "avg(last_5m):avg:aws.ec2.cpuutilization{*} > 80"
  message = <<-EOT
    CPU usage is too high on {{host.name}}
    Current value: {{value}}
    Threshold: 80%
    Environment: {{env}}
  EOT
  tags    = ["env:${var.environment}", "service:ec2"]
}

# Monitor de uso de memoria
resource "datadog_monitor" "memory_usage" {
  name    = "Memory Usage Alert"
  type    = "metric alert"
  query   = "avg(last_5m):avg:aws.ec2.memory.used{*} / avg:aws.ec2.memory.total{*} * 100 > 85"
  message = <<-EOT
    Memory usage is too high on {{host.name}}
    Current value: {{value}}%
    Threshold: 85%
    Environment: {{env}}
  EOT
  tags    = ["env:${var.environment}", "service:ec2"]
}

# Monitor de espacio en disco
resource "datadog_monitor" "disk_usage" {
  name    = "Disk Usage Alert"
  type    = "metric alert"
  query   = "avg(last_5m):avg:aws.ec2.disk.used{*} / avg:aws.ec2.disk.total{*} * 100 > 90"
  message = <<-EOT
    Disk usage is too high on {{host.name}}
    Current value: {{value}}%
    Threshold: 90%
    Environment: {{env}}
  EOT
  tags    = ["env:${var.environment}", "service:ec2"]
} 