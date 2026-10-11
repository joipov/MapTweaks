-- Adapted from Tweaks Forever by cjber, GPL-3.0-or-later.
-- https://github.com/cjber/tweaks-forever
-- Unexplored zone terrain, drawn under the explored tiles in a dim blue tint.
local _, ns = ...

local TINT_R, TINT_G, TINT_B, TINT_A = 0.55, 0.65, 0.85, 0.8

local function OverlayKey(x, y, width, height)
	return ("%d:%d:%d:%d"):format(x, y, width, height)
end

local function Decode(encoded)
	local layers = {}
	for record in encoded:gmatch("([^;]+);") do
		local values = {}
		for value in record:gmatch("%d+") do
			values[#values + 1] = tonumber(value)
		end
		local index = values[1]
		local area = {
			x = values[2],
			y = values[3],
			width = values[4],
			height = values[5],
			files = {},
		}
		area.key = OverlayKey(area.x, area.y, area.width, area.height)
		for i = 6, #values do
			area.files[#area.files + 1] = values[i]
		end
		local layer = layers[index]
		if not layer then
			layer = {}
			layers[index] = layer
		end
		layer[#layer + 1] = area
	end
	return layers
end

-- Partial edge tiles occupy power-of-two files, as in MapExplorationPinMixin.
local function TileSpan(total, size, index, count)
	if index < count then
		return size, 1
	end
	local pixels = total % size
	if pixels == 0 then
		pixels = size
	end
	local file = 16
	while file < pixels do
		file = file * 2
	end
	return pixels, pixels / file
end

local function OverlayTiles(width, height, tileWidth, tileHeight)
	local wide, tall = math.ceil(width / tileWidth), math.ceil(height / tileHeight)
	local tiles = {}
	for row = 1, tall do
		local h, v = TileSpan(height, tileHeight, row, tall)
		for column = 1, wide do
			local w, u = TileSpan(width, tileWidth, column, wide)
			tiles[#tiles + 1] = {
				x = tileWidth * (column - 1),
				y = tileHeight * (row - 1),
				width = w,
				height = h,
				u = u,
				v = v,
			}
		end
	end
	return tiles
end

local function Unexplored(areas, explored)
	local known, result = {}, {}
	for _, area in ipairs(explored or {}) do
		known[OverlayKey(area.offsetX, area.offsetY, area.textureWidth, area.textureHeight)] = true
	end
	for _, area in ipairs(areas) do
		if not known[area.key] then
			result[#result + 1] = area
		end
	end
	return result
end

local cachedArt, cachedLayers

local function Areas(art, layer)
	if cachedArt ~= art then
		cachedArt = art
		cachedLayers = ns.Overlays[art] and Decode(ns.Overlays[art]) or {}
	end
	return cachedLayers[layer] or {}
end

function ns.SetupExploration(map)
	local pool, poolPin
	local masked = {}

	local function ExplorationPin()
		for pin in map:EnumeratePinsByTemplate("MapExplorationPinTemplate") do -- luacheck: ignore 512 (first only)
			return pin
		end
	end

	local function Draw()
		if pool then
			pool:ReleaseAll()
		end
		if not ns.Enabled("exploration") then
			return
		end
		local pin = ExplorationPin()
		local mapID = map:GetMapID()
		local info = mapID and C_Map.GetMapInfo(mapID)
		if not pin or not info or info.mapType ~= Enum.UIMapType.Zone then
			return
		end
		if poolPin ~= pin then
			pool, poolPin = CreateTexturePool(pin, "ARTWORK", -1), pin
		end
		local art = C_Map.GetMapArtID(mapID)
		local index = map:GetCanvasContainer():GetCurrentLayerIndex()
		local layers = C_Map.GetMapArtLayers(mapID)
		local layer = layers and layers[index]
		if not art or not layer then
			return
		end
		local mask = map:GetMaskTexture()
		local useMask = mask and map:GetUseMaskTexture() or false
		local explored = C_MapExplorationInfo.GetExploredMapTextures(mapID)
		for _, area in ipairs(Unexplored(Areas(art, index), explored)) do
			for i, tile in ipairs(OverlayTiles(area.width, area.height, layer.tileWidth, layer.tileHeight)) do
				local texture = pool:Acquire()
				if mask and masked[texture] ~= useMask then
					if useMask then
						texture:AddMaskTexture(mask)
					else
						texture:RemoveMaskTexture(mask)
					end
					masked[texture] = useMask
				end
				texture:SetTexture(area.files[i], nil, nil, "TRILINEAR")
				texture:SetSize(tile.width, tile.height)
				texture:SetTexCoord(0, tile.u, 0, tile.v)
				texture:ClearAllPoints()
				texture:SetPoint("TOPLEFT", area.x + tile.x, -(area.y + tile.y))
				texture:SetVertexColor(TINT_R, TINT_G, TINT_B, TINT_A)
				texture:Show()
			end
		end
	end

	local Provider = CreateFromMixins(MapCanvasDataProviderMixin)
	function Provider.RemoveAllData()
		if pool then
			pool:ReleaseAll()
		end
	end
	Provider.RefreshAllData = Draw
	Provider.OnCanvasScaleChanged = Draw
	ns.RefreshExploration = Draw
	map:AddDataProvider(Provider)
end
