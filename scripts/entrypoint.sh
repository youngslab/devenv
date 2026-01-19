#!/bin/bash
# DevEnv container entrypoint
# Sets up symlinks and configurations on container start

# HOME이 설정되지 않은 경우 설정
export HOME="${HOME:-$(getent passwd "$(id -u)" | cut -d: -f6)}"

DOTFILES_DIR="$HOME/.dotfiles"

# ========================================
# oh-my-zsh 설치 (호스트에 없으면 복사)
# ========================================
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  cp -r /opt/oh-my-zsh "$HOME/.oh-my-zsh"
fi

# ========================================
# .zshrc 설정 (없거나 oh-my-zsh 설정이 없으면 생성)
# ========================================
if [ ! -f "$HOME/.zshrc" ] || ! grep -q "ZSH=" "$HOME/.zshrc"; then
  echo "Creating .zshrc..."
  cat > "$HOME/.zshrc" << 'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="refined_fast"
plugins=(git fzf z zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
[ -f ~/.dotfiles/shell/shellrc ] && source ~/.dotfiles/shell/shellrc
EOF
fi

# ========================================
# AstroNvim 설치 (호스트에 없으면 복사)
# ========================================
mkdir -p "$HOME/.config"
if [ ! -d "$HOME/.config/nvim" ]; then
  echo "Installing AstroNvim..."
  cp -r /opt/astro-nvim-template "$HOME/.config/nvim"
fi

# ========================================
# SuperClaude 설치 (Claude Code 확장 프레임워크)
# ========================================
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"
if [ ! -d "$HOME/.local/share/pipx/venvs/superclaude" ]; then
  echo "Installing SuperClaude..."
  pipx install superclaude 2>/dev/null || true
fi
# 명령어 설치 (없으면만)
if [ ! -d "$HOME/.claude/commands/sc" ]; then
  superclaude install >/dev/null 2>&1 || true
fi

# ========================================
# Symlink dotfiles (컨테이너 설정으로 override)
# ========================================
if [ -d "$DOTFILES_DIR" ]; then
  # zsh theme
  ln -sf "$DOTFILES_DIR/zsh/refined_fast.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/refined_fast.zsh-theme" 2>/dev/null

  # tmux
  ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

  # nvim custom settings
  ln -sf "$DOTFILES_DIR/nvim/lua/plugins/custom.lua" "$HOME/.config/nvim/lua/plugins/custom.lua"
  ln -sf "$DOTFILES_DIR/nvim/lua/polish.lua" "$HOME/.config/nvim/lua/polish.lua"

  # scripts
  [ -d "$DOTFILES_DIR/scripts" ] && ln -sf "$DOTFILES_DIR/scripts" "$HOME/.scripts"

  # claude commands (x prefix)
  [ -d "$DOTFILES_DIR/claude/commands/x" ] && ln -sf "$DOTFILES_DIR/claude/commands/x" "$HOME/.claude/commands/x"

  # claude global instructions
  [ -f "$DOTFILES_DIR/claude/CLAUDE.md" ] && ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

  # gdb config (debuginfod enabled)
  [ -f "$DOTFILES_DIR/gdb/gdbinit" ] && ln -sf "$DOTFILES_DIR/gdb/gdbinit" "$HOME/.gdbinit"
fi

# Execute the command passed to docker run
exec "$@"
