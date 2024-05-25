#!/bin/bash

# Declaración de variables de estilo
MANGENTA="\033[35m"
BOLD="\033[1m"
CLEAR_LINE="\033[2K"
WHITE="\033[37m"
GREEN="\033[32m"
RESET="\033[0m"

# Función para mostrar mensajes
function show_message {
    printf "${BOLD}$1${RESET}\n"
}

# Actualizar la lista de paquetes (silencioso)
show_message "Actualizando la lista de paquetes..."
sudo apt update -y > /dev/null 2>&1

# Instalar git si no está instalado
if ! command -v git &> /dev/null; then
    show_message "Git no está instalado. Instalando git..."
    sudo apt install git -y > /dev/null 2>&1
    show_message "Git instalado correctamente."
else
    show_message "Git ya está instalado."
fi

# Instalar vim si no está instalado
if ! command -v vim &> /dev/null; then
    show_message "Vim no está instalado. Instalando vim..."
    sudo apt install vim -y > /dev/null 2>&1
    show_message "Vim instalado correctamente."
else
    show_message "Vim ya está instalado."
fi

# Cambiar al directorio del usuario
cd ~

# Crear la carpeta doncom si no existe
if [ ! -d "doncom" ]; then
    mkdir doncom
fi

# Cambiar al directorio doncom
cd doncom

# Mostrar mensaje de clonación
show_message "Clonando el repositorio Arenita desde GitHub..."

# Clonar el repositorio usando git (silencioso)
git clone https://github.com/doncomproject/arenita > /dev/null 2>&1
show_message "Clonando el repositorio Yakuza desde GitHub..."
git clone https://github.com/doncomproject/yakuza > /dev/null 2>&1
show_message "Clonando el repositorio Rocket desde GitHub..."
git clone https://github.com/doncomproject/rocket > /dev/null 2>&1

# Mostrar mensaje de finalización
show_message "${GREEN}¡Clonación completa!${RESET}"
