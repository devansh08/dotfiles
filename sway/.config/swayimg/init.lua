local theme = require("theme")

local files = {}
local fileIndex = 0

swayimg.on_initialized(function()
  local handle = io.popen("/bin/ls -1 | /bin/grep -E '(png|jpg|jpeg|gif)'")
  if handle then
    for line in handle:lines() do
      table.insert(files, line)
      local fileName = swayimg.viewer.get_image().path
      fileName = fileName:match("^.+/(.+)$")
      if swayimg.mode == "viewer" and fileName == line then
        fileIndex = #files
      end
    end
    handle:close()
  end
  swayimg.viewer.set_text("topright", { fileIndex .. " / " .. #files, "{frame.index} / {frame.total}" })
end)

swayimg.mode = "viewer"
swayimg.antialiasing = false

swayimg.viewer.set_window_background(theme["bg_main"])
swayimg.viewer.history = 1
swayimg.viewer.preload = 1
swayimg.viewer.drag_button = "MouseLeft"
swayimg.viewer.set_text("topleft", { "{name}", "{format}", "{sizehr}", "{frame.width} x {frame.height}" })
swayimg.viewer.set_text("bottomleft", { "{scale}" })

swayimg.text.font = "JetBrainsMonoNL Nerd Font Mono"
swayimg.text.size = 18
swayimg.text.color = theme["fg_main"]
swayimg.text.timeout = 5
swayimg.text.status_timeout = 3

swayimg.viewer.on_key("Return", function()
  swayimg.mode = "gallery"
end)
swayimg.viewer.on_key("Ctrl+Left", function()
  fileIndex = (fileIndex - 1) % #files
  if fileIndex == 0 then
    fileIndex = #files
  end
  -- swayimg.viewer.open(files[fileIndex])
  swayimg.viewer.open("prev")
  swayimg.viewer.set_text("topright", { fileIndex .. " / " .. #files, "{frame.index} / {frame.total}" })
end)
swayimg.viewer.on_key("Ctrl+Right", function()
  fileIndex = (fileIndex + 1) % #files
  if fileIndex == 0 then
    fileIndex = #files
  end
  -- swayimg.viewer.open(files[fileIndex])
  swayimg.viewer.open("next")
  swayimg.viewer.set_text("topright", { fileIndex .. " / " .. #files, "{frame.index} / {frame.total}" })
end)
swayimg.viewer.on_key("[", function()
  swayimg.viewer.frame = swayimg.viewer.frame - 1
end)
swayimg.viewer.on_key("]", function()
  swayimg.viewer.frame = swayimg.viewer.frame + 1
end)
swayimg.viewer.on_key("f", function()
  swayimg.fullscreen = not swayimg.fullscreen
end)
swayimg.viewer.on_key("equal", function()
  local scale = swayimg.viewer.scale
  swayimg.viewer.set_abs_scale(scale + scale / 10)
end)
swayimg.viewer.on_key("minus", function()
  local scale = swayimg.viewer.scale
  swayimg.viewer.set_abs_scale(scale - scale / 10)
end)
swayimg.viewer.on_key("a", function()
  swayimg.antialiasing = not swayimg.antialiasing
end)
swayimg.viewer.on_key("Shift+Delete", function()
  os.remove(swayimg.viewer.get_image().path)
end)
swayimg.viewer.on_key("i", function()
  swayimg.text.visible = not swayimg.text.visible
end)
swayimg.viewer.on_key("Shift+q", function()
  swayimg.exit()
end)

swayimg.viewer.on_mouse("Ctrl+ScrollUp", function()
  local mouse = swayimg.get_mouse_pos()
  local scale = swayimg.viewer.scale
  swayimg.viewer.set_abs_scale(scale + scale / 10, mouse.x, mouse.y)
end)
swayimg.viewer.on_mouse("Ctrl+ScrollDown", function()
  local mouse = swayimg.get_mouse_pos()
  local scale = swayimg.viewer.scale
  swayimg.viewer.set_abs_scale(scale - scale / 10, mouse.x, mouse.y)
end)
