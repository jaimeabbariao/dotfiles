-- Pull in the wezterm API
local wezterm = require("wezterm")

-- local rose_pine_main = require('lua/rose-pine-official').main
-- local colors = rose_pine_main.colors()
-- local window_frame = rose_pine_main.window_frame()
-- local colors = require('lua/rose-pine').colors()
-- local window_frame = require('lua/rose-pine').window_frame()

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the color scheme:
config.font = wezterm.font_with_fallback({ "MonoLisa", "nonicons" })
config.font_size = 14
config.enable_scroll_bar = false
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 64
-- config.colors = colors
-- config.window_frame = window_frame
config.line_height = 1.2
-- config.color_scheme = 'One Dark (Gogh)'

-- config.color_scheme = 'Solarized Dark - Patched'
config.window_background_opacity = 1.0

local custom = wezterm.color.get_builtin_schemes()["Solarized Dark - Patched"]
custom.background = "#00141A"
custom.foreground = "#FFF"
custom.tab_bar = {
  background = "#00141A",
  active_tab = {
    bg_color = "#063642",
    fg_color = "#FFF"
  },
  inactive_tab = {
    bg_color = "#00141A",
    fg_color = "#FFF",
  },
  new_tab = {
    bg_color = "#002B36",
    fg_color = "#EEE8D5",
  },
}
-- custom.tab_bar.background = "#00141A"
-- custom.tab_bar.inactive_tab.bg_color = "#9EACAD"
-- custom.tab_bar.new_tab.bg_color = "#ADB8B8"

config.color_schemes = { ["Solarized Osaka"] = custom }
config.color_scheme = 'Solarized Osaka'

-- local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
-- custom.background = "#040404"
-- custom.tab_bar.background = "#040404"
-- custom.tab_bar.inactive_tab.bg_color = "#0f0f0f"
-- custom.tab_bar.new_tab.bg_color = "#080808"
--
-- config.color_schemes = { ["OLEDCat"] = custom }
-- config.color_scheme = "OLEDCat"

-- timeout_milliseconds defaults to 1000 and can be omitted
-- config.color_scheme = 'Moonfly'

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  {
    key = "n",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = "p",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = "h",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Left"),
  },
  {
    key = "l",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Right"),
  },
  {
    key = "k",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Up"),
  },
  {
    key = "j",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Down"),
  },
  {
    key = "-",
    mods = "LEADER",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "|",
    mods = "LEADER|SHIFT",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
  {
    key = "a",
    mods = "LEADER|CTRL",
    action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
  },
}

-- and finally, return the configuration to wezterm
return config
