return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        vtsls = {
          settings = {
            typescript = {
              tsserver = {
                nodePath = "node",
                maxTsServerMemory = 8192,
              },
            },
          },
        },
      },
    },
  },
}
