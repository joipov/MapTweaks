-- Saved variables for the world map features and the minimap button.
-- Plain Lua so tests/run.lua can exercise it without a client.
local _, ns = ...

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

local function CopyDefaults(db)
	for key, value in pairs(defaults) do
		if type(db[key]) ~= type(value) then
			db[key] = value
		end
	end
end

local function MigrateDB(db)
	if type(db.version) ~= "number" then
		db.version = 0
	end
	-- No migrations yet. A new one goes here as an if db.version < N block.
	db.version = DB_VERSION
end

local function Validate(db)
	EnsureTables(db)
end

function ns.LoadDB(saved)
	ns.firstRun = type(saved) ~= "table"
	local db = ns.firstRun and {} or saved
	MigrateDB(db)
	CopyDefaults(db)
	Validate(db)
	return db
end

ns.DB_VERSION = DB_VERSION
ns.defaults = defaults
