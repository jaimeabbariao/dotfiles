local M = {}

foreground = "#a0a8cd"
background = "#11121d"
cursor_bg = "#a0a8cd"
cursor_border = "#a0a8cd"
cursor_fg = "#11121d"
selection_bg = "#11121d"
selection_fg = "#a0a8cd"

ansi = {"#06080a","#ee6d85","#95c561","#d7a65f","#7199ee","#a485dd","#38a89d","#a0a8cd"}
brights = {"#212234","#ee6d85","#95c561","#d7a65f","#7199ee","#a485dd","#38a89d","#a0a8cd"}

local aurora = {
	red = "#BF616A",
	orange = "#D08770",
	yellow = "#EBCB8B",
	green = "#A3BE8C",
	purple = "#B48EAD",
}

local inactive_tab = {
	bg_color = background,
	fg_color = "#FFFFFF",
}

local active_tab = {
  bg_color = "#023020",
  fg_color = "#FFFFFF"
}

function M.colors()
  return {
    foreground = foreground,
    background = background,
    cursor_fg = cursor_fg,
    cursor_bg = cursor_bg,
    cursor_border = cursor_border,
    selection_bg = selection_bg,
    selection_fg = selection_fg,
    ansi = ansi,
    brights = brights,
    tab_bar = {
      background = background,
			active_tab = active_tab,
			inactive_tab = inactive_tab,
			inactive_tab_hover = active_tab,
			new_tab = inactive_tab,
			new_tab_hover = active_tab,
      inactive_tab_edge = background
    }
  }
end

function M.window_frame()
  return {
    active_titlebar_bg = background,
    inactive_titlebar_bg = background
  }
end

return M
