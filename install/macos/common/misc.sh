#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Define an array of Homebrew packages to be installed.
readonly BREW_PACKAGES=(
    gpg
    jq
    htop
    pinentry-mac
    watchexec
    zsh
)

# Define an array of Homebrew Cask packages to be installed.
# readonly CASK_PACKAGES=(
#     google-chrome
#     spotify
# )

# Function to check if a Homebrew package is installed.
function is_brew_package_installed() {
    local package="$1"
    brew list "${package}" &>/dev/null
}

# Function to install missing Homebrew packages.
function install_brew_packages() {
    local missing_packages=()

    # Check each package in BREW_PACKAGES array.
    for package in "${BREW_PACKAGES[@]}"; do
        if ! is_brew_package_installed "${package}"; then
            missing_packages+=("${package}")
        fi
    done

    # If there are missing packages, install them.
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        if "${CI:-false}"; then
            brew info "${missing_packages[@]}"
        else
            brew install --force "${missing_packages[@]}"
        fi
    fi
}

# Function to install missing Homebrew Cask packages.
function install_brew_cask_packages() {
    local missing_packages=()

    # Check each package in CASK_PACKAGES array.
    for package in "${CASK_PACKAGES[@]}"; do
        if ! is_brew_package_installed "${package}"; then
            missing_packages+=("${package}")
        fi
    done

    # If there are missing packages, install them.
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        if "${CI:-false}"; then
            brew info --cask "${missing_packages[@]}"
        else
            brew install --cask --force "${missing_packages[@]}"
        fi
    fi
}

# Function to set up Google Chrome as the default browser.
function setup_google_chrome() {
    open "/Applications/Google Chrome.app" --args --make-default-browser
}

# Main function to install packages and set up Google Chrome.
function main() {
    install_brew_packages
    # install_brew_cask_packages
    # setup_google_chrome
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
