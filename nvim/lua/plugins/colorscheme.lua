return {
  {
    "craftzdog/solarized-osaka.nvim",
    -- lazy = false,
    -- priority = 1000,
    enabled = false,
    opts = {},
  },
  {
    "embark-theme/vim",
    lazy = false,
    priority = 1000,
    name = "embark",
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "embark",
    },
  },
}
