local M = {}

local palette = {
	fg = "#c0caf5",
	bg = "#1a1b26",
	cursor_bg = "#c0caf5",
	cursor_border = "#c0caf5",
	cursor_fg = "#1a1b26",
	selection_bg = "#283457",
	selection_fg = "#c0caf5",
}

local ansi = { "#15161e", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6" }
local brights = { "#414868", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5" }

local tab_bar = {
	inactive_tab_edge = "#16161e",
	background = "#191b28",
}

local active_tab = {
	fg_color = "#7aa2f7",
	bg_color = "#1a1b26",
}

local inactive_tab = {
	bg_color = "#16161e",
	fg_color = "#545c7e",
}

local inactive_tab_hover = {
	bg_color = "#16161e",
	fg_color = "#7aa2f7",
}

local new_tab = {
	fg_color = "#7aa2f7",
	bg_color = "#191b28",
}

local new_tab_hover = {
	bg_color = "#16161e",
	fg_color = "#7aa2f7",
}

function M.colors()
	return {
		foreground = palette.fg,
		background = palette.bg,
		cursor_bg = palette.cursor_bg,
		cursor_border = palette.cursor_border,
		cursor_fg = palette.cursor_fg,
		selection_bg = palette.selection_bg,
		selection_fg = palette.selection_fg,
		ansi = ansi,
		brights = brights,
		tab_bar = {
			background = tab_bar.background,
			inactive_tab_edge = tab_bar.inactive_tab_edge,
			active_tab = active_tab,
			inactive_tab = inactive_tab,
			inactive_tab_hover = inactive_tab_hover,
			new_tab = new_tab,
			new_tab_hover = new_tab_hover,
		},
	}
end

function M.window_frame()
	return {
		active_titlebar_bg = palette.background,
		inactive_titlebar_bg = palette.background,
	}
end

return M
