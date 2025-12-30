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
- Dev tools: build-essential, cmake, python3, nodejs 22
- Search: ripgrep, fzf, ctags, cscope
- AI: Claude Code, SuperClaude, GitHub Copilot, claudecode.nvim
- LSP: clangd (C/C++), pyright (Python)
- Linter/Formatter: clang-format, black, ruff
- Browser Automation: Chrome, VNC/noVNC
- Container: Docker-in-Docker support

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
- `<F2>` - 터미널 토글 (toggleterm)
- `<C-x>` - 터미널 모드에서 normal mode로 전환
- `<F10>` - 윈도우 줌 토글

### AI 단축키

- `<Space>ac` - Claude Code 토글
- `<Space>af` - Claude Code 포커스
- `<C-=>` / `<F1>` - Claude Code 토글 (모든 모드)
- `<C-l>` - Copilot ghost text 수락
- `<Tab>` / `<Enter>` - Copilot CMP 메뉴 수락
- `<Alt-]>` / `<Alt-[>` - Copilot 다음/이전 제안

### SuperClaude 명령어

SuperClaude는 Claude Code를 확장하는 프레임워크입니다. 30개의 슬래시 명령어와 9개의 페르소나를 제공합니다.

```bash
# 주요 명령어 (Claude Code 내에서)
/build           # 프로젝트 빌드
/test            # 테스트 실행
/review          # 코드 리뷰
/refactor        # 리팩토링
/debug           # 디버깅 모드
/explain         # 코드 설명
/document        # 문서화
/security        # 보안 분석

# 페르소나 모드
/persona:architect   # 아키텍트 모드
/persona:reviewer    # 리뷰어 모드
```

자세한 내용: https://github.com/SuperClaude-Org/SuperClaude_Framework

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

## VNC + Chrome (OAuth 인증용)

브라우저 자동화를 위한 Chrome과 VNC가 내장되어 있습니다.

```bash
# 서비스 시작
vnc-server start

# 접속 포트
# - 5900: VNC (전용 클라이언트)
# - 7900: noVNC (웹 브라우저에서 http://localhost:7900)
```

Chrome 실행:
```bash
# VNC 시작 후 Chrome 실행
vnc-server start
DISPLAY=:99 google-chrome --no-sandbox

# http://localhost:7900 에서 브라우저 화면 확인 가능
```

## Known Issues

### devenv-snt 통합 불가

회사 빌드 환경(Dockerfile_snt)과 devenv 통합을 시도했으나 실패했습니다.

**원인: 기본 이미지 및 컴파일러 버전 불일치**

| 항목 | devenv | Dockerfile_snt |
|------|--------|----------------|
| Ubuntu | 24.04 | 22.04 |
| GCC | 13 | 10, 11 |
| Clang | 18 | 15 |
| Node.js | 22 | 18 |
| OpenSSL | 3.x | 1.1.1 (다운그레이드) |

**주요 호환성 문제:**
- 회사 프로젝트는 gcc-10/11, clang-15 기준으로 빌드됨
- OpenSSL 1.1.1이 필수 (Ubuntu 24.04는 3.x 기본)
- 특정 라이브러리들이 Ubuntu 22.04 전용 패키지 사용

**결론:** 두 환경은 별도로 유지해야 함. 회사 빌드는 기존 Dockerfile_snt 사용.
