-- Four checkboxes in the game's own settings. Each feature turns off on its own.
local _, ns = ...

local Settings = Settings

local OPTIONS = {
	{
		key = "docks",
		label = "Boats and zeppelins",
		tip = "Dock pins, the crossing, and where each boat or zeppelin goes.",
	},
	{
		key = "exploration",
		label = "Unexplored areas",
		tip = "Dim blue terrain for the parts of a zone you have not explored.",
	},
	{
		key = "zoneLevels",
		label = "Zone level ranges",
		tip = "The level range after the name of the zone under the cursor.",
	},
	{
		key = "entrances",
		label = "Instance entrances",
		tip = "Dungeon and raid pins. They still follow the map's own Show instance entrances checkbox.",
	},
}

function ns.Print(text)
	print("|cffc4b5fdJoipov|r " .. ns.DISPLAY .. ": " .. tostring(text or ""))
end

local function Apply(key)
	if key == "docks" then
		if ns.RefreshDocks then
			ns.RefreshDocks()
		end
	elseif key == "exploration" then
		if ns.RefreshExploration then
			ns.RefreshExploration()
		end
	elseif key == "entrances" then
		if ns.RefreshEntrances then
			ns.RefreshEntrances()
		end
	end
end

function ns.OpenSettings()
	if not ns.settingsCategory then
		ns.InitOptions()
	end
	if not ns.settingsCategory then
		ns.Print("Settings are not available yet.")
		return
	end
	Settings.OpenToCategory(ns.settingsCategory:GetID())
end

function _G.MapTweaks_OnAddonCompartmentClick()
	ns.OpenSettings()
end

function _G.MapTweaks_OnAddonCompartmentEnter(_, owner)
	if not GameTooltip then
		return
	end
	GameTooltip:SetOwner(owner or UIParent, "ANCHOR_LEFT")
	GameTooltip:AddLine(ns.DISPLAY)
	GameTooltip:AddLine("Click to open settings", 1, 1, 1)
	GameTooltip:Show()
end

function _G.MapTweaks_OnAddonCompartmentLeave()
	if GameTooltip then
		GameTooltip:Hide()
	end
end

function ns.InitOptions()
	if ns.settingsCategory or not ns.db then
		return
	end

	local category = Settings.RegisterVerticalLayoutCategory(ns.DISPLAY)
	ns.settingsCategory = category

	for _, option in ipairs(OPTIONS) do
		local key = option.key
		local setting = Settings.RegisterAddOnSetting(
			category,
			"MAPTWEAKS_" .. key:upper(),
			key,
			ns.db,
			Settings.VarType.Boolean,
			option.label,
			true
		)
		setting:SetValueChangedCallback(function()
			Apply(key)
		end)
		Settings.CreateCheckbox(category, setting, option.tip)
	end

	Settings.RegisterAddOnCategory(category)
end

_G.SLASH_MAPTWEAKS1 = "/mt"
_G.SLASH_MAPTWEAKS2 = "/maptweaks"
_G.SlashCmdList.MAPTWEAKS = function()
	ns.OpenSettings()
end
