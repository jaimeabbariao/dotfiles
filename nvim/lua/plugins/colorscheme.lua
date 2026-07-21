return {
  {
    "ja153903/embark-theme-vim",
    lazy = false,
    priority = 1000,
    name = "embark",
  },
  {
    "wurli/cobalt.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "embark",
    },
  },
}
