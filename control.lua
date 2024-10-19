local handler = require("__core__.lualib.event_handler")

--- @class IterationState
--- @field n_steps integer
--- @field last_step integer
--- @field calculation_complete boolean

--- @class MaskCalculation
--- @field tiles table<integer, string>
--- @field tiles_min integer
--- @field tiles_max integer
--- @field rails LuaEntity[]
--- @field drive_directions table<integer, integer>
--- @field p0 [integer, integer]
--- @field tile_map table<integer, table<integer, table<integer, number>>>
--- @field tile_array [integer, integer][]
--- @field iteration_state IterationState

--- @class TileCalculation
--- @field iteration_state IterationState

--- @class RailBowCalculation
--- @field player_index integer
--- @field inventory LuaInventory
--- @field mask_calculation MaskCalculation
--- @field tile_calculation TileCalculation

--- @class RailBowConfig
--- @field name string
--- @field tiles table<integer, string>

--- @class RailBowSelectionTool
--- @field presets RailBowConfig[]
--- @field selected_preset integer
--- @field opened_preset integer|nil
--- @field copied_tile string|nil

local function initialize_global(player)
    if not player then
        return
    end

    if not global.railbow_tools[player.index] then
        local init_tiles = {}
        for i = -8, 8 do
            if i ~= 0 then
                init_tiles[i] = nil
            end
        end

        --- @type RailBowConfig
        local init_config = {
            name = "default",
            tiles = init_tiles,
            mode = "vote"
        }

        global.railbow_tools[player.index] = {
            presets = {init_config},
            selected_preset = 1,
            opened_preset = nil,
            copied_tile = nil
        }
    end
end

local function create_button(player)
    if not player then return end
    if not player.gui.top.railbow_button then
        player.gui.top.add{
            type = "frame",
            name = "railbow_frame",
        }
        player.gui.top.railbow_frame.add{
            type = "sprite-button",
            name = "railbow_button",
            sprite = "item/railbow-selection-tool",
            tooltip = {"tooltips.railbow-open-gui"}
        }
    end
end

local function on_player_created(e)
    local player = game.get_player(e.player_index)
    initialize_global(player)
    create_button(player)
end

local function on_player_removed(e)
    global.railbow_tools[e.player_index] = nil
    for i, data in pairs(global.railbow_calculation_queue) do
        if data.player_index == e.player_index then
            table.remove(global.railbow_calculation_queue, i)
        end
    end
end

local function on_init()
    --- @type table<integer, RailBowSelectionTool>
    global.railbow_tools = {}
    --- @type RailBowCalculation[]
    global.railbow_calculation_queue = {}
    
    for _, player in pairs(game.players) do
        initialize_global(player)
        create_button(player)
    end
end

local control = {}

control.on_init = on_init

control.events = {
    [defines.events.on_player_created] = on_player_created,
    [defines.events.on_player_removed] = on_player_removed,
}

handler.add_libraries({
    control, 
    require("scripts.shortcut"),
    require("scripts.selection"),
    require("scripts.gui"),
    require("scripts.calculator"),
})