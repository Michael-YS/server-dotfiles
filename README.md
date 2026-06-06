# Server Zsh Dotfiles

Minimal Zsh dotfiles for servers and VPS, with oh-my-zsh + powerlevel10k.

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
├── install.sh
├── README.md
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
sh /tmp/install.sh
```

Notes:
- Installer first tries anonymous clone (for public repos).
- If that fails and `GITHUB_TOKEN` is set, it retries with the token.
- If `GITHUB_TOKEN` is not set, clone will fail.

Example:

```bash
export GITHUB_TOKEN=your_token_here
sh /tmp/install.sh
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