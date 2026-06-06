#!/usr/bin/env sh
set -eu

# =========================
# CONFIG
# =========================
REPO_URL="https://github.com/Michael-YS/server-dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
ZSHRC_TARGET="$HOME/.zshrc"
OHMYZSH_DIR="$HOME/.oh-my-zsh"
P10K_DIR="${ZSH_CUSTOM:-$OHMYZSH_DIR/custom}/themes/powerlevel10k"

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
# CLONE / UPDATE
# =========================
clone_repo() {
  if git clone "https://github.com/Michael-YS/server-dotfiles.git" "$DOTFILES_DIR" 2>/dev/null; then
    return 0
  fi

  if [ -n "${GITHUB_TOKEN:-}" ]; then
    err "Anonymous clone failed. Retrying with token..."
    if git clone "https://x-access-token:${GITHUB_TOKEN}@github.com/Michael-YS/server-dotfiles.git" "$DOTFILES_DIR"; then
      return 0
    fi
    err "Clone with token failed."
    return 1
  fi

  err "GITHUB_TOKEN not set. Cannot access private repository."
  return 1
}

if [ -d "$DOTFILES_DIR/.git" ]; then
  info "Dotfiles repo already exists. Updating..."
  git -C "$DOTFILES_DIR" pull --ff-only
else
  info "Cloning dotfiles repo..."
  clone_repo
fi


# =========================
# OH-MY-ZSH
# =========================
if [ ! -d "$OHMYZSH_DIR" ]; then
  warn "oh-my-zsh not found at $OHMYZSH_DIR"
  printf "Install oh-my-zsh now? [y/N]: "
  read yn
  case "$yn" in
    y|Y)
      info "Installing oh-my-zsh..."
      RUNZSH=no CHSH=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
      info "oh-my-zsh installed"
      ;;
    *)
      warn "Skipped oh-my-zsh installation."
      ;;
  esac
else
  info "oh-my-zsh already installed"
fi


# =========================
# POWERLEVEL10K
# =========================
if [ ! -d "$OHMYZSH_DIR" ]; then
  warn "Skipping powerlevel10k install because oh-my-zsh is missing."
elif [ -d "$P10K_DIR" ]; then
  info "powerlevel10k already installed"
else
  warn "powerlevel10k not found at $P10K_DIR"
  printf "Install powerlevel10k now? [y/N]: "
  read yn
  case "$yn" in
    y|Y)
      info "Installing powerlevel10k..."
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
      info "powerlevel10k installed"
      ;;
    *)
      warn "Skipped powerlevel10k installation."
      ;;
  esac
fi


# =========================
# LINK ZSHRC
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
# LINK P10K CONFIG
# =========================
P10K_TARGET="$HOME/.p10k.zsh"
P10K_SOURCE="$DOTFILES_DIR/zsh/p10k.zsh"
if [ -e "$P10K_TARGET" ] && [ ! -L "$P10K_TARGET" ]; then
  BACKUP="$P10K_TARGET.bak.$(date +%s)"
  warn "Existing ~/.p10k.zsh found. Backing up to $BACKUP"
  mv "$P10K_TARGET" "$BACKUP"
fi
if [ ! -L "$P10K_TARGET" ]; then
  info "Linking ~/.p10k.zsh -> $P10K_SOURCE"
  ln -s "$P10K_SOURCE" "$P10K_TARGET"
else
  info "~/.p10k.zsh already linked"
fi


info "Installation complete."
info "Open a new terminal or run: exec zsh"