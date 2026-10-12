-- Adapted from Shortest Path Forever by cjber, GPL-3.0-or-later.
-- https://github.com/cjber/shortest-path-forever
-- The world-map crossing: a solid line with a dark outline, and a curve where the route changes continent.
local _, ns = ...

local TEMPLATE = "MapTweaksRoutePinTemplate"
local THICKNESS = 3
local UNDER_THICKNESS = THICKNESS + 2
local UNDER_ALPHA = 0.5
local LIMIT = 4096

local COLORS = {
	boat = CreateColor(0.13, 0.83, 0.93),
	zeppelin = CreateColor(0.96, 0.72, 0.26),
}

-- Strokes in drawing order. Coordinates are canvas pixels, x right and y up from the pin's top left.
local function NewStrokes()
	return {
		n = 0,
		x1 = {},
		y1 = {},
		x2 = {},
		y2 = {},
		width = {},
		under = {},
		alpha = {},
		color = {},
		route = {},
	}
end

local out, width, height, fade, route

local function Begin(buffer)
	out = buffer
	out.n = 0
	fade, route = 1, nil
end

local function Stroke(x1, y1, x2, y2, color)
	local n = out.n
	if n >= LIMIT then
		return
	end
	n = n + 1
	out.n = n
	out.x1[n], out.y1[n], out.x2[n], out.y2[n] = x1, y1, x2, y2
	-- Base thickness; the draw scale is applied when the line is painted.
	out.width[n] = THICKNESS
	out.under[n] = UNDER_THICKNESS
	out.alpha[n], out.color[n], out.route[n] = fade, color, route
end

-- Clip segments, not vertices: a line can cross a zone with both endpoints outside it.
local function ClipAxis(start, delta, low, high, minimum, maximum)
	if delta == 0 then
		if start < minimum or start > maximum then
			return nil
		end
	else
		local a, b = (minimum - start) / delta, (maximum - start) / delta
		low, high = math.max(low, math.min(a, b)), math.min(high, math.max(a, b))
	end
	if low < high then
		return low, high
	end
end

local function Segment(x1, y1, x2, y2, low, high, color)
	local dx, dy = x2 - x1, y2 - y1
	if (dx == 0 and dy == 0) or not low then
		return
	end
	Stroke(x1 + low * dx, y1 + low * dy, x1 + high * dx, y1 + high * dy, color)
end

-- A line between two map fractions, clipped to the map.
local function Line(x1, y1, x2, y2, color)
	local low, high = ClipAxis(x1, x2 - x1, 0, 1, 0, 1)
	if low then
		low, high = ClipAxis(y1, y2 - y1, low, high, 0, 1)
	end
	Segment(x1 * width, -y1 * height, x2 * width, -y2 * height, low, high, color)
end

-- Smooth the gap across a loading screen. The control point bends the curve.
local function Curve(ax, ay, bx, by, cx, cy, color, fading)
	local px, py = ax, ay
	for step = 1, 12 do
		local t = step / 12
		local x = (1 - t) ^ 2 * ax + 2 * (1 - t) * t * cx + t ^ 2 * bx
		local y = (1 - t) ^ 2 * ay + 2 * (1 - t) * t * cy + t ^ 2 * by
		fade = fading and (1 - (step - 0.5) / 12) or 1
		Line(px, py, x, y, color)
		px, py = x, y
	end
	fade = 1
end

local function CrossingCurve(ax, ay, bx, by, color, px, py)
	local dx, dy = bx - ax, by - ay
	local cx, cy = (ax + bx) / 2 - dy * 0.25, (ay + by) / 2 + dx * 0.25
	if px then
		local tx, ty = ax - px, ay - py
		local length = math.sqrt(tx * tx + ty * ty)
		if length > 0 then
			local reach = math.sqrt(dx * dx + dy * dy) * 0.6 / length
			cx, cy = ax + tx * reach, ay + ty * reach
		end
	else
		-- Overview crossings arc toward open sea to the north, identically in either travel direction.
		local side = dx < 0 and -1 or 1
		cx, cy = (ax + bx) / 2 + dy * side * 0.6, (ay + by) / 2 - dx * side * 0.6
	end
	if math.abs((cx - ax) * dy - (cy - ay) * dx) < (dx * dx + dy * dy) * 0.1 then
		cx, cy = (ax + bx) / 2 - dy * 0.25, (ay + by) / 2 + dx * 0.25
	end
	Curve(ax, ay, bx, by, cx, cy, color)
end

