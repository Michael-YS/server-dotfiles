#!/usr/bin/env bash
source "$(dirname "$0")/utils.sh"
require_root

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Authenticate interactively and print the verification URL.
tailscale up
