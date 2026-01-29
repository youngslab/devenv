-- Custom settings (merged with AstroNvim defaults)
-- This file is added on top of the AstroNvim template

---@type LazySpec
return {
  -- AstroCore customizations
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      features = {
        large_buf = { size = 1024 * 512, lines = 10000 },
      },
      options = {
        opt = {
          -- Tabs & Indentation
          tabstop = 4,
          shiftwidth = 4,
          softtabstop = 4,
          expandtab = true,
          smartindent = true,
          autoindent = true,

          -- Search
          ignorecase = true,
          smartcase = true,
          hlsearch = true,
          incsearch = true,

          -- Display
          cursorline = true,
          scrolloff = 8,
          sidescrolloff = 8,

          -- Behavior
          -- clipboard = "unnamedplus", -- disabled: use "+y to copy to system clipboard
          undofile = true,
          swapfile = false,
          backup = false,
          updatetime = 300,
          timeoutlen = 300,

          -- Split windows
          splitright = true,
          splitbelow = true,

          -- Misc
          showmode = false,
          completeopt = { "menu", "menuone", "noselect" },

        },
      },
      mappings = {
        n = {
          -- Disable macro recording (q key)
          ["q"] = { "<Nop>", desc = "Disable macro recording" },

          -- Buffer navigation
          ["H"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
          ["L"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },

          -- Buffer management
          ["<Leader>bd"] = {
            function()
              require("astroui.status.heirline").buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Close buffer from tabline",
          },
          ["<Leader>b"] = { desc = " Buffers" },

          -- Window navigation
          ["<C-h>"] = { "<C-w>h", desc = "Move to left window" },
          ["<C-j>"] = { "<C-w>j", desc = "Move to lower window" },
          ["<C-k>"] = { "<C-w>k", desc = "Move to upper window" },
          ["<C-l>"] = { "<C-w>l", desc = "Move to right window" },
          -- 한글 상태에서도 window 이동 (터미널에 따라 동작 안할 수 있음)
          ["<C-ㅗ>"] = { "<C-w>h", desc = "Move to left window" },
          ["<C-ㅓ>"] = { "<C-w>j", desc = "Move to lower window" },
          ["<C-ㅏ>"] = { "<C-w>k", desc = "Move to upper window" },
          ["<C-ㅣ>"] = { "<C-w>l", desc = "Move to right window" },

          -- Clear search highlight
          ["<Esc>"] = { "<cmd>nohlsearch<CR>", desc = "Clear search highlight" },

          -- System clipboard
          ["<Leader>y"] = { '"+y', desc = "Copy to system clipboard" },
          ["<Leader>Y"] = { '"+Y', desc = "Copy line to system clipboard" },

          -- Toggle terminal mode (enter insert mode if in terminal buffer)
          ["<C-x>"] = {
            function()
              if vim.bo.buftype == "terminal" then
                vim.cmd("startinsert")
              end
            end,
            desc = "Enter terminal mode",
          },

          -- Better line navigation
          ["j"] = { "v:count == 0 ? 'gj' : 'j'", expr = true, silent = true },
          ["k"] = { "v:count == 0 ? 'gk' : 'k'", expr = true, silent = true },

          -- Quick save
          ["<C-s>"] = { "<cmd>w<CR>", desc = "Save file" },

          -- Move lines
          ["<A-j>"] = { "<cmd>m .+1<CR>==", desc = "Move line down" },
          ["<A-k>"] = { "<cmd>m .-2<CR>==", desc = "Move line up" },
        },
        i = {
          ["<C-s>"] = { "<Esc><cmd>w<CR>", desc = "Save file" },
          ["jk"] = { "<Esc>", desc = "Exit insert mode" },
        },
        v = {
          ["<"] = { "<gv", desc = "Indent left" },
          [">"] = { ">gv", desc = "Indent right" },
          ["<A-j>"] = { ":m '>+1<CR>gv=gv", desc = "Move selection down" },
          ["<A-k>"] = { ":m '<-2<CR>gv=gv", desc = "Move selection up" },
          ["p"] = { '"_dP', desc = "Paste without yanking" },
          ["<Leader>y"] = { '"+y', desc = "Copy to system clipboard" },
        },
        x = {
          ["<A-j>"] = { ":m '>+1<CR>gv=gv", desc = "Move selection down" },
          ["<A-k>"] = { ":m '<-2<CR>gv=gv", desc = "Move selection up" },
        },
        t = {
          -- Exit terminal mode (normal mode로 전환)
          ["<C-x>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
          -- Terminal mode window navigation
          ["<C-h>"] = { "<C-\\><C-n><C-w>h", desc = "Move to left window" },
          ["<C-j>"] = { "<C-\\><C-n><C-w>j", desc = "Move to lower window" },
          ["<C-k>"] = { "<C-\\><C-n><C-w>k", desc = "Move to upper window" },
          ["<C-l>"] = { "<C-\\><C-n><C-w>l", desc = "Move to right window" },
          -- 한글 상태에서도 window 이동
          ["<C-ㅗ>"] = { "<C-\\><C-n><C-w>h", desc = "Move to left window" },
          ["<C-ㅓ>"] = { "<C-\\><C-n><C-w>j", desc = "Move to lower window" },
          ["<C-ㅏ>"] = { "<C-\\><C-n><C-w>k", desc = "Move to upper window" },
          ["<C-ㅣ>"] = { "<C-\\><C-n><C-w>l", desc = "Move to right window" },
        },
      },
    },
  },

  -- AstroUI customizations
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "astrodark",
    },
  },

  -- Neo-tree: NERDTree 스타일 검색 (/ = vim 검색, f = filter)
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          -- / 를 vim 기본 검색으로 변경 (NERDTree 스타일)
          ["/"] = "noop",  -- neo-tree filter 비활성화
          ["f"] = "filter_on_submit",  -- f로 filter 사용
        },
      },
    },
    keys = {
      -- neo-tree에서 / 누르면 vim 검색 실행
      {
        "/",
        "/",
        desc = "Search in neo-tree",
        ft = "neo-tree",
      },
    },
  },

  -- Mason: LSP/linter/formatter 설치
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- C/C++
        "clangd",
        "clang-format",
        -- Python
        "pyright",
        "black",
        "ruff",
      },
    },
  },

  -- None-ls: Linter/Formatter
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local null_ls = require("null-ls")
      opts.sources = opts.sources or {}
      vim.list_extend(opts.sources, {
        -- C/C++
        null_ls.builtins.formatting.clang_format,
        -- Python
        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.ruff,
      })
      return opts
    end,
  },

  -- Claude Code integration
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = function()
      require("claudecode").setup({
        terminal_cmd = "claude --dangerously-skip-permissions",
      })
      -- 모든 터미널 버퍼에 돌아올 때 자동으로 insert mode
      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        pattern = "term://*",
        callback = function()
          vim.schedule(function()
            if vim.bo.buftype == "terminal" then
              vim.cmd("startinsert")
            end
          end)
        end,
      })
    end,
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<C-=>", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude", mode = { "n", "t", "i" } },
      { "<F1>", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude", mode = { "n", "t", "i" } },
    },
  },

  -- Toggleterm (terminal integration)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 15,
      open_mapping = [[<F2>]],
      direction = "horizontal",  -- horizontal, vertical, float, tab
      shade_terminals = true,
      shading_factor = 2,
      persist_size = true,
      close_on_exit = true,
      shell = "/usr/bin/zsh",
    },
    keys = {
      { "<F2>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<F2>", "<cmd>ToggleTerm<cr>", mode = "t", desc = "Toggle terminal" },
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Vertical terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal terminal" },
    },
  },

  -- GitHub Copilot (ghost text + cmp 하이브리드)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<C-l>",           -- Ctrl+l로 ghost text 수락
          accept_word = "<C-Right>",
          accept_line = "<C-End>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = true },
      filetypes = {
        markdown = true,
        yaml = true,
        gitcommit = true,
      },
    },
  },

  -- Copilot CMP integration
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    event = "InsertEnter",
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- nvim-cmp: Copilot 통합 + 정렬 + 아이콘
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "zbirenbaum/copilot-cmp" },
    config = function(_, opts)
      local cmp = require("cmp")

      -- Copilot 소스 추가 (최상단)
      table.insert(opts.sources, 1, { name = "copilot", group_index = 1, priority = 100 })

      -- Tab은 Copilot ghost text 전용, CMP에서 제거
      opts.mapping["<Tab>"] = nil
      opts.mapping["<S-Tab>"] = nil
      opts.mapping["<C-Space>"] = cmp.mapping.complete()

      -- Copilot 제안을 최상단에 정렬
      opts.sorting = opts.sorting or {}
      opts.sorting.comparators = {
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
      }

      -- Copilot 아이콘 표시
      local kind_icons = {
        Copilot = "",
        Text = "󰉿",
        Method = "󰆧",
        Function = "󰊕",
        Constructor = "",
        Field = "󰜢",
        Variable = "󰀫",
        Class = "󰠱",
        Interface = "",
        Module = "",
        Property = "󰜢",
        Unit = "󰑭",
        Value = "󰎠",
        Enum = "",
        Keyword = "󰌋",
        Snippet = "",
        Color = "󰏘",
        File = "󰈙",
        Reference = "󰈇",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "󰙅",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "",
      }

      opts.formatting = opts.formatting or {}
      opts.formatting.format = function(entry, vim_item)
        vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
        vim_item.menu = ({
          copilot = "[Copilot]",
          nvim_lsp = "[LSP]",
          luasnip = "[Snippet]",
          buffer = "[Buffer]",
          path = "[Path]",
        })[entry.source.name] or ""
        return vim_item
      end

      cmp.setup(opts)

      -- Copilot 하이라이트 색상
      vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
    end,
  },

  -- Window zoom toggle
  {
    "szw/vim-maximizer",
    lazy = false,  -- 즉시 로드 (F10이 처음부터 작동하도록)
    keys = {
      { "<F10>", "<cmd>MaximizerToggle<CR>", desc = "Zoom window toggle", mode = { "n", "i", "v" } },
      { "<F10>", "<C-\\><C-n><cmd>MaximizerToggle<CR>i", desc = "Zoom window toggle", mode = "t" },
    },
  },

  -- GitHub PR/Issue 관리 (octo.nvim)
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      picker = "telescope",
      enable_builtin = true,
      default_merge_method = "squash",
      mappings_disable_default = false,
      default_remote = { "origin", "ccu", "upstream" },  -- remote 이름 우선순위
    },
    keys = {
      { "<leader>oi", "<cmd>Octo issue list<cr>", desc = "List Issues" },
      { "<leader>oI", "<cmd>Octo issue create<cr>", desc = "Create Issue" },
      { "<leader>op", "<cmd>Octo pr list<cr>", desc = "List PRs" },
      { "<leader>oP", "<cmd>Octo pr create<cr>", desc = "Create PR" },
      { "<leader>oc", "<cmd>Octo pr checkout<cr>", desc = "Checkout PR" },
      { "<leader>or", "<cmd>Octo review start<cr>", desc = "Start Review" },
      { "<leader>os", "<cmd>Octo search<cr>", desc = "Search GitHub" },
      { "<leader>o", desc = " Octo (GitHub)" },
    },
  },

  -- Markdown 터미널 렌더링
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {
      enabled = true,  -- 기본 렌더링 활성화 (<leader>mr로 토글)
      render_modes = { "n", "c" },
      heading = {
        enabled = true,
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        enabled = true,
        sign = true,
        style = "full",
        border = "thin",
      },
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
      },
      pipe_table = { enabled = true },
      callout = {
        note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
        tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
        important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
        warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
        caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
      },
    },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown render" },
    },
  },
}
