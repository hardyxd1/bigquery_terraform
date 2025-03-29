#!/bin/bash

# Obtener el directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Función para validar el JSON
validate_json() {
    local config_file=$1
    
    # Verificar si el archivo existe
    if [ ! -f "$config_file" ]; then
        echo "Error: El archivo de configuración $config_file no existe"
        echo "Asegúrate de que la ruta sea correcta y el archivo exista"
        exit 1
    fi
    
    # Verificar si es un JSON válido
    if ! jq empty "$config_file" 2>/dev/null; then
        echo "Error: El archivo $config_file no es un JSON válido"
        exit 1
    fi
    
    # Verificar estructura básica
    if ! jq -e '.scenarios' "$config_file" > /dev/null; then
        echo "Error: El JSON debe contener un array 'scenarios'"
        exit 1
    fi
    
    # Verificar cada escenario
    jq -c '.scenarios[]' "$config_file" | while read -r scenario; do
        # Verificar campos requeridos
        if ! echo "$scenario" | jq -e '.name' > /dev/null; then
            echo "Error: Cada escenario debe tener un 'name'"
            exit 1
        fi
        if ! echo "$scenario" | jq -e '.dataset_id' > /dev/null; then
            echo "Error: Cada escenario debe tener un 'dataset_id'"
            exit 1
        fi
        if ! echo "$scenario" | jq -e '.location' > /dev/null; then
            echo "Error: Cada escenario debe tener un 'location'"
            exit 1
        fi
        if ! echo "$scenario" | jq -e '.tables' > /dev/null; then
            echo "Error: Cada escenario debe tener un array 'tables'"
            exit 1
        fi
        
        # Verificar cada tabla
        echo "$scenario" | jq -c '.tables[]' | while read -r table; do
            if ! echo "$table" | jq -e '.name' > /dev/null; then
                echo "Error: Cada tabla debe tener un 'name'"
                exit 1
            fi
            if ! echo "$table" | jq -e '.operation' > /dev/null; then
                echo "Error: Cada tabla debe tener una 'operation'"
                exit 1
            fi
            if ! echo "$table" | jq -e '.schema' > /dev/null; then
                echo "Error: Cada tabla debe tener un 'schema'"
                exit 1
            fi
        done
    done
    
    echo "Validación exitosa: El archivo de configuración es válido"
}

# Verificar si se proporcionó un archivo de configuración
if [ -z "$1" ]; then
    echo "Uso: $0 <archivo_config.json>"
    echo "Ejemplo: $0 ../data/dummy_data/config.json"
    exit 1
fi

# Convertir la ruta relativa a absoluta
CONFIG_FILE="$PROJECT_ROOT/$1"

# Validar el archivo de configuración
validate_json "$CONFIG_FILE" 