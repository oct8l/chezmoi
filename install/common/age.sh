#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Function to check if 'age' (a file encryption tool) is installed.
function is_age_installed() {
    command -v "age" &>/dev/null
}

# Function to get the home directory used by chezmoi.
function get_chezmoi_home_dir() {
    local home_dir
    home_dir=$(chezmoi data | jq -r '.chezmoi.homeDir')
    echo -n "${home_dir}"
}

# Function to get the source directory used by chezmoi.
function get_chezmoi_source_dir() {
    local source_dir
    source_dir=$(chezmoi data | jq -r '.chezmoi.sourceDir')
    echo -n "${source_dir}"
}

# Function to decrypt the age private key.
function decrypt_age_private_key() {
    local age_dir
    local age_src_key
    local age_dst_key

    # Check if running in a CI environment.
    if "${CI:-false}"; then
        # 'age' requires a TTY, which is not available in CI environments, so return early.
        return 0 # early return
    fi

    # If 'age' is installed, proceed with decryption.
    if is_age_installed; then
        age_dir="$(get_chezmoi_home_dir)/.config/age"
        age_src_key="$(get_chezmoi_source_dir)/.key.txt.age"
        age_dst_key="${age_dir}/key.txt"

        # If the destination key file does not exist, decrypt the source key file.
        if [ ! -f "${age_dst_key}" ]; then
            mkdir -p "${age_dir}"

            echo "Decrypting ${age_src_key} to ${age_dst_key}"
            age --decrypt --output "${age_dst_key}" "${age_src_key}"
            chmod 600 "${age_dst_key}"
        fi
    else
        # If 'age' is not installed, print an error message and exit.
        echo "age (https://github.com/FiloSottile/age) is required to decrypt the files." >&2
        exit 1
    fi
}

# Main function to decrypt the age private key.
function main() {
    decrypt_age_private_key
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
