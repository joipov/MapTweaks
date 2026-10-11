-- Adapted from Tweaks Forever by cjber, GPL-3.0-or-later.
-- https://github.com/cjber/tweaks-forever
-- The zone under the cursor gets its level range, colored like a quest level.
local _, ns = ...

local function Range(mapID)
	local low, high = C_Map.GetMapLevels(mapID)
	if low and high and low > 0 and high > 0 then
		return low, high
	end
	local range = ns.ZoneRanges[mapID]
	if range then
		return range[1], range[2]
	end
end

local function Text(low, high)
	if low == high then
		return tostring(low)
	end
	return low .. "-" .. high
end

-- The bottom of a zone above you, your level inside one, and two under the top of a zone below you.
local function ChallengeLevel(level, low, high)
	if level < low then
		return low
	elseif level > high then
		return high - 2
	end
	return level
end

function ns.SetupZoneLevels(map)
	local byName, namedMap = {}, nil

	local function Zone(name)
		local mapID = map:GetMapID()
		if mapID ~= namedMap then
			namedMap = mapID
			byName = {}
			for _, child in ipairs(C_Map.GetMapChildrenInfo(mapID, Enum.UIMapType.Zone) or {}) do
				local low, high = Range(child.mapID)
				if low then
					byName[child.name] = { low = low, high = high }
				end
			end
		end
		return byName[name]
	end

	-- The hover label carries only the zone name. Hooking EvaluateLabels wrote a field onto the frame and the
	-- map's data providers then failed, so the label's own update is what adds the range after it draws.
	for other in pairs(map.dataProviders) do
		if other.OnSetAreaLabel == AreaLabelDataProviderMixin.OnSetAreaLabel then
			local shown, plain
			other.Label:HookScript("OnUpdate", function(label)
				local text = label.Name:GetText()
				if not ns.Enabled("zoneLevels") then
					if plain and text == shown then
						label.Name:SetText(plain)
					end
					shown, plain = nil, nil
					return
				end
				if text == shown then
					return
				end
				local zone = text and Zone(text)
				if not zone then
					shown, plain = text, nil
					return
				end
				local level = UnitEffectiveLevel("player")
				local color = GetRelativeDifficultyColor(level, ChallengeLevel(level, zone.low, zone.high))
				plain = text
				shown = text
					.. RGBTableToColorCode(color)
					.. " ("
					.. Text(zone.low, zone.high)
					.. ")"
					.. FONT_COLOR_CODE_CLOSE
				label.Name:SetText(shown)
			end)
		end
	end
end
