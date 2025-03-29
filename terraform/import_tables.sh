#!/bin/bash

# Obtener el directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Verificar si se proporcionó un archivo de configuración
if [ -z "$1" ]; then
    echo "Uso: $0 <archivo_config.json>"
    echo "Ejemplo: $0 ../data/dummy_data/config.json"
    exit 1
fi

# Convertir la ruta relativa a absoluta
CONFIG_FILE="$PROJECT_ROOT/$1"

# Verificar si el archivo existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: No se encontró el archivo de configuración en: $CONFIG_FILE"
    echo "Asegúrate de que la ruta sea correcta y el archivo exista"
    exit 1
fi

echo "Usando archivo de configuración: $CONFIG_FILE"

# Validar el archivo de configuración
"$SCRIPT_DIR/validate_config.sh" "$CONFIG_FILE"

# Cambiar al directorio de Terraform
cd "$SCRIPT_DIR"

# Inicializar Terraform
terraform init

# Función para importar tablas existentes
import_existing_tables() {
    local config_file=$1
    
    # Obtener todas las tablas con operación "import"
    jq -c '.scenarios[] | select(.tables[].operation == "import") | {dataset_id: .dataset_id, tables: [.tables[] | select(.operation == "import")]}' "$config_file" | while read -r scenario; do
        dataset_id=$(echo "$scenario" | jq -r '.dataset_id')
        echo "$scenario" | jq -c '.tables[]' | while read -r table; do
            table_name=$(echo "$table" | jq -r '.name')
            echo "Importando tabla existente: $dataset_id.$table_name"
            terraform import "module.bigquery.google_bigquery_table.tables[\"$dataset_id.$table_name\"]" "projects/$TF_VAR_project_id/datasets/$dataset_id/tables/$table_name"
        done
    done
}

# Función para crear nuevos datasets
create_new_datasets() {
    local config_file=$1
    
    # Obtener todos los datasets nuevos
    jq -c '.scenarios[] | select(.name == "new_dataset_and_tables")' "$config_file" | while read -r scenario; do
        dataset_id=$(echo "$scenario" | jq -r '.dataset_id')
        echo "Creando nuevo dataset: $dataset_id"
        terraform apply -target="module.bigquery.google_bigquery_dataset.datasets[\"$dataset_id\"]" -auto-approve
    done
}

# Función para crear nuevas tablas
create_new_tables() {
    local config_file=$1
    
    # Obtener todas las tablas con operación "create"
    jq -c '.scenarios[] | {dataset_id: .dataset_id, tables: [.tables[] | select(.operation == "create")]}' "$config_file" | while read -r scenario; do
        dataset_id=$(echo "$scenario" | jq -r '.dataset_id')
        echo "$scenario" | jq -c '.tables[]' | while read -r table; do
            table_name=$(echo "$table" | jq -r '.name')
            echo "Creando nueva tabla: $dataset_id.$table_name"
            terraform apply -target="module.bigquery.google_bigquery_table.tables[\"$dataset_id.$table_name\"]" -auto-approve
        done
    done
}

# Ejecutar el proceso
echo "Iniciando proceso de importación y creación..."

# 1. Importar tablas existentes
echo "Fase 1: Importando tablas existentes..."
import_existing_tables "$CONFIG_FILE"

# 2. Crear nuevos datasets
echo "Fase 2: Creando nuevos datasets..."
create_new_datasets "$CONFIG_FILE"

# 3. Crear nuevas tablas
echo "Fase 3: Creando nuevas tablas..."
create_new_tables "$CONFIG_FILE"

# Verificar el estado final
echo "Estado final de Terraform:"
terraform state list 