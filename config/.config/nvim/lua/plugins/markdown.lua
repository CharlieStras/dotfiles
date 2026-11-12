return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    opts = {},
    keys = {
      { "<leader>mp", "<Cmd>RenderMarkdown preview<CR>", ft = "markdown", desc = "Preview Markdown in a split" },
      { "<leader>mt", "<Cmd>RenderMarkdown buf_toggle<CR>", ft = "markdown", desc = "Toggle Markdown rendering" },
    },
  },
}
