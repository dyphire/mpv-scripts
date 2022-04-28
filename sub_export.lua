-- SOURCE: https://github.com/kelciour/mpv-scripts/blob/master/sub-export.lua
-- COMMIT: 29 Aug 2018 5039d8b
--
-- Usage:
-- add bindings to input.conf:
-- X   script-message-to sub_export export-selected-subtitles
--
--  Note:
--     Requires FFmpeg in PATH environment variable or edit ffmpeg_path in the script options,
--     for example, by replacing "ffmpeg" with "C:\Programs\ffmpeg\bin\ffmpeg.exe"
--  Note: 
--     A small circle at the top-right corner is a sign that export is happenning now.
--  Note:
--     The exported subtitles will be automatically selected with visibility set to true. 
--  Note: 
--     It could take ~1-5 minutes to export subtitles.

local msg = require 'mp.msg'
local utils = require 'mp.utils'
local options = require "mp.options"

---- Script Options ----
local o = {
    ffmpeg_path = "ffmpeg"
}

options.read_options(o)
------------------------

function export_selected_subtitles()
    local i = 0
    local tracks_count = mp.get_property_number("track-list/count")
    while i < tracks_count do
        local track_type = mp.get_property(string.format("track-list/%d/type", i))
        local track_index = mp.get_property_number(string.format("track-list/%d/ff-index", i))
        local track_selected = mp.get_property(string.format("track-list/%d/selected", i))
        local track_title = mp.get_property(string.format("track-list/%d/title", i))
        local track_lang = mp.get_property(string.format("track-list/%d/lang", i))
        local track_external = mp.get_property(string.format("track-list/%d/external", i))
        local track_codec = mp.get_property(string.format("track-list/%d/codec", i))
        local path = mp.get_property('path')
        local dir, filename = utils.split_path(path)
        local fname = mp.get_property("filename/no-ext")
        local index = string.format("0:%d", track_index)

        if track_type == "sub" and track_selected == "yes" then
            if track_external == "yes" then
                msg.info("Error: external subtitles have been selected")
                mp.osd_message("Error: external subtitles have been selected", 2)
                return
            end

            local video_file = dir .. filename

            local subtitles_ext = ".srt"
            if string.match(track_codec, "ass") ~= nil then
                subtitles_ext = ".ass"
            elseif string.match(track_codec, "pgs") ~= nil then
                subtitles_ext = ".sup"
            end

            if track_lang ~= nil then
                if track_title ~= nil then
                    subtitles_ext = "." .. track_title .. "." .. track_lang .. subtitles_ext
                else 
                    subtitles_ext = "." .. track_lang .. subtitles_ext
                end
            end
            
            subtitles_file = dir .. fname .. subtitles_ext

            msg.info("Exporting selected subtitles")
            mp.osd_message("Exporting selected subtitles")

            cmd = string.format("%s -y -hide_banner -loglevel error -i '%s' -map '%s' -vn -an -c:s copy '%s'", o.ffmpeg_path, video_file, index, subtitles_file)
            args =  { 'powershell', '-NoProfile', '-Command', cmd }  

            mp.add_timeout(mp.get_property_number("osd-duration") * 0.001, process)

            break
        end

        i = i + 1
    end
end

function process()
    local screenx, screeny, aspect = mp.get_osd_size()

    mp.set_osd_ass(screenx, screeny, "{\\an9}● ")
    local res = mp.command_native({name = "subprocess", capture_stdout = true, playback_only = false, args = args})
    mp.set_osd_ass(screenx, screeny, "")
    if res.status == 0 then
        msg.info("Finished exporting subtitles")
        mp.osd_message("Finished exporting subtitles")
        mp.commandv("sub-add", subtitles_file)
        mp.set_property("sub-visibility", "yes")
    else
        msg.info("Failed to export subtitles")
        mp.osd_message("Failed to export subtitles, check console for more info.")
    end
end

mp.register_script_message("export-selected-subtitles", export_selected_subtitles)
