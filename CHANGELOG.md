# Changelog

## 1.3.0

Minimap button, and fewer stale pins when the map changes in combat.

### Added

- A minimap button, via LibDBIcon when present and a built-in button otherwise. On by default. Click opens settings.

### Fixed

- A map change in combat no longer leaves the previous map's dock pins and route lines on screen. They are released and rebuilt when combat ends.

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
