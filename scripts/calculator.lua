local math2d = require("__core__.lualib.math2d")
local masks = require("scripts.rail_masks")
local drive_directions = require("scripts.direction")

local tile_calculations_per_tick = 1000

local function entity_pos_to_built_pos(entity)
    return math2d.position.add(entity.position, {0.5, 0.5})
end

local function weight(d)
    return 1/(math.abs(d)^2+1)
end

---@param railbow_calculation RailBowCalculation
---@return RailBowCalculation
local function do_mask_accumulation(railbow_calculation)
    local mask_calculation = railbow_calculation.mask_calculation

    local iteration_state = mask_calculation.iteration_state

    local rail_calculations_per_tick = settings.global["railbow-rail-calculations-per-tick"].value
    local i0 = iteration_state.last_step + 1
    local i1 = math.min(iteration_state.last_step + rail_calculations_per_tick, iteration_state.n_steps)

    local p0 = mask_calculation.p0
    local tile_min = mask_calculation.tiles_min
    local tile_max = mask_calculation.tiles_max
    local tile_map = mask_calculation.tile_map
    local tile_array = mask_calculation.tile_array

    for i = i0, i1 do
        local entity = mask_calculation.rails[i]
        local pos_i = math2d.position.subtract(entity_pos_to_built_pos(entity), p0)
        local mask = masks[entity.name][entity.direction]
        for d, elem_i in pairs(mask) do

            local d_map = drive_directions.mapper[mask_calculation.drive_directions[entity.unit_number]]
            local d_ = d_map(d)
            if d_ < tile_min or d_ > tile_max then
                goto continue
            end
            local w = weight(d)
            for _, elem_j in pairs(elem_i) do
                local pos_j = math2d.position.add(pos_i, elem_j.pos)
                if not tile_map[pos_j.x] then
                    tile_map[pos_j.x] = {}
                end
                if not tile_map[pos_j.x][pos_j.y] then
                    tile_map[pos_j.x][pos_j.y] = {}
                    table.insert(tile_array, {pos_j.x, pos_j.y})
                end
                if not tile_map[pos_j.x][pos_j.y][d_] then
                    tile_map[pos_j.x][pos_j.y][d_] = 0.0
                end
                if elem_j.o then
                    tile_map[pos_j.x][pos_j.y][d_] = tile_map[pos_j.x][pos_j.y][d_] + w/2
                else
                    tile_map[pos_j.x][pos_j.y][d_] = tile_map[pos_j.x][pos_j.y][d_] + w
                end
            end
            ::continue::
        end
    end
    iteration_state.last_step = i1
    if iteration_state.last_step == iteration_state.n_steps then
        iteration_state.calculation_complete = true
        railbow_calculation.tile_calculation.iteration_state.n_steps = #tile_array
    end
    mask_calculation.tile_map = tile_map
    mask_calculation.tile_array = tile_array
    mask_calculation.iteration_state = iteration_state
    railbow_calculation.mask_calculation = mask_calculation
    return railbow_calculation
end

---@param railbow_calculation RailBowCalculation
---@return RailBowCalculation
local function do_tile_picking(railbow_calculation)
    local mask_calculation = railbow_calculation.mask_calculation
    local tile_calculation = railbow_calculation.tile_calculation

    local iteration_state = tile_calculation.iteration_state
    local blueprint_tiles = tile_calculation.blueprint_tiles
    local tile_map = mask_calculation.tile_map
    local tile_array = mask_calculation.tile_array
    local tiles = mask_calculation.tiles

    local tile_calculations_per_tick = settings.global["railbow-tile-calculations-per-tick"].value
    local i0 = iteration_state.last_step + 1
    local i1 = math.min(iteration_state.last_step + tile_calculations_per_tick, iteration_state.n_steps)

    for i = i0, i1 do
        local pos = tile_array[i]
        local max = 0
        local max_d = 0
        for d, w in pairs(tile_map[pos[1]][pos[2]]) do
            if w > max then
                max = w
                max_d = d
            end
        end
        local name = tiles[max_d]
        if name then
            table.insert(blueprint_tiles, {name = name, position = pos})
        end
    end

    iteration_state.last_step = i1
    if iteration_state.last_step == iteration_state.n_steps then
        iteration_state.calculation_complete = true
    end
    tile_calculation.blueprint_tiles = blueprint_tiles
    tile_calculation.iteration_state = iteration_state
    railbow_calculation.tile_calculation = tile_calculation
    return railbow_calculation
end

local function work()
    if not global.railbow_calculation_queue then
        return
    end
    local railbow_calculation = global.railbow_calculation_queue[1]
    if not railbow_calculation then
        return
    end

    if not railbow_calculation.mask_calculation.iteration_state.calculation_complete then
        global.railbow_calculation_queue[1] = do_mask_accumulation(railbow_calculation)
        return
    end

    if railbow_calculation.mask_calculation.iteration_state.calculation_complete then
        if not railbow_calculation.tile_calculation.iteration_state.calculation_complete then
            global.railbow_calculation_queue[1] = do_tile_picking(railbow_calculation)
            return
        end
    end

    railbow_calculation.inventory.insert({name = "blueprint", count = 1})
    local blueprint = railbow_calculation.inventory[1]
    blueprint.blueprint_absolute_snapping = true
    blueprint.blueprint_snap_to_grid = {x = 1, y = 1}
    blueprint.blueprint_position_relative_to_grid = { x = 0, y = 0 }
    blueprint.set_blueprint_tiles(railbow_calculation.tile_calculation.blueprint_tiles)

    blueprint.build_blueprint{
        surface = railbow_calculation.mask_calculation.rails[1].surface,
        force = game.players[railbow_calculation.player_index].force,
        position = railbow_calculation.mask_calculation.p0,
        force_build = true,
        by_player = game.players[railbow_calculation.player_index],
        create_build_effect_smoke = false,
    }

    table.remove(global.railbow_calculation_queue, 1)
end

local calculator = {}

calculator.events = {
    [defines.events.on_tick] = work
}

return calculator