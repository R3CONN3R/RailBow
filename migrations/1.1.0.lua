if global.railbow_tools then
    for player_id, data in pairs(global.railbow_tools) do
        if not data.presets then
            --- @type RailBowSelectionTool
            local new_data = {
                presets = {
                    {
                        name = "Default",
                        tiles = data.tiles,
                    }
                },
                selected_preset = 1,
                opened_preset = 1
            }
            global.railbow_tools[player_id] = new_data
        end
    end
else
    global.railbow_tools = {}
end

for _, player in pairs(game.players) do
    if player.gui.screen.railbow_window then
        player.gui.screen.railbow_window.destroy()
    end
end