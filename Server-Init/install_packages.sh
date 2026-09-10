#!/usr/bin/env bash
source "$(dirname "$0")/utils.sh"

# Install every APT-provided command used by the installer before any
# installation stage that needs it. bash/dpkg/coreutils are Ubuntu base-system
# prerequisites and therefore cannot be bootstrapped by this script.
PACKAGES=(
    ca-certificates
    curl
    git
    python3
    vim
    zsh
    btop
)
require_root


# Update package lists unless the parent installer already did so.
if [[ "${SKIP_APT_UPDATE:-0}" != "1" ]]; then
    apt-get update -y
fi

# Install packages in one idempotent transaction.
pkg_install "${PACKAGES[@]}"
