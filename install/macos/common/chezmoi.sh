#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Function to check if chezmoi is installed.
function is_chezmoi_installed() {
    command -v chezmoi &>/dev/null
}

# Function to install chezmoi if it is not already installed.
function install_chezmoi() {
    if ! is_chezmoi_installed; then
        brew install chezmoi
    fi
}

# Function to uninstall chezmoi.
function uninstall_chezmoi() {
    brew uninstall chezmoi
}

# Main function to install chezmoi.
function main() {
    install_chezmoi
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
