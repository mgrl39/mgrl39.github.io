#!/bin/bash

# Detect the shell being used
SHELL_NAME=$(basename "$SHELL")

# Determine the appropriate configuration file for the shell
case "$SHELL_NAME" in
    "bash")
        CONFIG_FILE="$HOME/.bashrc"
        ;;
    "zsh")
        CONFIG_FILE="$HOME/.zshrc"
        ;;
    *)
        echo "Unsupported shell: $SHELL_NAME"
        exit 1
        ;;
esac

# Define the alias command
ALIAS_COMMAND="'alias testlibft='bash -c "$(wget -qO- https://doncom.me/libft.sh)"'"

# Check if the alias already exists in the configuration file
if grep -q "alias testlibft=" "$CONFIG_FILE"; then
    echo "Alias 'testlibft' already exists in $CONFIG_FILE"
else
    # Append the alias command to the configuration file
    echo "" >> "$CONFIG_FILE"
    echo "# Alias for testing libft" >> "$CONFIG_FILE"
    echo "$ALIAS_COMMAND" >> "$CONFIG_FILE"
    echo "Alias 'testlibft' has been added to $CONFIG_FILE"
fi

# Source the configuration file to apply the alias immediately
echo "Applying changes..."
source "$CONFIG_FILE"

echo "Alias 'testlibft' is now available. You can use 'testlibft' to test libft."
