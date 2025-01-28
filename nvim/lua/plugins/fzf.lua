return {
  {
    "ibhagwan/fzf-lua",
    enabled = false,
    config = function()
      require("fzf-lua").setup({
        winopts = {
          backdrop = 100,
          fullscreen = true,
        },
        files = {
          git_icons = false,
        },
        grep = {
          rg_glob = true,
          glob_flag = "--iglob",
          glob_separator = "%s%-%-",
        },
      })
    end,
  },
}
