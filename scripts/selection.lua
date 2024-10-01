local drive_directions = require("scripts.direction")

local rail_list = {"curved-rail", "straight-rail"}
local signal_list = {"rail-signal", "rail-chain-signal"}

local function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

table.contains = contains

local function seperate_signals_and_rails(entities)
    local signals = {}
    local rails = {}
    for _, entity in pairs(entities) do
        if table.contains(rail_list, entity.name) then
            table.insert(rails, entity)
        elseif table.contains(signal_list, entity.name) then
            table.insert(signals, entity)
        end
    end
    return signals, rails
end

local function on_player_selected_area(e)
    if e.item ~= "railbow-selection-tool" then
        return
    end
    if not next(e.entities) then
        return
    end
    local player = game.get_player(e.player_index)
    if not player then
        return
    end
    if global.railbow_tools[player.index].calculation_active then
        game.print("There is an ongoing calculation for you, cannot start a new one.")
        return
    end

    local signals, rails = seperate_signals_and_rails(e.entities)
    global.railbow_tools[player.index].rails = rails
    global.railbow_tools[player.index].drive_directions = drive_directions.get_all(signals, rails)
    global.railbow_tools[player.index].calculation_active = true
    global.railbow_tools[player.index].n_steps = #rails

end

local selection = {}

selection.events = {
    [defines.events.on_player_selected_area] = on_player_selected_area
}

return selection