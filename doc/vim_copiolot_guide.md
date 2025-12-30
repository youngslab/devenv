# Vim/Neovim에서 GitHub Copilot 완벽 가이드

## 목차

1. [개요 및 플러그인 비교](#1-개요-및-플러그인-비교)
2. [github/copilot.vim (Vim/Neovim 공용)](#2-githubcopilotvim-vimneovim-공용)
3. [zbirenbaum/copilot.lua (Neovim 전용)](#3-zbirenbaumcopilotlua-neovim-전용)
4. [copilot-cmp란?](#4-copilot-cmp란)
5. [nvim-cmp와 통합하기](#5-nvim-cmp와-통합하기)
6. [실전 활용 팁](#6-실전-활용-팁)
7. [트러블슈팅](#7-트러블슈팅)
8. [추천 설정 (실전용)](#8-추천-설정-실전용)

---

## 1. 개요 및 플러그인 비교

### 플러그인 선택 가이드

| 비교 항목 | github/copilot.vim | zbirenbaum/copilot.lua |
|-----------|-------------------|------------------------|
| 언어 | VimScript | Lua (네이티브) |
| 성능 | 상대적으로 느림 | 더 빠름 |
| 지원 에디터 | Vim + Neovim | Neovim 전용 |
| nvim-cmp 통합 | 별도 작업 필요 | copilot-cmp로 원활 |
| 커스터마이징 | 제한적 | 유연함 |
| Neovim 전용 기능 | X | O |

**결론:**
- **Vim 사용자** → `github/copilot.vim`
- **Neovim 사용자** → `zbirenbaum/copilot.lua` 추천

---

## 2. github/copilot.vim (Vim/Neovim 공용)

### 2.1 설치

**vim-plug 사용 시:**
```vim
Plug 'github/copilot.vim'
```

설치 후 인증:
```vim
:Copilot setup
:Copilot enable
```

### 2.2 핵심 키 바인딩

| 동작 | 기본 키 | 설명 |
|------|---------|------|
| 제안 수락 | `Tab` | 전체 제안 적용 |
| 단어 단위 수락 | `Ctrl-Right` | 한 단어만 수락 |
| 라인 단위 수락 | 없음 (설정 필요) | 한 줄만 수락 |
| 다음 제안 | `Alt-]` | 다른 제안 보기 |
| 이전 제안 | `Alt-[` | 이전 제안으로 |
| 제안 무시 | `Ctrl-]` | 현재 제안 닫기 |

### 2.3 추천 설정

```vim
" ~/.vimrc 또는 ~/.config/nvim/init.vim

" Tab 키 충돌 방지 (다른 자동완성 플러그인 사용 시)
let g:copilot_no_tab_map = v:true

" 커스텀 수락 키 설정
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")

" 한 줄만 수락하는 매핑 추가
imap <C-L> <Plug>(copilot-accept-line)

" 한 단어만 수락
imap <C-K> <Plug>(copilot-accept-word)

" 제안 순환
imap <M-]> <Plug>(copilot-next)
imap <M-[> <Plug>(copilot-previous)

" 제안 취소
imap <C-\> <Plug>(copilot-dismiss)

" 특정 파일 타입에서 비활성화
let g:copilot_filetypes = {
    \ 'markdown': v:false,
    \ 'yaml': v:false,
    \ }
```

---

## 3. zbirenbaum/copilot.lua (Neovim 전용)

### 3.1 설치

**lazy.nvim 사용 시:**

```lua
return {
  -- Copilot 코어
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({})
    end,
  },

  -- nvim-cmp 통합 (선택사항)
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
}
```

**packer.nvim 사용 시:**

```lua
use {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({})
  end,
}

use {
  "zbirenbaum/copilot-cmp",
  after = { "copilot.lua" },
  config = function()
    require("copilot_cmp").setup()
  end,
}
```

### 3.2 상세 설정

```lua
require("copilot").setup({
  -- 제안 패널 설정
  panel = {
    enabled = true,
    auto_refresh = true,
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      open = "<M-CR>",  -- Alt+Enter로 패널 열기
    },
    layout = {
      position = "bottom",  -- "bottom" | "top" | "left" | "right"
      ratio = 0.4,
    },
  },

  -- 인라인 제안 설정
  suggestion = {
    enabled = true,
    auto_trigger = true,  -- 자동으로 제안 표시
    debounce = 75,        -- 타이핑 후 대기 시간(ms)
    keymap = {
      accept = "<M-l>",           -- Alt+l로 전체 수락
      accept_word = "<M-k>",      -- Alt+k로 단어 수락
      accept_line = "<M-j>",      -- Alt+j로 라인 수락
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },

  -- 파일타입별 설정
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false,  -- 숨김 파일
  },

  -- Copilot 서버 설정
  copilot_node_command = "node",  -- Node.js 경로

  -- 서버 옵션
  server_opts_overrides = {},
})
```

---

## 4. copilot-cmp란?

### 4.1 한마디로

**copilot.lua의 제안을 nvim-cmp 자동완성 팝업에 통합해주는 어댑터(브릿지) 플러그인**입니다.

### 4.2 구조 이해하기

```
┌─────────────────────────────────────────────────────────┐
│                      nvim-cmp                           │
│              (자동완성 프레임워크)                        │
│                                                         │
│   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐  │
│   │ nvim_lsp│ │ buffer  │ │ luasnip │ │ copilot-cmp │  │
│   │ (소스)  │ │ (소스)  │ │ (소스)  │ │   (소스)    │  │
│   └────┬────┘ └────┬────┘ └────┬────┘ └──────┬──────┘  │
└────────┼───────────┼───────────┼─────────────┼─────────┘
         │           │           │             │
         ▼           ▼           ▼             ▼
      LSP 서버    현재 버퍼    스니펫      copilot.lua
                   텍스트      엔진            │
                                               ▼
                                        GitHub Copilot
                                           서버
```

### 4.3 있을 때 vs 없을 때

**copilot-cmp 없이 (copilot.lua만):**

```
입력 중...

function calc|                       ghost text로 제안 표시
            ulate_sum(a, b)  ←──── (회색 미리보기)

┌──────────────────┐
│ calculate        │  ←──── nvim-cmp 팝업 (Copilot 제안 없음)
│ callback         │
│ calendar         │
└──────────────────┘
```

**두 개가 따로 동작** → Tab 키 등 충돌 가능성

**copilot-cmp 있을 때:**

```
입력 중...

function calc|

┌──────────────────────────────────┐
│  calculate_sum(a, b)        │  ←── Copilot 제안
│  calculate                      │  ←── LSP
│  callback                       │  ←── LSP
│  calendar                       │  ←── buffer
└──────────────────────────────────┘
```

**하나의 팝업에서 모든 제안 통합 관리**

### 4.4 핵심 역할

| 역할 | 설명 |
|------|------|
| 변환 | Copilot 제안 → nvim-cmp가 이해하는 형식으로 변환 |
| 통합 | LSP, 스니펫, 버퍼 등 다른 소스와 함께 표시 |
| 정렬 | 우선순위에 따라 Copilot 제안 순서 조정 |

### 4.5 비유하자면

```
copilot.lua  = 영어만 하는 사람 (Copilot 서버와 통신)
nvim-cmp     = 한국어만 아는 시스템 (자동완성 UI)
copilot-cmp  = 통역사 (둘 사이를 연결)
```

### 4.6 그래서 필요한가?

- **nvim-cmp 사용자라면** → 거의 필수. 통합된 경험 제공
- **nvim-cmp 안 쓴다면** → 필요 없음. copilot.lua의 ghost text만으로 충분

---

## 5. nvim-cmp와 통합하기

### 5.1 기본 통합

```lua
-- copilot-cmp 사용 시 suggestion을 비활성화 (충돌 방지)
require("copilot").setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})

require("copilot_cmp").setup()
```

### 5.2 nvim-cmp 설정에 소스 추가

```lua
local cmp = require("cmp")

cmp.setup({
  sources = cmp.config.sources({
    { name = "copilot", group_index = 2 },  -- Copilot 제안
    { name = "nvim_lsp", group_index = 2 }, -- LSP
    { name = "luasnip", group_index = 2 },  -- 스니펫
    { name = "buffer", group_index = 3 },   -- 버퍼 내 단어
    { name = "path", group_index = 3 },     -- 파일 경로
  }),

  -- Copilot 제안에 아이콘 표시
  formatting = {
    format = function(entry, vim_item)
      local icons = {
        Copilot = "",  -- 또는 원하는 아이콘
      }
      if icons[vim_item.kind] then
        vim_item.kind = icons[vim_item.kind] .. " " .. vim_item.kind
      end
      return vim_item
    end,
  },

  -- 정렬: Copilot 제안을 상단에
  sorting = {
    priority_weight = 2,
    comparators = {
      require("copilot_cmp.comparators").prioritize,
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
})
```

### 5.3 lspkind와 함께 예쁘게 표시

```lua
local lspkind = require("lspkind")

cmp.setup({
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol_text",
      maxwidth = 50,
      symbol_map = { Copilot = "" },
    }),
  },
})

-- Copilot 하이라이트 색상 (선택사항)
vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
```

### 5.4 세 가지 사용 패턴

#### 패턴 A: 인라인 제안만 사용 (cmp 없이)

```lua
require("copilot").setup({
  suggestion = {
    enabled = true,
    auto_trigger = true,
    keymap = {
      accept = "<Tab>",  -- Tab으로 수락
      accept_word = "<C-Right>",
      accept_line = "<C-Down>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },
  panel = { enabled = true },
})
```

**장점:** 설정이 간단하고 ghost text로 바로 보임
**단점:** 다른 자동완성과 별개로 동작

#### 패턴 B: nvim-cmp 통합 (추천)

```lua
require("copilot").setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})
require("copilot_cmp").setup()
```

**장점:** 모든 자동완성이 하나의 팝업에서 통합 관리
**단점:** ghost text 없음 (팝업에서만 표시)

#### 패턴 C: 하이브리드 (둘 다 사용)

```lua
require("copilot").setup({
  suggestion = {
    enabled = true,
    auto_trigger = false,  -- 수동으로만 트리거
    keymap = {
      accept = "<M-l>",
      -- ...
    },
  },
  panel = { enabled = true },
})
require("copilot_cmp").setup()
```

**장점:** 상황에 따라 선택 가능
**주의:** 키 바인딩 충돌에 신경 써야 함

---

## 6. 실전 활용 팁

### 6.1 주석으로 의도 전달하기

Copilot은 주석을 읽고 코드를 생성합니다:

```python
# 두 리스트를 받아서 공통 요소만 반환하는 함수
def find_common_elements(list1, list2):
    # Copilot이 여기서 적절한 구현을 제안합니다
```

### 6.2 함수 시그니처로 유도하기

```python
def calculate_tax(income: float, tax_rate: float) -> float:
    # 타입 힌트를 보고 정확한 구현을 제안
```

### 6.3 패널 모드로 여러 제안 비교

```vim
:Copilot panel
```

새 창에서 최대 10개의 대안을 한눈에 비교할 수 있습니다.

### 6.4 상태 표시 (lualine)

```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      {
        function()
          local status = require("copilot.api").status.data
          return " " .. (status.message or "")
        end,
        cond = function()
          local ok, clients = pcall(vim.lsp.get_active_clients, { name = "copilot" })
          return ok and #clients > 0
        end,
      },
    },
  },
})
```

### 6.5 유용한 명령어

```vim
:Copilot auth       " 인증
:Copilot enable     " 활성화
:Copilot disable    " 비활성화
:Copilot status     " 상태 확인
:Copilot panel      " 제안 패널 열기
```

### 6.6 특정 버퍼에서 토글

```lua
vim.keymap.set("n", "<leader>ct", function()
  require("copilot.suggestion").toggle_auto_trigger()
end, { desc = "Toggle Copilot auto trigger" })
```

---

## 7. 트러블슈팅

### 제안이 안 나올 때

```vim
:Copilot status    " 상태 확인
:Copilot enable    " 다시 활성화
```

### 특정 버퍼에서만 비활성화

```vim
:Copilot disable
```

### "Copilot not authenticated" 오류

```vim
:Copilot auth
```

### 제안이 느릴 때

```lua
suggestion = {
  debounce = 50,  -- 기본 75ms에서 줄이기
}
```

### Node.js 버전 문제

Copilot은 Node.js 18+ 필요

```lua
copilot_node_command = "/path/to/node",  -- 특정 버전 지정
```

---

## 8. 추천 설정 (실전용)

### 8.1 Neovim + lazy.nvim 사용자

```lua
-- 📁 lua/plugins/copilot.lua
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,  -- markdown에서도 사용
        help = false,
        gitcommit = true, -- 커밋 메시지에 유용
      },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = "copilot.lua",
    opts = {},
  },
}
```

### 8.2 Vim 사용자

```vim
" ~/.vimrc

" 플러그인 설치
Plug 'github/copilot.vim'

" Tab 충돌 방지
let g:copilot_no_tab_map = v:true

" 커스텀 키 매핑
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
imap <C-L> <Plug>(copilot-accept-line)
imap <C-K> <Plug>(copilot-accept-word)
imap <M-]> <Plug>(copilot-next)
imap <M-[> <Plug>(copilot-previous)
imap <C-\> <Plug>(copilot-dismiss)

" 파일타입 설정
let g:copilot_filetypes = {
    \ 'markdown': v:true,
    \ 'yaml': v:false,
    \ 'gitcommit': v:true,
    \ }
```

---

## 참고 링크

- [github/copilot.vim](https://github.com/github/copilot.vim)
- [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua)
- [zbirenbaum/copilot-cmp](https://github.com/zbirenbaum/copilot-cmp)
- [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
