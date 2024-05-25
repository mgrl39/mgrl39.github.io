#!/bin/bash

# Declaration of style variables
MAGENTA="\033[35m"
BOLD="\033[1m"
CLEAR_LINE="\033[2K"
WHITE="\033[37m"
GREEN="\033[32m"
RESET="\033[0m"

# Function to display messages
function show_message {
    printf "${BOLD}$1${RESET}\n"
}

# Function to display success messages
function show_success {
    printf "${GREEN}$1${RESET}\n"
}

# Update package list (silent)
show_message "Updating package list..."
sudo apt update -y > /dev/null 2>&1
show_success "Package list updated successfully."

# Install git if not installed
if ! command -v git &> /dev/null; then
    show_message "Git is not installed. Installing git..."
    sudo apt install git -y > /dev/null 2>&1
    show_success "Git installed successfully."
else
    show_message "Git is already installed."
fi

# Install vim if not installed
if ! command -v vim &> /dev/null; then
    show_message "Vim is not installed. Installing vim..."
    sudo apt install vim -y > /dev/null 2>&1
    show_success "Vim installed successfully."
else
    show_message "Vim is already installed."
fi

# Install python3-pip if not installed
if ! command -v pip3 &> /dev/null; then
    show_message "pip is not installed. Installing python3-pip..."
    sudo apt install python3-pip -y > /dev/null 2>&1
    show_success "python3-pip installed successfully."
else
    show_message "python3-pip is already installed."
fi

# Change to user directory
cd ~

# Create doncom directory if it doesn't exist
if [ ! -d "doncom" ]; then
    mkdir doncom
fi

# Change to doncom directory
cd doncom

# Create .dcprograms hidden directory if it doesn't exist
if [ ! -d ".dcprograms" ]; then
    mkdir .dcprograms
fi

# Change to .dcprograms directory
cd .dcprograms

# Display cloning message
show_message "Cloning Yakuza repository from GitHub..."
git clone https://github.com/doncomproject/yakuza > /dev/null 2>&1
show_success "Yakuza repository cloned successfully."

show_message "Cloning Rocket repository from GitHub..."
git clone https://github.com/doncomproject/rocket > /dev/null 2>&1
show_success "Rocket repository cloned successfully."

# Display completion message
show_success "${GREEN}Cloning complete!${RESET}"
