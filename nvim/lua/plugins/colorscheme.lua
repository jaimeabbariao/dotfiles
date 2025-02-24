return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "light"
      require("tokyonight").setup({
        style = "day",
      })
      vim.cmd([[colorscheme tokyonight-day]])
    end,
  },
}
