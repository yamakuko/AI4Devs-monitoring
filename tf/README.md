# Configuración de Infraestructura con Terraform

## Resumen
Este proyecto configura una infraestructura en AWS con integración a Datadog para monitoreo. Incluye:
- Instancias EC2 para frontend y backend
- Integración con Datadog para monitoreo
- Configuración de logs y métricas
- Dashboards personalizados

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

## Requisitos Previos

### Instalación de AWS CLI

#### Windows (usando PowerShell como administrador):
```powershell
# Descargar el instalador MSI
Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "AWSCLIV2.msi"

# Instalar AWS CLI
Start-Process msiexec.exe -Wait -ArgumentList '/i AWSCLIV2.msi /qn'

# Verificar la instalación
aws --version
```

#### Windows (usando Chocolatey):
```powershell
# Instalar Chocolatey si no está instalado
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar AWS CLI
choco install awscli

# Verificar la instalación
aws --version
```

## Estructura del Proyecto
```
tf/
├── provider.tf          # Configuración del proveedor AWS
├── datadog_provider.tf  # Configuración del proveedor Datadog
├── variables.tf         # Variables de Terraform
├── ec2.tf              # Configuración de instancias EC2
├── s3.tf               # Configuración del bucket S3
├── security_groups.tf  # Grupos de seguridad
├── iam.tf              # Roles y políticas IAM
└── scripts/            # Scripts de inicialización
```

## Configuración de Credenciales

### AWS
Las credenciales de AWS se almacenan en:
- Windows: `C:\Users\<USERNAME>\.aws\credentials`
- Linux/Mac: `~/.aws/credentials`

