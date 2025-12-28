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
      zsh tmux ripgrep less unzip fontconfig \
      universal-ctags cscope \
      build-essential cmake pkg-config \
      python3 python3-pip python3-venv \
      nodejs npm \
      xclip \
    && rm -rf /var/lib/apt/lists/*

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

# Claude Code CLI 설치
RUN npm install -g @anthropic-ai/claude-code

# Nerd Font 설치 (JetBrainsMono)
RUN mkdir -p /usr/share/fonts/nerd-fonts && \
    curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip && \
    unzip -o /tmp/JetBrainsMono.zip -d /usr/share/fonts/nerd-fonts && \
    rm /tmp/JetBrainsMono.zip && \
    fc-cache -fv

# 로케일
RUN sed -i 's/# \(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen && \
    locale-gen && update-ca-certificates

# 사용자/그룹 생성 (GID 충돌 시 기존 그룹 재사용)
RUN set -eux; \
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

# oh-my-zsh + 플러그인 설치
USER ${USERNAME}
ENV ZSH="/home/${USERNAME}/.oh-my-zsh"
ENV DOTFILES_DIR="/home/${USERNAME}/.dotfiles"

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH}/custom/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH}/custom/plugins/zsh-syntax-highlighting

# AstroNvim 설치
RUN git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim && \
    rm -rf ~/.config/nvim/.git

# 커스텀 nvim 설정 복사
COPY --chown=${UID}:${GID} dotfiles/nvim/lua/plugins/custom.lua /home/${USERNAME}/.config/nvim/lua/plugins/
COPY --chown=${UID}:${GID} dotfiles/nvim/lua/polish.lua /home/${USERNAME}/.config/nvim/lua/

# dotfiles 심볼릭 링크 설정 (볼륨 마운트 시 적용됨)
RUN mkdir -p ${DOTFILES_DIR} ~/.config && \
    # zsh 설정
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="refined_fast"/' ~/.zshrc && \
    sed -i 's/^plugins=.*/plugins=(git fzf z zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc && \
    echo '# Load custom dotfiles' >> ~/.zshrc && \
    echo '[ -f ~/.dotfiles/shell/shellrc ] && source ~/.dotfiles/shell/shellrc' >> ~/.zshrc && \
    # 심볼릭 링크 생성
    ln -sf ${DOTFILES_DIR}/zsh/refined_fast.zsh-theme ${ZSH}/custom/themes/refined_fast.zsh-theme && \
    ln -sf ${DOTFILES_DIR}/tmux/tmux.conf ~/.tmux.conf && \
    ln -sf ${DOTFILES_DIR}/git/gitconfig ~/.gitconfig && \
    ln -sf ${DOTFILES_DIR}/scripts ~/.scripts

WORKDIR /home/${USERNAME}
CMD ["zsh"]
