#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

# Base URL of the GitHub repository
GITHUB_URL="https://raw.githubusercontent.com/mgrl39/42checker/main/libft"

# Download the list of exercises
echo -e "${BLUE}Downloading the list of exercises...${NC}"
wget -q -O list.txt "$GITHUB_URL/list.txt"

# Read the list of exercises into an array
mapfile -t exercises < list.txt

# List .c files in the current directory that are in the list of exercises
c_files=$(ls *.c)
evaluatable_files=()

# Check .c files that can be evaluated
for exercise in "${exercises[@]}"; do
    file="ft_${exercise}.c"
    if [[ -f "$file" ]]; then
        evaluatable_files+=("$file")
    fi
done

# Display .c files in the current directory that can be evaluated
echo -e "${YELLOW}.c files in the current directory that can be evaluated:${NC}"
for file in $c_files; do
    if [[ " ${evaluatable_files[@]} " =~ " ${file} " ]]; then
        echo -e "${GREEN}$file${NC}"
    fi
done

# Display known exercise options
echo -e "${YELLOW}Select an exercise to evaluate:${NC}"
select exercise in "${exercises[@]}"; do
    if [[ " ${exercises[@]} " =~ " ${exercise} " ]]; then
        echo -e "${GREEN}You selected: $exercise${NC}"
        break
    else
        echo -e "${RED}Invalid option. Please select a valid exercise.${NC}"
    fi
done

# Download the main corresponding to the exercise
main_url="$GITHUB_URL/ft_${exercise}_main.c"
ex_name="ft_${exercise}_main.c"
echo -e "${BLUE}Downloading $ex_name...${NC}"
wget -q -O "$ex_name" "$main_url"

# Check if the exercise file exists
if [[ ! -f "ft_${exercise}.c" ]]; then
    echo -e "${RED}The file ft_${exercise}.c does not exist in the current directory.${NC}"
    exit 1
fi

# Compile with the downloaded file and the selected exercise
echo -e "${BLUE}Compiling: cc -Wall -Wextra -Werror $ex_name ft_${exercise}.c -o a.out${NC}"
cc -Wall -Wextra -Werror $ex_name ft_${exercise}.c -o a.out

# Check if the compilation was successful
if [[ ! -f "a.out" ]]; then
    echo -e "${RED}Compilation error.${NC}"
    exit 1
fi

# Delete the downloaded main file
rm "$ex_name"

# Run the compiled file
echo -e "${BLUE}Running the compiled file:${NC}"
./a.out

# Check the result of the execution
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Execution error of the compiled file.${NC}"
    exit 1
fi

# Delete the executable file
rm a.out

# Delete the downloaded list of exercises
rm list.txt

echo -e "${GREEN}Tests completed.${NC}"
