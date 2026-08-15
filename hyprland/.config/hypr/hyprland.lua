-- Hyprland Lua Configuration
-- Split into multiple files for better organization
-- https://wiki.hypr.land/Configuring/Start/

local theme = require("mocha")

-- ========================
---- MONITORS ----
-- ========================

hl.monitor({
  output = "DP-1",
  mode = "2560x1420@74.97Hz",
  position = "0x0",
  scale = 1,
})

-- Fallback for any other monitor
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})

-- ========================
---- AUTOSTART ----
-- ========================

hl.on("hyprland.start", function()
  -- Start services
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("kanshi")
  hl.exec_cmd("waybar")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("dunst")

  -- Clipboard watcher
  hl.exec_cmd("wl-paste --watch cliphist store")

  -- Set cursor theme and size
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")

  -- Auto-launch apps on workspaces
  hl.exec_cmd("[workspace 1] kitty")
  hl.exec_cmd("[workspace 2 silent] librewolf")

  -- Start on workspace 1
  hl.exec_cmd("hyprctl dispatch workspace 1")
end)

-- ========================
---- ENVIRONMENT VARIABLES ----
-- ========================

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- ========================
---- CONFIGURATION ----
-- ========================

hl.config({
  general = {
    border_size = 4,
    gaps_in = 4,
    gaps_out = 8,
    resize_on_border = true,
    extend_border_grab_area = 4,
    hover_icon_on_border = true,
    allow_tearing = false,
    layout = "dwindle",

    col = {
      active_border = theme["border_active"],
      inactive_border = theme["border_inactive"],
    },

    snap = {
      enabled = false,
    },
  },

  decoration = {
    rounding = 0,
    dim_modal = true,
    dim_inactive = true,
    dim_strength = 0.25,
    border_part_of_window = true,

    blur = {
      enabled = false,
    },

    shadow = {
      enabled = true,
      range = 8,
      render_power = 2,
      color = theme["bg_main"],
    },
  },

  animations = {
    enabled = true,
    workspace_wraparound = true,
  },

  dwindle = {
    preserve_split = true,
    force_split = 2,
  },

  misc = {
    font_family = "JetBrainsMonoNL Nerd Font Mono",
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    disable_autoreload = false,
    middle_click_paste = true,
  },

  binds = {
    workspace_center_on = 0,
    movefocus_cycles_groupfirst = false,
    window_direction_monitor_fallback = false,
  },

  xwayland = {
    enabled = true,
  },

  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },

  input = {
    kb_layout = "us",
    numlock_by_default = true,
    repeat_rate = 30,
    repeat_delay = 300,
    sensitivity = 0,
    natural_scroll = false,
    follow_mouse = 1,
    mouse_refocus = true,

    touchpad = {
      disable_while_typing = true,
      natural_scroll = false,
      middle_button_emulation = true,
      tap_to_click = true,
      tap_and_drag = true,
    },
  },

  group = {
    auto_group = true,
    insert_after_current = true,
    focus_removed_window = true,
    drag_into_group = 1,
    merge_groups_on_drag = true,
    merge_groups_on_groupbar = true,
    merge_floated_into_tiled_on_groupbar = true,
    group_on_movetoworkspace = true,

    col = {
      border_active = theme["border_active"],
      border_inactive = theme["border_inactive"],
      border_locked_active = theme["accent_secondary"],
      border_locked_inactive = theme["status_warning"],
    },

    groupbar = {
      enabled = true,
      font_family = "JetBrainsMonoNL Nerd Font Mono",
      font_size = 18,
      font_weight_active = "bold",
      font_weight_inactive = "normal",
      height = 28,
      indicator_gap = 0,
      indicator_height = 0,
      stacked = false,
      render_titles = true,
      text_offset = 0,
      scrolling = false,
      rounding = 0,
      gradients = true,

      text_color = theme["fg_selection"],
      text_color_inactive = theme["fg_main"],
      text_color_locked_active = theme["fg_selection"],
      text_color_locked_inactive = theme["fg_main"],

      col = {
        active = theme["accent_primary"],
        inactive = theme["bg_main"],
        locked_active = theme["accent_secondary"],
        locked_inactive = theme["bg_main"],
      },

      gaps_in = 2,
      gaps_out = 2,
      keep_upper_gap = false,
    },
  },

  cursor = {
    invisible = false,
    enable_hyprcursor = true,
    sync_gsettings_theme = true,
    inactive_timeout = 0,
    persistent_warps = true,
    warp_on_change_workspace = true,
    default_monitor = "HDMI-A-1",
  },

  gestures = {
    workspace_swipe_invert = true,
  },
})

-- ========================
---- CURVES ----
-- ========================

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default spring (same as sample config)
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

-- ========================
---- ANIMATIONS ----
-- ========================

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- ========================
---- KEYBINDS ----
-- ========================

require("keybinds")

-- ========================
---- WINDOW RULES ----
-- ========================

require("windowrules")
