#!/usr/bin/env bash

set -Eeuo pipefail

# Check if DOTFILES_DEBUG is set or if a debug flag is passed as an argument
DEBUG="${DOTFILES_DEBUG:-false}"
for arg in "$@"; do
    if [[ "$arg" == "--debug" ]]; then
        DEBUG=true
    fi
done

if [ "$DEBUG" == "true" ]; then
    set -x
fi

# Function to print debug messages
function debug_echo() {
    if [ "$DEBUG" == "true" ]; then
        echo "$@"
    fi
}

# shellcheck disable=SC2016
declare -r DOTFILES_LOGO='
                          /$$                                      /$$
                         | $$                                     | $$
     /$$$$$$$  /$$$$$$  /$$$$$$   /$$   /$$  /$$$$$$      /$$$$$$$| $$$$$$$
    /$$_____/ /$$__  $$|_  $$_/  | $$  | $$ /$$__  $$    /$$_____/| $$__  $$
   |  $$$$$$ | $$$$$$$$  | $$    | $$  | $$| $$  \ $$   |  $$$$$$ | $$  \ $$
    \____  $$| $$_____/  | $$ /$$| $$  | $$| $$  | $$    \____  $$| $$  | $$
    /$$$$$$$/|  $$$$$$$  |  $$$$/|  $$$$$$/| $$$$$$$//$$ /$$$$$$$/| $$  | $$
   |_______/  \_______/   \___/   \______/ | $$____/|__/|_______/ |__/  |__/
                                           | $$
                                           | $$
                                           |__/

             *** This is setup script for my dotfiles setup ***
                     https://github.com/oct8l/chezmoi
'

declare -r DOTFILES_REPO_URL="https://github.com/oct8l/chezmoi"
declare -r BRANCH_NAME="${BRANCH_NAME:-main}"
declare -r DOTFILES_GITHUB_PAT="${DOTFILES_GITHUB_PAT:-}"

function is_ci() {
    debug_echo "Checking if running in CI environment..."
    "${CI:-false}"
}

function is_tty() {
    debug_echo "Checking if running in a TTY..."
    [ -t 0 ]
}

function is_not_tty() {
    debug_echo "Checking if not running in a TTY..."
    ! is_tty
}

function is_ci_or_not_tty() {
    debug_echo "Checking if running in CI or not in a TTY..."
    is_ci || is_not_tty
}

function at_exit() {
    debug_echo "Setting up at_exit trap..."
    AT_EXIT+="${AT_EXIT:+$'\n'}"
    AT_EXIT+="${*?}"
    # shellcheck disable=SC2064
    trap "${AT_EXIT}" EXIT
}

function keepalive_sudo_linux() {
    debug_echo "Setting up sudo keep-alive for Linux..."
    echo "Checking for \`sudo\` access which may request your password."
    sudo -v

    # Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
}

function keepalive_sudo_macos() {
    debug_echo "Setting up sudo keep-alive for macOS..."
    (
        builtin read -r -s -p "Password: " </dev/tty
        builtin echo "add-generic-password -U -s 'dotfiles' -a '${USER}' -w '${REPLY}'"
    ) | /usr/bin/security -i
    printf "\n"
    at_exit "
                echo -e '\033[0;31mRemoving password from Keychain …\033[0m'
                /usr/bin/security delete-generic-password -s 'dotfiles' -a '${USER}'
            "
    SUDO_ASKPASS="$(/usr/bin/mktemp)"
    at_exit "
                echo -e '\033[0;31mDeleting SUDO_ASKPASS script …\033[0m'
                /bin/rm -f '${SUDO_ASKPASS}'
            "
    {
        echo "#!/bin/sh"
        echo "/usr/bin/security find-generic-password -s 'dotfiles' -a '${USER}' -w"
    } >"${SUDO_ASKPASS}"

    /bin/chmod +x "${SUDO_ASKPASS}"
    export SUDO_ASKPASS

    if ! /usr/bin/sudo -A -kv 2>/dev/null; then
        echo -e '\033[0;31mIncorrect password.\033[0m' 1>&2
        exit 1
    fi
}

function keepalive_sudo() {
    debug_echo "Setting up sudo keep-alive..."
    local ostype
    ostype=$(uname)
    debug_echo "OS type: ${ostype}"

    if [ "${ostype}" == "Darwin" ]; then
        keepalive_sudo_macos
    elif [ "${ostype}" == "Linux" ]; then
        keepalive_sudo_linux
    else
        echo "Invalid OS type: ${ostype}" >&2
        exit 1
    fi
}

