-- Git Worktree integration with Telescope
-- Keymaps: <leader>gw = list worktrees, <leader>gW = create worktree

---@type LazySpec
return {
  {
    "polarmutex/git-worktree.nvim",
    version = "^2",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    event = "VeryLazy",
    config = function()
      require("telescope").load_extension("git_worktree")
    end,
    keys = {
      {
        "<leader>gw",
        function() require("telescope").extensions.git_worktree.git_worktree() end,
        desc = "Git Worktrees",
      },
      {
        "<leader>gW",
        function() require("telescope").extensions.git_worktree.create_git_worktree() end,
        desc = "Create Git Worktree",
      },
    },
  },
}
