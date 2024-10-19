for i, _ in pairs(global.railbow_calculation_queue) do
    table.remove(global.railbow_calculation_queue, i)
end
for _, player in pairs(game.players) do
    if player.gui.top.railbow_frame then
        player.gui.top.railbow_frame.destroy()
    end
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
