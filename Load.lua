-- Waits for the world map, then turns on every map feature.
local addonName, ns = ...

local queueFrame

function ns.QueueRefresh()
	if not queueFrame then
		queueFrame = CreateFrame("Frame")
		queueFrame:SetScript("OnEvent", function(self)
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			if ns.RefreshLines then
				ns.RefreshLines()
			end
			if ns.RefreshDocks then
				ns.RefreshDocks()
			end
			if ns.RefreshEntrances then
				ns.RefreshEntrances()
			end
		end)
	end
	if not queueFrame:IsEventRegistered("PLAYER_REGEN_ENABLED") then
		queueFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end

local installed = false

local function Install()
	if installed or not WorldMapFrame then
		return
	end
	installed = true
	ns.SetupLines(WorldMapFrame)
	ns.SetupDocks(WorldMapFrame)
	ns.SetupExploration(WorldMapFrame)
	ns.SetupZoneLevels(WorldMapFrame)
	ns.SetupEntrances(WorldMapFrame)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, _, name)
	if name == addonName or name == "Blizzard_WorldMap" then
		Install()
	end
end)
if C_AddOns.IsAddOnLoaded("Blizzard_WorldMap") then
	Install()
end
