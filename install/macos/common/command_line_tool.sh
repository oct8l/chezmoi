#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Function to install command line developer tools if not already installed.
function install_command_line_tool() {
    local git_cmd_path="/Library/Developer/CommandLineTools/usr/bin/git"

    # Check if the git command from the command line tools exists.
    if [ ! -e "${git_cmd_path}" ]; then
        # Install command line developer tool
        xcode-select --install
        # Wait for user input to confirm installation completion.
        echo "Press any key when the installation has completed."
        IFS= read -r -n 1 -d ''
        #          │  │    └ The first character of DELIM is used to terminate the input line, rather than newline.
        #          │  │
        #          │  └ returns after reading NCHARS characters rather than waiting for a complete line of input.
        #          │
        #          └ If this option is given, backslash does not act as an escape character.
        #            The backslash is considered to be part of the line. In particular, a backslash-newline
        #            pair may not be used as a line continuation.
    else
        echo "Command line developer tools are installed."
    fi
}

# Main function to install command line developer tools.
function main() {
    install_command_line_tool
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