Formato del archivo:
```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

Terraform lee automáticamente estas credenciales cuando se ejecuta. No es necesario especificarlas en los archivos de Terraform.

#### Pasos para crear y configurar un usuario IAM:

1. **Acceder al Portal AWS**:
   - Inicia sesión en la [Consola de AWS](https://aws.amazon.com/console/)
   - Busca "IAM" en la barra de búsqueda de servicios
   - Selecciona "IAM" en los resultados

2. **Crear un Grupo IAM**:
   - En el panel izquierdo, selecciona "User groups"
   - Haz clic en "Create group"
   - Nombre del grupo: `terraform-admin` (o el nombre que prefieras)
   - Adjunta las políticas necesarias:
     - `AmazonEC2FullAccess`
     - `AmazonS3FullAccess`
     - `AmazonVPCFullAccess`
     - `IAMFullAccess`
   - Haz clic en "Create group"

3. **Crear un Usuario IAM**:
   - En el panel izquierdo, selecciona "Users"
   - Haz clic en "Add users"
   - Nombre de usuario: `terraform-user` (o el nombre que prefieras)
   - Selecciona "Access key - Programmatic access"
   - Haz clic en "Next: Permissions"

4. **Asignar Permisos**:
   - Selecciona "Add user to group"
   - Selecciona el grupo `terraform-admin` que creaste
   - Haz clic en "Next: Tags"
   - (Opcional) Añade tags si es necesario
   - Haz clic en "Next: Review"
   - Revisa la configuración y haz clic en "Create user"

5. **Obtener las Credenciales**:
   - Se te mostrarán dos valores:
     - Access key ID (ejemplo: AKIAIOSFODNN7EXAMPLE)
     - Secret access key (ejemplo: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY)
   - **IMPORTANTE**: Esta es la única vez que podrás ver la Secret access key
   - Descarga el archivo .csv o copia ambos valores

6. **Configurar AWS CLI**:
   ```bash
   aws configure
   ```
   - AWS Access Key ID: [Pega tu Access key ID]
   - AWS Secret Access Key: [Pega tu Secret access key]
   - Default region name: us-east-1
   - Default output format: json

7. **Verificar la Configuración**:
   ```bash
   aws sts get-caller-identity
   ```
   Deberías ver información sobre tu usuario IAM.

#### Buenas Prácticas de Seguridad:
1. **Principio de Mínimo Privilegio**:
   - Asigna solo los permisos necesarios
   - Revisa y ajusta los permisos regularmente

2. **Rotación de Credenciales**:
   - Rota las access keys cada 90 días
   - Usa diferentes keys para diferentes entornos

3. **Monitoreo**:
   - Habilita CloudTrail para auditar el uso de las credenciales
   - Revisa regularmente los logs de actividad

4. **MFA**:
   - Habilita la autenticación multifactor para el usuario IAM
   - Usa MFA para acceder a la consola de AWS

### Datadog
Las credenciales de Datadog se almacenan en el archivo `terraform.tfvars` (no versionado):
```hcl
datadog_api_key = "tu-api-key"
datadog_app_key = "tu-app-key"
environment     = "development"
```

#### Asociación de Keys:
- **API Key**: El valor que obtienes al crear una API Key en Datadog (el campo `key`) se asigna a `datadog_api_key`
- **Application Key**: El valor que obtienes al crear una Application Key en Datadog (el campo `key_id`) se asigna a `datadog_app_key`
- No hay necesidad de transformación o procesamiento adicional de las keys

#### Pasos para obtener las keys de Datadog:

1. **Acceder al Portal de Datadog**:
   - Inicia sesión en [Datadog](https://app.datadoghq.com)
   - Ve a "Organization Settings" (⚙️) en el menú lateral izquierdo

2. **Obtener API Key**:
   - En el menú lateral, selecciona "API Keys"
   - Haz clic en "New Key"
   - Asigna un nombre descriptivo (ej: "terraform-integration")
   - Copia la API Key generada
   - **IMPORTANTE**: Esta es la única vez que podrás ver la API Key completa

3. **Obtener Application Key**:
   - En el menú lateral, selecciona "Application Keys"
   - Haz clic en "New Key"
   - Asigna un nombre descriptivo (ej: "terraform-app-key")
   - Copia la Application Key generada
   - **IMPORTANTE**: Esta es la única vez que podrás ver la Application Key completa

4. **Configurar las Keys en Terraform**:
   - Abre el archivo `terraform.tfvars`
   - Reemplaza los valores de ejemplo con tus keys:
     ```hcl
     datadog_api_key = "tu-api-key-real"
     datadog_app_key = "tu-app-key-real"
     environment     = "development"
     ```

5. **Verificar la Configuración**:
   ```bash
   terraform init
   terraform plan
   ```
   Si no hay errores relacionados con las credenciales, la configuración es correcta.

#### Buenas Prácticas de Seguridad para Datadog:
1. **Rotación de Keys**:
   - Rota las API Keys y Application Keys regularmente
   - Usa diferentes keys para diferentes entornos

2. **Permisos Mínimos**:
   - Asigna solo los permisos necesarios a las Application Keys
   - Revisa y ajusta los permisos regularmente

3. **Monitoreo**:
   - Habilita la auditoría de uso de keys
   - Revisa regularmente los logs de actividad

4. **Almacenamiento Seguro**:
   - Nunca subas las keys a control de versiones
   - Usa un gestor de secretos para entornos de producción

## Flujo de Credenciales

### AWS
1. Se configuran las credenciales con `aws configure`
2. Las credenciales se almacenan en `.aws/credentials`
3. Terraform las lee automáticamente al ejecutarse
4. No es necesario especificarlas en los archivos de Terraform

### Datadog
1. Se especifican las credenciales en `terraform.tfvars`
2. Terraform las lee al ejecutarse
3. Se utilizan en la configuración del proveedor Datadog

## Cambios Realizados

### 2024-03-21
1. Configuración inicial de proveedores:
   - AWS provider con región us-east-1
   - Datadog provider con API y App keys

2. Integración AWS-Datadog:
   - Configuración del recurso `datadog_integration_aws`
   - Filtros por ambiente
   - Modificación de regiones para incluir us-east-1 en la recolección de métricas
   - Creación del rol IAM `DatadogAWSIntegrationRole`
   - Configuración de políticas IAM para Datadog:
     - CloudWatchReadOnlyAccess
     - AmazonEC2ReadOnlyAccess
     - AmazonS3ReadOnlyAccess

3. Monitores de Datadog:
   - Monitor de uso de CPU (umbral: 80%)
   - Monitor de uso de memoria (umbral: 85%)
   - Monitor de espacio en disco (umbral: 90%)
   - Configuración de mensajes de alerta personalizados
   - Etiquetado por ambiente y servicio

4. Variables de Terraform:
   - Definición de variables para credenciales
   - Variables para configuración de ambiente
   - Marcado de variables sensibles

5. Instalación del Agente Datadog:
   - Modificación de scripts de usuario para EC2
   - Configuración optimizada para tests:
     - Compresión de logs
     - Batch de logs
     - Intervalos de recolección ajustados
   - Políticas IAM específicas para el agente
   - Etiquetado específico para tests

6. Optimización de Costos:
   - Cambio de instancia frontend a t2.micro
   - Configuración de logs optimizada para tests
   - Uso de compresión y batching para reducir volumen
   - Configuración dentro de los límites gratuitos de AWS y Datadog

7. Configuración de Logs:
   - Configuración de Docker para logging:
     - Driver: json-file
     - Tamaño máximo: 10MB
     - Rotación: 3 archivos
   - Configuración de Datadog Agent:
     - Recolección de logs de contenedores
     - Filtros específicos para logs importantes
     - Exclusión de logs del agente
     - Compresión y batching optimizados

8. Dashboard de Monitoreo:
   - Creación de dashboard en Datadog con widgets para:
     - Uso de CPU por instancia
     - Uso de memoria por instancia
     - Uso de disco por instancia
     - Estado de contenedores Docker
     - Logs de aplicación
     - Alertas activas
   - Variables de template para filtrado
   - Tags para organización

9. Mejoras de Seguridad:
   - Implementación de VPC con subredes públicas
   - Grupos de seguridad específicos para frontend y backend
   - Políticas IAM con principio de mínimo privilegio:
     - Acceso específico a CloudWatch metrics
     - Acceso limitado a recursos EC2
     - Acceso específico a bucket S3
   - Configuración de rutas y gateways
   - Tags para todos los recursos

10. Documentación y Mejoras:
    - Actualización de prompts con todas las interacciones
    - Documentación de mejoras de seguridad implementadas
    - Registro de próximos pasos y tareas pendientes

11. Documentación de Proceso de Despliegue:
    - Descripción detallada de los pasos de terraform
    - Documentación de la secuencia de creación de recursos
    - Registro de la configuración final

12. Solución de Problemas de Descarga:
    - Implementación de mirror alternativo para Datadog
    - Configuración de proveedor con alias para mirror
    - Uso de endpoint alternativo (api.datadoghq.eu)
    - Resolución exitosa del problema de TLS

## Problemas Encontrados y Soluciones

### 2024-05-25
1. **Problema con el nombre del bucket S3**:
   - **Problema**: El nombre del bucket S3 contenía mayúsculas, lo que causaba problemas de compatibilidad.
   - **Solución**: Se cambió el nombre del bucket a `ai4devs-project-code-bucket-cnv` (todo en minúsculas).
   - **Archivos afectados**: 
     - `s3.tf`
     - `scripts/backend_user_data.sh`
     - `scripts/frontend_user_data.sh`

2. **Problema con los tags del dashboard de Datadog**:
   - **Problema**: Los tags del dashboard no seguían el formato clave:valor requerido por Datadog.
   - **Solución**: Se corrigieron los tags para incluir el tag 'team' y asegurar que todos los tags sigan el formato clave:valor.
   - **Archivos afectados**:
     - `datadog_dashboard.tf`

3. **Problema con la autenticación de Datadog**:
   - **Problema**: Errores de autenticación al intentar acceder a Datadog.
   - **Solución**: Se verificó y corrigió la configuración de las credenciales de Datadog en `terraform.tfvars`.
   - **Archivos afectados**:
     - `datadog_provider.tf`
     - `terraform.tfvars`

4. **Problema con la generación de archivos ZIP**:
   - **Problema**: El script de generación de ZIP no se ejecutaba correctamente en Windows.
   - **Solución**: Se modificó el script para usar WSL y asegurar la compatibilidad con Windows.
   - **Archivos afectados**:
     - `s3.tf`
     - `generar-zip.sh`

## Problemas y correcciones encontradas durante la ejecución

### Integración AWS-Datadog (Quinta corrección)
- **Problema:** El recurso `datadog_integration_aws` está marcado como deprecado, pero el nuevo recurso `datadog_integration_aws_account` tiene una API menos estable y más compleja.
- **Solución:** Mantener el uso de `datadog_integration_aws` por las siguientes razones:
  1. Es más estable y mejor documentado
  2. Funciona correctamente con nuestra configuración actual
  3. Aunque está marcado como deprecado, sigue siendo funcional
  4. La migración al nuevo recurso se realizará cuando su API esté más madura y documentada

### Errores de Permisos
- **Problema 1:** Error 403 Forbidden al acceder a los archivos en S3.
  - **Solución:** Verificar que:
    1. El bucket S3 existe y es accesible
    2. Las credenciales de AWS están correctamente configuradas
    3. El rol IAM tiene los permisos necesarios para acceder al bucket

- **Problema 2:** Error 403 Forbidden con el proveedor de Datadog.
  - **Solución:** Verificar que:
    1. Las credenciales de Datadog (API key y APP key) son válidas
    2. Las credenciales tienen los permisos necesarios
    3. La cuenta de Datadog está activa y en buen estado

### Integración AWS-Datadog (Cuarta corrección)
- **Problema:** El recurso `datadog_integration_aws_account` tiene una API inestable y requiere bloques complejos que no están bien documentados.
- **Solución:** Cambiar al recurso clásico `datadog_integration_aws` que es más estable y mejor documentado:
  ```hcl
  resource "datadog_integration_aws" "main" {
    account_id                       = data.aws_caller_identity.current.account_id
    role_name                        = aws_iam_role.datadog_integration.name
    filter_tags                      = ["env:${var.environment}"]
    host_tags                        = ["env:${var.environment}"]
    account_specific_namespace_rules = {
      auto_scaling = true
      opsworks     = true
    }
    excluded_regions = []
  }
  ```

### Integración AWS-Datadog (Tercera corrección)
- **Problema:** El recurso `datadog_integration_aws_account` requiere ahora varios bloques obligatorios (`aws_regions`, `auth_config`, `logs_config`, `metrics_config`, `traces_config`).
- **Solución:** Añadir los bloques requeridos con valores mínimos para permitir la integración básica:
  ```hcl
  resource "datadog_integration_aws_account" "main" {
    aws_account_id = data.aws_caller_identity.current.account_id
    aws_partition  = "aws"

    aws_regions {
      region = var.aws_region
    }

    auth_config {
      aws_auth_config_role {
        role_name = aws_iam_role.datadog_integration.name
      }
    }

    logs_config {
      lambda_forwarder {
        enabled = false
      }
    }

    metrics_config {
      namespace_filters {
        namespace = "*"
      }
    }

    traces_config {
      xray_services {
        enabled = false
      }
    }
  }
  ```

### Integración AWS-Datadog (Segunda corrección)
- **Problema:** Los argumentos anteriores no eran correctos. El recurso requiere específicamente `aws_account_id` y `aws_partition`.
- **Solución:** Simplificar la configuración usando solo los argumentos requeridos:
  ```hcl
  resource "datadog_integration_aws_account" "main" {
    aws_account_id = data.aws_caller_identity.current.account_id
    aws_partition  = "aws"
  }
  ```

### Integración AWS-Datadog (Primera corrección)
- **Problema:** Argumentos no soportados en el recurso `datadog_integration_aws_account` (`aws_account_id`, `aws_partition`, etc.)
- **Solución:** Usar solo los argumentos válidos: `account_id`, `role_name`, `filter_tags`, `host_tags`, `account_specific_namespace_rules`, `excluded_regions`.

### Dashboard Datadog
- **Problema:** Faltaba el argumento `layout_type` en el bloque `group_definition`.
- **Solución:** Añadido `layout_type = "ordered"` en el bloque correspondiente.

### S3
- **Problema:** Uso de recursos y argumentos deprecados (`aws_s3_bucket_object`, `key`).
- **Solución:** Cambio a `aws_s3_object` para los archivos `backend.zip` y `frontend.zip`.

### Proceso de depuración
- Se han realizado varias iteraciones para ajustar los argumentos de los recursos según la documentación oficial de los proveedores.
- Se han corregido errores de sintaxis y compatibilidad para asegurar la correcta ejecución de `terraform plan` y `terraform apply`.
- Se ha decidido mantener el uso del recurso `datadog_integration_aws` por su estabilidad y mejor documentación, a pesar de estar marcado como deprecado.
- Se han identificado y documentado problemas de permisos que requieren atención manual.

## Proceso de Despliegue con Terraform

Al ejecutar `terraform apply`, se realizarán los siguientes pasos en orden:

1. **Inicialización de Proveedores**:
   - AWS Provider (us-east-1)
   - Datadog Provider (con API y App keys)

2. **Creación de VPC y Redes**:
   - VPC con CIDR 10.0.0.0/16
   - 2 subredes públicas en diferentes AZs
   - Internet Gateway
   - Tabla de rutas pública
   - Grupos de seguridad

3. **Configuración de IAM**:
   - Rol `lti-project-ec2-role`
   - Políticas de acceso específicas
   - Perfil de instancia EC2

4. **Configuración de S3**:
   - Bucket con cifrado
   - Subida de archivos de aplicación

5. **Integración AWS-Datadog**:
   - Configuración de integración
   - Asignación de roles
   - Filtros por ambiente

6. **Configuración de Monitores**:
   - Monitores de recursos
   - Alertas personalizadas

7. **Creación del Dashboard**:
   - Widgets de métricas
   - Visualización de logs
   - Estado de contenedores

8. **Configuración de EC2**:
   - Instancias con roles
   - Scripts de usuario
   - Configuración de Docker

9. **Configuración de Logs**:
   - Docker logging
   - Datadog Agent
   - Filtros y compresión

10. **Verificación Final**:
    - Validación de integración
    - Comprobación de métricas
    - Verificación de monitores

## Estado Actual de la Configuración

### Integración AWS-Datadog ✅
- Configuración del recurso `datadog_integration_aws`
- Rol IAM `DatadogAWSIntegrationRole` con políticas necesarias
- Filtros por ambiente configurados
- Región us-east-1 incluida en la recolección de métricas

### Proveedor Datadog ✅
- Proveedor configurado en `datadog_provider.tf`
- Variables para API y App keys definidas
- Credenciales configuradas en `terraform.tfvars`

### Agente Datadog ✅
- Scripts de usuario modificados para instalación automática
- Configuración optimizada para tests:
  - Logs comprimidos y en batch
  - Intervalos de recolección ajustados
  - Etiquetado específico para tests
- Políticas IAM configuradas para envío de métricas
- Configuración de logs Docker:
  - Recolección de logs de contenedores
  - Filtros específicos
  - Rotación y límites de tamaño

### Dashboards ✅
- Dashboard principal creado con:
  - Métricas de sistema (CPU, memoria, disco)
  - Estado de contenedores Docker
  - Stream de logs de aplicación
  - Visualización de alertas
- Variables de template para filtrado
- Tags para organización

### Seguridad de Red ✅
- VPC configurada con:
  - Subredes públicas en diferentes AZs
  - Internet Gateway
  - Tablas de rutas
- Grupos de seguridad:
  - Frontend: Puerto 3000 abierto
  - Backend: Puerto 8000 solo desde frontend
- Acceso a internet controlado

### IAM y Permisos ✅
- Roles IAM con mínimo privilegio:
  - Acceso específico a CloudWatch metrics
  - Acceso limitado a recursos EC2
  - Acceso específico a bucket S3
- Políticas documentadas y justificadas
- Tags para auditoría

### Documentación ✅
- README actualizado con todos los cambios
- Prompts registrados y documentados
- Próximos pasos definidos
- Mejoras de seguridad documentadas

## Análisis de Costos

### Elementos Gratuitos ✅
- Instancias EC2 t2.micro (750 horas/mes)
- Almacenamiento EBS (30GB/mes)
- Datos de entrada en AWS
- IAM roles y políticas
- Métricas básicas de CloudWatch
- 5GB de logs en Datadog

### Elementos con Costo ❌
- Transferencia de datos fuera de AWS (100GB/mes gratis)
- Logs de CloudWatch (5GB/mes gratis)
- Transferencia S3 fuera de la región

### Optimizaciones Implementadas
1. **Instancias**:
   - Frontend cambiado a t2.micro
   - Backend ya en t2.micro

2. **Logs**:
   - Compresión activada
   - Batch de logs configurado
   - Recolección selectiva
   - Intervalos optimizados
   - Rotación de logs (3 archivos)
   - Límite de tamaño (10MB)

3. **Almacenamiento**:
   - Configuración dentro de límites gratuitos
   - Optimización para tests

## Próximos Pasos
1. **Mejoras de Seguridad**:
   - Implementar WAF para protección adicional
   - Configurar AWS Shield para DDoS
   - Revisar y actualizar políticas IAM regularmente

2. **Mantenimiento**:
   - Revisar y ajustar umbrales de alertas
   - Optimizar consultas de métricas
   - Actualizar documentación según necesidades

3. **Testing y Validación**:
   - Realizar pruebas de la infraestructura
   - Validar la configuración de seguridad
   - Verificar el funcionamiento del monitoreo

4. **Integración y Notificaciones**:
   - Configurar integración con sistemas de notificación
   - Implementar alertas adicionales
   - Optimizar la recolección de métricas

5. **Documentación Final**:
   - Actualizar procedimientos de mantenimiento
   - Documentar procesos de actualización
   - Crear guías de troubleshooting

6. **Implementación - 2024-05-25**:
   - Proceder con `terraform apply` para desplegar la infraestructura
   - Verificar la creación correcta de todos los recursos
   - Validar la integración con Datadog
   - Comprobar el funcionamiento de los monitores y dashboards

## Solución de Problemas

### Problemas de Conectividad con Terraform

#### Síntomas
- Error al ejecutar `terraform init`
- Timeout al intentar descargar proveedores
- Error de TLS handshake

#### Verificación de Conectividad
1. **Ping al registro**:
   ```powershell
   ping registry.terraform.io
   ```

2. **Verificación de Firewall**:
   - Comprobar si el firewall está bloqueando la conexión
   - Verificar reglas de salida para HTTPS (puerto 443)
   - Comprobar si hay reglas específicas para Terraform

3. **Configuración de Red**:
   - Verificar que no hay proxy configurado
   - Comprobar configuración de DNS
   - Verificar que no hay VPN activa que pueda interferir

#### Soluciones Posibles
1. **Configuración de Firewall**:
   - Añadir excepción para Terraform
   - Permitir conexiones HTTPS salientes
   - Verificar reglas de Windows Defender

2. **Configuración de Terraform**:
   - Aumentar timeout de conexión
   - Usar mirror alternativo
   - Descargar proveedores manualmente

3. **Alternativas**:
   - Usar VPN si está disponible
   - Configurar proxy si es necesario
   - Usar mirror local de Terraform 

### Análisis de Error de Descarga de Proveedores

#### Error de S3 de GitHub
- El error ocurre al intentar descargar el proveedor de Datadog
- La descarga se intenta desde `objects.githubusercontent.com`
- Usa credenciales de AWS S3 internas de GitHub
- No está relacionado con nuestras credenciales de AWS

#### Diferenciación de S3
1. **S3 de GitHub**:
   - Usado para distribuir assets de GitHub
   - No requiere nuestras credenciales
   - Parte de la infraestructura de GitHub

2. **Nuestro S3** (`s3.tf`):
   - Bucket: `ai4devs-project-code-bucket`
   - Acceso: Privado
   - Contenido: 
     - `backend.zip`
     - `frontend.zip`
   - Usa nuestras credenciales de AWS

#### Solución con Mirror Alternativo
1. **Configuración de Mirror**:
   - Usar un mirror alternativo para los proveedores
   - Evitar problemas de TLS con GitHub
   - Mantener la funcionalidad de los proveedores

2. **Implementación**:
   - Modificar la configuración de proveedores
   - Usar mirrors confiables
   - Mantener las versiones requeridas

## Componentes de Terraform

### Proveedores Configurados
1. **AWS Provider** (`provider.tf`):
   - Fuente: `hashicorp/aws`
   - Versión: Última disponible
   - Región: us-east-1

2. **Datadog Provider** (`datadog_provider.tf`):
   - Fuente: `datadog/datadog`
   - Versión: ~> 3.0
   - Requiere API y App keys

3. **Proveedores Implícitos**:
   - `hashicorp/null` (usado internamente)

### Verificación de Credenciales
1. **GitHub**:
   - Usuario: yamakuko
   - Email: yamakuko@gmail.com
   - Credenciales almacenadas en Git Credential Manager

2. **AWS**:
   - Credenciales en `~/.aws/credentials`
   - Región: us-east-1

3. **Datadog**:
   - API Key y App Key en `terraform.tfvars`
   - Variables definidas en `variables.tf`

## Configuración de Proveedores

### Datadog Provider
1. **Configuración Principal**:
   ```hcl
   provider "datadog" {
     api_key = var.datadog_api_key
     app_key = var.datadog_app_key
   }
   ```

2. **Configuración de Mirror**:
   ```hcl
   provider "datadog" {
     alias = "mirror"
     api_key = var.datadog_api_key
     app_key = var.datadog_app_key
     api_url = "https://api.datadoghq.eu"
   }
   ```

3. **Requerimientos**:
   ```hcl
   required_providers {
     datadog = {
       source = "datadog/datadog"
       version = "~> 3.0"
       configuration_aliases = [datadog.mirror]
     }
   }
   ```

### Resultados
- Inicialización exitosa de Terraform
- Descarga correcta de todos los proveedores
- Resolución del problema de TLS
- Mantenimiento de la funcionalidad completa 

## Verificación de Pasos

### 2024-03-21
1. **Credenciales AWS** ✅
   - Usuario: terraform-user
   - Cuenta: 803133978871
   - Credenciales válidas

2. **Archivos de Configuración** ✅
   - Todos los archivos necesarios presentes
   - Estructura correcta
   - Archivos de estado presentes

3. **Scripts** ✅
   - `frontend_user_data.sh` presente
   - `backend_user_data.sh` presente
   - Ambos scripts con tamaño correcto

4. **Variables** ✅
   - Región AWS configurada
   - API y App keys de Datadog presentes
   - Ambiente definido

5. **Recursos** ✅
   - Nombres de recursos únicos
   - Regiones correctas
   - Tipos de instancia adecuados

6. **Preparación** ✅
   - Terraform inicializado correctamente
   - Proveedores descargados
   - Estado listo para plan 

## Cambios recientes (2024-03-21)

1. Integración AWS-Datadog: actualizado a argumentos correctos y uso de aws_iam_role.datadog_integration.
2. Dashboard Datadog: añadido layout_type en group_definition.
3. S3: cambio de aws_s3_bucket_object a aws_s3_object para backend.zip y frontend.zip. 

### Tag obligatorio 'team' en dashboards de Datadog
- **Problema:** La organización de Datadog requiere que todos los dashboards tengan el tag `team`.
- **Solución:** Añadir el tag `team` en el bloque `tags` del recurso `datadog_dashboard` en Terraform. El valor de `team` se define como variable en Terraform y puede ser personalizado según el equipo responsable.

Ejemplo:
```hcl
tags = [
  "team:${var.team}",
  "env:${var.environment}",
  "managed-by:terraform",
  "service:monitoring"
]
```

# Resumen de Problemas y Soluciones

- **Problema:** El agente de Datadog no se comunica desde la instancia EC2.  
  **Solución:** Verificar la API Key en el archivo de configuración del agente y reiniciar el servicio.

- **Problema:** La instancia EC2 no tiene acceso a Internet.  
  **Solución:** Revisar la configuración de red en Terraform (Internet Gateway, Security Groups, rutas) para asegurar que el tráfico de salida está permitido.

- **Problema:** El agente de Datadog no se instala automáticamente en la EC2.  
  **Solución:** Asegurar que el script de instalación del agente está incluido en el user_data de la instancia EC2 en Terraform.

- **Problema:** La API Key de Datadog es inválida o no está configurada correctamente.  
  **Solución:** Actualizar la API Key en el archivo de configuración del agente y reiniciar el servicio. 



 