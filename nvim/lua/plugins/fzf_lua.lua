return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      {"<leader><leader>", ":FzfLua<CR>"}
    },
    config = function()
      require("fzf-lua").setup({})
    end
  }
}
