#!/usr/bin/env bash

# Enable strict error handling
set -Eeuo pipefail

# Enable debug mode if DOTFILES_DEBUG is set
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Function to install Rosetta on macOS if not already installed
function install_rosetta() {
    local rosetta_path="/Library/Apple/usr/share/rosetta/rosetta"
    if ! [[ -f "${rosetta_path}" ]]; then
        softwareupdate --install-rosetta --agree-to-license
    fi
}

# Main function to orchestrate the script
function main() {
    install_rosetta
}

# Execute main function if the script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
