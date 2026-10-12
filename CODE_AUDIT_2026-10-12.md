# Map Tweaks audit — 2026-10-12

Target: World of Warcraft Forever, `## Interface: 16001`, Lua 5.1.
References: Ketho's vscode-wow-api annotations, the Forever API, and the other Joipov addons.

## Already in good shape

Combat pin clearing and the zoom redraw cache from the 2026-10-11 pass still hold. Entrance settle stays on a 0.25s throttle. The license is GPL-3.0-or-later, and the source notes in the README and file headers stay.

## This pass

- `Options.lua` loads last. Nothing calls it until `ADDON_LOADED`, which fires after the TOC list.
- TOC fields follow the house order.
- The README uses the same Features and Commands headings as the other addons.
- The unreleased dungeon pins are version 1.3.3.
- Ketho's annotation path stays in `.luarc.json`. That file is the library list LuaLS uses for this addon.

## Zone level labels

The area label's `OnUpdate` stays. Hooking `EvaluateLabels` wrote a field onto the frame and the map's data providers then failed, so the label's own update is what appends the range after it draws. The handler returns as soon as the text already matches.
