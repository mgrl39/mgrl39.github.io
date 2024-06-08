#!/bin/bash

repo_url="https://github.com/mgrl39/42Project.git"
destination_folder="42project"

# Comprobamos si la carpeta de destino ya existe
if [ -d "$destination_folder" ]; then
  echo "La carpeta de destino ya existe. Por favor, elimínela o especifique una carpeta diferente."
  exit 1
fi

# Clonamos el repositorio
git clone "$repo_url" "$destination_folder"

# Comprobamos si la clonación fue exitosa
if [ $? -eq 0 ]; then
  echo "Repositorio clonado exitosamente en: $destination_folder"
else
  echo "Error al clonar el repositorio."
  exit 1
fi

exit 0
