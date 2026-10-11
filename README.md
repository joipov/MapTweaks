# Transports

Boats and zeppelins on the world map for World of Warcraft **Forever** (`camelot`, TOC `## Interface: 16001`). Hover a dock to see the crossing and where it goes. Click to open that map.

Both factions are shown. A dock that belongs to one faction says so on the tooltip.

The route lines and the zeppelin icon are adapted from [Shortest Path Forever](https://github.com/cjber/shortest-path-forever) by cjber, which is GPL-3.0-or-later. This addon is GPL-3.0-or-later for that reason. It does not calculate paths, track departure times, or put anything on the minimap.

## Development

The repository lives outside the game folder. The AddOns entry is a directory junction to it:

```
mklink /J "C:\Program Files (x86)\World of Warcraft\_classic_beta_\Interface\AddOns\Transports" "D:\Repos\Joipov\Transports"
```

Static check (no game client needed):

```
luacheck .
```

LuaLS uses `.luarc.json` and Ketho's WoW API annotations.

`assets/` is release media for CurseForge and Wago. The game does not load it, and it is not part of the addon zip.
