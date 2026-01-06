# DevEnv Cheatsheet

Ubuntu 24.04 기반 개발 환경의 단축키 및 사용법 모음.

---

## Neovim (AstroNvim)

Leader key: `<Space>`

### 기본 네비게이션

| 키 | 설명 |
|----|------|
| `H` | 이전 버퍼 |
| `L` | 다음 버퍼 |
| `<C-h/j/k/l>` | 윈도우 이동 (좌/하/상/우) |
| `j` / `k` | 줄 단위 이동 (wrapped line 지원) |
| `<Esc>` | 검색 하이라이트 제거 |

### 파일/버퍼 관리

| 키 | 설명 |
|----|------|
| `<Space>e` | 파일 탐색기 (Neo-tree) |
| `<Space>ff` | 파일 찾기 (Telescope) |
| `<Space>fw` | 텍스트 검색 (live grep) |
| `<Space>fb` | 버퍼 목록 |
| `<Space>bd` | 버퍼 선택 후 닫기 |
| `<C-s>` | 저장 (normal/insert) |

### 편집

| 키 | 설명 |
|----|------|
| `<A-j>` / `<A-k>` | 줄/선택 영역 이동 |
| `<` / `>` (visual) | 들여쓰기 (반복 유지) |
| `p` (visual) | 붙여넣기 (yank 안함) |
| `jk` (insert) | Insert 모드 종료 |

### 윈도우 관리

| 키 | 설명 |
|----|------|
| `<F10>` | 윈도우 줌 토글 (vim-maximizer) |
| `<C-w>` + `>/<` | 너비 증가/감소 |
| `<C-w>` + `+/-` | 높이 증가/감소 |
| `<C-w>` + `=` | 윈도우 균등 분할 |

### toggleterm (터미널)

| 키 | 설명 |
|----|------|
| `<F2>` | 터미널 토글 (horizontal) |
| `<Space>tt` | 터미널 토글 |
| `<Space>tf` | 플로팅 터미널 |
| `<Space>tv` | 수직 분할 터미널 |
| `<Space>th` | 수평 분할 터미널 |

### 터미널 모드

| 키 | 설명 |
|----|------|
| `<C-x>` | Normal 모드로 전환 |
| `<C-h/j/k/l>` | 다른 윈도우로 이동 |
| `<F10>` | 윈도우 줌 토글 |
| `<F2>` | 터미널 닫기 |

### Claude Code (claudecode.nvim)

| 키 | 설명 |
|----|------|
| `<Space>ac` | Claude Code 토글 |
| `<Space>af` | Claude Code 포커스 |
| `<C-=>` | Claude Code 토글 |
| `<F1>` | Claude Code 토글 |

### GitHub Copilot (copilot.lua)

| 키 | 설명 |
|----|------|
| `<Tab>` | 제안 수락 |
| `<C-Right>` | 단어 단위 수락 |
| `<C-End>` | 줄 단위 수락 |
| `<M-]>` | 다음 제안 |
| `<M-[>` | 이전 제안 |
| `<C-]>` | 제안 닫기 |

**첫 사용 시:** `:Copilot auth`

### LSP

| 키 | 설명 |
|----|------|
| `gd` | 정의로 이동 |
| `gr` | 참조 목록 |
| `K` | 문서 보기 |
| `<Space>lf` | 포맷 |
| `<Space>la` | Code action |
| `<Space>lr` | 이름 변경 |

### Git (lazygit)

| 키 | 설명 |
|----|------|
| `<Space>gg` | lazygit 열기 |

### 클립보드 (OSC 52)

| 키 | 설명 |
|----|------|
| `"+y` | 시스템 클립보드로 복사 |
| `y` | 시스템 클립보드로 복사 (unnamedplus) |

tmux 내에서도 OSC 52 passthrough로 호스트 클립보드 사용 가능.

---

## tmux

Prefix key: `<C-b>` (기본값)

### 패인 네비게이션

| 키 | 설명 |
|----|------|
| `prefix` + `h/j/k/l` | 패인 이동 (vim 스타일) |
| `<M-h/j/k/l>` | 패인 이동 (prefix 없이, 줌 상태 제외) |
| `<M-z>` | 패인 줌 토글 |

### 윈도우 관리

