#!/bin/bash

# Array of files and exercises to verify
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
    "ft_lstnew_bonus.c"
    "ft_lstadd_front_bonus.c"
    "ft_lstsize_bonus.c"
    "ft_lstlast_bonus.c"
    "ft_lstadd_back_bonus.c"
    "ft_lstdelone_bonus.c"
    "ft_lstclear_bonus.c"
    "ft_lstiter_bonus.c"
    "ft_lstmap_bonus.c"
)

# Function to check the existence of a specific file and display in color
check_file() {
    filename=$1
    if [ -e "$filename" ]; then
        echo -e "\e[32m$filename - Yes\e[0m"
    else
        echo -e "\e[31m$filename - No\e[0m"
    fi
}

# Variables to count found and not found files and exercises
count_found=0
count_not_found=0

# Check the existence of files and exercises in the current directory and subdirectories
for file in "${files_to_check[@]}"; do
    check_file "$file"
    if [ -e "$file" ]; then
        ((count_found++))
    else
        ((count_not_found++))
    fi
done

# Print summary
echo ""
echo -e "\e[32m### Summary ###\e[0m"
echo "Files found: $count_found"
echo "Files not found: $count_not_found"
