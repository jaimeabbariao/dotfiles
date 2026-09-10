return {
  {
    "neovim/nvim-lspconfig",
    event = function()
      return { "User LspEnabled" }
    end,
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        sorbet = {},
        tsserver = { enabled = false },
        vtsls = { enabled = false },
        tsgo = {
          cmd = { "tsgo", "--lsp", "--stdio" },
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          root_markers = {
            "tsconfig.json",
            "jsconfig.json",
            "package.json",
            ".git",
            "tsconfig.base.json",
          },
          enabled = true,
        },
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    lazy = true,
    ft = function()
      return {}
    end,
    opts = {
      server = {
        auto_attach = function()
          return not vim.g.plain_text_mode
        end,
      },
    },
  },
  {
    "Saecki/crates.nvim",
    lazy = true,
    event = function()
      return {}
    end,
    opts = {
      lsp = { enabled = false },
      on_attach = function()
        if not vim.g.plain_text_mode then
          require("crates.lsp").start_server()
        end
      end,
    },
  },
}
