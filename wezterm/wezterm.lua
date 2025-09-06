-- Pull in the wezterm API
local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- config.font = wezterm.font("Monaspace Krypton")
-- config.font = wezterm.font_with_fallback({ "Monaspace Krypton", "Noto Color Emoji" })
-- config.font = wezterm.font_with_fallback({ "TX-02", "Noto Color Emoji" })
-- config.font = wezterm.font_with_fallback({ "MonoLisa", "Noto Color Emoji" })
-- config.font = wezterm.font_with_fallback({ { family = "Operator Mono", weight = "Light" }, "Noto Color Emoji" })
-- config.font = wezterm.font("MonoLisa")
-- config.font = wezterm.font_with_fallback({ "Gintronic", "Noto Color Emoji" })
config.font = wezterm.font_with_fallback({ "TX-02", "Noto Color Emoji" })

config.font_size = 14

config.color_scheme = "carbonfox"

config.freetype_load_flags = "NO_HINTING"

config.leader = { key = "e", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "n",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
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
}

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 100

tabline.setup({
	options = {
		icons_enabled = true,
		tabs_enabled = true,
		theme = "carbonfox",
		theme_overrides = {},
		section_separators = "",
		component_separators = "",
		tab_separators = "",
	},
	sections = {
		tabline_a = { "" },
		tabline_b = { "" },
		tabline_c = { "" },
		tab_active = {
			"index",
			{ "cwd", padding = { left = 0, right = 1 } },
		},
		tab_inactive = { "index", { "cwd", padding = { left = 0, right = 1 } } },
		tabline_x = { "ram", "cpu" },
		tabline_y = { "battery" },
		tabline_z = { "datetime" },
	},
	extensions = {},
})

for i = 1, 8 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL|ALT",
		action = wezterm.action.MoveTab(i - 1),
	})
end

-- Finally, return the configuration to wezterm:
return config
