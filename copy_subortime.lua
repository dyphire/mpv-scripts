-- copy-subortime (Windows version)

-- Copies current timecode in HH:MM:SS.MS format to clipboard

-------------------------------------------------------------------------------
-- Script adapted by Alex Rogers (https://github.com/linguisticmind)
-- Modified from https://github.com/Arieleg/mpv-copyTime
-- Released under GNU GPL 3.0

-- Usage, add bindings to input.conf:
-- key    script-message-to copy_subortime copy-time
-- key    script-message-to copy_subortime copy-subtitle

require "mp"

local function set_clipboard (text)
  local echo
  if text ~= "" then
    for i = 1, 2 do text = text:gsub("[%^&\\<>|]", "^%0") end
    echo = "(echo " .. text:gsub("\n", " & echo ") .. ")"
  else
    echo = "echo:"
  end
  mp.commandv("run", "cmd.exe", "/d", "/c", echo .. " | clip")
end

local function copy_time()
  local time_pos = mp.get_property_number("time-pos")
  local time_in_seconds = time_pos
  local time_seg = time_pos % 60
  time_pos = time_pos - time_seg
  local time_hours = math.floor(time_pos / 3600)
  time_pos = time_pos - (time_hours * 3600)
  local time_minutes = time_pos/60
  time_seg,time_ms=string.format("%.03f", time_seg):match"([^.]*).(.*)"
  time = string.format("%02d:%02d:%02d.%s", time_hours, time_minutes, time_seg, time_ms)
  set_clipboard(time)
  mp.osd_message(string.format("已复制当前时间: %s", time))
end

local function copy_subtitle ()
  local subtitle = mp.get_property("sub-text")
  set_clipboard(subtitle)
  mp.osd_message("已复制当前字幕内容")
end

mp.register_script_message("copy-time", copy_time)
mp.register_script_message("copy-subtitle", copy_subtitle)