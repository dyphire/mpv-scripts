-- Copyright (c) 2025 dyphire <qimoge@gmail.com>
-- License: MIT
-- link: https://github.com/dyphire/mpv-scripts
-- Automatically switches the display's SDR and HDR modes for HDR passthrough
-- based on the content of the video being played by the mpv, only works on Windows 10 and later systems

local msg = require 'mp.msg'
local utils = require 'mp.utils'
local options = require 'mp.options'

local o = {
    -- Specify the script working mode, value: noth, pass, switch. default: noth
    -- noth: Do nothing
    -- pass: Passing HDR signals for HDR content when the monitor is in HDR mode
    -- switch: Automatically switch between HDR displays and SDR displays
    -- on Windows 10 and later based on video specifications
    hdr_mode = "noth",
    -- Specify whether to switch HDR mode only when the window is in fullscreen or window maximized
    -- only works with hdr_mode = "switch", default: false
    fullscreen_only = false,
    -- Specify the target peak of the HDR display, default: 203
    -- must be the true peak brightness of the monitor,
    -- otherwise it will cause HDR content to display incorrectly
    target_peak = "203",
    -- Specifies the measured contrast of the output display.
    -- Used in black point compensation during HDR tone-mapping and HDR passthrough.
    -- Must be the true contrast information of the display, e.g. 100000 means 100000:1 maximum contrast
    -- OLED display do not need to change this, default: auto
    target_contrast = "auto",
    -- Specify the path of HDRCmd executable, you can download it from here:
    -- https://github.com/res2k/HDRTray
    -- Supports absolute and relative paths
    HDRCmd_path = "HDRCmd",
}
options.read_options(o, _, function() end)

local HDRCmd = mp.command_native({ "expand-path", o.HDRCmd_path })
local hdr_active = false
local hdr_invalid = nil
local last_luma_state = nil
local current_state = nil

local state = {
    target_peak = mp.get_property_native("target-peak"),
    target_contrast = mp.get_property_native("target_contrast"),
    colorspace_hint = mp.get_property_native("target-colorspace-hint"),
}

local function switch_display_mode(arg)
    local args = { HDRCmd, arg }
    local result = mp.command_native({
        name = "subprocess",
        args = args,
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
    })
    if result.status == 0 then
        if arg == "on" then
            hdr_active = true
            msg.info("HDR Display is on")
        else
            hdr_active = false
            msg.info("HDR Display is off")
        end
    else
        msg.error("HDRCmd execution failed: ", result.error)
    end
end

local function runHDRCmd(check)
    local args = { HDRCmd, "status" }

    local result = mp.command_native({
        name = "subprocess",
        args = args,
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
    })

    if result.status == 0 then
        if result.stdout:match("HDR is off") then
            hdr_invalid = false
            if not check then
                switch_display_mode("on")
            end
        elseif result.stdout:match("HDR is on") then
            hdr_invalid = false
            if not check then
                switch_display_mode("off")
            else
                hdr_active = true
            end
        else
            hdr_invalid = true
        end
    else
        msg.error("HDRCmd execution failed: ", result.error)
    end
end

