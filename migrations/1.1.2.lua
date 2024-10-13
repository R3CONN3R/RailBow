for _, player in pairs(game.players) do
    local player_data = global.railbow_tools[player.index]
    for _, preset in pairs(player_data.presets) do
        if not preset.tiles then
            preset.tiles = {}
        end
    end
end