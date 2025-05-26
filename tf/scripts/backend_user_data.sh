#!/bin/bash
yum update -y
sudo yum install -y docker

# Iniciar el servicio de Docker
sudo service docker start

# Instalar el agente Datadog
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${datadog_api_key} DD_SITE="datadoghq.eu" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Verificar la instalación
echo "Verificando instalación de Datadog..."
ls -l /etc/datadog-agent/
cat /etc/datadog-agent/datadog.yaml | grep site

# Configurar el agente Datadog
cat > /etc/datadog-agent/datadog.yaml << EOF
api_key: ${datadog_api_key}
site: datadoghq.eu
logs:
  enabled: true
  logs_config_container_collect_all: true
  logs_config_processing_enabled: true
  logs_config_use_http: true
  logs_config_use_compression: true
  logs_config_compression_level: 6
  logs_config_batch_wait: 5
  logs_config_batch_size: 100
  logs_config_exclude_paths:
    - /var/log/datadog/agent.log
    - /var/log/datadog/process-agent.log
  logs_config_include_paths:
    - /var/log/docker/*.log
    - /var/log/containers/*.log
process_config:
  enabled: true
  process_collection:
    enabled: true
    interval: 10
  process_dd_url: https://process.datadoghq.eu
  process_agent_dd_url: https://process.datadoghq.eu
  process_agent_url: https://process.datadoghq.eu
tags:
  - env:${environment}
  - service:backend
  - purpose:test
EOF

# Verificar la configuración después de aplicarla
echo "Verificando configuración después de aplicarla..."
cat /etc/datadog-agent/datadog.yaml | grep site

# Configurar Docker para enviar logs a Datadog
cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# Reiniciar Docker para aplicar la configuración
sudo systemctl restart docker

# Reiniciar el agente Datadog
sudo systemctl restart datadog-agent

# Verificar la configuración después del reinicio
echo "Verificando configuración después del reinicio..."
cat /etc/datadog-agent/datadog.yaml | grep site

# Descargar y descomprimir el archivo backend.zip desde S3
aws s3 cp s3://ai4devs-project-code-bucket-cnv/backend.zip /home/ec2-user/backend.zip
unzip /home/ec2-user/backend.zip -d /home/ec2-user/

# Construir la imagen Docker para el backend
cd /home/ec2-user/backend
sudo docker build -t lti-backend .

# Ejecutar el contenedor Docker con logging configurado
sudo docker run -d \
  --log-driver json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  -p 8080:8080 \
  lti-backend

# Timestamp to force update
echo "Timestamp: ${timestamp}"
