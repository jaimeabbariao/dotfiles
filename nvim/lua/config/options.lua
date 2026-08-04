-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Prevent terminal query responses from leaking as input in tmux + SSH
if os.getenv("SSH_TTY") then
  vim.o.termsync = false
  vim.g.terminfo_guicolors = false
end

vim.opt.list = false

vim.opt.mousescroll = "ver:1,hor:0"
vim.opt.wrap = false

vim.opt.clipboard = "unnamedplus"

-- A remote host cannot access the desktop clipboard directly. OSC 52 sends
-- clipboard operations through SSH (and Herdr) to the local terminal instead.
-- Ghostty permits OSC 52 reads and writes in ghostty/config.
if os.getenv("SSH_TTY") or os.getenv("SSH_CONNECTION") then
  vim.g.clipboard = "osc52"
end
