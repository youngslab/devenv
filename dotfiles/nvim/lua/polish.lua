-- Custom polish settings (runs last in setup)

-- OSC 52 clipboard support (works in SSH/containers/tmux)
local function osc52_copy(text)
  local base64 = vim.base64.encode(text)
  local osc = string.format('\x1b]52;c;%s\x07', base64)
  -- Wrap in tmux passthrough if inside tmux
  if vim.env.TMUX then
    osc = string.format('\x1bPtmux;\x1b%s\x1b\\', osc)
  end
  io.stdout:write(osc)
end

vim.g.clipboard = {
  name = "OSC 52 (tmux aware)",
  copy = {
    ["+"] = function(lines) osc52_copy(table.concat(lines, "\n")) end,
    ["*"] = function(lines) osc52_copy(table.concat(lines, "\n")) end,
  },
  paste = {
    ["+"] = function() return { vim.fn.getreg(""), vim.fn.getregtype("") } end,
    ["*"] = function() return { vim.fn.getreg(""), vim.fn.getregtype("") } end,
  },
}

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Remove trailing whitespace",
  group = vim.api.nvim_create_augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Return to last edit position
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Return to last edit position",
  group = vim.api.nvim_create_augroup("restore_cursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits
vim.api.nvim_create_autocmd("VimResized", {
  desc = "Auto-resize splits",
  group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Dim inactive windows + highlight window separator
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Dim inactive windows and highlight separator",
  group = vim.api.nvim_create_augroup("dim_inactive", { clear = true }),
  callback = function()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
    if normal.bg then
      local r = math.floor(normal.bg / 0x10000)
      local g = math.floor((normal.bg % 0x10000) / 0x100)
      local b = normal.bg % 0x100
      local dimmed = math.max(0, r - 12) * 0x10000 + math.max(0, g - 12) * 0x100 + math.max(0, b - 12)
      vim.api.nvim_set_hl(0, "NormalNC", { bg = dimmed })
    end
    -- Bright window separator
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#7aa2f7", bold = true })
  end,
})
vim.defer_fn(function() vim.cmd("doautocmd ColorScheme") end, 50)

-- Terminal mode: Esc to exit to normal mode
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Disable AstroNvim default split mappings
vim.keymap.del('n', '\\')
vim.keymap.del('n', '|')

-- Filetype-specific settings
vim.api.nvim_create_autocmd("FileType", {
  desc = "Filetype-specific settings",
  group = vim.api.nvim_create_augroup("filetype_settings", { clear = true }),
  callback = function()
    local ft = vim.bo.filetype
    -- 2 spaces for certain filetypes
    if vim.tbl_contains({ "lua", "yaml", "json", "javascript", "typescript", "html", "css" }, ft) then
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
      vim.bo.softtabstop = 2
    end
    -- Wrap for text files
    if vim.tbl_contains({ "markdown", "text", "gitcommit" }, ft) then
      vim.wo.wrap = true
      vim.wo.linebreak = true
    end
  end,
})
