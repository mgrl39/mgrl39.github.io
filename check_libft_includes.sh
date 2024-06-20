#!/bin/bash

# Variables to count files that meet and do not meet the criteria
count_included=0
count_not_included=0

# Function to print in green
print_green() {
    echo -e "\e[32m$1\e[0m"
}

# Function to print in red
print_red() {
    echo -e "\e[31m$1\e[0m"
}

# Folder to explore (change to your desired path)
folder="."

# Check .c files in the folder
c_files=$(find "$folder" -name "*.c")

# Iterate over each .c file found
for file in $c_files; do
    if grep -q '#include "libft.h"' "$file"; then
        print_green "$file: Yes"
        (( count_included++ ))
    else
        print_red "$file: No"
        (( count_not_included++ ))
    fi
done

# Print global count
echo "Files with '#include \"libft.h\"' found: $count_included"
echo "Files without '#include \"libft.h\"' found: $count_not_included"
