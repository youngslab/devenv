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
          clipboard = "unnamedplus",
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

          -- Clear search highlight
          ["<Esc>"] = { "<cmd>nohlsearch<CR>", desc = "Clear search highlight" },

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
        },
        x = {
          ["<A-j>"] = { ":m '>+1<CR>gv=gv", desc = "Move selection down" },
          ["<A-k>"] = { ":m '<-2<CR>gv=gv", desc = "Move selection up" },
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

  -- Treesitter: 언어별 파서
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "c",
        "cpp",
        "python",
        "lua",
        "vim",
        "vimdoc",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
        "bash",
      })
      return opts
    end,
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
    config = true,
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    },
  },

  -- GitHub Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
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
      },
    },
  },
}
