#!/bin/bash

# Declaración de variables de estilo
MANGENTA="\033[35m"
BOLD="\033[1m"
CLEAR_LINE="\033[2K"
WHITE="\033[37m"
GREEN="\033[32m"
RESET="\033[0m"

# Cambiar al directorio del usuario
cd ~

# Crear la carpeta doncom si no existe
if [ ! -d "doncom" ]; then
    mkdir doncom
fi

# Cambiar al directorio doncom
cd doncom

# Mostrar mensaje de descarga
printf "${BOLD}Descargando Arenita...${RESET}\n"

# Descargar el archivo usando wget
wget https://doncom.me/install/arenita -q --show-progress

# Mostrar mensaje de finalización
printf "\n${GREEN}${BOLD}¡Descarga completa!${RESET}\n"
