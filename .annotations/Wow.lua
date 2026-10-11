---@meta

-- Optional Blizzard frames are read through `_G.<name>` in some map code.
-- LuaLS has the Lua builtins disabled, so `_G` has no index type and such
-- lookups would be "undefined-field". Type `_G` here so they resolve.
---@type table<string, any>
_G = _G
