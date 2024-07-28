local wezterm = require("wezterm")

local act = wezterm.action

local config = {}

config.enable_wayland = true

config.check_for_updates = false
config.show_update_window = false

-- Check for 'wezterm' https://wezfurlong.org/wezterm/config/lua/config/term.html
config.term = "xterm-256color"

config.daemon_options = nil

config.font = wezterm.font({ family = "JetBrainsMonoNL Nerd Font Mono", weight = "Light", scale = 1.0 })
-- config.font = wezterm.font({ family = "ComicShannsMono Nerd Font Mono", scale = 1.0 })
config.font_size = 14
config.bold_brightens_ansi_colors = "BrightAndBold"
config.color_scheme = "Catppuccin Mocha"
config.custom_block_glyphs = true
config.line_height = 1.0
config.unicode_version = 14
config.warn_about_missing_glyphs = false

config.enable_csi_u_key_encoding = true

config.animation_fps = 1
config.cursor_blink_rate = 0
config.default_cursor_style = "SteadyBlock"
config.hide_mouse_cursor_when_typing = true

config.audible_bell = "Disabled"

config.quote_dropped_files = "SpacesOnly"

config.automatically_reload_config = true

config.enable_tab_bar = false
config.enable_scroll_bar = false

config.prefer_to_spawn_tabs = false
config.quit_when_all_windows_are_closed = true
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "TITLE | RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.default_prog = { "/home/devansh/.bin/tmux-default" }
config.default_cwd = "/home/devansh"

for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
	if gpu.backend == "Vulkan" and gpu.device_type == "IntegratedGpu" then
		config.webgpu_preferred_adapter = gpu
		config.front_end = "WebGpu"
		break
	end
end

config.disable_default_key_bindings = true
config.disable_default_mouse_bindings = true
config.keys = {
	{ key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
	{ key = "+", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "+", mods = "SHIFT|CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "-", mods = "SHIFT|CTRL", action = act.DecreaseFontSize },
	{ key = "-", mods = "SUPER", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },
	{ key = "0", mods = "SHIFT|CTRL", action = act.ResetFontSize },
	{ key = "C", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
	{ key = "F", mods = "SHIFT|CTRL", action = act.Search("CurrentSelectionOrEmptyString") },
	{ key = "K", mods = "SHIFT|CTRL", action = act.ClearScrollback("ScrollbackOnly") },
	{ key = "L", mods = "SHIFT|CTRL", action = act.ShowDebugOverlay },
	{ key = "N", mods = "SHIFT|CTRL", action = act.SpawnWindow },
	{ key = "P", mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
	{ key = "R", mods = "SHIFT|CTRL", action = act.ReloadConfiguration },
	{
		key = "U",
		mods = "SHIFT|CTRL",
		action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
	},
	{ key = "V", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
}

return config
