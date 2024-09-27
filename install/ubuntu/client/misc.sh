#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Define an array of packages to be installed.
readonly PACKAGES=(
    htop
    cowsay
    fortune
    sl
)

# Function to install miscellaneous packages.
function install_misc() {
    sudo apt-get install -y "${PACKAGES[@]}"
}

# Function to uninstall miscellaneous packages.
function uninstall_misc() {
    sudo apt-get remove -y "${PACKAGES[@]}"
}

# Main function to install miscellaneous packages.
function main() {
    install_misc
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
