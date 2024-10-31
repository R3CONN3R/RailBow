local mod_gui = require("mod-gui")

for _, player in pairs(game.players) do
    if player.gui.top.railbow_frame then
        player.gui.top.railbow_frame.destroy()
    end
    local button_flow = mod_gui.get_button_flow(player)
    if not button_flow.railbow_button then
        button_flow.add{
            type = "sprite-button",
            name = "railbow_button",
            sprite = "item/railbow-selection-tool",
            tooltip = {"tooltips.railbow-open-gui"},
            style=mod_gui.button_style
        }
    end
end