| 키 | 설명 |
|----|------|
| `<M-1>` ~ `<M-7>` | 윈도우 1~7 선택 |
| `<C-S-Left>` | 윈도우 왼쪽으로 이동 |
| `<C-S-Right>` | 윈도우 오른쪽으로 이동 |
| `prefix` + `c` | 새 윈도우 |
| `prefix` + `&` | 윈도우 닫기 |
| `prefix` + `,` | 윈도우 이름 변경 |

### 세션 관리

| 키 | 설명 |
|----|------|
| `prefix` + `d` | 세션 분리 (detach) |
| `prefix` + `s` | 세션 목록 |
| `prefix` + `$` | 세션 이름 변경 |

### 복사 모드 (vi 스타일)

| 키 | 설명 |
|----|------|
| `prefix` + `[` | 복사 모드 시작 |
| `v` | 선택 시작 |
| `V` | 줄 선택 |
| `r` | 사각형 선택 토글 |
| `y` | 복사 (OSC 52로 시스템 클립보드) |
| `q` | 복사 모드 종료 |

### 패인 분할

| 키 | 설명 |
|----|------|
| `prefix` + `%` | 수직 분할 |
| `prefix` + `"` | 수평 분할 |
| `prefix` + `x` | 패인 닫기 |

---

## Zsh

### fzf 단축키

| 키 | 설명 |
|----|------|
| `<C-r>` | 히스토리 검색 |
| `<C-t>` | 파일 검색 후 삽입 |
| `<M-c>` | 디렉토리 검색 후 cd |

### 히스토리 검색

| 키 | 설명 |
|----|------|
| `<C-p>` | 이전 히스토리 (prefix 기반) |
| `<C-n>` | 다음 히스토리 (prefix 기반) |

### 앨리어스

#### 파일 목록

| 앨리어스 | 명령 |
|----------|------|
| `ll` | `ls -alF --color=auto` |
| `la` | `ls -A --color=auto` |
| `l` | `ls -CF --color=auto` |

#### 검색

| 앨리어스 | 명령 |
|----------|------|
| `f` | `find . \| grep -i` |
| `g` | `grep -nirEI` |

#### Git

| 앨리어스 | 명령 |
|----------|------|
| `gs` | `git status -s` |
| `gl` | `git log --oneline --graph --all` |
| `gd` | `git diff` |
| `gb` | `git branch -a` |

#### 기타

| 앨리어스 | 명령 |
|----------|------|
| `j` | `z` (디렉토리 점프) |
| `vim`, `vi`, `v` | `nvim` |

### Zsh 플러그인

- **git**: git 명령어 자동완성 및 상태 표시
- **fzf**: 퍼지 검색
- **z**: 자주 가는 디렉토리 점프 (`j <keyword>`)
- **zsh-autosuggestions**: 명령어 자동 제안
- **zsh-syntax-highlighting**: 명령어 문법 하이라이트

---

## DevEnv 스크립트

```bash
devenv              # 컨테이너 시작 (zsh 쉘)
devenv nvim         # nvim 직접 실행
devenv bash         # bash 쉘
```

---

## VNC + Chrome (OAuth 인증용)

컨테이너에 Chrome과 VNC가 포함되어 있습니다.

### 서비스 시작/중지

```bash
vnc-server start     # VNC 서비스 시작
vnc-server stop      # 서비스 중지
vnc-server status    # 상태 확인
vnc-server restart   # 재시작
```

### 포트

| 포트 | 용도 | 접속 방법 |
|------|------|----------|
| 5900 | VNC | `vnc://localhost:5900` (전용 클라이언트) |
| 7900 | noVNC | `http://localhost:7900` (웹 브라우저) |

### Chrome 실행

```bash
# VNC 서버 시작 후
vnc-server start

# Chrome 실행 (noVNC에서 화면 확인)
DISPLAY=:99 google-chrome --no-sandbox
```

### 화면 해상도 변경

```bash
SCREEN_WIDTH=1280 SCREEN_HEIGHT=720 vnc-server start
```

---

## 첫 사용 시 인증

```bash
# GitHub Copilot
:Copilot auth       # Neovim 내에서

# Claude Code
claude              # 터미널에서 실행 후 인증

# GitHub CLI
gh auth login       # 터미널에서
```

---

## 요구사항

- **호스트 터미널**: Nerd Font 설치 (아이콘 표시)
- **클립보드**: OSC 52 지원 터미널 필요
  - iTerm2: Preferences > General > Selection > "Applications in terminal may access clipboard"
  - Windows Terminal, Alacritty: 기본 지원
  - macOS Terminal.app: 미지원
