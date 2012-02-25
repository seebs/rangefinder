--[[ RangeFinder
     A rangefinder on your target frame

]]--

local RangeFinder = {}
local rf = RangeFinder
rf.frames = {
	target = { ui = UI.Native.PortraitTarget, unit = "player.target" },
	focus = { ui = UI.Native.PortraitFocus, unit = "focus" },
	targettarget = { ui = UI.Native.PortraitTargetTarget, unit = "player.target.target" },
	party1 = { ui = UI.Native.PortraitParty1, unit = "group01", loc = "TOPRIGHT" },
	party2 = { ui = UI.Native.PortraitParty2, unit = "group02", loc = "TOPRIGHT" },
	party3 = { ui = UI.Native.PortraitParty3, unit = "group03", loc = "TOPRIGHT" },
	party4 = { ui = UI.Native.PortraitParty4, unit = "group04", loc = "TOPRIGHT" },
	pet = { ui = UI.Native.PortraitPet, unit = "player.pet", loc = "TOPRIGHT" },
}

function rf.printf(fmt, ...)
  print(string.format(fmt or 'nil', ...))
end


function rf.slashcommand(args)
  if not args then
    rf.printf("Usage error.")
    return
  end
end

function rf.update()
  local me = Inspect.Unit.Detail("player")
  if not rf.ui then
    rf.ui = UI.CreateContext("RangeFinder")
  end

  if not rf.text then
    rf.text = UI.CreateFrame("Text", "RangeFinder", rf.ui)
    rf.text:SetPoint("TOPLEFT", UI.Native.PortraitTarget, "TOPLEFT")
  end
  local hiding = (not me or not me.coordX)
  for key, data in pairs(rf.frames) do
    local you = Inspect.Unit.Detail(data.unit)
    if hiding or not you or you.id == me.id then
      if data.frame then
        data.frame:SetVisible(false)
      end
    else
      if not data.frame then
	local loc = data.loc or "TOPLEFT"
        data.frame = UI.CreateFrame("Text", "RangeFinder_" .. key, rf.ui)
	data.frame:SetPoint(loc, data.ui, loc)
      end
      if data.frame then
	if me.coordX and me.coordY and me.coordZ and
	   you.coordX and you.coordY and you.coordZ then
	  local dx = me.coordX - you.coordX
	  local dy = me.coordY - you.coordY
	  local dz = me.coordZ - you.coordZ
	  local dxy = math.sqrt((dx * dx) + (dy * dy))
	  local dtotal = math.sqrt((dxy * dxy) + (dz * dz))
	  data.frame:SetText(string.format("%.2fm", dtotal))
	else
	  data.frame:SetText("--")
	end
	data.frame:SetVisible(true)
      end
    end
  end
end

Library.LibGetOpt.makeslash("", "RangeFinder", "rf", rf.slashcommand)
table.insert(Event.System.Update.Begin, { rf.update, "RangeFinder", "update hook" })
