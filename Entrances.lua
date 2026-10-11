-- Adapted from Tweaks Forever by cjber, GPL-3.0-or-later.
-- https://github.com/cjber/tweaks-forever
-- Dungeon and raid entrances. The retail icons, a tooltip, and a click that sets a waypoint.
local _, ns = ...

local TEMPLATE = "MapTweaksEntrancePinTemplate"
local CVAR = "showDungeonEntrancesOnMap"
local SETTLE_INTERVAL = 0.25
local COVER = 10
local MARKERS = { "FlightPointPinTemplate", "MapTweaksDockPinTemplate" }

local function Aspect(atlas)
	local info = C_Texture.GetAtlasInfo(atlas)
	if info and info.width > 0 and info.height > 0 then
		return info.width / info.height
	end
	return 1
end

local function Markup(atlas, height)
	return ("|A:%s:%d:%d|a"):format(atlas, height, math.floor(height * Aspect(atlas) + 0.5))
end

local function Atlas(entry)
	for _, instance in ipairs(entry.instances) do
		if not ns.RaidInstances[instance] then
			return "Dungeon"
		end
	end
	return "Raid"
end

-- Name and description only change with the client locale, so cache per entry.
local function Describe(entry)
	if entry.cachedTitle ~= nil then
		return entry.cachedTitle, entry.cachedLines
	end
	local names = {}
	for i, instance in ipairs(entry.instances) do
		names[i] = GetRealZoneText(instance)
	end
	local title = entry.area and C_Map.GetAreaInfo(entry.area) or table.remove(names, 1)
	local lines
	if #names > 0 then
		if entry.area and Atlas(entry) == "Dungeon" then
			for i, instance in ipairs(entry.instances) do
				local atlas = ns.RaidInstances[instance] and "Raid" or "Dungeon"
				names[i] = Markup(atlas, 16) .. " " .. names[i]
			end
		end
		lines = table.concat(names, "\n")
	end
	entry.cachedTitle, entry.cachedLines = title, lines
	return title, lines
end

local function Covers(x, y, mx, my, halfX, halfY)
	return math.abs(x - mx) < halfX and math.abs(y - my) < halfY
end

function ns.SetupEntrances(map)
	MapTweaksEntrancePinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")
	local Pin = MapTweaksEntrancePinMixin

	local function HalfExtents()
		local canvas, scale = map:GetCanvas(), map:GetScaleForMinZoom()
		return COVER / (canvas:GetWidth() * scale), COVER / (canvas:GetHeight() * scale)
	end

	local function Covered(pin, halfX, halfY)
		local x, y = pin:GetPosition()
		if not x or not y then
			return false
		end
		for _, template in ipairs(MARKERS) do
			for marker in map:EnumeratePinsByTemplate(template) do
				local mx, my = marker:GetPosition()
				if mx and marker:IsShown() and Covers(x, y, mx, my, halfX, halfY) then
					return true
				end
			end
		end
		return false
	end

	function Pin:OnAcquired(entry)
		local title, lines = Describe(entry)
		BaseMapPoiPinMixin.OnAcquired(self, {
			name = title,
			atlasName = Atlas(entry),
			position = CreateVector2D(entry.x, entry.y),
		})
		self.entry = entry
		self.lines = lines
		self:SetShown(not Covered(self, HalfExtents()))
	end

	function Pin:UseTooltip()
		return true
	end

	function Pin:GetBestNameAndDescription()
		return self.name, self.lines
	end

	function Pin:GetTooltipInstructions()
		if C_Map.CanSetUserWaypointOnMap(self:GetMap():GetMapID()) then
			return "Click to set a waypoint here"
		end
	end

	function Pin:OnMouseClickAction(button)
		if button ~= "LeftButton" then
			return
		end
		local mapID = self:GetMap():GetMapID()
		local entry = self.entry
		if C_Map.CanSetUserWaypointOnMap(mapID) then
			C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, entry.x, entry.y))
			C_SuperTrack.SetSuperTrackedUserWaypoint(true)
		end
	end

	local Provider = CreateFromMixins(MapCanvasDataProviderMixin)

	function Provider:RemoveAllData()
		self:GetMap():RemoveAllPinsByTemplate(TEMPLATE)
	end

	function Provider:RefreshAllData()
		local canvas = self:GetMap()
		if InCombatLockdown() then
			ns.QueueRefresh()
			for pin in canvas:EnumeratePinsByTemplate(TEMPLATE) do
				pin:SetShown(false)
			end
			return
		end
		self:RemoveAllData()
		if not ns.Enabled("entrances") or not GetCVarBool(CVAR) then
			return
		end
		for _, entry in ipairs(ns.DungeonEntrances[canvas:GetMapID()] or {}) do
			canvas:AcquirePin(TEMPLATE, entry)
		end
	end

	map:AddDataProvider(Provider)
	ns.RefreshEntrances = function()
		Provider:RefreshAllData()
	end

	local events = CreateFrame("Frame")
	events:RegisterEvent("CVAR_UPDATE")
	events:SetScript("OnEvent", function(_, _, cvar)
		if cvar == CVAR and map:IsShown() then
			Provider:RefreshAllData()
		end
	end)

	-- Flight points and docks are placed by their own providers, before or after ours.
	local elapsed = 0
	map:HookScript("OnUpdate", function(_, delta)
		elapsed = elapsed + delta
		if elapsed < SETTLE_INTERVAL or InCombatLockdown() then
			return
		end
		elapsed = 0
		local halfX, halfY = HalfExtents()
		for pin in map:EnumeratePinsByTemplate(TEMPLATE) do
			pin:SetShown(not Covered(pin, halfX, halfY))
		end
	end)
end
