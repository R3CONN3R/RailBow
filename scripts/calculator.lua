local Event = require('__stdlib__/stdlib/event/event')
local math2d = require("__core__.lualib.math2d")
local masks = require("scripts.rail_masks")
local drive_directions = require("scripts.direction")

local rail_calculations_per_tick = 25

local function entity_pos_to_built_pos(entity)
    return math2d.position.add(entity.position, {0.5, 0.5})
end

local function weight(d)
    return 1/(math.abs(d)^2+1)
end

local function work_batch(player_index, rail_calculations)

    local p0 = entity_pos_to_built_pos(global.railbow_tools[player_index].rails[1])
    local railbow_cache = global.railbow_tools[player_index]  
    local i0 = railbow_cache.last_step + 1
    local i1 = math.min(railbow_cache.last_step + rail_calculations, railbow_cache.n_steps)

    local tile_min = -8
    for i = -8, 8 do
        if i ~=0 and railbow_cache.tiles[i] then
            tile_min = i
            break
        end
    end
    
    local tile_max = 8
    for i = 8, -8, -1 do
        if i ~=0 and railbow_cache.tiles[i] then
            tile_max = i
            break
        end
    end

    for i = i0, i1 do
        local entity = railbow_cache.rails[i]
        local pos_i = math2d.position.subtract(entity_pos_to_built_pos(entity), p0)
        local mask = masks[entity.name][entity.direction]
        for d, elem_i in pairs(mask) do

            local d_map = drive_directions.mapper[railbow_cache.drive_directions[entity.unit_number]]
            local d_ = d_map(d)
            if d_ < tile_min or d_ > tile_max then
                goto continue
            end
            local w = weight(d)
            for _, elem_j in pairs(elem_i) do
                local pos_j = math2d.position.add(pos_i, elem_j.pos)
                if not railbow_cache.tile_map[pos_j.x] then
                    railbow_cache.tile_map[pos_j.x] = {}
                end
                if not railbow_cache.tile_map[pos_j.x][pos_j.y] then
                    railbow_cache.tile_map[pos_j.x][pos_j.y] = {}
                end
                if not railbow_cache.tile_map[pos_j.x][pos_j.y][d_] then
                    railbow_cache.tile_map[pos_j.x][pos_j.y][d_] = 0.0
                end
                if elem_j.o then
                    railbow_cache.tile_map[pos_j.x][pos_j.y][d_] = railbow_cache.tile_map[pos_j.x][pos_j.y][d_] + w/2
                else
                    railbow_cache.tile_map[pos_j.x][pos_j.y][d_] = railbow_cache.tile_map[pos_j.x][pos_j.y][d_] + w
                end
            end
            ::continue::
        end
    end
    railbow_cache.last_step = i1
    global.railbow_tools[player_index] = railbow_cache
end

local function batch_jobs()
    local n_jobs = 0
    for _, railbow_cache in pairs(global.railbow_tools) do
        if railbow_cache.calculation_active then
            n_jobs = n_jobs + 1
        end
    end

    if n_jobs == 0 then
        return
    end

    local calculations_per_player = math.ceil(rail_calculations_per_tick / n_jobs)
    for player_index, railbow_cache in pairs(global.railbow_tools) do
        if railbow_cache.calculation_active then
            work_batch(player_index, calculations_per_player)
        end
    end
end

Event.register(defines.events.on_tick, batch_jobs)