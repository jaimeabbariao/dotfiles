if not vim.g.vscode then
  return {}
end

local vscode = require("vscode")

-- Override snacks_picker keybinds with VSCode/Cursor equivalents.
--
-- These are defined on the snacks.nvim spec (not via vim.keymap.set) so that
-- lazy.nvim's key dedup (by lhs+mode, last spec wins) REPLACES the default
-- snacks mappings instead of layering on top of them. Our lua/plugins files
-- load after the LazyVim extras, so the snacks picker implementations are
-- never invoked. Modes must match the defaults to fully shadow them.
--
-- This file early-returns {} outside VSCode, so native Neovim keeps the real
-- snacks pickers untouched.
return {
  {
    "folke/snacks.nvim",
    keys = {
      -- Find all references (snacks default here is grep-word; remapped per request)
      {
        "<leader>sw",
        function()
          vscode.call("references-view.findReferences")
        end,
        desc = "Find all references",
        mode = { "n", "x" },
      },
      -- Grep across files
      {
        "<leader>sg",
        function()
          vscode.call("workbench.action.findInFiles")
        end,
        desc = "Grep (find in files)",
      },
      -- File search (quick open)
      {
        "<leader>ff",
        function()
          vscode.call("workbench.action.quickOpen")
        end,
        desc = "Find files",
      },
      {
        "<leader><leader>",
        function()
          vscode.call("workbench.action.quickOpen")
        end,
        desc = "Find files (alt)",
      },
      {
        "<leader>e",
        function()
          vscode.call("workbench.action.toggleSidebarVisibility")
        end,
        desc = "Toggle explorer",
      },
    },
  },
}
