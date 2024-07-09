#!/bin/bash

# Array of files that SHOULD be in the delivery folder
files_to_check=(
    "libft.h"
    "Makefile"
    "ft_isalpha.c"
    "ft_isdigit.c"
    "ft_isalnum.c"
    "ft_isascii.c"
    "ft_isprint.c"
    "ft_toupper.c"
    "ft_tolower.c"
    "ft_strlen.c"
    "ft_strlcpy.c"
    "ft_strlcat.c"
    "ft_strchr.c"
    "ft_strrchr.c"
    "ft_strnstr.c"
    "ft_strncmp.c"
    "ft_memset.c"
    "ft_bzero.c"
    "ft_memcpy.c"
    "ft_memmove.c"
    "ft_memchr.c"
    "ft_memcmp.c"
    "ft_strdup.c"
    "ft_calloc.c"
    "ft_atoi.c"
    "ft_substr.c"
    "ft_strjoin.c"
    "ft_strtrim.c"
    "ft_split.c"
    "ft_striteri.c"
    "ft_itoa.c"
    "ft_strmapi.c"
    "ft_putchar_fd.c"
    "ft_putstr_fd.c"
    "ft_putendl_fd.c"
    "ft_putnbr_fd.c"
    "ft_lstnew.c"
    "ft_lstadd_front.c"
    "ft_lstsize.c"
    "ft_lstlast.c"
    "ft_lstadd_back.c"
    "ft_lstdelone.c"
    "ft_lstclear.c"
    "ft_lstiter.c"
    "ft_lstmap.c"
)

# Function to check if a file is in the list of files to check
is_required_file() {
    filename=$1
    for file in "${files_to_check[@]}"; do
        if [ "$filename" == "$file" ]; then
            return 0
        fi
    done
    return 1
}

# Function to check the existence of specific files and display in color
check_files() {
    filename=$1
    if is_required_file "$filename"; then
        echo -e "\e[32m$filename - Found\e[0m"
    else
        echo -e "\e[31m$filename - Not part of libft exercises\e[0m"
    fi
}

# Check for all files (including hidden) in the current directory
echo -e "\e[32m### Checking all files (including hidden) ###\e[0m"
shopt -s dotglob # Enable globbing to include hidden files
for file in *; do
    if [ -f "$file" ]; then
        check_files "$file"
    fi
done
shopt -u dotglob # Disable dotglob to revert back to normal behavior

