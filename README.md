# Server Zsh Dotfiles

A minimal, profile-based Zsh configuration designed for servers and VPS.

This setup prioritizes:
- Fast startup
- Safe behavior for non-interactive shells
- Zero unnecessary dependencies by default
- Optional full-featured interactive experience when needed

---

## Features

- **Profile-based configuration**
  - `low` (default): minimal, fast, dependency-free
  - `full`: oh-my-zsh + powerlevel10k

- **Non-interactive shell safe**
  - `scp`, `rsync`, `ssh host cmd` never load heavy configs

- **Single source of truth**
  - All configs live in this repo
  - No scattered dotfiles

---

## Repository Structure
.
├── zsh/
│ ├── zshrc # main entry point
│ └── p10k.zsh # powerlevel10k config (full profile only)
├── profiles/
│ ├── low
│ └── full
└── README.md

---

## Installation

```bash
git clone https://github.com/yourname/server-dotfiles.git ~/.dotfiles
ln -s ~/.dotfiles/zsh/zshrc ~/.zshrc