local function switch_hdr()
    local params = mp.get_property_native("video-params")
    local gamma = params and params["gamma"]
    local max_luma = params and params["max-luma"]
    local is_hdr = max_luma and max_luma > 203
    if not gamma then return end

    if is_hdr then
        current_state = "hdr"
    else
        current_state = "sdr"
    end

    if current_state == last_luma_state then
        return
    end

    local pause_changed = false
    local paused = mp.get_property_native("pause")
    local fullscreen = mp.get_property_native("fullscreen")
    local maximized = mp.get_property_native("window-maximized")
    local inverse_mapping = mp.get_property_native("inverse-tone-mapping")
    local is_fullscreen = fullscreen or maximized
    if current_state == "hdr" then
        if not hdr_active and o.hdr_mode == "switch" and not o.fullscreen_only or is_fullscreen then
            if not paused then
                mp.set_property_native("pause", true)
                pause_changed = true
            end
            msg.info("Switching to HDR output...")
            runHDRCmd()
        end
        if hdr_active and o.hdr_mode ~= "noth" then
            if not paused and pause_changed then
                mp.add_timeout(3.5, function()
                    mp.set_property_native("pause", false)
                end)
            end
            mp.set_property_native("target-peak", o.target_peak)
            mp.set_property_native("target-contrast", o.target_contrast)
            mp.set_property_native("target-colorspace-hint", "yes")
        end
    elseif current_state == "sdr" then
        if hdr_active and o.hdr_mode == "switch" and not o.fullscreen_only or is_fullscreen then
            if not paused then
                mp.set_property_native("pause", true)
                pause_changed = true
            end
            msg.info("Switching back to SDR output...")
            runHDRCmd()
        end
        if (not hdr_active or o.hdr_mode ~= "noth") and hdr_invalid == false
        and last_luma_state == "hdr" then
            if not paused and pause_changed then
                mp.add_timeout(3.5, function()
                    mp.set_property_native("pause", false)
                end)
            end
            if not inverse_mapping then
                mp.set_property_native("target-peak", "203")
                mp.set_property_native("target-colorspace-hint", "no")
            else
                mp.set_property_native("target-peak", state.target_peak)
                mp.set_property_native("target-colorspace-hint", state.colorspace_hint)
            end
            mp.set_property_native("target_contrast", state.target_contrast)
        end
        if hdr_active and o.hdr_mode == "pass" and inverse_mapping then
            mp.set_property_native("target-peak", state.target_peak)
            mp.set_property_native("target-contrast", state.target_contrast)
            mp.set_property_native("target-colorspace-hint", state.colorspace_hint)
        end
    end
    if not o.fullscreen_only or is_fullscreen then
        last_luma_state = current_state
    end
end

local function check_paramet()
    local target_peak = mp.get_property_native("target-peak")
    local target_contrast = mp.get_property_native("target-contrast")
    local colorspace_hint = mp.get_property_native("target-colorspace-hint")
    local params = mp.get_property_native("video-params")
    local gamma = params and params["gamma"]
    local max_luma = params and params["max-luma"]
    local is_hdr = max_luma and max_luma > 203
    if not gamma or not is_hdr then return end

    if hdr_active and o.hdr_mode ~= "noth" and is_hdr then
        if target_peak ~= o.target_peak then
            mp.set_property_native("target-peak", o.target_peak)
        end
        if target_contrast ~= o.target_contrast then
            mp.set_property_native("target-contrast", o.target_contrast)
        end
        if colorspace_hint ~= "yes" then
            mp.set_property_native("target-colorspace-hint", "yes")
        end
    end
end

local function idle(_, active)
    runHDRCmd(true)
    if hdr_active and active and o.hdr_mode ~= "noth" then
        mp.set_property_native("target-peak", "203")
        mp.set_property_native("target-colorspace-hint", "no")
        last_luma_state = nil
    end
end

mp.observe_property("idle-active", "native", idle)

mp.register_event('start-file', function()
    if o.hdr_mode == "noth" or tonumber(o.target_peak) <= 203 then
        return
    end
    local vo = mp.get_property("vo")
    if vo and vo ~= "gpu-next" then
        msg.warn("The current video output is not supported, please use gpu-next")
        return
    end
    runHDRCmd(true)
    mp.observe_property("video-params", "native", switch_hdr)
    mp.observe_property("target-peak", "native", check_paramet)
    mp.observe_property("target-contrast", "native", check_paramet)
    mp.observe_property("target-colorspace-hint", "native", check_paramet)
    if o.fullscreen_only then
        mp.observe_property("fullscreen", "native", switch_hdr)
        mp.observe_property("window-maximized", "native", switch_hdr)
    end
end)

mp.register_event('end-file', function()
    mp.unobserve_property(switch_hdr)
    mp.unobserve_property(check_paramet)
end)
mp.register_event('shutdown', function()
    if hdr_active and o.hdr_mode == "switch" then
        msg.info("Switching back to SDR output...")
        runHDRCmd()
    end
end)