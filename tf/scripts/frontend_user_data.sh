#!/bin/bash
sudo yum update -y
sudo yum install -y docker

# Iniciar el servicio de Docker
sudo service docker start

# Instalar el agente Datadog
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${datadog_api_key} DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Configurar el agente Datadog
cat > /etc/datadog-agent/datadog.yaml << EOF
api_key: ${datadog_api_key}
site: datadoghq.com
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
tags:
  - env:${environment}
  - service:frontend
  - purpose:test
EOF

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

# Descargar y descomprimir el archivo frontend.zip desde S3
aws s3 cp s3://ai4devs-project-code-bucket-cnv/frontend.zip /home/ec2-user/frontend.zip
unzip /home/ec2-user/frontend.zip -d /home/ec2-user/

# Construir la imagen Docker para el frontend
cd /home/ec2-user/frontend
sudo docker build -t lti-frontend .

# Ejecutar el contenedor Docker con logging configurado
sudo docker run -d \
  --log-driver json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  -p 3000:3000 \
  lti-frontend

# Timestamp to force update
echo "Timestamp: ${timestamp}"
