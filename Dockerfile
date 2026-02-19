# Dev Env Dockerfile — Ubuntu 24.04 기반
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME
ARG UID=1000
ARG GID=1000

# 기본 패키지 & 개발 도구 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo ca-certificates curl wget git tzdata locales openssh-client \
      zsh ripgrep less unzip fontconfig iputils-ping file jq \
      universal-ctags cscope repo docker.io docker-compose-v2 \
      build-essential cmake ninja-build pkg-config ccache \
      python3 python3-pip python3-venv \
      xclip libevent-dev libncurses-dev bison \
      # Debug tools (debuginfod for symbol server, heaptrack for memory profiling)
      gdb debuginfod elfutils heaptrack \
    && rm -rf /var/lib/apt/lists/*

# tmux 최신 버전 설치 (3.5+ for extended-keys-format)
RUN TMUX_VERSION=$(curl -s "https://api.github.com/repos/tmux/tmux/releases/latest" | grep -Po '"tag_name": "\K[^"]*') && \
    curl -Lo /tmp/tmux.tar.gz "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" && \
    cd /tmp && tar -xzf tmux.tar.gz && \
    cd tmux-${TMUX_VERSION} && ./configure && make && make install && \
    cd / && rm -rf /tmp/tmux*

# Node.js 22 설치 (Copilot 요구사항)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Google Chrome + VNC 설치 (OAuth 인증용)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gnupg \
      libnss3 libxss1 libasound2t64 libatk-bridge2.0-0 libgtk-3-0 libgbm1 \
      fonts-liberation fonts-noto-cjk xdg-utils \
      xvfb x11vnc fluxbox \
    && rm -rf /var/lib/apt/lists/* && \
    # Chrome 설치
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/* && \
    # noVNC 설치 (웹 브라우저로 VNC 접속)
    git clone --depth 1 https://github.com/novnc/noVNC /opt/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# fzf 최신 버전 설치 (apt 버전은 오래됨)
RUN FZF_VERSION=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -Po '"tag_name": "v?\K[^"]*') && \
    curl -Lo /tmp/fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz" && \
    tar -xzf /tmp/fzf.tar.gz -C /usr/local/bin && \
    rm /tmp/fzf.tar.gz && \
    mkdir -p /usr/share/doc/fzf/examples && \
    curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh \
       -o /usr/share/doc/fzf/examples/key-bindings.zsh && \
    curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh \
       -o /usr/share/doc/fzf/examples/completion.zsh

# Neovim 최신 버전 설치 (AstroNvim 요구사항: v0.9+)
RUN curl -fsSL https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tar.gz && \
    tar -C /opt -xzf /tmp/nvim.tar.gz && \
    rm /tmp/nvim.tar.gz && \
    ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# lazygit 설치 (AstroNvim git 통합용)
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar -xzf lazygit.tar.gz lazygit && \
    install lazygit /usr/local/bin && \
    rm lazygit lazygit.tar.gz

# GitHub CLI 설치
RUN GH_VERSION=$(curl -s "https://api.github.com/repos/cli/cli/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo gh.tar.gz "https://github.com/cli/cli/releases/latest/download/gh_${GH_VERSION}_linux_amd64.tar.gz" && \
    tar -xzf gh.tar.gz && \
    install gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin && \
    rm -rf gh.tar.gz gh_${GH_VERSION}_linux_amd64

# Atlassian CLI 설치
RUN curl -fsSLo /usr/local/bin/acli "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli" && \
    chmod +x /usr/local/bin/acli

# Claude Code CLI: 사용자 전환 후 설치 (auto-update 권한 문제 해결)

# pipx 설치 (SuperClaude용)
RUN pip install --break-system-packages pipx

# pwndbg 설치 (GDB 확장)
RUN curl -qsL 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb

# Nerd Font 설치 (JetBrainsMono)
RUN mkdir -p /usr/share/fonts/nerd-fonts && \
    curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip && \
    unzip -o /tmp/JetBrainsMono.zip -d /usr/share/fonts/nerd-fonts && \
    rm /tmp/JetBrainsMono.zip && \
    fc-cache -fv

# 로케일
RUN sed -i 's/# \(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen && \
    locale-gen && update-ca-certificates

# 터미널 색상 지원
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

# oh-my-zsh + 플러그인을 /opt에 설치 (템플릿용)
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh /opt/oh-my-zsh && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions /opt/oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting /opt/oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# AstroNvim 템플릿을 /opt에 설치
RUN git clone --depth 1 https://github.com/AstroNvim/template /opt/astro-nvim-template && \
    rm -rf /opt/astro-nvim-template/.git

# 사용자/그룹 생성 (UID/GID 충돌 시 기존 유저/그룹 처리)
RUN set -eux; \
    # 기존 UID 사용자 삭제 (ubuntu 등)
    if getent passwd "${UID}" >/dev/null; then \
        EXISTING_USER="$(getent passwd "${UID}" | cut -d: -f1)"; \
        userdel -r "${EXISTING_USER}" 2>/dev/null || true; \
    fi; \
    # 그룹 처리
    if getent group "${GID}" >/dev/null; then \
        EXISTING_GROUP="$(getent group "${GID}" | cut -d: -f1)"; \
    else \
        groupadd -g "${GID}" "${USERNAME}"; \
        EXISTING_GROUP="${USERNAME}"; \
    fi; \
    useradd -m -u "${UID}" -g "${EXISTING_GROUP}" -s /usr/bin/zsh "${USERNAME}" && \
    usermod -aG sudo "${USERNAME}" && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-nopasswd-sudo && \
    chmod 0440 /etc/sudoers.d/90-nopasswd-sudo

# 스크립트 복사
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/vnc-server /usr/local/bin/vnc-server
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/vnc-server

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# npm global prefix를 사용자 홈으로 설정 (auto-update 권한 확보)
RUN mkdir -p ~/.npm-global && \
    npm config set prefix '~/.npm-global' && \
    npm install -g @anthropic-ai/claude-code

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["zsh"]
