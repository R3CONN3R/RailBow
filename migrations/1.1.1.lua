local util = require("__core__.lualib.util")

local init_tiles = {}
for i = -8, 8 do
    if i ~= 0 then
        init_tiles[i] = nil
    end
end

--- Close any open railbow windows
for _, player in pairs(game.players) do
    if player.gui.screen.railbow_window then
        player.gui.screen.railbow_window.destroy()
    end
end

--- Handle missing railbow_calculation_queue array
if not global.railbow_calculation_queue then
    global.railbow_calculation_queue = {}
end

--- Handle missing railbow_tools table
if not global.railbow_tools then
    global.railbow_tools = {}
end

--- Handle missing presets table per player
for player_index, _ in pairs(game.players) do
    if not global.railbow_tools[player_index] then
        global.railbow_tools[player_index] = {
            presets = {
                {
                    name = "default",
                    tiles = util.table.deepcopy(init_tiles),
                    mode = "vote"
                }
            },
            selected_preset = 1,
            opened_preset = 1
        }
    end
end

--- Handle misconfigured presets tables
for _, data in pairs(global.railbow_tools) do
    if (not data.presets) or (#data.presets == 0) then
        data.presets = {
            {
                name = "default",
                tiles = util.table.deepcopy(init_tiles),
                mode = "vote"
            }
        }
        data.selected_preset = 1
        data.opened_preset = 1
    end
end

--- Handle misconfgured preset indices
for _, data in pairs(global.railbow_tools) do
    if (not data.selected_preset) or (data.selected_preset < 1) or (data.selected_preset > #data.presets) then
        data.selected_preset = 1
    end
    if (not data.opened_preset) or (data.opened_preset < 1) or (data.opened_preset > #data.presets) then
        data.opened_preset = 1
    end
end