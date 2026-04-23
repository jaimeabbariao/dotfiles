-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.clipboard = "unnamedplus"

-- Over SSH there's no pbcopy/xclip; route the + and * registers through
-- OSC 52 so yanks reach the host terminal's clipboard. Locally, leave the
-- default provider alone (pbcopy/pbpaste is faster and avoids OSC prompts).
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
  }
end

vim.opt.list = false

vim.opt.mousescroll = "ver:1,hor:0"
vim.opt.wrap = false
