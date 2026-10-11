-- Saved variables for the world map features and the minimap button.
-- Plain Lua so tests/run.lua can exercise it without a client.
local addonName, ns = ...

ns.DISPLAY = "Map Tweaks"

local DB_VERSION = 1
local MINIMAP_POS = 250

-- Scalars only. Tables are built fresh in EnsureTables.
local defaults = {
	docks = true,
	exploration = true,
	zoneLevels = true,
	entrances = true,
	showMinimapButton = true,
}

local function ClampNumber(value, lo, hi, fallback)
	if type(value) ~= "number" or value ~= value then
		return fallback
	end
	if value < lo then
		return lo
	end
	if value > hi then
		return hi
	end
	return value
end

local function EnsureTables(db)
	if type(db.minimapIcon) ~= "table" then
		db.minimapIcon = {}
	end
	db.minimapIcon.minimapPos = ClampNumber(db.minimapIcon.minimapPos, 0, 360, MINIMAP_POS)
end

function ns.Enabled(key)
	local db = ns.db
	if not db then
		return true
	end
	return db[key] ~= false
end

function ns.LoadDB(saved)
	ns.firstRun = type(saved) ~= "table"
	local db = ns.firstRun and {} or saved
	for key, value in pairs(defaults) do
		if type(db[key]) ~= type(value) then
			db[key] = value
		end
	end
	EnsureTables(db)
	db.version = DB_VERSION
	return db
end

local frame = CreateFrame("Frame")

local handlers = {}

function handlers.ADDON_LOADED(name)
	if name ~= addonName then
		return
	end
	frame:UnregisterEvent("ADDON_LOADED")
	ns.db = ns.LoadDB(_G.MapTweaksDB)
	_G.MapTweaksDB = ns.db
	ns.InitOptions()
end

-- Other addons load LibDBIcon by PLAYER_LOGIN.
function handlers.PLAYER_LOGIN()
	ns.Welcome()
	ns.CreateMinimapButton()
end

frame:SetScript("OnEvent", function(_, event, ...)
	handlers[event](...)
end)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

ns.DB_VERSION = DB_VERSION
