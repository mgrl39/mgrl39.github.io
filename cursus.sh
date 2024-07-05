#!/bin/bash

# ANSI color definitions
DEF_COLOR='\033[0;39m'
BLACK='\033[0;30m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
GRAY='\033[0;37m'
WHITE='\033[1;37m'

# Function to print the LIBFT gradient
print_libft_logo() {
    printf "${RED}  _    ___ ___ ___ _____ \n"
    printf "${MAGENTA} | |  |_ _| _ ) __|_   _|\n"
    printf "${RED} | |__ | || _ \ _|  | |  \n"
    printf "${MAGENTA} |____|___|___/_|   |_|  "
    printf "${RED}by mgrl39\n"
}

# Function to execute commands using wget and bash
execute_command() {
    url=$1
    echo "Executing $url..."
    bash -c "$(wget -qO- $url)"
}

# Clear screen and display LIBFT gradient
clear
print_libft_logo

# Menu options
echo -e "${MANGENTA}"
echo "Choose an option:"
echo -e "${RED}1) ${MAGENTA}Check libft files..."
echo -e "${RED}2) ${MAGENTA}Check include 'libft.h' in each file"
echo -e "${RED}3) ${MAGENTA}42checker "
echo -e "${RED}4) ${MAGENTA}Makefile checker "
echo -e "${RED}0) ${MAGENTA}Exit"
echo -e "${DEF_COLOR}"

# Read user option
read -p "Select an option: " option

# Execute corresponding action
case $option in
    1)
        execute_command https://doncom.me/libft_finder.sh
        ;;
    2)
        execute_command https://doncom.me/check_libft_includes.sh
        ;;
    3)
        execute_command https://doncom.me/libft.sh
        ;;
    4)
        execute_command https://doncom.me/makefile_libft_checker.sh
    0)
        echo "Exiting..."
        ;;
    *)
        echo -e "${RED}Error: Invalid option.${DEF_COLOR}"
        ;;
esac
