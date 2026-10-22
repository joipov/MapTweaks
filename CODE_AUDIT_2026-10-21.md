# Map Tweaks audit

Target: World of Warcraft Forever, `## Interface: 16001` (client 1.60.1.70425), Lua 5.1.
Upstream, both GPL-3.0-or-later and credited in each adapted file:
Shortest Path Forever 1.21.8 and Tweaks Forever 0.15.2 (2026-10-21),
HiddenMaps 1.0.0.

This note is for development. It is not shipped in the addon zip.

## Data verdict (verified 2026-10-21)

Boat and zeppelin geometry is identical to upstream's regeneration for
build 1.60.1.70450: 25 docks, 13 routes (241, 285, 292, 293, 295, 301, 302,
303, 11167, 11391, 11398, 11457, 11616). Zone ranges and overlays are
unchanged from 70425 to 70450. Entrance data matches upstream plus the
Forever-only entrances upstream does not produce (2998, 2999, 2959, 3065),
which stay. Generated-file headers now say so. `tests/run.lua` asserts the
25/13 counts and that every route stop is a dock, so a future sync is
checkable instead of silent.

## What changed in 1.3.10

- `Transports.lua` and `Lines.lua` carry the "Adapted from Shortest Path
  Forever" header every other adapted file already had.
- Entrance settle: marker positions are collected once per 0.25 s tick and
  shared by all pins (was: full pin-template enumeration per pin). The
  collection also reads the `ForeverMapMarkers` global fresh each tick —
  current Shortest Path Forever and Tweaks Forever publish dock and
  entrance positions there instead of placing map pins — so entrances keep
  stepping aside for them. Entries that are not plain positions are
  ignored; a failing provider is skipped, not propagated.
- Exploration redraws on `MAP_EXPLORATION_UPDATED` while the map is shown.
- `Database.lua` is back to the house shape (`LoadDB -> MigrateDB ->
  CopyDefaults -> Validate`, exports `ns.defaults` and `ns.DB_VERSION`)
  and the event frame moved to `Load.lua`, so the saved-variables file is
  plain Lua for the tests again.
- Settings rows take defaults from `ns.defaults`.

## Recorded decisions

- Gamepad pin pools: upstream moved its pins off MapCanvas data providers
  (1.20.0 / 0.15.0) over a claimed gamepad blocked-action. That was not
  reproduced here, so the port is not done blind. To settle it: on the
  Forever client with a gamepad active, open the world map in and out of
  combat and watch for a blocked `SetPreferredGamepadInteractTarget`. If
  it reproduces, the port is mechanical (own-frame layer, drop
  `AddDataProvider` and the XML pin templates) and this note gets updated.
- Map Tweaks has no master Enable row: the four per-feature rows are the
  design. Recorded in STYLE.md.
- HiddenMaps draws over the same map at higher strata. Overlap is a
  test-and-see item, not a code change without a visible defect.

## Checked in the client (manual pass, 1.3.10)

- [ ] Boat, zeppelin, entrance, and unexplored features each on and off.
- [ ] Entrance pins step aside under flight points, docks, and (with
      Shortest Path Forever installed) its travel pins.
- [ ] Discover an area with the map open — the tint lifts at once.
