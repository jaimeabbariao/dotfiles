-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>z", function()
  require("zen-mode").toggle()
end, { desc = "Toggle ZenMode" })

vim.keymap.set("n", "<leader>km", function()
  local cwd = vim.fn.getcwd()
  if cwd ~= vim.fn.expand("~/figma/figma") then
    vim.notify("maintainers: only available in ~/figma/figma", vim.log.levels.WARN)
    return
  end
  local rel_path = vim.fn.expand("%:.")
  local cmd = "bazel --quiet run //maintainers -- " .. rel_path .. " ~/figma/figma"
  local noice = require("noice")
  local stdout = {}
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(stdout, data)
      end
    end,
    on_exit = function()
      local lines = vim.tbl_filter(function(l)
        return l ~= ""
      end, stdout)
      local last2 = table.concat(vim.list_slice(lines, math.max(1, #lines - 1)), "\n")
      noice.notify(last2 ~= "" and last2 or "(no output)", vim.log.levels.INFO, { title = "maintainers" })
    end,
  })
end, { desc = "Run maintainers on current file" })

local plain_text_lsp_configs = {}
local inline_completion_was_enabled = false

vim.keymap.set("n", "<leader>up", function()
  vim.g.plain_text_mode = not vim.g.plain_text_mode

  if vim.g.plain_text_mode then
    plain_text_lsp_configs = vim.tbl_keys(vim.lsp._enabled_configs)
    table.sort(plain_text_lsp_configs)
    inline_completion_was_enabled = vim.lsp.inline_completion.is_enabled()

    if #plain_text_lsp_configs > 0 then
      vim.lsp.enable(plain_text_lsp_configs, false)
    end
    vim.lsp.inline_completion.enable(false)

    if package.loaded["blink.cmp"] then
      require("blink.cmp").cancel()
      require("blink.cmp").hide_signature()
    end

    vim.notify("Plain text mode enabled")
  else
    if #plain_text_lsp_configs > 0 then
      vim.lsp.enable(plain_text_lsp_configs)
    end
    if inline_completion_was_enabled then
      vim.lsp.inline_completion.enable()
    end

    vim.notify("Plain text mode disabled")
  end
end, { desc = "Toggle plain text mode" })