local function EdgeCurve(x, y, nx, ny, color)
	if not nx then
		return
	end
	local dx, dy = x - nx, y - ny
	local length = math.sqrt(dx * dx + dy * dy)
	if length < 0.000001 then
		return
	end
	dx, dy = dx / length, dy / length
	-- Bend gently out to sea while retaining the sampled tangent at the loading point.
	local ex, ey = dx - dy * 0.3, dy + dx * 0.3
	local distance = math.huge
	if ex ~= 0 then
		distance = math.min(distance, ((ex > 0 and 1 or 0) - x) / ex)
	end
	if ey ~= 0 then
		distance = math.min(distance, ((ey > 0 and 1 or 0) - y) / ey)
	end
	if distance > 0 and distance < math.huge then
		local cx, cy = x + dx * distance * 0.55, y + dy * distance * 0.55
		Curve(x, y, x + ex * distance, y + ey * distance, cx, cy, color, true)
	end
end

local function Bridge(position, mapID, points, index, ax, ay, bx, by, color)
	local before, after = points[index - 2] or points[#points - 1], points[index + 1] or points[2]
	local px, py, nx, ny
	if before and before.map == points[index - 1].map then
		px, py = position(before, mapID)
	end
	if after and after.map == points[index].map then
		nx, ny = position(after, mapID)
	end
	if ax and bx then
		CrossingCurve(ax, ay, bx, by, color, px, py)
	elseif ax then
		EdgeCurve(ax, ay, px, py, color)
	elseif bx then
		EdgeCurve(bx, by, nx, ny, color)
	end
end

-- Both ends of a sea crossing are on this map, so one arc stands in for the sampled path.
local function OverviewCrossing(position, mapID, path, color)
	local first, last = path.points[1], path.points[#path.points]
	if not first or first.map == last.map then
		return false
	end
	local ax, ay = position(first, mapID)
	local bx, by = position(last, mapID)
	if ax and bx then
		CrossingCurve(ax, ay, bx, by, color)
		return true
	end
	return false
end

local function DrawPaths(buffer, paths, view)
	Begin(buffer)
	width, height = view.width, view.height
	local mapID, position = view.mapID, view.position
	for _, path in ipairs(paths) do
		local color = COLORS[path.mode]
		route = path.route
		local previous, px, py
		local points = path.points
		local crossing = OverviewCrossing(position, mapID, path, color)
		local last = crossing and 0 or #points
		for index = 1, last do
			local point = points[index]
			local x, y = position(point, mapID)
			if previous then
				if previous.jump or previous.map ~= point.map then
					Bridge(position, mapID, points, index, px, py, x, y, color)
				elseif px and x then
					Line(px, py, x, y, color)
				end
			end
			previous, px, py = point, x, y
		end
	end
end

-- Each map's world corners: continent, x and y at the top left, x and y at the bottom right.
local corners = {}

local function Corners(mapID)
	if corners[mapID] == nil then
		local continent, topLeft = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
		local other, bottomRight = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
		corners[mapID] = false
		if continent and continent == other and topLeft and bottomRight then
			local x0, y0 = topLeft:GetXY()
			local x1, y1 = bottomRight:GetXY()
			if x0 ~= x1 and y0 ~= y1 then
				corners[mapID] = { continent, x0, y0, x1, y1 }
			end
		end
	end
	return corners[mapID]
end

-- A world point on this map, in map fractions. Lines are clipped, so a point past the edge still counts.
function ns.Project(point, mapID)
	local uiMap, position = C_Map.GetMapPosFromWorldPos(point.map, CreateVector2D(point.x, point.y), mapID)
	if uiMap == mapID and position then
		return position:GetXY()
	end
	local map = Corners(mapID)
	if map and map[1] == point.map then
		-- World x runs north and y west, so the map's x follows world y and its y follows world x.
		return (point.y - map[3]) / (map[5] - map[3]), (point.x - map[2]) / (map[4] - map[2])
	end
end

local highlightedRoutes, hoverOwner

local function Paint(owner, strokes)
	local lines, underlines = owner.lines, owner.underlines
	local scale = owner.drawScale or 1
	for index = 1, strokes.n do
		local line, underline = lines[index], underlines[index]
		if not line then
			underline = owner:CreateLine(nil, "ARTWORK", nil, -1)
			underline:SetColorTexture(0.04, 0.04, 0.04, 1)
			line = owner:CreateLine(nil, "ARTWORK")
			line:SetColorTexture(1, 1, 1, 1)
			lines[index], underlines[index] = line, underline
		end
		local x1, y1, x2, y2 = strokes.x1[index], strokes.y1[index], strokes.x2[index], strokes.y2[index]
		underline:SetThickness(strokes.under[index] / scale)
		underline:SetStartPoint("TOPLEFT", owner, x1, y1)
		underline:SetEndPoint("TOPLEFT", owner, x2, y2)
		underline:Show()
		line:SetVertexColor(strokes.color[index]:GetRGBA())
		line:SetThickness(strokes.width[index] / scale)
		line:SetStartPoint("TOPLEFT", owner, x1, y1)
		line:SetEndPoint("TOPLEFT", owner, x2, y2)
		line:Show()
	end
	for index = strokes.n + 1, #lines do
		lines[index]:Hide()
		underlines[index]:Hide()
	end
end

MapTweaksRoutePinMixin = CreateFromMixins(MapCanvasPinMixin)

function MapTweaksRoutePinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_FOG_OF_WAR")
	self:SetIgnoreGlobalPinScale(true)
	self:SetScaleStyle(AM_PIN_SCALE_STYLE_WITH_TERRAIN)
	self:EnableMouse(false)
	self.lines, self.underlines = {}, {}
	self.strokes = NewStrokes()
end

function MapTweaksRoutePinMixin:UpdateAlpha()
	local strokes = self.strokes
	for index = 1, strokes.n do
		local shown = highlightedRoutes and highlightedRoutes[strokes.route[index]]
		local alpha = shown and strokes.alpha[index] or 0
		self.lines[index]:SetAlpha(alpha)
		self.underlines[index]:SetAlpha(alpha * UNDER_ALPHA)
	end
end

function MapTweaksRoutePinMixin:Draw()
	local map = self:GetMap()
	local canvas = map:GetCanvas()
	self.drawScale = self:GetEffectiveScale()
	self:SetSize(canvas:GetWidth(), canvas:GetHeight())
	self:SetPosition(0.5, 0.5)
	local view = {
		mapID = map:GetMapID(),
		position = ns.Project,
		width = self:GetWidth(),
		height = self:GetHeight(),
	}
	DrawPaths(self.strokes, self.paths, view)
	Paint(self, self.strokes)
	self:UpdateAlpha()
end

function MapTweaksRoutePinMixin:OnAcquired(paths)
	self.paths = paths
	self:Draw()
end

-- The points do not move on zoom, only the on-screen thickness does.
function MapTweaksRoutePinMixin:Rescale()
	if not self.strokes or self.strokes.n == 0 then
		return
	end
	local scale = self:GetEffectiveScale()
	self.drawScale = scale
	for index = 1, self.strokes.n do
		self.lines[index]:SetThickness(self.strokes.width[index] / scale)
		self.underlines[index]:SetThickness(self.strokes.under[index] / scale)
	end
end

function MapTweaksRoutePinMixin:OnCanvasScaleChanged()
	if self.paths then
		self:Rescale()
	end
end

function MapTweaksRoutePinMixin:OnCanvasSizeChanged()
	if self.paths then
		self:Draw()
	end
end

function MapTweaksRoutePinMixin:OnReleased()
	self.paths = nil
	MapCanvasPinMixin.OnReleased(self)
end

-- routes is [route id] = true while owner is the hovered dock, or nil to clear that hover.
function ns.HoverRoutes(owner, routes)
	if not routes and owner and hoverOwner ~= owner then
		return
	end
	hoverOwner, highlightedRoutes = routes and owner or nil, routes
	for pin in WorldMapFrame:EnumeratePinsByTemplate(TEMPLATE) do
		pin:UpdateAlpha()
	end
end

local geometry

local function Geometry()
	if geometry then
		return geometry
	end
	geometry = {}
	local ids = {}
	for id in pairs(ns.Routes) do
		ids[#ids + 1] = id
	end
	table.sort(ids)
	for _, id in ipairs(ids) do
		local path = ns.Routes[id]
		geometry[#geometry + 1] = { mode = path.kind, route = id, points = path.frames }
	end
	return geometry
end

local LineProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin)

function LineProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(TEMPLATE)
end

local function PinCount(map)
	local count = 0
	for _ in map:EnumeratePinsByTemplate(TEMPLATE) do
		count = count + 1
	end
	return count
end

function LineProviderMixin:RefreshAllData()
	if InCombatLockdown() then
		-- Releasing pins is allowed in combat; acquiring them is not. Clear the
		-- previous map's lines so they do not linger at wrong positions.
		self:RemoveAllData()
		self.mapID = nil
		ns.QueueRefresh()
		return
	end
	local map = self:GetMap()
	local mapID = map:GetMapID()
	if not (mapID and map:IsVisible()) then
		self:RemoveAllData()
		self.mapID = nil
		return
	end
	if self.mapID == mapID and PinCount(map) > 0 then
		return
	end
	self:RemoveAllData()
	self.mapID = mapID
	map:AcquirePin(TEMPLATE, Geometry())
end

-- The pin handles its own OnCanvasScaleChanged; the provider does not redraw.

function ns.SetupLines(map)
	local provider = CreateFromMixins(LineProviderMixin)
	map:AddDataProvider(provider)
	ns.RefreshLines = function()
		provider:RefreshAllData()
	end
end
