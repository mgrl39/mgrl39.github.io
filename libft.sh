#!/bin/bash

# Definir colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# URL base del repositorio de GitHub
GITHUB_URL="https://raw.githubusercontent.com/mgrl39/42checker/main/libft"

# Descargar la lista de ejercicios
echo -e "${BLUE}Descargando la lista de ejercicios...${NC}"
wget -q -O list.txt "$GITHUB_URL/list.txt"

# Leer la lista de ejercicios en un array
mapfile -t ejercicios < list.txt

# Listar archivos .c en el directorio actual que están en la lista de ejercicios
archivos_c=$(ls *.c)
archivos_evaluables=()

# Verificar archivos .c que se pueden evaluar
for ejercicio in "${ejercicios[@]}"; do
    archivo="ft_${ejercicio}.c"
    if [[ -f "$archivo" ]]; then
        archivos_evaluables+=("$archivo")
    fi
done

# Mostrar archivos .c en el directorio actual que se pueden evaluar
echo -e "${YELLOW}Archivos .c en el directorio actual que se pueden evaluar:${NC}"
for archivo in $archivos_c; do
    if [[ " ${archivos_evaluables[@]} " =~ " ${archivo} " ]]; then
        echo -e "${GREEN}$archivo${NC}"
    fi
done

# Mostrar opciones de ejercicios conocidos
echo -e "${YELLOW}Selecciona un ejercicio para evaluar:${NC}"
select ejercicio in "${ejercicios[@]}"; do
    if [[ " ${ejercicios[@]} " =~ " ${ejercicio} " ]]; then
        echo -e "${GREEN}Has seleccionado: $ejercicio${NC}"
        break
    else
        echo -e "${RED}Opción no válida. Por favor, selecciona un ejercicio válido.${NC}"
    fi
done

# Descargar el main correspondiente al ejercicio
main_url="$GITHUB_URL/ft_${ejercicio}_main.c"
ex_name="ft_${ejercicio}_main.c"
echo -e "${BLUE}Descargando $ex_name...${NC}"
wget -q -O "$ex_name" "$main_url"

# Verificar si el archivo del ejercicio existe
if [[ ! -f "ft_${ejercicio}.c" ]]; then
    echo -e "${RED}El archivo ft_${ejercicio}.c no existe en el directorio actual.${NC}"
    exit 1
fi

# Compilar con el archivo descargado y el ejercicio seleccionado
echo -e "${BLUE}Compilando: cc -Wall -Wextra -Werror $ex_name ft_${ejercicio}.c -o a.out${NC}"
cc -Wall -Wextra -Werror $ex_name ft_${ejercicio}.c -o a.out

# Verificar si la compilación fue exitosa
if [[ ! -f "a.out" ]]; then
    echo -e "${RED}Error en la compilación.${NC}"
    exit 1
fi

# Eliminar el archivo main descargado
rm "$ex_name"

# Ejecutar el archivo compilado
echo -e "${BLUE}Ejecutando el archivo compilado:${NC}"
./a.out

# Verificar el resultado de la ejecución
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error en la ejecución del archivo compilado.${NC}"
    exit 1
fi

# Eliminar el archivo ejecutable
rm a.out

# Eliminar la lista de ejercicios descargada
rm list.txt

echo -e "${GREEN}Tests completados.${NC}"
