local files = {}
local fileIndex = 0

swayimg.on_initialized(function()
  local handle = io.popen("/bin/ls -1 | /bin/grep -E '(png|jpg|jpeg|gif)'")
  if handle then
    for line in handle:lines() do
      table.insert(files, line)
      local fileName = swayimg.viewer.get_image().path
      fileName = fileName:match("^.+/(.+)$")
      if swayimg.get_mode() == "viewer" and fileName == line then
        fileIndex = #files
      end
    end
    handle:close()
  end
  swayimg.viewer.set_text("topright", { fileIndex .. " / " .. #files, "{frame.index} / {frame.total}" })
end)

swayimg.set_mode("viewer")
swayimg.enable_antialiasing(false)

swayimg.viewer.set_window_background(0xff1e1e2e)
swayimg.viewer.limit_history(1)
swayimg.viewer.limit_preload(1)
swayimg.viewer.set_drag_button("MouseLeft")
swayimg.viewer.set_text("topleft", { "{name}", "{format}", "{sizehr}", "{frame.width} x {frame.height}" })
swayimg.viewer.set_text("bottomleft", { "{scale}" })

swayimg.text.set_font("JetBrainsMonoNL Nerd Font Mono")
swayimg.text.set_size(18)
swayimg.text.set_foreground(0xffcdd6f4)
swayimg.text.set_timeout(5)
swayimg.text.set_status_timeout(3)

swayimg.viewer.on_key("Return", function()
  swayimg.set_mode("gallery")
end)
swayimg.viewer.on_key("Left", function()
  fileIndex = (fileIndex - 1) % #files
  if fileIndex == 0 then
    fileIndex = #files
  end
  swayimg.viewer.open(files[fileIndex])
  swayimg.viewer.set_text("topright", { fileIndex .. " / " .. #files, "{frame.index} / {frame.total}" })
end)
swayimg.viewer.on_key("Right", function()
  fileIndex = (fileIndex + 1) % #files
  if fileIndex == 0 then
    fileIndex = #files
  end
  swayimg.viewer.open(files[fileIndex])
  swayimg.viewer.set_text("topright", { fileIndex .. " / " .. #files, "{frame.index} / {frame.total}" })
end)
swayimg.viewer.on_key("[", function()
  swayimg.viewer.prev_frame()
end)
swayimg.viewer.on_key("]", function()
  swayimg.viewer.next_frame()
end)
swayimg.viewer.on_key("f", function()
  swayimg.set_fullscreen()
end)
swayimg.viewer.on_key("equal", function()
  local scale = swayimg.viewer.get_scale()
  swayimg.viewer.set_abs_scale(scale + scale / 10)
end)
swayimg.viewer.on_key("minus", function()
  local scale = swayimg.viewer.get_scale()
  swayimg.viewer.set_abs_scale(scale - scale / 10)
end)
swayimg.viewer.on_key("a", function()
  swayimg.enable_antialiasing(true)
end)
swayimg.viewer.on_key("A", function()
  swayimg.enable_antialiasing(false)
end)
swayimg.viewer.on_key("Shift+Delete", function()
  os.remove(swayimg.viewer.get_image().path)
end)
swayimg.viewer.on_key("i", function()
  if swayimg.text.visible() then
    swayimg.text.hide()
  else
    swayimg.text.show()
  end
end)
swayimg.viewer.on_key("Shift+q", function()
  swayimg.exit()
end)

swayimg.viewer.on_mouse("Ctrl+ScrollUp", function()
  local mouse = swayimg.get_mouse_pos()
  local scale = swayimg.viewer.get_scale()
  swayimg.viewer.set_abs_scale(scale + scale / 10, mouse.x, mouse.y)
end)
swayimg.viewer.on_mouse("Ctrl+ScrollDown", function()
  local mouse = swayimg.get_mouse_pos()
  local scale = swayimg.viewer.get_scale()
  swayimg.viewer.set_abs_scale(scale - scale / 10, mouse.x, mouse.y)
end)
