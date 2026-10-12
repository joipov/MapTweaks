# Changelog

## Unreleased

New dungeon entrances on the world map.

### Added

- A dungeon entrance pin for Excavation Site: Wetlands, on the Wetlands map and on Eastern Kingdoms.
- The Hall of Thanes, in Ironforge.
- Ruins of Lordaeron, on the Tirisfal Glades and Undercity maps.
- City of Dalaran, on the Alterac Mountains, Silverpine Forest, and Dalaran City maps.

## 1.3.2

The login line shows the addon name and version. The Joipov name color is a brighter violet.

### Changed

- The login line reads Joipov <name> (v<version>). The name and version come from the TOC, so they never drift. The version is a different color.
- Joipov is now a saturated violet.

## 1.3.1

Minimap button, fewer stale pins when the map changes in combat, and a lighter map.

### Added

- A minimap button, via LibDBIcon when present and a built-in button otherwise. On by default. Click opens settings.

### Fixed

- A map change in combat no longer leaves the previous map's dock pins and route lines on screen. They are released and rebuilt when combat ends.
- The waypoint hint only shows on maps that allow waypoints.
- A dock ping is not placed in combat.

### Performance

- Route lines rescale without a full redraw when the map zooms.
- Dock, destination, and entrance lookups are cached.
- The unexplored tint no longer redraws on every zoom step.

### Changed

- The saved-variables table now has a version and a shared shape with the other Joipov addons.
- The addon loads only on the `forever` game type.

## 1.2.0

The addon list name is Map Tweaks. Each world map feature can be turned off on its own.

### Added

- Settings for boats and zeppelins, unexplored areas, zone level ranges, and instance entrances. `/mt` or `/maptweaks` opens them, and so does the addon compartment.

## 1.1.0

Renamed to MapTweaks. The world map also shows unexplored terrain, zone level ranges, and instance entrances.

### Added

- Unexplored parts of a zone map, in a dim blue tint under the explored tiles.
- The level range of the zone under the cursor, after its name, colored like a quest level.
- Dungeon and raid entrance pins with the retail icons. A complex lists each wing. Clicking one sets a waypoint, and the pins follow the map's "Show instance entrances" checkbox.

## 1.0.0

Boats and zeppelins on the world map.

### Added

- A dock pin for every boat and zeppelin. Boats use the map's ferry icon. Zeppelins use their own.
- Hovering a dock draws that crossing, names where it goes, and glows the other dock.
- Clicking a dock opens the destination map. A dock with more than one other map offers a menu.
