#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Function to check if 'mas' (Mac App Store command line interface) is installed.
function is_mas_installed() {
    command -v mas &>/dev/null
}

# Function to install 'mas' using Homebrew if it is not already installed.
function install_mas() {
    if ! is_mas_installed; then
        brew install mas
    fi
}

# Function to install a Mac App Store app using its app ID.
function run_mas_install() {
    local app_id="$1"
    mas install "${app_id}"
}

# Function to install Bandwidth+ app from the Mac App Store.
function install_bandwidth_plus() {
    local app_id="490461369"
    run_mas_install "${app_id}"
}

# Function to install LINE app from the Mac App Store.
function install_line() {
    local app_id="539883307"
    run_mas_install "${app_id}"
}

# Function to install 1Password 7 app from the Mac App Store.
function install_1password7() {
    local app_id="1333542190"
    run_mas_install "${app_id}"
}

# Function to install Xcode app from the Mac App Store.
function install_xcode() {
    local app_id="497799835"
    run_mas_install "${app_id}"
}

# Function to install Tailscale app from the Mac App Store.
function install_tailscale() {
    local app_id="1475387142"
    run_mas_install "${app_id}"
}

# Main function to install 'mas' and then install apps if not in a CI environment.
function main() {
    # install_mas
    # install_bandwidth_plus
    # install_line
    # install_1password7
    # install_xcode
    # install_tailscale

    # Check if not running in a Continuous Integration (CI) environment.
    if ! "${CI:-false}"; then
        # Add app installation functions here if needed.
    fi
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
