#!/usr/bin/env bash
# Re-exec with bash when this script was downloaded and invoked with sh.
if [ -z "${BASH_VERSION:-}" ]; then
    if [ -f "$0" ]; then
        exec bash "$0" "$@"
    fi
    echo "[ERR] This installer requires bash. Use: curl -fsSL <url> | bash" >&2
    exit 1
fi
set -euo pipefail

# If utils.sh doesn't exist, we're running from the one-liner. Bootstrap from
# GitHub's archive instead of git: git is installed only after the full
# installer starts.
if [ ! -f "$(dirname "$0")/Server-Init/utils.sh" ]; then
    TEMP_DIR=$(mktemp -d)
    ARCHIVE_URL="https://codeload.github.com/Michael-YS/server-dotfiles/tar.gz/refs/heads/main"
    echo "[INFO] Downloading installer files..."
    curl -fsSL "$ARCHIVE_URL" | tar -xz --strip-components=1 -C "$TEMP_DIR"
    # --all later runs the dotfiles installer as the invoking user, who must
    # be able to traverse this public archive directory.
    chmod 755 "$TEMP_DIR"
    exec bash "$TEMP_DIR/install.sh" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/Server-Init/utils.sh"

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
    # --all runs the server setup as root, but shell configuration belongs to
    # the user who invoked sudo rather than /root.
    if [[ $EUID -eq 0 && -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]]; then
        sudo -H -u "$SUDO_USER" bash "$SCRIPT_DIR/install_dotfiles.sh"
    else
        bash "$SCRIPT_DIR/install_dotfiles.sh"
    fi
}

install_server() {
    log_info "=== Initial apt update ==="
    apt-get update -y

    log_info "=== Installing all APT prerequisites ==="
    SKIP_APT_UPDATE=1 bash "$SCRIPT_DIR/Server-Init/install_packages.sh"

    log_info "=== Installing Docker ==="
    SKIP_APT_UPDATE=1 bash "$SCRIPT_DIR/Server-Init/install_docker.sh"

    log_info "=== Installing Tailscale ==="
    bash "$SCRIPT_DIR/Server-Init/install_tailscale.sh"

    log_info "=== Server setup complete ==="
}

main() {
    case "${1:---dotfiles}" in
        --dotfiles)  install_dotfiles ;;
        --server)    require_root; install_server ;;
        --all)       require_root; install_server; install_dotfiles ;;
        -h|--help)   usage; exit 0 ;;
        *)           usage; exit 1 ;;
    esac
}

main "$@"
