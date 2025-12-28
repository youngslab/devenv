# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a Dockerfile for building an Ubuntu 24.04-based development environment container.

## Build Commands

```bash
# Build the container (USERNAME is required)
docker build --build-arg USERNAME=$(whoami) --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t devenv .

# Run the container with mounted workspace
docker run -it --rm -v ~/workspace:/home/$(whoami)/workspace devenv
```

## Container Features

- Base: Ubuntu 24.04
- Shell: zsh with oh-my-zsh (agnoster theme)
- Plugins: git, fzf, z, zsh-autosuggestions, zsh-syntax-highlighting
- Editor: Neovim (latest) with AstroNvim
- Font: JetBrainsMono Nerd Font (아이콘 표시용)
- Git: lazygit (AstroNvim 통합)
- Dev tools: build-essential, cmake, python3, nodejs/npm
- Search: ripgrep, fzf, ctags, cscope
- llm: Claude Code

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
- `<C-\>` - 터미널 토글

### AstroNvim 설정 커스터마이징

설정 파일 위치: `~/.config/nvim/lua/`
- `plugins/` - 추가 플러그인 설정
- `polish.lua` - 추가 설정

