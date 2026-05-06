--[[
    Fixed A/V sync when switching the audio output device with using audio filters
    available at: https://github.com/dyphire/mpv-scripts
]]--

local msg = require "mp.msg"

local function is_protocol(path)
    return type(path) == 'string' and (path:find('^%a[%w.+-]-://') ~= nil or path:find('^%a[%w.+-]-:%?') ~= nil)
end


local function fix_avsync()
    local paused = mp.get_property_bool("pause")
    msg.info("fix A/V sync.")
    mp.commandv("frame-back-step")
    if paused then
        return
    else
        mp.set_property_bool("pause", false)
    end
end

mp.observe_property("current-ao", "native", function(_, device)
    local aid = mp.get_property_number("aid")
    local has_af = mp.get_property("af", "") ~= ""
    local path = mp.get_property("path")
    local time = mp.get_property_native("time-pos")
    if device and aid and has_af and time > 0 and not is_protocol(path) then
        fix_avsync()
    end
end)