--[[
    When switching the audio track, if there is audio filter then seek to repair the freezing of video.
    available at: https://github.com/dyphire/mpv-scripts
]]--

local mp = require "mp"
local msg = require "mp.msg"

function fix_af_out ()
  local afs = mp.get_property_native("af")
  for _, af in pairs(afs) do
    if af["name"] ~= nil and af["name"] ~= "" then
      msg.info("fix af out.")
      mp.command("no-osd seek  0.1 exact")
      mp.command("no-osd seek -0.1 exact")
    end
  end
end

mp.observe_property("aid", "string", fix_af_out)