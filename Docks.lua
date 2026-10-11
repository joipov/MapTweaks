-- Adapted from Shortest Path Forever by cjber, GPL-3.0-or-later.
-- https://github.com/cjber/shortest-path-forever
-- Dock pins on the world map. Hover draws that crossing and names where it goes.
local _, ns = ...

local PIN_TEMPLATE = "MapTweaksDockPinTemplate"
local PING_TEMPLATE = "MapTweaksPingPinTemplate"
local PIN_SIZE = 20
-- Half a pin, as a fraction of a zoomed-out map.
local EDGE = 0.015
-- Docks closer than this many pins apart merge into one.
local OVERLAP = 0.8
local FERRY_ATLAS = "flightmasterferry"

local TO = {
	boat = "Boat to %s",
	zeppelin = "Zeppelin to %s",
}
local KINDS = { boat = "Boats", zeppelin = "Zeppelins" }
local ORDER = { "boat", "zeppelin" }
local LANDING = { boat = "%s pier", zeppelin = "%s tower" }
local COMPASS = {
	"east",
	"northeast",
	"north",
	"northwest",
	"west",
	"southwest",
	"south",
	"southeast",
}

local provider
local atlasInfo

local function SetTransportIcon(texture, kind)
	if kind == "zeppelin" then
		texture:SetTexCoord(0, 1, 0, 1)
		texture:SetTexture("Interface\\AddOns\\MapTweaks\\media\\zeppelin")
		texture:SetSize(PIN_SIZE, PIN_SIZE)
		return
	end
	if atlasInfo == nil then
		atlasInfo = C_Texture.GetAtlasInfo(FERRY_ATLAS) or false
	end
	texture:SetAtlas(FERRY_ATLAS)
	if atlasInfo then
		local scale = math.min(PIN_SIZE / atlasInfo.width, PIN_SIZE / atlasInfo.height)
		texture:SetSize(atlasInfo.width * scale, atlasInfo.height * scale)
	else
		texture:SetSize(PIN_SIZE, PIN_SIZE)
	end
end

-- The zone map a world point sits on. GetMapPosFromWorldPos may answer with the continent.
local function Resolve(point)
	local world = CreateVector2D(point.x, point.y)
	local uiMap, position = C_Map.GetMapPosFromWorldPos(point.map, world)
	if not uiMap or not position then
		return nil
	end
	local info = C_Map.GetMapInfo(uiMap)
	if info and info.mapType ~= Enum.UIMapType.Zone then
		local zoneX, zoneY = position:GetXY()
		local zone = C_Map.GetMapInfoAtPosition(uiMap, zoneX, zoneY)
		if zone and zone.mapType == Enum.UIMapType.Zone then
			local zoneMap, zonePosition = C_Map.GetMapPosFromWorldPos(point.map, world, zone.mapID)
			if zoneMap and zonePosition then
				uiMap, position, info = zoneMap, zonePosition, zone
			end
		end
	end
	return { uiMap = uiMap, zone = info and info.name or UNKNOWN }
end

local locations = {}

function ns.DockLocation(dockID)
	if locations[dockID] == nil then
		locations[dockID] = Resolve(ns.Docks[dockID]) or false
	end
	return locations[dockID] or nil
end

function ns.DockZone(dockID)
	local location = ns.DockLocation(dockID)
	return location and location.zone or UNKNOWN
end

local function DockKind(dockID)
	local routeID = ns.RoutesAtDock[dockID][1]
	return ns.Routes[routeID].kind
end

-- On the map and fully inside it. Piers at the edge stay whole.
local function PinPosition(point, mapID)
	local uiMap, position = C_Map.GetMapPosFromWorldPos(point.map, CreateVector2D(point.x, point.y), mapID)
	if uiMap ~= mapID or not position then
		return nil
	end
	local x, y = position:GetXY()
	if x >= 0 and x <= 1 and y >= 0 and y <= 1 then
		return Clamp(x, EDGE, 1 - EDGE), Clamp(y, EDGE, 1 - EDGE)
	end
