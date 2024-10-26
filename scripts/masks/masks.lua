local curved_rail_a = require("scripts.masks.curved_rail_a")
local curved_rail_b = require("scripts.masks.curved_rail_b")
local straight_rail = require("scripts.masks.straight_rail")
local half_diagonal_rail = require("scripts.masks.half_diagonal_rail")

--- @class TileInfo
--- @field pos Vector
--- @field n Vector
--- @field o boolean

--- @class Mask
--- @field table table<integer, TileInfo[]>|nil

local masks = {
    ["curved-rail-a"] = curved_rail_a,
    ["curved-rail-b"] = curved_rail_b,
    ["straight-rail"] = straight_rail,
    ["half-diagonal-rail"] = half_diagonal_rail,
}

return masks
