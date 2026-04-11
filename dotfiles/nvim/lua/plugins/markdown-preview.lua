-- Markdown Preview: 브라우저에서 실시간 markdown 프리뷰 (mermaid, image 지원)
-- 사용법: :MarkdownPreview → 호스트 브라우저에서 http://<서버IP>:8090 접속

---@type LazySpec
return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npx --yes yarn install",
    init = function()
      vim.g.mkdp_auto_start = 0          -- 자동 시작 비활성화
      vim.g.mkdp_auto_close = 0          -- 버퍼 닫아도 프리뷰 유지
      vim.g.mkdp_open_to_the_world = 1   -- 0.0.0.0 바인딩 (원격 접속 허용)
      vim.g.mkdp_port = ""               -- 랜덤 포트
      vim.g.mkdp_browser = ""            -- 브라우저 자동 열기 비활성화
      vim.g.mkdp_echo_preview_url = 1    -- 프리뷰 URL 출력
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Markdown Preview", ft = "markdown" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", desc = "Markdown Preview Stop", ft = "markdown" },
    },
  },
}
