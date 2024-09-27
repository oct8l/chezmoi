#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Function to check if 'jq' (a lightweight and flexible command-line JSON processor) is installed.
function is_jq_installed() {
    command -v jq &>/dev/null
}

# Function to install 'age' (a simple, modern, and secure file encryption tool).
function install_age() {
    sudo apt-get install -y age
}

# Function to install 'jq' if it is not already installed.
function install_jq() {
    if ! is_jq_installed; then
        sudo apt-get install -y jq
    fi
}

# Function to uninstall 'age'.
function uninstall_age() {
    sudo apt-get remove -y age
}

# Function to uninstall 'jq'.
function uninstall_jq() {
    sudo apt-get remove -y jq
}

# Main function to install 'jq' and 'age'.
function main() {
    install_jq
    install_age
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
