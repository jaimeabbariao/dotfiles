return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        sorbet = {},
        tsserver = { enabled = false },
        ts_ls = { enabled = false },
        vtsls = { enabled = false },
        tsgo = { enabled = false },
        tsc = {
          mason = false,
        },
      },
    },
  },
}
