local telescope = require("telescope")
local telescopeConfig = require("telescope.config")

local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

-- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, "--hidden")
-- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      version = "^1.0.0",
    },
    config = function()
      require("telescope").load_extension("live_grep_args")
    end,
    keys = {
      {"<leader>sg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>"}
    },
    opts = {
      defaults = {
        vimgrep_arguments = vimgrep_arguments
      },
      pickers = {
        find_files = {
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" }
        },
        git_files = {
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" }
        }
      }
    }
  },
}
