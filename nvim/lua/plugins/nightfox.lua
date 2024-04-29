local palettes = {
  carbonfox = {
    sel0 = "#304E75",
  },
}

return {
  {
    "EdenEast/nightfox.nvim",
    disabled = true,
    -- lazy = false,
    -- priority = 1000,
    config = function()
      require("nightfox").setup({
        palettes = palettes,
      })
    end,
  },
}
