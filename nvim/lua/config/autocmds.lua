-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_user_command("CopyRelPath", "call setreg('+', expand('%'))", {})

-- Stop indent backwards when dot operator is used in Ruby
vim.cmd([[autocmd FileType ruby setlocal indentkeys-=.]])
