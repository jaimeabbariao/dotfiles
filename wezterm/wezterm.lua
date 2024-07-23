-- Pull in the wezterm API
local wezterm = require 'wezterm'

local solarized_osaka = require('lua/solarized-osaka').custom

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the color scheme:
config.font = wezterm.font_with_fallback { 'MonoLisa', 'nonicons' }
config.font_size = 13
config.freetype_load_flags = 'NO_HINTING'
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
config.line_height = 1.5
-- config.window_background_opacity = 0.9
-- config.macos_window_background_blur = 20

config.color_schemes = { ['Solarized Osaka'] = solarized_osaka }
config.color_scheme = 'Tokyo Night Storm'

config.inactive_pane_hsb = {
  saturation = 1.0,
  brightness = 1.0,
}

-- timeout_milliseconds defaults to 1000 and can be omitted
config.leader = { key = 'e', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  {
    key = 'n',
    mods = 'LEADER',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = 'h',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = '-',
    mods = 'LEADER',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = '|',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
  {
    key = 'e',
    mods = 'LEADER|CTRL',
    action = wezterm.action.SendKey { key = 'e', mods = 'CTRL' },
  },
}

-- and finally, return the configuration to wezterm
return config
