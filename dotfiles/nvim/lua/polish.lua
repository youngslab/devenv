-- Custom polish settings (runs last in setup)

-- OSC 52 clipboard support (works in SSH/containers)
if vim.fn.has("nvim-0.10") == 1 then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end

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