end

-- A dock shows on its zone and every map above it.
local function IsDockMap(location, mapID)
	local info = C_Map.GetMapInfo(location.uiMap)
	while info do
		if info.mapID == mapID then
			return true
		end
		if info.parentMapID == 0 then
			return false
		end
		info = C_Map.GetMapInfo(info.parentMapID)
	end
	return false
end

local function MapDocks(mapID)
	local docks = {}
	for dockID, dock in ipairs(ns.Docks) do
		local location = ns.DockLocation(dockID)
		if location and IsDockMap(location, mapID) then
			local x, y = PinPosition(dock, mapID)
			if x then
				docks[#docks + 1] = { id = dockID, x = x, y = y }
			end
		end
	end
	return docks
end

-- Groups the points whose pins would overlap at the map's current zoom.
local function OverlapGroups(map, points, size)
	local canvas = map:GetCanvas()
	size = size * OVERLAP / map:GetCanvasScale()
	local reachX, reachY = size / canvas:GetWidth(), size / canvas:GetHeight()
	local root = {}
	local function Find(i)
		while root[i] ~= i do
			i = root[i]
		end
		return i
	end
	for i in ipairs(points) do
		root[i] = i
	end
	for i = 1, #points do
		for j = i + 1, #points do
			if math.abs(points[i].x - points[j].x) < reachX and math.abs(points[i].y - points[j].y) < reachY then
				root[Find(j)] = Find(i)
			end
		end
	end
	local byRoot, groups = {}, {}
	for i, point in ipairs(points) do
		local parent = Find(i)
		local group = byRoot[parent]
		if not group then
			group = {}
			byRoot[parent] = group
			groups[#groups + 1] = group
		end
		group[#group + 1] = point
	end
	return groups
end

local function Clusters(map, docks)
	local zoom = Saturate(map:GetCanvasZoomPercent())
	local groups = OverlapGroups(map, docks, PIN_SIZE * map:GetGlobalPinScale() * Lerp(1, 1.2, zoom))
	local clusters = {}
	for i, group in ipairs(groups) do
		local cluster = { docks = group, kinds = {} }
		local x, y, ids = 0, 0, {}
		for _, dock in ipairs(group) do
			x, y = x + dock.x, y + dock.y
			ids[#ids + 1] = dock.id
			local kind = DockKind(dock.id)
			cluster.kinds[kind] = true
			cluster.kind = cluster.kind or kind
		end
		cluster.x, cluster.y = x / #group, y / #group
		cluster.key = table.concat(ids, ",")
		clusters[i] = cluster
	end
	return clusters
end

local function PierName(x, y, cx, cy, kind)
	local angle = math.atan2(cy - y, x - cx)
	local direction = COMPASS[math.floor(angle / (2 * math.pi) * 8 + 0.5) % 8 + 1]
	return string.format(LANDING[kind], direction)
end

-- Which dock this is when several share a pin: its zone, or which way it lies when the zones match.
local function LandingName(cluster, dock, kind)
	local zone, sharedZone = ns.DockZone(dock.id), false
	for _, other in ipairs(cluster.docks) do
		sharedZone = sharedZone or (other ~= dock and ns.DockZone(other.id) == zone)
	end
	if not sharedZone then
		return zone
	end
	local name = PierName(dock.x, dock.y, cluster.x, cluster.y, kind)
	if #cluster.docks > 2 then
		return zone .. ", " .. name
	end
	return (name:gsub("^%l", string.upper))
end

-- Other docks on the routes that call here.
local function Destinations(dockID)
	local list, seen = {}, {}
	for _, routeID in ipairs(ns.RoutesAtDock[dockID]) do
		local path = ns.Routes[routeID]
		for _, otherID in ipairs(path.stops) do
			if otherID ~= dockID and not seen[otherID] then
				seen[otherID] = true
				list[#list + 1] = {
					dockID = otherID,
					kind = path.kind,
					faction = path.faction,
					zone = ns.DockZone(otherID),
					point = ns.Docks[otherID],
				}
			end
		end
	end
	return list
end

local function AddDestinationLine(dest)
	local text = string.format("to %s", dest.zone)
	if dest.faction then
		GameTooltip_AddColoredDoubleLine(GameTooltip, text, dest.faction, NORMAL_FONT_COLOR, GRAY_FONT_COLOR)
	else
		GameTooltip_AddColoredLine(GameTooltip, text, NORMAL_FONT_COLOR)
	end
end

local function AddDockTooltip(cluster)
	local groups = {}
	for _, dock in ipairs(cluster.docks) do
		local destinations = Destinations(dock.id)
		if #destinations > 0 then
			groups[#groups + 1] = { dock = dock, destinations = destinations }
		end
	end
	local count = 0
	for _, group in ipairs(groups) do
		count = count + #group.destinations
	end
	if count == 1 then
		local dest = groups[1].destinations[1]
		GameTooltip_SetTitle(GameTooltip, string.format(TO[dest.kind], dest.zone))
		if dest.faction then
			GameTooltip_AddColoredLine(GameTooltip, dest.faction, GRAY_FONT_COLOR)
		end
		return
	end
	local titles = {}
	for _, kind in ipairs(ORDER) do
		if cluster.kinds[kind] then
			titles[#titles + 1] = KINDS[kind]
		end
	end
	GameTooltip_SetTitle(GameTooltip, table.concat(titles, " & "))
	for _, group in ipairs(groups) do
		if #groups > 1 then
			local kind = group.destinations[1].kind
			GameTooltip_AddColoredLine(GameTooltip, LandingName(cluster, group.dock, kind), HIGHLIGHT_FONT_COLOR)
		end
		for _, dest in ipairs(group.destinations) do
			AddDestinationLine(dest)
		end
	end
end

-- Where a pin's routes end, one per map other than this one.
local function Ends(mapID, candidates)
	local ends, seen = {}, { [mapID] = true }
	for _, candidate in ipairs(candidates) do
		local location = ns.DockLocation(candidate.dockID)
		if location and not seen[location.uiMap] then
			seen[location.uiMap] = true
			candidate.uiMap, candidate.zone = location.uiMap, location.zone
			ends[#ends + 1] = candidate
		end
	end
	return ends
end

local function ShowEnd(target)
	C_Map.OpenWorldMap(target.uiMap)
	local x, y = PinPosition(target.point, target.uiMap)
	if x then
		provider:Ping(x, y)
	end
end

local function OpenEnds(pin, button)
	if button ~= "LeftButton" or IsModifierKeyDown() then
		return
	end
	local ends = pin:GetEnds()
	if #ends == 1 then
		ShowEnd(ends[1])
	elseif #ends > 1 then
		MenuUtil.CreateContextMenu(pin, function(_, root)
			for _, target in ipairs(ends) do
				root:CreateButton(string.format(TO[target.kind], target.zone), function()
					ShowEnd(target)
				end)
			end
		end)
	end
end

local function AddEndsLine(ends)
	if #ends == 1 then
		GameTooltip_AddInstructionLine(GameTooltip, string.format("Click to show %s", ends[1].zone))
	elseif #ends > 1 then
		GameTooltip_AddInstructionLine(GameTooltip, "Click to show where they go")
	end
end

MapTweaksDockPinMixin = CreateFromMixins(MapCanvasPinMixin)

function MapTweaksDockPinMixin:OnLoad()
	-- Above town, flight point and dungeon icons, so a dock beside one still takes the hover.
	self:UseFrameLevelType("PIN_FRAME_LEVEL_GOSSIP")
	self:SetScalingLimits(1, 1, 1.2)
	self:SetSize(PIN_SIZE, PIN_SIZE)
	self:SetScript("OnHide", self.OnMouseLeave)
end

function MapTweaksDockPinMixin:OnAcquired(cluster)
	self.cluster = cluster
	SetTransportIcon(self.Texture, cluster.kind)
	SetTransportIcon(self.HighlightTexture, cluster.kind)
	self:SetPosition(cluster.x, cluster.y)
end

function MapTweaksDockPinMixin:GetEnds()
	local candidates = {}
	for _, dock in ipairs(self.cluster.docks) do
		for _, dest in ipairs(Destinations(dock.id)) do
			candidates[#candidates + 1] = dest
		end
	end
	return Ends(self:GetMap():GetMapID(), candidates)
end

function MapTweaksDockPinMixin:RefreshTooltip()
	AddDockTooltip(self.cluster)
	AddEndsLine(self:GetEnds())
	GameTooltip:Show()
end

function MapTweaksDockPinMixin:OnMouseEnter()
	local routes = {}
	for _, dock in ipairs(self.cluster.docks) do
		for _, routeID in ipairs(ns.RoutesAtDock[dock.id]) do
			routes[routeID] = true
		end
	end
	ns.HoverRoutes(self, routes)
	provider:ShowDestinations(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	self:RefreshTooltip()
end

function MapTweaksDockPinMixin:OnMouseLeave()
	ns.HoverRoutes(self, nil)
	if provider then
		provider:HideDestinations()
	end
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function MapTweaksDockPinMixin:OnReleased()
	self:OnMouseLeave()
	self.Glow:Hide()
	self.cluster = nil
	MapCanvasPinMixin.OnReleased(self)
end

MapTweaksDockPinMixin.OnMouseClickAction = OpenEnds

local ProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin)

function ProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(PIN_TEMPLATE)
	self:GetMap():RemoveAllPinsByTemplate(PING_TEMPLATE)
	self.ping = nil
	self.pinOf, self.pins = {}, {}
end

function ProviderMixin:ShowDestinations(pin)
	for _, dock in ipairs(pin.cluster.docks) do
		for _, dest in ipairs(Destinations(dock.id)) do
			local target = self.pinOf[dest.dockID]
			if target and target ~= pin then
				target.Glow:Show()
			end
		end
	end
end

function ProviderMixin:HideDestinations()
	for _, pin in pairs(self.pins or {}) do
		pin.Glow:Hide()
	end
end

function ProviderMixin:Ping(x, y)
	if not self.ping then
		self.ping = self:GetMap():AcquirePin(PING_TEMPLATE)
		self.ping:UseFrameLevelType("PIN_FRAME_LEVEL_QUEST_PING")
	end
	self.ping:SetNumLoops(2)
	self.ping:PlayAt(x, y)
end

function ProviderMixin:RefreshAllData()
	if InCombatLockdown() then
		ns.QueueRefresh()
		return
	end
	if not ns.Enabled("docks") then
		ns.HoverRoutes(nil, nil)
		self:RemoveAllData()
		self.mapID = nil
		return
	end
	local map = self:GetMap()
	local mapID = map:GetMapID()
	if not (mapID and map:IsVisible()) then
		self:RemoveAllData()
		self.mapID = nil
		return
	end
	local clusters = Clusters(map, MapDocks(mapID))
	local wanted = {}
	for _, cluster in ipairs(clusters) do
		wanted[cluster.key] = cluster
	end
	local same = self.pins ~= nil and mapID == self.mapID
	for key, pin in pairs(self.pins or {}) do
		same = same and pin.cluster ~= nil and wanted[key] ~= nil
	end
	for key in pairs(wanted) do
		same = same and self.pins[key] ~= nil
	end
	self.mapID = mapID
	if same then
		return
	end
	self:RemoveAllData()
	for _, cluster in ipairs(clusters) do
		local pin = map:AcquirePin(PIN_TEMPLATE, cluster)
		self.pins[cluster.key] = pin
		for _, dock in ipairs(cluster.docks) do
			self.pinOf[dock.id] = pin
		end
	end
end

function ProviderMixin:OnCanvasScaleChanged()
	self:RefreshAllData()
end

function ns.SetupDocks(map)
	provider = CreateFromMixins(ProviderMixin)
	map:AddDataProvider(provider)
	ns.RefreshDocks = function()
		provider:RefreshAllData()
	end
end
