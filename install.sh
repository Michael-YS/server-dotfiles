#!/usr/bin/env sh
set -eu

# =========================
# CONFIG
# =========================
REPO_URL="https://github.com/Michael-YS/server-dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
ZSHRC_TARGET="$HOME/.zshrc"
PROFILE_DIR="$HOME/.config/dotfiles"
PROFILE_FILE="$PROFILE_DIR/profile"
OHMYZSH_DIR="$HOME/.oh-my-zsh"

# =========================
# UTIL
# =========================
info() { printf "\033[1;32m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }

# =========================
# PRECHECK
# =========================
command -v git >/dev/null 2>&1 || {
  err "git not found. Please install git first."
  exit 1
}

# =========================
# CLONE / UPDATE (private repo aware)
# =========================
clone_repo() {
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    git clone "https://x-access-token:${GITHUB_TOKEN}@github.com/Michael-YS/server-dotfiles.git" "$DOTFILES_DIR"
  else
    err "GITHUB_TOKEN not set. Cannot access private repository."
    err "Set GITHUB_TOKEN or use cloud-init to inject it."
    exit 1
  fi
}

if [ -d "$DOTFILES_DIR/.git" ]; then
  info "Dotfiles repo already exists. Updating..."
  git -C "$DOTFILES_DIR" pull --ff-only
else
  info "Cloning dotfiles repo..."
  clone_repo
fi


# =========================
# ZSHRC LINK
# =========================
if [ -e "$ZSHRC_TARGET" ] && [ ! -L "$ZSHRC_TARGET" ]; then
  BACKUP="$ZSHRC_TARGET.bak.$(date +%s)"
  warn "Existing ~/.zshrc found. Backing up to $BACKUP"
  mv "$ZSHRC_TARGET" "$BACKUP"
fi

if [ ! -L "$ZSHRC_TARGET" ]; then
  info "Linking ~/.zshrc -> $DOTFILES_DIR/zsh/zshrc"
  ln -s "$DOTFILES_DIR/zsh/zshrc" "$ZSHRC_TARGET"
else
  info "~/.zshrc already linked"
fi

# =========================
# PROFILE SELECTION
# =========================
info "Select shell profile:"
echo "  0) Auto detect (recommended)"
echo "  1) low  (minimal, server-safe)"
echo "  2) full (oh-my-zsh + p10k)"
printf "> "
read choice

detect_profile() {
  if [ -n "${SSH_CONNECTION:-}" ]; then
    echo "low"
    return
  fi

  if command -v free >/dev/null 2>&1; then
    mem=$(free -m | awk '/Mem:/ {print $2}')
    [ "$mem" -lt 1500 ] && echo "low" || echo "full"
    return
  fi

  echo "full"
}

case "$choice" in
  0|"")
    PROFILE="$(detect_profile)"
    info "Auto-detected profile: $PROFILE"
    ;;
  1) PROFILE="low" ;;
  2) PROFILE="full" ;;
  *)
    warn "Invalid choice. Falling back to auto detect."
    PROFILE="$(detect_profile)"
    ;;
esac

# =========================
# WRITE PROFILE
# =========================
mkdir -p "$PROFILE_DIR"
echo "$PROFILE" > "$PROFILE_FILE"
info "Profile set to: $PROFILE"

# =========================
# OH-MY-ZSH CHECK (FULL ONLY)
# =========================
if [ "$PROFILE" = "full" ]; then
  if [ ! -d "$OHMYZSH_DIR" ]; then
    warn "oh-my-zsh not found at $OHMYZSH_DIR"
    printf "Install oh-my-zsh now? [y/N]: "
    read yn
    case "$yn" in
      y|Y)
        info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        info "oh-my-zsh installed"
        ;;
      *)
        warn "Skipped oh-my-zsh installation. Full profile may not work correctly."
        ;;
    esac
  else
    info "oh-my-zsh already installed"
  fi
fi

# =========================
# DONE
# =========================
info "Installation complete."
info "Open a new terminal or run: exec zsh"
