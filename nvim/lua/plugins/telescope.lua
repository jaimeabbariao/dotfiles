return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      version = "^1.0.0",
    },
    config = function()
      require("telescope").load_extension("live_grep_args")
    end,
    keys = {
      {"<leader>sg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>"}
    }
  },
}
