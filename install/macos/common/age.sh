#!/usr/bin/env bash

# Enable strict error handling
set -Eeuo pipefail

# Enable debug mode if DOTFILES_DEBUG is set
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Function to check if 'age' is installed
function is_age_installed() {
    command -v age &>/dev/null
}

# Function to check if 'jq' is installed
function is_jq_installed() {
    command -v jq &>/dev/null
}

# Function to install 'age' using Homebrew if not already installed
function install_age() {
    if ! is_age_installed; then
        brew install age
    fi
}

# Function to install 'jq' using Homebrew if not already installed
function install_jq() {
    if ! is_jq_installed; then
        brew install jq
    fi
}

# Function to uninstall 'age' using Homebrew
function uninstall_age() {
    brew uninstall age
}

# Function to uninstall 'jq' using Homebrew
function uninstall_jq() {
    brew uninstall jq
}

# Main function to orchestrate the script
function main() {
    install_age
    install_jq
}

# Execute main function if the script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
