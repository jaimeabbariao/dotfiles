return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    enabled = false,
    opts = { mode = "cursor" },
    keys = {
      {
        "<leader>ut",
        function()
          local Util = require("lazyvim.util")
          local tsc = require("treesitter-context")
          tsc.toggle()
          if Util.inject.get_upvalue(tsc.toggle, "enabled") then
            Util.info("Enabled Treesitter Context", { title = "Option" })
          else
            Util.warn("Disabled Treesitter Context", { title = "Option" })
          end
        end,
        desc = "Toggle Treesitter Context",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    opts = {
      indent = {
        disable = { "python" },
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "python" },
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    config = function()
      require("nvim-ts-autotag").setup({
        enable = true,
        enable_close_on_slash = false,
      })
    end,
  },
  { "nvim-treesitter/playground" },
}
