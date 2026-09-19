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
-- yanks through SSH (and Herdr) to the local terminal instead. Do not use the
-- OSC 52 paste/query operation: some terminals prompt with "Waiting for OSC 52"
-- while Neovim waits for a clipboard response. Cache our own yanks for `p`, and
-- use the terminal's normal paste shortcut for text copied outside Neovim.
if os.getenv("SSH_TTY") or os.getenv("SSH_CONNECTION") then
  local osc52 = require("vim.ui.clipboard.osc52")
  local cache = {
    ["+"] = { {}, "v" },
    ["*"] = { {}, "v" },
  }

  local function copy(reg)
    local osc52_copy = osc52.copy(reg)
    return function(lines, regtype)
      cache[reg] = { vim.deepcopy(lines), regtype }
      osc52_copy(lines, regtype)
    end
  end

  local function paste(reg)
    return function()
      return cache[reg]
    end
  end

  vim.g.clipboard = {
    name = "OSC 52 (copy only)",
    copy = {
      ["+"] = copy("+"),
      ["*"] = copy("*"),
    },
    paste = {
      ["+"] = paste("+"),
      ["*"] = paste("*"),
    },
  }
end
