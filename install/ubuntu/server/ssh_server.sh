#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Function to install packages.
function install_packages() {
    # Update package list and install packages without recommended packages.
    sudo apt-get update && sudo apt-get install --no-install-recommends -y \
        nano
}

# Function to set up SSH daemon configuration.
function setup_sshd() {
    # Create necessary directories for SSH daemon.
    sudo mkdir -p /var/run/sshd
    mkdir -p ${HOME}/.ssh

    # Modify SSH daemon configuration to enhance security and usability.
    sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config &&
        sudo sed -i 's/^#Port 22/Port 22/' /etc/ssh/sshd_config &&
        sudo sed -i 's/^#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config &&
        sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config &&
        sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config &&
        sudo sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

    # Check the SSH daemon configuration for syntax errors.
    sudo /usr/sbin/sshd -t

    # Create .ssh/authorized_keys file if it does not exist.
    touch ${HOME}/.ssh/authorized_keys
}

# Function to start the SSH daemon.
function run_sshd() {
    # Start the SSH service.
    sudo /usr/sbin/service ssh start
}

# Main function to install and configure the SSH server.
function main() {
    install_packages
    setup_sshd
    run_sshd
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
