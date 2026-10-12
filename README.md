# Map Tweaks

World map additions: boats, zeppelins, unexplored terrain, zone levels, and instance entrances.

Target client: World of Warcraft **Forever** (`## Interface: 16001`).

## Features

- Boat and zeppelin docks. Hover one to see the crossing and where it goes. Click to open that map. Both factions are shown, and a dock that belongs to one faction says so on the tooltip.
- Unexplored zone terrain, drawn in a dim blue tint under the explored tiles.
- The level range of the zone under the cursor, colored the way quest levels are.
- Dungeon and raid entrances, using the retail icons. They follow the map's own "Show instance entrances" checkbox. Click one to set a waypoint.

Each of those four can be turned off on its own. Esc > Options > AddOns > Map Tweaks opens the same panel.

The docks and the zeppelin icon are adapted from [Shortest Path Forever](https://github.com/cjber/shortest-path-forever) by cjber. The overlays, zone ranges, and entrance pins are adapted from [Tweaks Forever](https://github.com/cjber/tweaks-forever) by cjber. Both are GPL-3.0-or-later, and so is this addon. It does not calculate paths or track departure times.

## Commands

| Command | Effect |
| --- | --- |
| `/mt`, `/maptweaks` | Open the settings panel |

The addon compartment and the minimap button open the same panel.

## Files

Loaded in TOC order; modules communicate only through the shared `ns` table.

| File | Concern |
| --- | --- |
| `Database.lua` | SavedVariables defaults, validation, event frame |
| `Transports.lua`, `Lines.lua`, `Docks.lua`, `Docks.xml` | Boat and zeppelin docks |
| `Overlays.lua`, `Exploration.lua` | Unexplored zone terrain |
| `ZoneRanges.lua`, `ZoneLevels.lua` | Zone level ranges |
| `EntranceData.lua`, `Entrances.lua`, `Entrances.xml` | Dungeon and raid entrances |
| `Load.lua` | Installs the features on the world map |
| `MinimapButton.lua` | LibDBIcon launcher or built-in button |
| `Options.lua` | Settings panel, addon compartment, slash commands |

## Development

The repository lives outside the game folder. The AddOns entry is a directory junction to it:

```
mklink /J "C:\Program Files (x86)\World of Warcraft\_classic_beta_\Interface\AddOns\MapTweaks" "D:\Repos\Joipov\MapTweaks"
```

Static checks (no game client needed):

```
luacheck .            # .luacheckrc: Lua 5.1, explicit WoW globals
luajit tests/run.lua  # or: lua5.1 tests/run.lua
```

LuaLS uses `.luarc.json` and Ketho's WoW API annotations.

`assets/` is release media for CurseForge and Wago. The game does not load it, and it is not part of the addon zip. Do not delete it during cleanup.

Local zip, with the addon folder at the root, written to `.release/`:

```
powershell -File package.ps1
```

Releases: push an annotated tag (`git tag -a 1.3.0 -m "1.3.0"`). The `Package and release` workflow runs BigWigsMods/packager.
