#!/usr/bin/env bash
# 颜色 + log 函数，被其他模块 source

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERR]${NC}   $*" >&2; }

# 检查命令是否存在
has() { command -v "$1" &>/dev/null; }

# 幂等 apt 安装：只在未安装时才装
pkg_install() {
    local pkgs=()
    for p in "$@"; do
        dpkg -s "$p" &>/dev/null || pkgs+=("$p")
    done
    [[ ${#pkgs[@]} -eq 0 ]] && return 0
    log_info "Installing: ${pkgs[*]}"
    apt-get install -y "${pkgs[@]}"
}

# 用于需要 root 的操作
require_root() {
    [[ $EUID -eq 0 ]] || { log_error "Run as root (sudo)"; exit 1; }
}