# Server Zsh Dotfiles

Minimal Zsh dotfiles for servers and VPS, with oh-my-zsh + powerlevel10k.

**Server one-liner:** `curl -fsSL https://raw.githubusercontent.com/Michael-YS/server-dotfiles/main/install.sh | sudo bash -s -- --all`

This setup is designed for:
- Fast startup
- Safe behavior in non-interactive shells
- Single source of truth for all shell config

---

## Features

- oh-my-zsh + powerlevel10k theme
- Git plugin enabled
- Non-interactive shell safe: `scp`, `rsync`, `ssh host cmd` won't load heavy config
- Common aliases and settings included

---

## Repository Structure

```text
.
├── install.sh             # unified installer entry point
├── install_dotfiles.sh    # user-level dotfiles installer
├── README.md
├── Server-Init/
│   ├── install_packages.sh
│   ├── install_docker.sh
│   ├── install_tailscale.sh
│   └── utils.sh
└── zsh/
    ├── zshrc      # main entry point
    ├── zshrc.full # full config (oh-my-zsh + p10k + common settings)
    └── p10k.zsh   # powerlevel10k config
```

---

## How It Works

1. `~/.zshrc` is symlinked to `~/.dotfiles/zsh/zshrc`.
2. `zshrc` exits immediately for non-interactive shells.
3. For interactive shells, it sources the full config.

---

## Installation

### Option A: Use installer script (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/Michael-YS/server-dotfiles/main/install.sh -o /tmp/install.sh
sudo bash /tmp/install.sh --all
```

Notes:
- The server one-liner needs `curl`, `bash`, and `tar` from the base OS. It then installs every other APT-provided dependency before using it.
- With no option, the installer only installs user-level dotfiles and requires `git` to already be installed.
- Use `--server` as root to install base packages, Docker, and Tailscale.
- Use `--all` as root to install both dotfiles and server packages.
- Tailscale authentication is interactive and prints a verification URL during installation.
- Installer first tries anonymous clone (for public repos).
- If that fails and `GITHUB_TOKEN` is set, it retries with the token.
- If `GITHUB_TOKEN` is not set, clone will fail.

Example:

```bash
export GITHUB_TOKEN=your_token_here
bash /tmp/install.sh
```

Server-only example:

```bash
sudo bash /tmp/install.sh --server
```

### Option B: Manual install

```bash
git clone https://github.com/Michael-YS/server-dotfiles.git ~/.dotfiles
ln -sf ~/.dotfiles/zsh/zshrc ~/.zshrc
```

Installer will set up oh-my-zsh and powerlevel10k for you.

---

## Requirements

- `~/.oh-my-zsh` — oh-my-zsh framework
- `~/.oh-my-zsh/custom/themes/powerlevel10k` — powerlevel10k theme

Installer can handle both automatically.

---

## Updating

```bash
git -C ~/.dotfiles pull --ff-only
exec zsh
```

---

## Troubleshooting

Check oh-my-zsh path:

```bash
test -d ~/.oh-my-zsh && echo ok || echo missing
```

Check p10k theme path:

```bash
test -d ~/.oh-my-zsh/custom/themes/powerlevel10k && echo ok || echo missing
```

---

## License

Personal dotfiles repository.
