return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        ruby_lsp = {
          cmd = { os.getenv("HOME") .. "/.rbenv/shims/ruby-lsp" },
        },
      },
    },
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("typescript-tools").setup({
        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = "insert_leave",
          expose_as_code_action = { "add_missing_imports", "remove_unused" },
          tsserver_path = nil,
          tsserver_plugins = {},
          tsserver_max_memory = 16384,
          tsserver_format_options = {
            semicolons = "insert",
            insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
          },
          tsserver_file_preferences = {
            includeInlayParameterNameHints = "none",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayVariableTypeHints = false,
            includeInlayPropertyDeclarationTypeHints = false,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayEnumMemberValueHints = false,
            includeCompletionsForModuleExports = false,
            includeCompletionsWithSnippetText = false,
          },
          tsserver_locale = "en",
          complete_function_calls = false,
          include_completions_with_insert_text = false,
          code_lens = "off",
          disable_member_code_lens = true,
          jsx_close_tag = {
            enable = false,
            filetypes = { "javascriptreact", "typescriptreact" },
          },
        },
      })
    end,
  },
}
