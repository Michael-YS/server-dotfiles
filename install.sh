#!/usr/bin/env bash
# Re-exec with bash if running under sh (e.g., curl | sh on Ubuntu where sh=dash)
if [ -z "${BASH_VERSION:-}" ]; then
    ARGS="$@"
    TMP=$(mktemp)
    cat > "$TMP"
    exec bash "$TMP" $ARGS
fi
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
source "$SCRIPT_DIR/Server-Init/utils/mask_apt.sh"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTION]

Options:
    --dotfiles     Install dotfiles only (default, user-level)
    --server       Install server packages (requires root)
    --all          Install both dotfiles and server packages
    -h, --help     Show this help message

EOF
}

install_dotfiles() {
    bash "$SCRIPT_DIR/install_dotfiles.sh"
}

install_server() {
    log_info "=== Initial apt update ==="
    apt-get update -y

    log_info "=== Installing base packages ==="
    bash "$SCRIPT_DIR/Server-Init/install_packages.sh"

    mask
    log_info "=== Installing Docker ==="
    bash "$SCRIPT_DIR/Server-Init/install_docker.sh"

    log_info "=== Refreshing apt after Docker source added ==="
    unmask
    apt-get update -y

    log_info "=== Installing Tailscale ==="
    bash "$SCRIPT_DIR/Server-Init/install_tailscale.sh"

    log_info "=== Server setup complete ==="
}

main() {
    case "${1:-all}" in
        --dotfiles)  install_dotfiles ;;
        --server)    require_root; install_server ;;
        --all)       install_dotfiles; require_root; install_server ;;
        -h|--help)   usage; exit 0 ;;
        *)           usage; exit 1 ;;
    esac
}

main "$@"