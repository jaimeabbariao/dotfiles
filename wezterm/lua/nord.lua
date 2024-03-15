local M = {}

local polar_night = {
	nord0 = "#2E3440",
	nord1 = "#3B4252",
	nord2 = "#434C5E",
	nord3 = "#4C566A",
}

local snow_storm = {
	nord4 = "#D8DEE9",
	nord5 = "#E5E9F0",
	nord6 = "#ECEFF4",
}

local frost = {
	nord7 = "#8FBCBB",
	nord8 = "#88C0D0",
	nord9 = "#81A1C1",
	nord10 = "#5E81AC",
}

local aurora = {
	red = "#BF616A",
	orange = "#D08770",
	yellow = "#EBCB8B",
	green = "#A3BE8C",
	purple = "#B48EAD",
}

local inactive_tab = {
	bg_color = polar_night.nord1,
	fg_color = snow_storm.nord4,
}

local active_tab = {
	bg_color = aurora.green,
	fg_color = polar_night.nord0,
}

function M.colors()
	return {
		foreground = snow_storm.nord4,
		background = polar_night.nord0,
		cursor_bg = snow_storm.nord6,
		cursor_fg = "#282828",
		selection_bg = snow_storm.nord6,
		selection_fg = polar_night.nord3,
		ansi = {
			polar_night.nord1,
			aurora.red,
			aurora.green,
			aurora.yellow,
			frost.nord9,
      aurora.purple,
			frost.nord8,
			snow_storm.nord5,
		},
		brights = {
			polar_night.nord3,
			aurora.red,
			aurora.green,
			aurora.yellow,
			frost.nord9,
			aurora.purple,
			frost.nord7,
			snow_storm.nord6,
		},
		tab_bar = {
			background = polar_night.nord0,
			active_tab = active_tab,
			inactive_tab = inactive_tab,
			inactive_tab_hover = active_tab,
			new_tab = inactive_tab,
			new_tab_hover = active_tab,
      inactive_tab_edge = polar_night.nord2
		},
	}
end

function M.window_frame()
  return {
    active_titlebar_bg = polar_night.nord0,
    inactive_titlebar_bg = polar_night.nord0
  }
end

return M
