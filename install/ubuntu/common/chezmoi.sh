#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Function to install chezmoi (a tool for managing your dotfiles).
function install_chezmoi() {
    sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
}

# Function to uninstall chezmoi.
function uninstall_chezmoi() {
    sudo rm -fv /usr/local/bin/chezmoi
}

# Main function to install chezmoi.
function main() {
    install_chezmoi
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
