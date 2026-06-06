#!/usr/bin/env bash
source "$(dirname "$0")/utils.sh"
PACKAGES=(git python3 vim zsh)
require_root


# Update package lists
apt update

# Install packages
for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "Installing $pkg..."
        apt install -y "$pkg"
    else
        echo "$pkg is already installed."
    fi
done

