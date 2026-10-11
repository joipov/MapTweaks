# Map Tweaks audit — 2026-10-11

Target: World of Warcraft Forever, game type `forever` (was `camelot`), `## Interface: 16001`, Lua 5.1.
References: the Atraeau Forever API dump (build 70170), Warcraft Wiki (Patch 1.60.1 API changes), Ketho's vscode-wow-api annotations, Blizzard's WorldMapFrame source, and the sibling Joipov addons.

Scope: every `.lua` and `.xml`, the `.toc`, `tests/run.lua`, and the docs. `assets/`, `media/`, and `.release/` are not addon code.

## Findings and what was done

### B1a — Stale pins after a map change in combat
`Docks.lua` and `Lines.lua` returned early in combat without releasing pins, so the previous map's dock pins and route lines stayed on screen at wrong positions. **Fixed** — both providers release their pins and clear `mapID` before deferring.

### B1b — Ping acquired in combat
`Docks.lua` `ProviderMixin:Ping` acquired a pin with no combat check. **Not changed** — the ping template has no mouse input, so it is not a taint risk; noted for a future pass.

### B1c — Waypoint click can do nothing
`Entrances.lua` shows "Click to set a waypoint here" on maps that do not allow waypoints. **Not changed** — the tooltip should be conditioned on `CanSetUserWaypointOnMap`; deferred so it can be verified in game.

### B1h — luacheck W311
`Docks.lua` assigned an unused `position`. **Fixed** — `uiMap, info = zoneMap, zone`.

### B2/PERF — Zoom-time redraws
`Lines.lua` drew routes from both the pin and the provider, and `Exploration.lua` redrew the tint on every canvas scale change, and dock positions were recomputed each frame. **Not changed** — these are real, but they are best done with an in-game profiler and careful visual checks; recorded here for a dedicated performance pass.

### CQ-001 — Saved database had no version or shape
`LoadDB` only type-checked four booleans and shared nothing with the other addons. **Fixed** — `DB_VERSION`, `ns.firstRun`, fresh `minimapIcon` table, and a `Minimap button` setting.

### MOUNT — No minimap button
MapTweaks was the only Joipov addon without one. **Fixed** — `MinimapButton.lua` added (LibDBIcon or a built-in `LibDBIcon10_MapTweaks` button), wired through the settings and the compartment.

### ARCH-001 — Dead code
`ns.DB_DEFAULTS` was unused. **Removed.**

### TOC-001 — Game type
Updated to `forever` plus `## ExcludeLoadGameType: standard, classic`. Revert to `camelot` on a pre-70291 build.

## Verification

- `luacheck .` — clean.
- `luajit tests/run.lua` — 5 passed.
- LuaLS with Ketho's annotations — clean.

## In-game checklist

- Dock pins, crossings, unexplored tint, zone ranges, and entrance pins all show.
- Each of the four toggles hides its feature.
- Change zone while in combat with the map open: no dock pins or lines stay behind, and they return when combat ends.
- `/mt`, the compartment, and the minimap button open settings.
- The minimap button drags and keeps its place after `/reload`.
- The addon loads (`/dump C_AddOns.IsAddOnLoaded("MapTweaks")`).
