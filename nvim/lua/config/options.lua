-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.clipboard = "unnamedplus"

-- Over SSH, make the Mac's system clipboard the single source of truth:
-- copy writes via OSC 52, paste reads via OSC 52. Requires every layer
-- between nvim and Ghostty to pass OSC 52 reads through — notably, do
-- NOT run zellij on the remote host (it's write-only for OSC 52).
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
