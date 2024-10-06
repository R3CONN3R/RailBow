local gui_layout = require("scripts.gui_layout")
local gui_updates = require("scripts.gui_updates")

local function open_gui(player)
    if player.gui.screen.railbow_window then
        player.gui.screen.railbow_window.destroy()
    else
        gui_layout.create_railbow_window(player)
    end
end

local function close_gui(player)
    if player.gui.screen.railbow_window then
        player.gui.screen.railbow_window.destroy()
    end
end

local function gui_click(e)
    local element = e.element
    if not element.valid then return end
    local player = game.get_player(e.player_index)
    if not player then return end

    if element.name == "railbow_button" then
        open_gui(player)
    elseif element.name == "railbow_close_button" then
        close_gui(player)
    elseif element.name == "railbow_add_preset_button" then
        gui_updates.add_preset(player)
    elseif string.find(element.name, "railbow_preset_button_") then
        local index = tonumber(element.name:match("([+-]?%d+)$"))
        if index then
            gui_updates.change_preset(player, index)
        end
    elseif element.name == "railbow_delete_preset_button" then
        gui_updates.delete_preset(player)
    elseif element.name == "railbow_copy_preset_button" then
        gui_updates.copy_preset(player)
    end
end

local function gui_closed(e)
    local player = game.get_player(e.player_index)
    if not player then return end
    if e.element and e.element.name == "railbow_window" then
        close_gui(player)
    end
end

local function selector_changed(event)
    local element = event.element
    local player_index = event.player_index
    if string.find(element.name, "railbow_tile_selector_") then
        local index = tonumber(element.name:match("([+-]?%d+)$"))
        if index then
            local opened_preset = global.railbow_tools[player_index].opened_preset
            global.railbow_tools[player_index].presets[opened_preset].tiles[index] = element.elem_value
        end
    end
end

local function text_changed(event)
    local element = event.element
    local player_index = event.player_index
    local player = game.get_player(player_index)
    if not player then return end
    if element.name == "railbow_preset_name" then
        local opened_preset = global.railbow_tools[player_index].opened_preset
        global.railbow_tools[player_index].presets[opened_preset].name = element.text
        gui_layout.add_preset_list(player.gui.screen.railbow_window.configuration_flow.preset_selection_frame, "opened")
    end
end

local function checked_state_changed(event)
    local element = event.element
    local player_index = event.player_index
    local player = game.get_player(player_index)
    if not player then return end
    if string.find(element.name, "railbow_preset_activity_") then
        local index = tonumber(element.name:match("([+-]?%d+)$"))
        if index then
            global.railbow_tools[player_index].selected_preset = index
        end
        gui_layout.add_preset_list(player.gui.screen.railbow_window.configuration_flow.preset_selection_frame, "selected")
        gui_layout.add_elem_choose_header(player.gui.screen.railbow_window.configuration_flow.tile_selection_frame)
        gui_layout.add_choose_elem_table(player.gui.screen.railbow_window.configuration_flow.tile_selection_frame)
    end
end

-- local function switch_pressed(event)
--     local element = event.element
--     local player_index = event.player_index
--     local player = game.get_player(player_index)
--     if not player then return end
--     if element.name == "railbow_switch_button" then
--         global.railbow_tools[player_index].selected_preset = global.railbow_tools[player_index].opened_preset
--         gui_layout.add_preset_list(player.gui.screen.railbow_window.configuration_flow.preset_selection_frame, "opened")

--     end
-- end

local gui = {}

gui.events = {
    [defines.events.on_gui_click] = gui_click,
    [defines.events.on_gui_elem_changed] = selector_changed,
    [defines.events.on_gui_closed] = gui_closed,
    [defines.events.on_gui_text_changed] = text_changed,
    [defines.events.on_gui_checked_state_changed] = checked_state_changed,
    -- [defines.events.on_gui_switch_state_changed] = switch_pressed
}

return gui