function initialize_os_macos() {
    debug_echo "Initializing macOS environment..."
    function is_homebrew_exists() {
        command -v brew &>/dev/null
    }

    # Install Homebrew if needed.
    if ! is_homebrew_exists; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Setup Homebrew envvars.
    if [[ $(arch) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ $(arch) == "i386" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        echo "Invalid CPU arch: $(arch)" >&2
        exit 1
    fi
}

function initialize_os_linux() {
    debug_echo "Initializing Linux environment..."
    :
}

function initialize_os_env() {
    debug_echo "Initializing OS environment..."
    local ostype
    ostype=$(uname)
    debug_echo "OS type: ${ostype}"

    if [ "${ostype}" == "Darwin" ]; then
        initialize_os_macos
    elif [ "${ostype}" == "Linux" ]; then
        initialize_os_linux
    else
        echo "Invalid OS type: ${ostype}" >&2
        exit 1
    fi
}

function run_chezmoi() {
    debug_echo "Running chezmoi..."
    # Download the chezmoi binary from the URL
    sh -c "$(curl -fsLS get.chezmoi.io)"
    local chezmoi_cmd
    chezmoi_cmd="./bin/chezmoi"
    local chezmoi_dir
    chezmoi_dir="./bin"
    debug_echo "chezmoi command path: ${chezmoi_cmd}"
    debug_echo "chezmoi directory path: ${chezmoi_dir}"

    if is_ci_or_not_tty; then
        no_tty_option="--no-tty" # /dev/tty is not available (especially in the CI)
    else
        no_tty_option="" # /dev/tty is available OR not in the CI
    fi
    debug_echo "no_tty_option: ${no_tty_option}"

    # Run `chezmoi init` to setup the source directory,
    # generate the config file, and optionally update the destination directory
    # to match the target state.
    "${chezmoi_cmd}" init "${DOTFILES_REPO_URL}" \
        --force \
        --branch "${BRANCH_NAME}" \
        ${no_tty_option}
    debug_echo "chezmoi init completed."

    # The `age` command requires a tty, but there is no tty in the GitHub actions.
    # Therefore, it is currently difficult to decrypt the files encrypted with `age` in this workflow.
    # I decided to temporarily remove the encrypted target files from chezmoi's control.
    if is_ci_or_not_tty; then
        find "$(${chezmoi_cmd} source-path)" -type f -name "encrypted_*" -exec rm -fv {} +
    fi

    # Add to PATH for installing the necessary binary files under `$HOME/.local/bin`.
    export PATH="${PATH}:${HOME}/.local/bin"

    if [[ -n "${DOTFILES_GITHUB_PAT}" ]]; then
        export DOTFILES_GITHUB_PAT
    fi

    # Run `chezmoi apply` to ensure that target files are in the target state,
    # updating them if necessary.
    "${chezmoi_cmd}" apply ${no_tty_option}
    debug_echo "chezmoi apply completed."

    # Check if the directory is empty before attempting to delete it
    if [ -d "${chezmoi_dir}" ] && [ -z "$(ls -A "${chezmoi_dir}")" ]; then
        debug_echo "Directory ${chezmoi_dir} is empty. Deleting..."
        rm -rfv "${chezmoi_dir}"
        debug_echo "chezmoi directory purged."
    else
        debug_echo "Directory ${chezmoi_dir} is not empty. Skipping deletion."
    fi
}

function initialize_dotfiles() {
    debug_echo "Initializing dotfiles..."
    if ! is_ci_or_not_tty; then
        # - /dev/tty of the github workflow is not available.
        # - We can use password-less sudo in the github workflow.
        # Therefore, skip the sudo keep alive function.
        keepalive_sudo
    fi
    run_chezmoi
}

function get_system_from_chezmoi() {
    debug_echo "Getting system from chezmoi..."
    local system
    system=$(chezmoi data | jq -r '.system')
    debug_echo "System: ${system}"
    echo "${system}"
}

function restart_shell_system() {
    debug_echo "Restarting shell system..."
    local system
    system=$(get_system_from_chezmoi)
    debug_echo "System: ${system}"

    # exec shell as login shell (to reload the .zprofile or .profile)
    if [ "${system}" == "client" ]; then
        /bin/bash --login
    elif [ "${system}" == "server" ]; then
        /bin/bash --login
    else
        echo "Invalid system: ${system}; expected \`client\` or \`server\`" >&2
        exit 1
    fi
}

function restart_shell() {
    debug_echo "Restarting shell..."
    # Restart shell if specified "bash -c $(curl -L {URL})"
    # not restart:
    #   curl -L {URL} | bash
    if [ -p /dev/stdin ]; then
        echo "Now continue with Rebooting your shell"
    else
        debug_echo "Restarting your shell..."
        restart_shell_system
    fi
}

function main() {
    echo "Starting main function..."
    echo "$DOTFILES_LOGO"

    initialize_os_env
    initialize_dotfiles

    # restart_shell # Disabled because the at_exit function does not work properly.
    echo "Main function completed."
}

main
