return {
  {
    "stevearc/conform.nvim",
    opts = function()
      ---@type conform.setupOpts
      local opts = {
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_format = "fallback", -- not recommended to change
        },
        formatters_by_ft = {
          lua = { "stylua" },
          fish = { "fish_indent" },
          sh = { "shfmt" },
          typescriptreact = { "biome", "prettier" },
          typescript = { "biome", "prettier" },
          javascriptreact = { "biome", "prettier" },
          javascript = { "biome", "prettier" },
          ruby = { "prettier" },
          json = { "jq", "prettier" },
          erb = { "erb_format" },
        },
        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } },
          biome = {
            require_cwd = true,
          },
          prettier = {
            require_cwd = true,
          },
          erb = { require_cwd = true },
          jq = {
            require_cwd = true,
            prepend_args = { "to_entries | sort_by(.key) | from_entries" },
          },
        },
      }
      return opts
    end,
  },
}
