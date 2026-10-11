-- Saved variables for the four world map features. Each one defaults to on.
local addonName, ns = ...

ns.DISPLAY = "Map Tweaks"

local defaults = {
	docks = true,
	exploration = true,
	zoneLevels = true,
	entrances = true,
}

function ns.Enabled(key)
	local db = ns.db
	if not db then
		return true
	end
	return db[key] ~= false
end

local function Load()
	local db = MapTweaksDB
	if type(db) ~= "table" then
		db = {}
		MapTweaksDB = db
	end
	for key, value in pairs(defaults) do
		if type(db[key]) ~= "boolean" then
			db[key] = value
		end
	end
	ns.db = db
	if ns.InitOptions then
		ns.InitOptions()
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, name)
	if name ~= addonName then
		return
	end
	frame:UnregisterEvent("ADDON_LOADED")
	Load()
end)
