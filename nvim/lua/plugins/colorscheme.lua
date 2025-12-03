local opts = {
  theme = "dark",
  styles = {
    type = { bold = true },
    lsp = { underline = true },
    match_paren = { underline = true },
  },
}

local function config()
  local plugin = require("no-clown-fiesta")
  local loaded_state = plugin.load(opts)
  vim.cmd([[colorscheme no-clown-fiesta]])
  return loaded_state
end

return {
  "aktersnurra/no-clown-fiesta.nvim",
  priority = 1000,
  config = config,
  lazy = false,
}
