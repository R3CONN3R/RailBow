local math2d = require("__core__.lualib.math2d")

local function entity_pos_to_built_pos(entity)
    return math2d.position.add(entity.position, {0.5, 0.5})
end

local function main(e)
    for player_index, railbow_cache in pairs(global.railbow_tools) do
        local player = game.get_player(player_index)
        if not player then
            goto countinue
        end

        if not railbow_cache.calculation_active then
            goto countinue
        end

        if not (railbow_cache.last_step == railbow_cache.n_steps) then
            goto countinue
        end
        local blueprint_tiles = {}

        for x, row in pairs(railbow_cache.tile_map) do
            for y, col in pairs(row) do
                local max = 0
                local max_d = 0
                for d, w in pairs(col) do
                    if w > max then
                        max = w
                        max_d = d
                    end
                end
                local name = railbow_cache.tiles[max_d]
                if name then
                    table.insert(blueprint_tiles, {name = name, position = {x, y}})
                end
            end
        end

        local p0 = entity_pos_to_built_pos(railbow_cache.rails[1])

        railbow_cache.blueprints.insert({name = "blueprint", count = 1})
        local blueprint = railbow_cache.blueprints[1]

        blueprint.blueprint_absolute_snapping = true
        blueprint.blueprint_snap_to_grid = {x = 1, y = 1}
        blueprint.blueprint_position_relative_to_grid = { x = 0, y = 0 }
        blueprint.set_blueprint_tiles(blueprint_tiles)

        blueprint.build_blueprint{
                    surface = railbow_cache.rails[1].surface,
                    force = player.force,
                    position = p0,
                    force_build = true,
                    by_player = player,
                    create_build_effect_smoke = false,
                }

        railbow_cache.blueprints.clear()
        railbow_cache.rails = {}
        railbow_cache.drive_directions = {}
        railbow_cache.calculation_active = false
        railbow_cache.n_steps = 0
        railbow_cache.last_step = 0
        railbow_cache.tile_map = {}
        global.railbow_tools[player_index] = railbow_cache

        ::countinue::
    end
end

local builder = {}
builder.events = {
    [defines.events.on_tick] = main
}

return builder