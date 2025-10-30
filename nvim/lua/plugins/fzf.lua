return {
  "ibhagwan/fzf-lua",
  config = function()
    require("fzf-lua").setup({
      winopts = {
        preview = {
          layout = "vertical",
        },
      },
    })
  end,
}
