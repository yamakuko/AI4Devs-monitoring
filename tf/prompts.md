# Prompts para Configuración de Infraestructura

## Configuración de Datadog

### Dominio de Datadog
Es importante asegurarse de que todas las configuraciones usen el dominio correcto de Datadog:
- Para usuarios en la región EU: `datadoghq.eu`
- Para usuarios en la región US: `datadoghq.com`

La configuración del dominio debe ser consistente en:
1. Provider de Terraform (`datadog_provider.tf`)
2. Scripts de user data de las instancias EC2
3. Archivo de configuración del agente (`datadog.yaml`)

### Solución de Problemas
Si encuentras errores como:
```
API Key invalid, dropping transaction for https://process.datadoghq.com/api/v1/collector
```
Verifica que:
1. El archivo `/etc/datadog-agent/datadog.yaml` tenga configurado el sitio correcto:
```yaml
site: datadoghq.eu  # o datadoghq.com según tu región
```
2. Los scripts de user data (`backend_user_data.sh` y `frontend_user_data.sh`) usen el dominio correcto
3. El provider de Terraform esté configurado con la URL correcta 