#!/bin/bash

# Colors for output
DEF_COLOR='\033[0;39m'
RED='\033[1;91m'
GREEN='\033[1;92m'

# Default Makefile name
makefile="Makefile"

# Function to check each rule in the Makefile
check_makefile() {
    local errors=0

    # Check proper compilation flags
    grep -E -q "(-Wall|-Wextra|-Werror)" "$makefile"
    if [ $? -ne 0 ]; then
        echo -e "${RED}[KO]${DEF_COLOR} Proper compilation flags are missing in the Makefile."
        errors=$((errors + 1))
    else
        echo -e "${GREEN}[OK]${DEF_COLOR} Compilation flags (-Wall -Wextra -Werror) are defined correctly."
    fi

    # Check essential rules (all, clean, fclean, re)
    check_rule "all"
    check_rule "clean"
    check_rule "fclean"
    check_rule "re"

    # Run make to compile and then verify compilation
    make &> /dev/null
    local result_make=$?
    if [ $result_make -ne 0 ]; then
        echo -e "${RED}[KO]${DEF_COLOR} Error executing make."
        return 1
    fi

    # Check if all required .o files and libft.a are created
    check_compilation

    # If no errors so far, run make clean and make fclean
    make clean &> /dev/null
    local result_clean=$?
    if [ $result_clean -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} make clean executed successfully."
    else
        echo -e "${RED}[KO]${DEF_COLOR} Error executing make clean."
        errors=$((errors + 1))
        return $errors
    fi

    make fclean &> /dev/null
    local result_fclean=$?
    if [ $result_fclean -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} make fclean executed successfully."
    else
        echo -e "${RED}[KO]${DEF_COLOR} Error executing make fclean."
        errors=$((errors + 1))
        return $errors
    fi

    # Run make again and verify it does not unnecessarily recompile everything
    make &> /dev/null
    local result_make_second=$?

    # Check if make recompiled everything unnecessarily
    if [ $result_make_second -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} make did not unnecessarily recompile all code."
    else
        echo -e "${RED}[KO]${DEF_COLOR} make unnecessarily recompiled all code."
        errors=$((errors + 1))
        return $errors
    fi

    # Finally, run make re and verify
    make re &> /dev/null
    local result_re=$?
    if [ $result_re -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} make re executed successfully."
    else
        echo -e "${RED}[KO]${DEF_COLOR} Error executing make re."
        errors=$((errors + 1))
        return $errors
    fi

    # Check again if all required .o files and libft.a are created after make re
    check_compilation

    # If no errors, show everything is OK
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} Makefile complies with all required standards."
    fi

    return $errors
}

# Function to check the existence of a rule in the Makefile
check_rule() {
    local rule="$1"
    grep -q "^$rule:" "$makefile"
    if [ $? -ne 0 ]; then
        echo -e "${RED}[KO]${DEF_COLOR} Rule '$rule' is missing in the Makefile."
        return 1
    else
        echo -e "${GREEN}[OK]${DEF_COLOR} Rule '$rule' is defined in the Makefile."
    fi
}

# Function to check compilation of all .o files and libft.a
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

    # Check existence of .o files
    for func in "${mandatory_functions[@]}"; do
        object_file="ft_$(echo $func | sed 's/ft_//').o"
        if [ ! -f "$object_file" ]; then
            missing_objects="$missing_objects $object_file"
            errors=$((errors + 1))
        fi
    done

    if [ $errors -ne 0 ]; then
        echo -e "${RED}[KO]${DEF_COLOR} The following .o files are missing: $missing_objects"
    else
        echo -e "${GREEN}[OK]${DEF_COLOR} All required .o files have been created."
    fi

    # Check existence of libft.a
    if [ ! -f "libft.a" ]; then
        echo -e "${RED}[KO]${DEF_COLOR} libft.a file has not been created."
        errors=$((errors + 1))
    else
        echo -e "${GREEN}[OK]${DEF_COLOR} libft.a file has been created."
    fi

    return $errors
}

# Function to clean .o files and libft.a
clean_up() {
    echo "Cleaning .o files and libft.a..."

    # Remove .o files
    rm -f *.o
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} .o files deleted successfully."
    else
        echo -e "${RED}[KO]${DEF_COLOR} Error deleting .o files."
    fi

    # Remove libft.a
    rm -f libft.a
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK]${DEF_COLOR} libft.a file deleted successfully."
    else
        echo -e "${RED}[KO]${DEF_COLOR} Error deleting libft.a file."
    fi
}

# Call the verification function
check_makefile
errors=$?

# Clean files before exiting
clean_up

exit $errors
