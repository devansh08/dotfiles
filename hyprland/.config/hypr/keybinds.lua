local mainMod = "SUPER"

-- ========================
---- KEYBINDS ----
-- ========================

-- Kill active window
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

-- Exit Hyprland
hl.bind(
  mainMod .. " + SHIFT + M",
  hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

-- Terminal (kitty)
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))

-- Floating kitty
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("[float on; size 1920 1080; center on] kitty"))

-- File manager (yazi)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("~/.bin/hypr-float 'yazi' 'kitty -- yazi'"))

-- Music player (cliamp)
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.bin/hypr-float 'cliamp' 'kitty -- cliamp'"))

-- Launcher - rofi drun
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("rofi -show drun"))

-- Run mode - rofi
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -no-show-icons -show run"))

-- Power menu
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd('rofi -show powermenu -modi "powermenu:~/.bin/rofi-power-menu"'))

-- Color picker
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker --autocopy --format=hex"))

-- Clipboard picker
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd('rofi -show clipboard -modi "clipboard:~/.bin/rofi-cliphist"'))

-- Lock screen & suspend
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock & sleep 1 && systemctl suspend"))

-- Fullscreen toggle
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }))

-- Toggle floating
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

-- Dwindle: toggle split
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Dwindle: rotate split
hl.bind(mainMod .. " + K", hl.dsp.layout("rotatesplit 90"))

-- Workspace switching (global)
for i = 1, 10 do
  local key = i == 10 and "0" or tostring(i)
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))

-- ========================
---- SUBMAP: window ----
-- ========================

hl.bind(mainMod .. " + SHIFT + W", hl.dsp.submap("window"))
hl.define_submap("window", function()
  -- Swap windows with SHIFT+arrows
  hl.bind("left", hl.dsp.window.swap({ direction = "l" }))
  hl.bind("right", hl.dsp.window.swap({ direction = "r" }))
  hl.bind("up", hl.dsp.window.swap({ direction = "u" }))
  hl.bind("down", hl.dsp.window.swap({ direction = "d" }))

  -- Move group window forward
  hl.bind("S", hl.dsp.group.move_window({ forward = true }))

  -- Resize active window with ALT+arrows
  hl.bind("ALT + left", hl.dsp.window.resize({ x = -10, y = 0 }))
  hl.bind("ALT + right", hl.dsp.window.resize({ x = 10, y = 0 }))
  hl.bind("ALT + up", hl.dsp.window.resize({ x = 0, y = -10 }))
  hl.bind("ALT + down", hl.dsp.window.resize({ x = 0, y = 10 }))

  -- Center active window
  hl.bind("CTRL + C", hl.dsp.window.center())

  -- Exit submap (back to normal)
  hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Navigate windows with hypr-nav
hl.bind(mainMod .. " + left", hl.dsp.exec_cmd("~/.bin/hypr-nav l"))
hl.bind(mainMod .. " + right", hl.dsp.exec_cmd("~/.bin/hypr-nav r"))
hl.bind(mainMod .. " + up", hl.dsp.exec_cmd("~/.bin/hypr-nav u"))
hl.bind(mainMod .. " + down", hl.dsp.exec_cmd("~/.bin/hypr-nav d"))

-- Cycle next window
hl.bind(mainMod .. " + GRAVE", hl.dsp.window.cycle_next({ next = true }))

-- Group management
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.lock_active({ action = "toggle" }))
hl.bind(mainMod .. " + CTRL + SHIFT + G", hl.dsp.window.move({ out_of_group = true }))

-- Move into group
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ into_group = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ into_group = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ into_group = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ into_group = "d" }))

-- Change group active window
hl.bind(mainMod .. " + COMMA", hl.dsp.group.prev())
hl.bind(mainMod .. " + PERIOD", hl.dsp.group.next())

-- Previous workspace (in submap context)
hl.bind(mainMod .. " + CTRL + left", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "+1" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + BACKSPACE", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + SHIFT + BACKSPACE", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Mouse move/resize windows
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m output -m active -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { repeating = true })

-- Player controls
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
