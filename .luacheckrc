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

globals = {
	"TransportsDockPinMixin",
	"TransportsRoutePinMixin",
}

read_globals = {
	"C_AddOns",
	"C_Map",
	"C_Texture",
	"Enum",

	"AM_PIN_SCALE_STYLE_WITH_TERRAIN",
	"Clamp",
	"CreateColor",
	"CreateFrame",
	"CreateFromMixins",
	"CreateVector2D",
	"GameTooltip",
	"GameTooltip_AddColoredDoubleLine",
	"GameTooltip_AddColoredLine",
	"GameTooltip_AddInstructionLine",
	"GameTooltip_SetTitle",
	"GRAY_FONT_COLOR",
	"HIGHLIGHT_FONT_COLOR",
	"InCombatLockdown",
	"IsModifierKeyDown",
	"Lerp",
	"MapCanvasDataProviderMixin",
	"MapCanvasPinMixin",
	"MenuUtil",
	"NORMAL_FONT_COLOR",
	"PIN_FRAME_LEVEL_FOG_OF_WAR",
	"PIN_FRAME_LEVEL_GOSSIP",
	"PIN_FRAME_LEVEL_QUEST_PING",
	"Saturate",
	"UNKNOWN",
	"WorldMapFrame",
}
