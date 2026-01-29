-- Custom polish settings (runs last in setup)

-- OSC 52 clipboard via TextYankPost (does NOT interfere with normal yy/p)
-- vim.g.clipboard causes issues on Windows Terminal, so we use autocmd instead
-- Use "+y to copy to system clipboard
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Copy to system clipboard via OSC 52 when using + register",
  group = vim.api.nvim_create_augroup("osc52_clipboard", { clear = true }),
  callback = function()
    if vim.v.event.regname == "+" then
      require("vim.ui.clipboard.osc52").copy("+")(vim.split(vim.fn.getreg("+"), "\n"))
    end
  end,
})

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


-- Disable AstroNvim default split mappings
vim.keymap.del('n', '\\')
vim.keymap.del('n', '|')

-- Force disable macro recording (q) globally and in all buffers
-- Global mapping (applies immediately on startup)
vim.keymap.set("n", "q", "<Nop>", { silent = true, desc = "Disable macro recording" })

-- Also apply per-buffer to override any plugin mappings
vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "FileType" }, {
  desc = "Force disable q macro recording",
  group = vim.api.nvim_create_augroup("disable_macro", { clear = true }),
  callback = function()
    vim.keymap.set("n", "q", "<Nop>", { buffer = true, silent = true })
  end,
})

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
