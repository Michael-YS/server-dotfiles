#!/usr/bin/env bash
set -euo pipefail

# If utils.sh doesn't exist, we're running via curl - clone the repo first
if [ ! -f "$(dirname "$0")/Server-Init/utils.sh" ]; then
    REPO_URL="https://github.com/Michael-YS/server-dotfiles.git"
    TEMP_DIR=$(mktemp -d)
    echo "[INFO] Cloning repo for remote installation..."
    git clone --depth=1 "$REPO_URL" "$TEMP_DIR"
    exec bash "$TEMP_DIR/install.sh" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/Server-Init/utils.sh"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTION]

Options:
    --dotfiles     Install dotfiles only (default)
    --server       Install server packages (Docker, Tailscale)
    --all          Install both dotfiles and server packages
    -h, --help     Show this help message

EOF
}

install_dotfiles() {
    bash "$SCRIPT_DIR/install_dotfiles.sh"
}

install_server() {
    local packages=(git python3 vim zsh)

    log_info "=== Installing base packages ==="
    pkg_install "${packages[@]}"

    log_info "=== Installing Docker ==="
    install_docker

    log_info "=== Installing Tailscale ==="
    install_tailscale

    log_info "=== Server setup complete ==="
}

install_docker() {
    if command -v docker &>/dev/null; then
        log_info "Docker already installed"
        return
    fi

    apt update
    apt install -y ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_tailscale() {
    if command -v tailscale &>/dev/null; then
        log_info "Tailscale already installed"
        return
    fi

    curl -fsSL https://tailscale.com/install.sh | sh
}

main() {
    require_root

    case "${1:-all}" in
        --dotfiles)  install_dotfiles ;;
        --server)    install_server ;;
        --all)       install_dotfiles && install_server ;;
        -h|--help)   usage; exit 0 ;;
        *)           usage; exit 1 ;;
    esac
}

main "$@"