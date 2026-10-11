-- luacheck configuration: Lua 5.1, the WoW globals this addon reads,
-- and the mixin globals it writes.
std = "lua51"
max_line_length = false
self = false

exclude_files = {
	".release/",
	".annotations/",
	"assets/",
}

-- Unit tests run under plain Lua 5.1 / LuaJIT. Database.lua creates one event
-- frame at load, which the test stubs.
files["tests/"] = {
	std = "lua51",
	globals = {
		"CreateFrame",
		"MapTweaksDB",
	},
}

globals = {
	"MapTweaksDB",
	"MapTweaksDockPinMixin",
	"MapTweaksEntrancePinMixin",
	"MapTweaksRoutePinMixin",
	"MapTweaks_OnAddonCompartmentClick",
	"MapTweaks_OnAddonCompartmentEnter",
	"MapTweaks_OnAddonCompartmentLeave",
	"SLASH_MAPTWEAKS1",
	"SLASH_MAPTWEAKS2",
	SlashCmdList = { fields = { "MAPTWEAKS" } },
}

read_globals = {
	"C_AddOns",
	"C_Map",
	"C_Texture",
	"Enum",

	"AM_PIN_SCALE_STYLE_WITH_TERRAIN",
	"AreaLabelDataProviderMixin",
	"BaseMapPoiPinMixin",
	"C_Timer",
	"Clamp",
	"CreateColor",
	"CreateFrame",
	"CreateFromMixins",
	"CreateTexturePool",
	"CreateVector2D",
	"C_MapExplorationInfo",
	"C_SuperTrack",
	"FONT_COLOR_CODE_CLOSE",
	"GameTooltip",
	"GameTooltip_AddColoredDoubleLine",
	"GameTooltip_AddColoredLine",
	"GameTooltip_AddInstructionLine",
	"GameTooltip_SetTitle",
	"GetCursorPosition",
	"GetCVarBool",
	"GetRealZoneText",
	"GetRelativeDifficultyColor",
	"GRAY_FONT_COLOR",
	"HIGHLIGHT_FONT_COLOR",
	"InCombatLockdown",
	"IsModifierKeyDown",
	"Lerp",
	"LibStub",
	"MapCanvasDataProviderMixin",
	"MapCanvasPinMixin",
	"MenuUtil",
	"Minimap",
	"NORMAL_FONT_COLOR",
	"RGBTableToColorCode",
	"PIN_FRAME_LEVEL_FOG_OF_WAR",
	"PIN_FRAME_LEVEL_GOSSIP",
	"PIN_FRAME_LEVEL_QUEST_PING",
	"print",
	"Saturate",
	"Settings",
	"UIParent",
	"UiMapPoint",
	"UnitEffectiveLevel",
	"UNKNOWN",
	"WorldMapFrame",
}
