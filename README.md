# Server Zsh Dotfiles

Minimal, profile-based Zsh dotfiles for servers and VPS.

This setup is designed for:
- Fast startup
- Safe behavior in non-interactive shells
- Minimal dependencies by default
- Optional full interactive experience when needed

---

## Features

- Profile-based configuration:
  - `low` (default): minimal, fast, dependency-free
  - `full`: oh-my-zsh + powerlevel10k
- Non-interactive shell safe:
  - `scp`, `rsync`, `ssh host cmd` won't load heavy interactive config
- Single source of truth:
  - All shell config lives in this repo

---

## Repository Structure

```text
.
├── install.sh
├── README.md
└── zsh/
    ├── zshrc         # main entry point; dispatches by profile
    ├── zshrc.low     # low profile
    ├── zshrc.full    # full profile
    └── p10k.zsh      # powerlevel10k config used by full profile
```

---

## How It Works

1. `~/.zshrc` is symlinked to `~/.dotfiles/zsh/zshrc`.
2. `zshrc` exits immediately for non-interactive shells.
3. For interactive shells, it reads profile from:
   - `~/.config/dotfiles/profile`
4. Based on profile value:
   - `low` -> source `zsh/zshrc.low`
   - `full` -> source `zsh/zshrc.full`

If profile file is missing or invalid, it falls back to `low`.

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
mkdir -p ~/.config/dotfiles
echo low > ~/.config/dotfiles/profile
```

If you want full profile:

```bash
echo full > ~/.config/dotfiles/profile
```

---

## Profiles

### `low`

- No oh-my-zsh dependency
- Minimal history config
- Simple prompt (`user@host:cwd#`)
- Suitable for low-memory or remote server environments

### `full`

- Uses oh-my-zsh
- Theme: powerlevel10k
- Plugin: `git`
- Requires:
  - `~/.oh-my-zsh`
  - powerlevel10k theme under oh-my-zsh custom themes

Installer can set these up for you interactively.

---

## Switching Profile

```bash
echo low > ~/.config/dotfiles/profile
# or
echo full > ~/.config/dotfiles/profile

exec zsh
```

---

## Updating

```bash
git -C ~/.dotfiles pull --ff-only
exec zsh
```

---

## Troubleshooting

### Full profile did not load

Check profile file:

```bash
cat ~/.config/dotfiles/profile
```

Check oh-my-zsh path:

```bash
test -d ~/.oh-my-zsh && echo ok || echo missing
```

Check p10k theme path:

```bash
test -d ~/.oh-my-zsh/custom/themes/powerlevel10k && echo ok || echo missing
```

### Non-interactive commands are noisy

Ensure your shell entrypoint is `zsh/zshrc` from this repo and that the first check keeps non-interactive shells returning early.

---

## License

Personal dotfiles repository. Add a license file if you plan to distribute or open-source this project.
