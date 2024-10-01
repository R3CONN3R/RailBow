local handler = require("__core__.lualib.event_handler")

--- @class RailBowSelectionTool
--- @field tiles table<integer, string>
--- @field blueprints LuaInventory
--- @field rails LuaEntity[]
--- @field drive_directions table<integer, integer>
--- @field calculation_active boolean
--- @field n_steps integer
--- @field last_step integer
--- @field tile_map table<integer, table<integer, table<integer, number>>>

local function initialize_global(player)
    if not player then
        return
    end

    if not global.railbow_tools[player.index] then
        local init_tiles = {}
        for i = -8, 8 do
            if i ~= 0 then
                if math.abs(i) == 1 then
                    init_tiles[i] = "refined-concrete"
                elseif math.abs(i) == 2 then 
                    init_tiles[i] = "concrete"
                elseif math.abs(i) == 3 then
                    init_tiles[i] = "stone-path"
                else
                    init_tiles[i] = nil
                end
            end
        end

        global.railbow_tools[player.index] = {
            tiles = init_tiles,
            blueprints = game.create_inventory(1),
            rails = {},
            drive_directions = {},
            calculation_active = false,
            n_steps = 0,
            last_step = 0,
            tile_map = {},
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
end



local function on_init()
    --- @type table<integer, RailBowSelectionTool>
    global.railbow_tools = {}
    
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
    require("scripts.builder")
})