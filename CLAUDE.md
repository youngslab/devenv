# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a Dockerfile for building an Ubuntu 24.04-based development environment container.

## Build Commands

```bash
# Build the container
docker build --build-arg USERNAME=$(whoami) --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t devenv .
```

## Run Commands

```bash
# 방법 1: 스크립트 사용 (권장)
# PATH에 추가: export PATH="$HOME/workspace/devenv/scripts:$PATH"
devenv              # 기본 zsh 쉘
devenv nvim         # nvim 직접 실행

# 방법 2: 직접 실행 (모든 auth 마운트 포함)
docker run -it --rm \
  -v ~/workspace:/home/$(whoami)/workspace \
  -v ~/workspace/devenv/dotfiles:/home/$(whoami)/.dotfiles \
  -v ~/.claude:/home/$(whoami)/.claude \
  -v ~/.config/gh:/home/$(whoami)/.config/gh \
  -v ~/.ssh:/home/$(whoami)/.ssh:ro \
  -v ~/.gnupg:/home/$(whoami)/.gnupg:ro \
  devenv
```

## Container Features

- Base: Ubuntu 24.04
- Shell: zsh with oh-my-zsh (refined_fast theme)
- Plugins: git, fzf, z, zsh-autosuggestions, zsh-syntax-highlighting
- Editor: Neovim (latest) with AstroNvim
- Font: JetBrainsMono Nerd Font (아이콘 표시용)
- Git: lazygit, GitHub CLI (gh)
- Dev tools: build-essential, cmake, python3, nodejs/npm
- Search: ripgrep, fzf, ctags, cscope
- AI: Claude Code, GitHub Copilot, claudecode.nvim
- LSP: clangd (C/C++), pyright (Python)
- Linter/Formatter: clang-format, black, ruff

**참고**: 호스트 터미널에서도 Nerd Font를 설정해야 아이콘이 정상 표시됩니다.

## Neovim 개발 환경

AstroNvim 기반의 터미널 개발 환경이 설정되어 있습니다.

```bash
# 컨테이너 최초 실행 시 nvim을 열면 플러그인이 자동 설치됨
nvim

# 터미널 내에서 lazygit 실행
lazygit
```

### AstroNvim 주요 단축키

- `<Space>` - Leader key
- `<Space>e` - 파일 탐색기 (Neo-tree)
- `<Space>ff` - 파일 찾기 (Telescope)
- `<Space>fw` - 텍스트 검색 (live grep)
- `<Space>gg` - lazygit 열기
- `<C-\>` - 터미널 토글 (toggleterm)
- `<C-q>` - 터미널 모드에서 normal mode로 전환

### AI 단축키

- `<Space>ac` - Claude Code 토글
- `<Space>af` - Claude Code 포커스
- `<Tab>` - Copilot 제안 수락
- `<Alt-]>` / `<Alt-[>` - Copilot 다음/이전 제안

### 첫 실행 시 인증

```bash
:Copilot auth    # GitHub Copilot 인증
claude           # Claude Code 인증 (터미널에서)
gh auth login    # GitHub CLI 인증
```

### 클립보드 (OSC 52)

tmux 내에서도 시스템 클립보드로 복사가 가능합니다.

- `"+y` - 시스템 클립보드로 복사 (visual mode에서)
- `Cmd+V` - 호스트에서 붙여넣기

**요구사항**: 호스트 터미널이 OSC 52를 지원해야 함
- iTerm2: Preferences → General → Selection → "Applications in terminal may access clipboard" 체크
- Windows Terminal, Alacritty: 기본 지원
- macOS Terminal.app: 미지원

### AstroNvim 설정 커스터마이징

설정 파일 위치: `~/.config/nvim/lua/`
- `plugins/` - 추가 플러그인 설정
- `polish.lua` - 추가 설정

