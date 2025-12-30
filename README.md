# DevEnv

Ubuntu 24.04 기반 Docker 개발 환경 컨테이너.

터미널에서 AI 지원 개발을 위한 완전한 환경을 제공합니다.

## Features

### Core
- **Ubuntu 24.04** base image
- **zsh** + oh-my-zsh with plugins (git, fzf, z, autosuggestions, syntax-highlighting)
- **Neovim** with AstroNvim configuration
- **tmux** 3.5+ with vi-mode and OSC 52 clipboard

### AI Tools
- **Claude Code** - Anthropic's AI coding assistant
- **SuperClaude** - Claude Code enhancement framework
- **GitHub Copilot** - AI code completion

### Development
- **Languages**: Python 3, Node.js 22
- **Build**: build-essential, cmake
- **LSP**: clangd (C/C++), pyright (Python)
- **Linters**: clang-format, black, ruff
- **Git**: lazygit, GitHub CLI (gh)
- **Search**: ripgrep, fzf, ctags, cscope

### Browser Automation
- **Google Chrome** + **VNC/noVNC** for OAuth flows

## Quick Start

### 1. Build

```bash
docker build \
  --build-arg USERNAME=$(whoami) \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) \
  -t devenv .
```

### 2. Run

```bash
# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/workspace/devenv/scripts:$PATH"

# Start container (runs in background, survives SSH disconnect)
devenv
```

The container runs in background mode with `--restart unless-stopped`.
It will persist even after SSH session ends.

### 3. First-time Setup

Inside the container:

```bash
# GitHub CLI authentication
gh auth login

# Claude Code authentication
claude

# In Neovim - Copilot authentication
:Copilot auth
```

## Directory Structure

```
devenv/
├── Dockerfile              # Container definition
├── scripts/
│   ├── devenv              # Container launcher script
│   ├── entrypoint.sh       # Container initialization
│   └── vnc-server          # VNC service manager
└── dotfiles/
    ├── nvim/               # Neovim configuration
    │   └── lua/
    │       ├── plugins/custom.lua
    │       └── polish.lua
    ├── tmux/tmux.conf      # tmux configuration
    ├── shell/              # Shell configuration
    │   ├── shellrc
    │   └── aliases
    ├── git/gitconfig       # Git configuration
    └── zsh/                # Zsh theme
```

## Key Bindings

See [devenv_cheatsheet.md](devenv_cheatsheet.md) for full keybinding reference.

### Neovim

| Key | Description |
|-----|-------------|
| `<Space>` | Leader key |
| `<Space>e` | File explorer (Neo-tree) |
| `<Space>ff` | Find files (Telescope) |
| `<Space>fw` | Live grep |
| `<Space>gg` | lazygit |
| `<F2>` | Terminal toggle |
| `<F10>` | Window zoom toggle |
| `<C-x>` | Exit terminal mode |

### AI

| Key | Description |
|-----|-------------|
| `<Space>ac` | Claude Code toggle |
| `<F1>` / `<C-=>` | Claude Code toggle |
| `<C-l>` | Copilot ghost text accept |
| `<Tab>` / `<Enter>` | Copilot CMP menu accept |
| `<M-]>` / `<M-[>` | Copilot next/prev |

### tmux

| Key | Description |
|-----|-------------|
| `<C-b>` | Prefix |
| `<M-h/j/k/l>` | Pane navigation |
| `<M-z>` | Pane zoom |
| `<M-1~7>` | Window selection |

## VNC (Browser Automation)

For OAuth flows requiring a browser:

```bash
# Start VNC server
vnc-server start

# Access via web browser
# http://localhost:7900

# Run Chrome
DISPLAY=:99 google-chrome --no-sandbox
```

## Volumes

The devenv script automatically mounts:

| Host | Container | Purpose |
|------|-----------|---------|
| `~/workspace` | `~/workspace` | Projects |
| `~/.claude` | `~/.claude` | Claude Code auth |
| `~/.config/gh` | `~/.config/gh` | GitHub CLI auth |
| `~/.config/github-copilot` | `~/.config/github-copilot` | Copilot auth |
| `~/.ssh` | `~/.ssh` (ro) | SSH keys |
| `~/.gnupg` | `~/.gnupg` (ro) | GPG keys |
| `/var/run/docker.sock` | `/var/run/docker.sock` | Docker-in-Docker |

A named volume `devenv-home-$USER` persists the container home directory.

## Requirements

### Host Terminal
- **Nerd Font** installed (for icons)
- **OSC 52 clipboard** support:
  - iTerm2: Enable "Applications in terminal may access clipboard"
  - Windows Terminal, Alacritty: Built-in support
  - macOS Terminal.app: Not supported

### Docker
- Docker Engine installed
- User in `docker` group (for Docker-in-Docker)

## Customization

### Neovim Plugins

Edit `dotfiles/nvim/lua/plugins/custom.lua` to add plugins or modify keybindings.

### Shell Aliases

Edit `dotfiles/shell/aliases` to add custom aliases.

### tmux Configuration

Edit `dotfiles/tmux/tmux.conf` for tmux settings.

## License

MIT
