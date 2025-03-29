# BigQuery Terraform Infrastructure

Este repositorio contiene la infraestructura como código (IaC) para configurar y gestionar recursos en Google BigQuery utilizando Terraform.

## 🏗️ Estructura del Proyecto

```
.
├── terraform/
│   ├── main.tf              # Configuración principal de Terraform
│   ├── variables.tf         # Definición de variables
│   ├── terraform.tfvars     # Valores de variables
│   ├── modules/
│   │   └── bigquery/        # Módulo para recursos de BigQuery
│   │       ├── main.tf
│   │       └── variables.tf
│   ├── import_tables.sh     # Script para importar tablas existentes
│   └── validate_config.sh   # Script para validar la configuración
└── data/                    # Directorio para archivos de datos
```

## 📋 Prerrequisitos

- [Terraform](https://www.terraform.io/downloads.html) (versión 1.0.0 o superior)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- Cuenta de servicio de Google Cloud con permisos necesarios
- Credenciales de Google Cloud configuradas

## 🔧 Configuración

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/hardyxd1/bigquery_terraform.git
   cd bigquery_terraform
   ```

2. Configurar las credenciales de Google Cloud:
   - Crear un archivo `credentials.json` con las credenciales de la cuenta de servicio
   - **Nota**: No subir este archivo al repositorio (está en .gitignore)

3. Configurar las variables en `terraform/terraform.tfvars`:
   ```hcl
   project_id = "tu-proyecto-id"
   region     = "us-central1"
   # Otras variables según sea necesario
   ```

## 🚀 Uso

1. Inicializar Terraform:
   ```bash
   cd terraform
   terraform init
   ```

2. Validar la configuración:
   ```bash
   ./validate_config.sh
   ```

3. Planificar los cambios:
   ```bash
   terraform plan
   ```

4. Aplicar los cambios:
   ```bash
   terraform apply
   ```

5. Para importar tablas existentes:
   ```bash
   ./import_tables.sh
   ```

## 🔒 Seguridad

- Las credenciales sensibles están excluidas del control de versiones
- Se recomienda usar variables de entorno o secretos para datos sensibles
- Revisar y ajustar los permisos de la cuenta de servicio según sea necesario

## 📝 Notas Importantes

- El archivo `terraform.tfstate` contiene el estado de la infraestructura y no debe ser compartido
- Mantener actualizado el archivo `.terraform.lock.hcl` para versiones de providers
- Revisar los cambios antes de aplicar con `terraform plan`

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, asegúrate de:
1. Crear una rama para tu feature
2. Seguir las mejores prácticas de Terraform
3. Actualizar la documentación según sea necesario
4. Probar los cambios antes de crear un pull request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles. 