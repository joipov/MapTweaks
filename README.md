# MapTweaks

World map additions for World of Warcraft **Forever** (`camelot`, TOC `## Interface: 16001`).

- Boat and zeppelin docks. Hover one to see the crossing and where it goes. Click to open that map. Both factions are shown, and a dock that belongs to one faction says so on the tooltip.
- Unexplored zone terrain, drawn in a dim blue tint under the explored tiles.
- The level range of the zone under the cursor, colored the way quest levels are.
- Dungeon and raid entrances, using the retail icons. They follow the map's own "Show instance entrances" checkbox. Click one to set a waypoint.

The docks and the zeppelin icon are adapted from [Shortest Path Forever](https://github.com/cjber/shortest-path-forever) by cjber. The overlays, zone ranges, and entrance pins are adapted from [Tweaks Forever](https://github.com/cjber/tweaks-forever) by cjber. Both are GPL-3.0-or-later, and so is this addon. It does not calculate paths, track departure times, or put anything on the minimap.

## Development

The repository lives outside the game folder. The AddOns entry is a directory junction to it:

```
mklink /J "C:\Program Files (x86)\World of Warcraft\_classic_beta_\Interface\AddOns\MapTweaks" "D:\Repos\Joipov\MapTweaks"
```

Static check (no game client needed):

```
luacheck .
```

LuaLS uses `.luarc.json` and Ketho's WoW API annotations.

`assets/` is release media for CurseForge and Wago. The game does not load it, and it is not part of the addon zip.
