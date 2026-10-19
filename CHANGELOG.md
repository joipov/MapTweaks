# Changelog

## 1.3.9

Boat and zeppelin crossings draw dock to dock again, with a thinner stroke. Color stays Joipov violet.

### Fixed

- Overview and zone maps no longer draw the full loop past the docks; each crossing is pier to pier.

### Changed

- Route lines are 2 px thick again, with a 1 px dark outline around the stroke.

## 1.3.8

Boat and zeppelin crossings use the same Joipov violet.

### Changed

- Boat and zeppelin route lines are both Joipov violet (`#8b5cf6`).

## 1.3.7

The map data was checked against Forever 1.60.1.70425. Two Skyborne crossings follow the new course. Unexplored terrain, zone levels, and dungeon entrances are unchanged.

### Changed

- The Alliance skyship between Dalaran and Valanaar closes its loop farther west on Zephras Isle.
- The Horde zeppelin between Thunder Bluff and Zephras Isle bends slightly earlier on the approach to the island.
- Overlay, zone level, and route sources now cite Forever build 1.60.1.70425.

## 1.3.6

The map data was checked against Forever 1.60.1.70374. Boats, zeppelins, unexplored terrain, zone levels, and dungeon entrances are unchanged.

### Changed

- Overlay and zone level sources now cite Forever build 1.60.1.70374.

## 1.3.5

Boat and zeppelin routes are easier to tell apart, and the lines are a pixel thicker.

### Changed

- Boat routes are a lighter cyan, and zeppelin routes are brass.
- Route lines are 3 px thick, with the dark outline still one pixel around the stroke.

## 1.3.4

The minimap button tooltip is shorter.

### Changed

- The minimap button tooltip says the button opens settings.

## 1.3.3

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
