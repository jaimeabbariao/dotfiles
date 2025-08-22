return {
  "ibhagwan/fzf-lua",
  config = function()
    require("fzf-lua").setup({
      winopts = {
        fullscreen = true,
        preview = {
          layout = "vertical",
        },
      },
    })
  end,
}
