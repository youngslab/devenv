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
}
