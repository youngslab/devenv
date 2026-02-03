# CLAUDE.md

Claude Code가 이 저장소에서 작업할 때 따라야 할 지침입니다.

## Claude의 역할

이 저장소는 Ubuntu 24.04 기반 개발 환경 컨테이너(devenv)입니다.
Claude는 다음을 수행합니다:
- Dockerfile 및 설정 파일 수정/개선
- dotfiles 관리 (nvim, tmux, zsh 설정)
- 스크립트 작성 및 디버깅

## 행동 규칙

### MUST DO
- Git 커밋: 항상 `/x:commit` 사용 (직접 git commit 금지)
- 응답 언어: 사용자 질문과 동일한 언어로 응답
- 코드 수정 전: 반드시 해당 파일 먼저 읽기

### MUST NOT
- Dockerfile 베이스 이미지 변경 금지 (Ubuntu 24.04 유지)
- dotfiles/ 외부의 설정 파일 직접 생성 금지
- 인증 정보(~/.ssh, ~/.gnupg) 내용 출력 금지

## 주요 파일 위치

| 용도 | 경로 |
|------|------|
| 컨테이너 정의 | `Dockerfile` |
| 실행 스크립트 | `scripts/devenv` |
| Neovim 설정 | `dotfiles/nvim/` |
| tmux 설정 | `dotfiles/tmux/tmux.conf` |
| Claude 설정 | `dotfiles/claude/` |

## 빌드 & 실행

```bash
# 빌드
docker build --build-arg USERNAME=$(whoami) --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t devenv .

# 실행 (권장)
devenv              # 기본 zsh 쉘 (noVNC 포트 7901 기본 활성화)
devenv nvim         # nvim 직접 실행
devenv -f           # 컨테이너 재생성 (이미지 업데이트 시)
```

## 참고 사항

### Container Features
- Shell: zsh + oh-my-zsh, Neovim + AstroNvim
- AI: Claude Code, SuperClaude, GitHub Copilot
- Dev: build-essential, cmake, ccache, python3, nodejs 22
- LSP: clangd, pyright
- Browser: Chrome + noVNC (port 7901)

### Known Issues
devenv-snt 통합 불가: Ubuntu/컴파일러 버전 불일치 (24.04 vs 22.04)로 별도 유지 필요
