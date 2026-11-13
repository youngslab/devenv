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

# With VNC support (for browser automation/OAuth)
devenv --vnc
```

The container runs in background mode with `--restart unless-stopped`.
It will persist even after SSH session ends.

Options:
- `--vnc` - Enable VNC ports (5900, 7900) and auto-start vnc-server

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

New containers start the desktop automatically for browser/OAuth workflows:

```bash
# Check the automatically started desktop
vnc-server status

# Access via web browser
# http://localhost:7900

# Run Chrome
google-chrome --no-sandbox
```

### Automatic desktop and DISPLAY

New images start Xvfb, Fluxbox, VNC and noVNC automatically on container
start/restart. `devenv` also runs a bounded, idempotent health check when attaching:
only missing services are started. Healthy X sessions and clipboard contents are
not reset. New commands inherit `DISPLAY=:99`, including `codex`; the host's
SSH-forwarded DISPLAY is intentionally not inherited. Existing tmux panes and
Codex processes must be relaunched to receive environment changes.

- `vnc-server status` shows readiness; `vnc-server ensure` repairs missing services.
- `start` is an alias for `ensure`; `stop` / `restart` are explicit, destructive to
  desktop sessions. Logs and identity records live in `/tmp/vnc` (private to its owner).
- Startup/lock waits are bounded to 15 seconds; failures warn but do not deny shell
  access. This is not a continuous supervisor: recovery happens on the next attach.
- Set `DEVENV_VNC_AUTOSTART=0` in the launcher's `.env` **before container creation**
  to disable automatic startup (DISPLAY remains set). An existing container keeps
  its own setting; host environment changes do not override it. Disabling startup
  does not stop already running services.
- Old images / legacy PID records are not silently adopted or restarted. Rebuild
  the image and schedule container recreation for full activation; the launcher
  never automatically rebuilds or recreates an existing container. `devenv -f`
  remains an explicit destructive action. Do not use it during an active session.

Both VNC (5900) and noVNC (7900) bind **127.0.0.1 only**; X11 TCP is disabled.
For remote browser access, tunnel `ssh -L 7900:127.0.0.1:7900 user@server`, then open
<http://127.0.0.1:7900>. These services have no password: other processes/users on
the server are trusted, as are local X11 socket clients (`Xvfb -ac`). Do not expose
these listeners through a public proxy or port forward.

This prepares Codex to read the **remote X11 clipboard**. It does **not** transport
images copied on your local PC to the server; noVNC/OSC 52 text clipboard support
is not an image clipboard bridge.

Verification: `python3 -m unittest discover -s tests -v`,
`bash -n scripts/devenv scripts/entrypoint.sh`, and `git diff --check`.

Opt-in real-service verification (requires an existing `devenv:latest` image):
`python3 tests/integration_vnc.py`. It builds a disposable overlay image and tests
real services with no host mounts, published ports, or changes to the active container.
This is not a full Dockerfile rebuild.

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
