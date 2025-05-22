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
local first_switch_check = true

local state = {
    target_peak = mp.get_property_native("target-peak"),
    target_contrast = mp.get_property_native("target_contrast"),
    colorspace_hint = mp.get_property_native("target-colorspace-hint"),
    inverse_mapping = mp.get_property_native("inverse-tone-mapping")
}

local function run_hdrcmd(arg)
    local result = mp.command_native({
        name = "subprocess",
        args = { HDRCmd, arg },
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
    })
    if result.status ~= 0 then
        msg.error("HDRCmd execution failed:", result.error or "unknown")
        return false
    end
    return result.stdout
end

local function query_hdr_state()
    local res = run_hdrcmd("status")
    if not res then return end
    if res:match("HDR is on") then
        hdr_active = true
        hdr_invalid = false
    elseif res:match("HDR is off") then
        hdr_active = false
        hdr_invalid = false
    else
        hdr_invalid = true
    end
end

local function switch_display_mode(enable)
    if enable == hdr_active then return end
    local arg = enable and "on" or "off"
    local res = run_hdrcmd(arg)
    if res then
        hdr_active = enable
        msg.info("Switched HDR display to: ", arg:upper())
    end
end

local function apply_hdr_settings()
    mp.set_property_native("target-peak", o.target_peak)
    mp.set_property_native("target-contrast", o.target_contrast)
    mp.set_property_native("target-colorspace-hint", "yes")
    mp.set_property_native("inverse-tone-mapping", "no")
end

local function apply_sdr_settings()
    mp.set_property_native("target-peak", "203")
    mp.set_property_native("target-colorspace-hint", "no")
end

local function reset_target_settings()
    mp.set_property_native("target-peak", state.target_peak)
    mp.set_property_native("target-contrast", state.target_contrast)
    mp.set_property_native("target-colorspace-hint", state.colorspace_hint)
    mp.set_property_native("inverse-tone-mapping", state.inverse_mapping)
end

local function should_switch_hdr(hdr_active, is_fullscreen)
    if o.hdr_mode ~= "switch" then return false end
    if not hdr_active and (not o.fullscreen_only or is_fullscreen) then
        return true
    elseif hdr_active and o.fullscreen_only and not is_fullscreen then
        return true
    end
    return false
end

local function switch_hdr()
    local params = mp.get_property_native("video-params")
    local gamma = params and params["gamma"]
    local max_luma = params and params["max-luma"]
    local is_hdr = max_luma and max_luma > 203
    if not gamma then return end
    local current_state = is_hdr and "hdr" or "sdr"

    local pause_changed = false
    local paused = mp.get_property_native("pause")
    local fullscreen = mp.get_property_native("fullscreen")
    local maximized = mp.get_property_native("window-maximized")
    local target_peak = mp.get_property_native("target-peak")
    local is_fullscreen = fullscreen or maximized
    if current_state == "hdr" then
        if first_switch_check and o.fullscreen_only and not is_fullscreen then
            first_switch_check = false
        elseif should_switch_hdr(hdr_active, is_fullscreen) then
            if not paused then
                mp.set_property_native("pause", true)
                pause_changed = true
            end
            msg.info("Switching to HDR output...")
            switch_display_mode(true)
        end
        if hdr_active and o.hdr_mode ~= "noth" then
            if not paused and pause_changed then
                mp.add_timeout(3.5, function()
                    mp.set_property_native("pause", false)
                end)
            end
            apply_hdr_settings()
        end
        if not hdr_active and o.hdr_mode ~= "noth" and tonumber(target_peak) ~= 203 then
            apply_sdr_settings()
        end
    elseif current_state == "sdr" then
        if hdr_active and o.hdr_mode == "switch" and (not o.fullscreen_only or is_fullscreen) then
            if not paused then
                mp.set_property_native("pause", true)
                pause_changed = true
            end
            msg.info("Switching back to SDR output...")
            switch_display_mode(false)
        end
        if (not hdr_active or o.hdr_mode ~= "noth") and hdr_invalid == false
        and last_luma_state == "hdr" then
            if not paused and pause_changed then
                mp.add_timeout(3.5, function()
                    mp.set_property_native("pause", false)
                end)
            end
            if not hdr_active or (not state.inverse_mapping and tonumber(target_peak) ~= 203) then
                apply_sdr_settings()
            elseif hdr_active and state.inverse_mapping then
                reset_target_settings()
            end
        end
        if hdr_active and o.hdr_mode == "pass" and state.inverse_mapping then
            reset_target_settings()
        end
    end
    last_luma_state = current_state
end

local function check_paramet()
    local target_peak = mp.get_property_native("target-peak")
    local target_contrast = mp.get_property_native("target-contrast")
    local colorspace_hint = mp.get_property_native("target-colorspace-hint")
    local inverse_mapping = mp.get_property_native("inverse-tone-mapping")
    local params = mp.get_property_native("video-params")
    local gamma = params and params["gamma"]
    local max_luma = params and params["max-luma"]
    local is_hdr = max_luma and max_luma > 203
    if not gamma or not is_hdr then return end

    query_hdr_state()
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
        if inverse_mapping then
            mp.set_property_native("inverse-tone-mapping", "no")
        end
    end
    if not hdr_active and o.hdr_mode ~= "noth"
    and target_peak ~= "auto" and tonumber(target_peak) ~= 203 then
        apply_sdr_settings()
    end
end

local function on_start()
    if o.hdr_mode == "noth" or tonumber(o.target_peak) <= 203 then
        return
    end
    local vo = mp.get_property("vo")
    if vo and vo ~= "gpu-next" then
        msg.warn("The current video output is not supported, please use gpu-next")
        return
    end
    query_hdr_state()
    mp.observe_property("video-params", "native", switch_hdr)
    mp.observe_property("target-peak", "native", check_paramet)
    mp.observe_property("target-contrast", "native", check_paramet)
    mp.observe_property("target-colorspace-hint", "native", check_paramet)
    if o.fullscreen_only then
        mp.observe_property("fullscreen", "native", switch_hdr)
        mp.observe_property("window-maximized", "native", switch_hdr)
    end
end

local function on_end()
    first_switch_check = true
    mp.unobserve_property(switch_hdr)
    mp.unobserve_property(check_paramet)
end

local function on_idle(_, active)
    query_hdr_state()
    local target_peak = mp.get_property_native("target-peak")
    if active and hdr_active and o.hdr_mode ~= "noth" and tonumber(target_peak) ~= 203 then
        apply_sdr_settings()
        last_luma_state = nil
    end
end

local function on_shutdown()
    if hdr_active and o.hdr_mode == "switch" then
        msg.info("Restoring display to SDR on shutdown")
        switch_display_mode(false)
    end
end

mp.register_event("start-file", on_start)
mp.register_event("end-file", on_end)
mp.observe_property("idle-active", "native", on_idle)
mp.register_event("shutdown", on_shutdown)
