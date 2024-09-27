#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Main function to set the timezone.
function main() {
    # Set the timezone to America/Chicago
    export TZ="America/Chicago"

    # Create a symbolic link to the timezone file
    sudo ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime

    # Write the timezone to /etc/timezone
    echo "${TZ}" | sudo tee /etc/timezone

    # Install the tzdata package non-interactively
    DEBIAN_FRONTEND="noninteractive" sudo apt-get install -y tzdata
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
