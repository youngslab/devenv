# Feature: Debug Container Integration

## 개요

dbg-container의 디버깅 기능 중 일부를 devenv에 통합하여, 심볼 서버를 활용한 디버깅 환경을 구성합니다.

## 배경

### dbg-container란?
Sonatus 내부 프로젝트로, crash dump 분석을 위한 전용 디버깅 환경입니다.
- Coredump / Minidump 분석
- debuginfod 심볼 서버 연동
- pwndbg, LLDB, Valgrind 등 디버깅 도구
- Breakpad 도구 (dump_syms, minidump_stackwalk)
- minidump_analyze (내부 Python 패키지)

### 통합 범위 결정

| 도구/기능 | apt 설치 | devenv 통합 |
|-----------|----------|-------------|
| debuginfod | ✅ | ✅ 통합 |
| heaptrack | ✅ | ✅ 통합 |
| DEBUGINFOD_URLS 환경변수 | - | ✅ 통합 |
| gdb 설정 (debuginfod enabled) | - | ✅ 통합 |
| Breakpad 도구 (dump_syms 등) | ❌ 빌드 필요 | ❌ 제외 |
| minidump_analyze | ❌ 내부 패키지 | ❌ 제외 |
| dlt-tools | ✅ | ❌ 제외 (필요시 추가) |

**결론**: apt로 설치 가능한 도구 + 환경변수 설정만 통합. 나머지는 dbg-container repo에서 직접 사용.

## 변경 사항

### 1. Dockerfile

```dockerfile
# Debug tools (debuginfod for symbol server, heaptrack for memory profiling)
debuginfod elfutils heaptrack \
```

**위치**: 기본 패키지 설치 섹션 (line 17)

### 2. .env.example (신규)

```bash
# ===========================================
# DevEnv Environment Configuration
# ===========================================
# Copy this file to .env and customize as needed:
#   cp .env.example .env

# Symbol Server (debuginfod)
# Space-separated list of debuginfod server URLs
DEBUGINFOD_URLS=http://builder-kr-2.kr.sonatus.com:8002

# Heaptrack debuginfod integration
HEAPTRACK_ENABLE_DEBUGINFOD=1
```

### 3. scripts/devenv

`.env` 파일 로딩 및 docker run에 전달:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVENV_DIR="$(dirname "$SCRIPT_DIR")"

# Load .env file if exists
ENV_FILE="${DEVENV_DIR}/.env"
ENV_FILE_ARG=""
if [[ -f "$ENV_FILE" ]]; then
  ENV_FILE_ARG="--env-file $ENV_FILE"
fi

# docker run 명령에 추가
docker run -d \
  ...
  $ENV_FILE_ARG \
  ...
```

### 4. dotfiles/gdb/gdbinit (신규)

```gdb
# GDB Configuration for DevEnv
# Symlinked to ~/.gdbinit by entrypoint.sh

# Enable debuginfod for automatic symbol fetching
set debuginfod enabled on

# Pretty printing
set print pretty on
set print object on
set print static-members on
set print vtbl on
set print demangle on
set demangle-style gnu-v3
set print sevenbit-strings off

# History
set history save on
set history filename ~/.gdb_history
set history size 10000

# Pagination off for scripting
set pagination off

# Disable confirmation prompts
set confirm off
```

### 5. scripts/entrypoint.sh

gdbinit symlink 추가:

```bash
# gdb config (debuginfod enabled)
[ -f "$DOTFILES_DIR/gdb/gdbinit" ] && ln -sf "$DOTFILES_DIR/gdb/gdbinit" "$HOME/.gdbinit"
```

## 사용 방법

### 초기 설정

```bash
# 1. .env 파일 생성
cd ~/workspace/devenv
cp .env.example .env

# 2. (필요시) .env 수정
vim .env

# 3. 이미지 재빌드
docker build -t devenv \
  --build-arg USERNAME=$(whoami) \
  --build-arg UID=$(id -u) \
  --build-arg GID=$(id -g) .

# 4. 컨테이너 재생성
devenv -f
```

### 디버깅 작업

```bash
# devenv 컨테이너 내에서

# GDB로 coredump 분석 (심볼 자동 fetch)
gdb -c core.12345 ./binary

# Heaptrack으로 메모리 프로파일링
heaptrack ./my_program
heaptrack_print heaptrack.my_program.*.zst
```

### Breakpad/minidump 분석이 필요한 경우

dbg-container를 별도로 사용:

```bash
cd ~/workspace
git clone <sonatus>/dbg-container
cd dbg-container
./run-container  # 또는 VS Code DevContainer

# 컨테이너 내에서
minidump-analyze crash.dmp
```

## 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│  devenv/.env                                                │
│  DEBUGINFOD_URLS=http://builder-kr-2.kr.sonatus.com:8002   │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  scripts/devenv                                             │
│  docker run --env-file .env ...                            │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  devenv Container                                           │
│  ├── $DEBUGINFOD_URLS (환경변수)                            │
│  ├── ~/.gdbinit (debuginfod enabled)                       │
│  └── heaptrack, debuginfod (apt 설치됨)                    │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Symbol Server                                              │
│  http://builder-kr-2.kr.sonatus.com:8002                   │
│  (gdb, heaptrack이 자동으로 심볼 fetch)                     │
└─────────────────────────────────────────────────────────────┘
```

## 제외된 항목 (dbg-container에서 직접 사용)

- **Breakpad 도구**: dump_syms, minidump_stackwalk, minidump_dump
- **minidump_analyze**: Sonatus 내부 Python 패키지
- **symbolsrv.py**: 로컬 심볼 서버 (대부분 원격 서버로 충분)
- **dlt-tools**: DLT 로그 변환 (필요시 apt install dlt-tools)

이 도구들이 필요한 경우 dbg-container repo를 clone하여 사용합니다.
