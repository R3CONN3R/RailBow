for _, player in pairs(game.players) do
    if player.gui.screen.railbow_window then
        player.gui.screen.railbow_window.destroy()
    end
end