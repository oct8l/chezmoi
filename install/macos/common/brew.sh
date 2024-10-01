#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Function to check if Homebrew is installed.
function is_homebrew_exists() {
    command -v brew &>/dev/null
}

# Function to install Homebrew if it is not already installed.
function install_homebrew() {
    if ! is_homebrew_exists; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Function to opt out of Homebrew analytics.
function opt_out_of_analytics() {
    brew analytics off
}

# Function to add Homebrew to the PATH.
function add_homebrew_to_path() {
    if is_homebrew_exists; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    fi
}

# Main function to install Homebrew and opt out of analytics.
function main() {
    install_homebrew
    opt_out_of_analytics
    add_homebrew_to_path
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
