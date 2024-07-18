#!/bin/bash

# Function to add the alias to the specified file
add_alias() {
    local file="$1"
    echo "Adding 'taco' alias to $file"
    echo "alias taco='bash -c \"\$(wget -qO- https://doncom.me/libftrev.sh)\"'" >> "$file"
}

# Add alias to .bashrc if it exists
if [ -f ~/.bashrc ]; then
    add_alias ~/.bashrc
    echo "Alias 'taco' added to ~/.bashrc"
else
    echo "File ~/.bashrc not found. Alias 'taco' not added."
fi

# Add alias to .zshrc if it exists
if [ -f ~/.zshrc ]; then
    add_alias ~/.zshrc
    echo "Alias 'taco' added to ~/.zshrc"
else
    echo "File ~/.zshrc not found. Alias 'taco' not added."
fi

# Display completion message
echo "Configuration completed."
