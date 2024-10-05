if global.railbow_tools then
    for player_id, data in pairs(global.railbow_tools) do
        --- @type RailBowSelectionTool
        local new_data = {
            tiles = data.tiles,
        }
        global.railbow_tools[player_id] = new_data
    end
else
    global.railbow_tools = {}
end

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

for _, player in pairs(game.players) do
    if not global.railbow_tools[player.index] then
        global.railbow_tools[player.index] = {
            tiles = init_tiles,
        }
    end
end

global.railbow_calculation_queue = global.railbow_calculation_queue or {}