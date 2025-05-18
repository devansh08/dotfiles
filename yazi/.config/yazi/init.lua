function Linemode:mtime_custom()
  ---@type integer
  local time = math.floor(self._file.cha.mtime or 0)
  if time == 0 then
    return ""
  elseif os.date("%Y", tonumber(time)) == os.date("%Y") then
    return os.date("%b %d %H:%M", time)
  else
    return os.date("%b %d  %Y", time)
  end
end
