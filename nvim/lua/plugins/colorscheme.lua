return {
  {
    "rose-pine/neovim",
    enabled = false,
    lazy = false,
    priority = 1000,
    name = "rose-pine",
    opts = {
      variant = "main", -- auto, main, moon, or dawn
      -- dark_variant = "moon", -- main, moon, or dawn
      dim_inactive_windows = false,
      extend_background_behind_borders = true,

      enable = {
        terminal = true,
        legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
        migrations = true,        -- Handle deprecated options automatically
      },

      styles = {
        bold = true,
        italic = false,
        transparency = false,
      },

      groups = {
        border = "muted",
        link = "iris",
        panel = "surface",

        error = "love",
        hint = "iris",
        info = "foam",
        note = "pine",
        todo = "rose",
        warn = "gold",

        git_add = "foam",
        git_change = "rose",
        git_delete = "love",
        git_dirty = "rose",
        git_ignore = "muted",
        git_merge = "iris",
        git_rename = "pine",
        git_stage = "iris",
        git_text = "rose",
        git_untracked = "subtle",

        h1 = "iris",
        h2 = "foam",
        h3 = "rose",
        h4 = "gold",
        h5 = "pine",
        h6 = "foam",
      },

      highlight_groups = {
        Comment = { fg = "foam" },
        VertSplit = { fg = "muted", bg = "muted" },
      },

      before_highlight = function(group, highlight, palette)
        -- Disable all undercurls
        if highlight.undercurl then
          highlight.undercurl = false
        end

        if highlight.fg == palette.pine then
          highlight.fg = palette.foam
        end
      end,
    }
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      transparent = true, -- Enable this to disable setting the background color
      terminal_colors = true, -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
      styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        -- Background styles. Can be "dark", "transparent" or "normal"
        sidebars = "transparent",          -- style for sidebars, see below
        floats = "dark",            -- style for floating windows
      },
      sidebars = { "qf", "help" },  -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
      day_brightness = 0.3,         -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
      hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
      dim_inactive = false,         -- dims inactive windows
      lualine_bold = false,         -- When `true`, section headers in the lualine theme will be bold

      --- You can override specific color groups to use other groups or a hex color
      --- function will be called with a ColorScheme table
      ---@param colors ColorScheme
      on_colors = function(colors) end,

      --- You can override specific highlights to use other groups or a hex color
      --- function will be called with a Highlights and ColorScheme table
      ---@param highlights Highlights
      ---@param colors ColorScheme
      on_highlights = function(highlights, colors) end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized-osaka",
    },
  },
}
