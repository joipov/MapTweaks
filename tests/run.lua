-- Unit tests for the pure parts of Map Tweaks.
--   luajit tests/run.lua
--   lua5.1 tests/run.lua
-- Files that build providers and pins are not loaded. Database.lua only creates
-- one event frame at load, which the CreateFrame stub below absorbs.

local root = (arg and arg[0] or "tests/run.lua"):match("^(.*)[/\\]tests[/\\]") or "."

local ns = {}

CreateFrame = function()
	return {
		RegisterEvent = function() end,
		UnregisterEvent = function() end,
		SetScript = function() end,
	}
end
MapTweaksDB = nil

local function load(file)
	local chunk, err = loadfile(root .. "/" .. file)
	assert(chunk, err)
	chunk("MapTweaks", ns)
end

load("Database.lua")

local passed, failed = 0, 0

local function eq(actual, expected, label)
	if actual ~= expected then
		error(string.format("%s: expected %s, got %s", label or "value", tostring(expected), tostring(actual)), 2)
	end
end

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		passed = passed + 1
	else
		failed = failed + 1
		print("FAIL " .. name .. ": " .. tostring(err))
	end
end

test("LoadDB fills every feature on", function()
	local db = ns.LoadDB(nil)
	eq(db.docks, true, "docks")
	eq(db.exploration, true, "exploration")
	eq(db.zoneLevels, true, "zoneLevels")
	eq(db.entrances, true, "entrances")
end)

test("LoadDB keeps an explicit off", function()
	local db = ns.LoadDB({ docks = false })
	eq(db.docks, false, "docks")
	eq(db.exploration, true, "exploration")
end)

test("LoadDB replaces a non-boolean value", function()
	local db = ns.LoadDB({ entrances = 0 })
	eq(db.entrances, true)
end)

test("Enabled treats a missing db as on", function()
	ns.db = nil
	eq(ns.Enabled("docks"), true)
end)

test("Enabled reads the saved flag", function()
	ns.db = { docks = false }
	eq(ns.Enabled("docks"), false)
	eq(ns.Enabled("entrances"), true)
end)

if failed > 0 then
	print(string.format("%d passed, %d failed", passed, failed))
	os.exit(1)
end
print(string.format("%d passed", passed))
