local palettes = {
  carbonfox = {
    bg0 = "#161616",
    bg1 = "#161616",
    sel0 = "#304E75",
  },
}

return {
  {
    "EdenEast/nightfox.nvim",
    enabled = false,
    -- lazy = false,
    -- priority = 1000,
    config = function()
      require("nightfox").setup({
        palettes = palettes,
      })
    end,
  },
}
