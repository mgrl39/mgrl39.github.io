#!/bin/bash

# Colores para la salida
DEF_COLOR='\033[0;39m'
RED='\033[1;91m'
GREEN='\033[1;92m'

# Nombre por defecto del Makefile
makefile="Makefile"

# Función para verificar cada regla del Makefile
check_makefile() {
    local errors=0

    # Verificar las banderas de compilación adecuadas
    grep -E -q "(-Wall|-Wextra|-Werror)" "$makefile"
    if [ $? -ne 0 ]; then
        echo -e "${RED}[KO]${DEF_COLOR} Falta la definición correcta de las banderas de compilación en el Makefile."
        errors=$((errors + 1))
    else
        echo -e "${GREEN}[OK]${DEF_COLOR} Las banderas de compilación (-Wall -Wextra -Werror) están definidas correctamente."
    fi

    # Verificar las reglas esenciales (all, clean, fclean, re)
    check_rule "all"
    check_rule "clean"
    check_rule "fclean"
    check_rule "re"

    # Ejecutar make para compilar y luego verificar la compilación
    make &> /dev/null
    local result_make=$?
    if [ $result_make -ne 0 ]; then
        echo -e "${RED}[KO]${DEF_COLOR} Error al ejecutar make."
        return 1
    fi

    # Verificar que se crean todos los .o requeridos y libft.a
    check_compilation

    # Si no hay errores hasta aquí, ejecutar make clean y make fclean
    make clean &> /dev/null
    local result_clean=$?
    if [ $result_clean -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} make clean se ejecutó correctamente."
    else
        echo -e "${RED}[KO]${DEF_COLOR} Error al ejecutar make clean."
        errors=$((errors + 1))
        return $errors
    fi

    make fclean &> /dev/null
    local result_fclean=$?
    if [ $result_fclean -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} make fclean se ejecutó correctamente."
    else
        echo -e "${RED}[KO]${DEF_COLOR} Error al ejecutar make fclean."
        errors=$((errors + 1))
        return $errors
    fi

    # Ejecutar make nuevamente y verificar que no vuelva a compilar todo si no es necesario
    make &> /dev/null
    local result_make_second=$?

    # Verificar si make volvió a compilar todo
    if [ $result_make_second -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} make no volvió a compilar todo el código innecesariamente."
    else
        echo -e "${RED}[KO]${DEF_COLOR} make volvió a compilar todo el código innecesariamente."
        errors=$((errors + 1))
        return $errors
    fi

    # Finalmente, ejecutar make re y verificar
    make re &> /dev/null
    local result_re=$?
    if [ $result_re -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} make re se ejecutó correctamente."
    else
        echo -e "${RED}[KO]${DEF_COLOR} Error al ejecutar make re."
        errors=$((errors + 1))
        return $errors
    fi

    # Verificar nuevamente que se crean todos los .o requeridos y libft.a después de make re
    check_compilation

    # Si no hay errores, mostrar que todo está OK
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} El Makefile cumple con todas las normas requeridas."
    fi

    return $errors
}

# Función para verificar la existencia de una regla en el Makefile
check_rule() {
    local rule="$1"
    grep -q "^$rule:" "$makefile"
    if [ $? -ne 0 ]; then
        echo -e "${RED}[KO]${DEF_COLOR} Falta la regla '$rule' en el Makefile."
        return 1
    else
        echo -e "${GREEN}[OK]${DEF_COLOR} La regla '$rule' está definida en el Makefile."
    fi
}

# Función para verificar la compilación de todos los .o y libft.a
check_compilation() {
    local mandatory_functions=(
        "ft_isalpha" "ft_isdigit" "ft_isalnum" "ft_isascii" "ft_isprint"
        "ft_strlen" "ft_memset" "ft_bzero" "ft_memcpy" "ft_memmove"
        "ft_strlcpy" "ft_strlcat" "ft_toupper" "ft_tolower" "ft_strchr"
        "ft_strrchr" "ft_strncmp" "ft_memchr" "ft_memcmp" "ft_strnstr"
        "ft_atoi" "ft_calloc" "ft_strdup" "ft_substr" "ft_strjoin"
        "ft_strtrim" "ft_split" "ft_itoa" "ft_strmapi" "ft_striteri"
        "ft_putchar_fd" "ft_putstr_fd" "ft_putendl_fd" "ft_putnbr_fd"
    )

    local objects=""
    local missing_objects=""
    local errors=0

    # Verificar la existencia de los archivos .o
    for func in "${mandatory_functions[@]}"; do
        object_file="ft_$(echo $func | sed 's/ft_//').o"
        if [ ! -f "$object_file" ]; then
            missing_objects="$missing_objects $object_file"
            errors=$((errors + 1))
        fi
    done

    if [ $errors -ne 0 ]; then
        echo -e "${RED}[KO]${DEF_COLOR} Faltan los siguientes archivos .o: $missing_objects"
    else
        echo -e "${GREEN}[OK]${DEF_COLOR} Se han creado todos los archivos .o requeridos."
    fi

    # Verificar la existencia de libft.a
    if [ ! -f "libft.a" ]; then
        echo -e "${RED}[KO]${DEF_COLOR} No se ha creado el archivo libft.a."
        errors=$((errors + 1))
    else
        echo -e "${GREEN}[OK]${DEF_COLOR} Se ha creado el archivo libft.a."
    fi

    return $errors
}

# Función para limpiar archivos .o y libft.a
clean_up() {
    echo "Limpiando archivos .o y libft.a..."

    # Eliminar archivos .o
    rm -f *.o
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} Archivos .o eliminados correctamente."
    else
        echo -e "${RED}[KO]${DEF_COLOR} Error al eliminar archivos .o."
    fi

    # Eliminar libft.a
    rm -f libft.a
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} Archivo libft.a eliminado correctamente."
    else
        echo -e "${RED}[KO]${DEF_COLOR} Error al eliminar el archivo libft.a."
    fi
}

# Llamada a la función de verificación
check_makefile
errors=$?

# Limpiar archivos antes de salir
clean_up

exit $errors
