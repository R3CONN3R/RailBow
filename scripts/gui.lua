local function create_config_frame(player)
    local frame = player.gui.screen.add{
        type = "frame",
        name = "railbow_config_frame",
        direction = "vertical"
    }
    frame.location = {75, 75}
    player.opened = frame

    local title_bar = frame.add{
        type = "flow", 
        name = "title_bar", 
        direction = "horizontal"
    }

    title_bar.add{
        type = "label",
        style = "frame_title",
        caption = {"titles.railbow-gui-title"},
        ignored_by_interaction = true
    }

    local dragger = title_bar.add{
        type = "empty-widget",
        style = "draggable_space_header",
    }
    dragger.style.horizontally_stretchable = true
    dragger.style.height = 24
    dragger.style.minimal_width = 24
    dragger.drag_target = frame

    title_bar.add{
        type = "sprite-button",
        name = "railbow_close_button",
        sprite = "utility/close_white",
        style = "frame_action_button",
        mouse_button_filter = {"left"}
    }

    local table = frame.add{
        type = "table",
        name = "railbow_table",
        column_count = 17,5
    }

    for i = -8, 8 do
        if i ~= 0 then
            local j = i
            if i < 0 then
                j = i + 9
            else
                j = i + 8
            end
            table.add{
                type = "choose-elem-button",
                name = "railbow_tile_selector_" .. j,
                elem_type = "tile",
                tile = global.railbow_tools[player.index].tiles[i],
                elem_filters = {{filter = "blueprintable"}},
            }
        
        else
            table.add{
                type = "sprite-button",
                sprite = "utility/indication_arrow",
                tooltip = {"tooltips.railbow-gui-arrow"},
                enabled = false
            }
        end
    end
end

local function open_gui(player)
    if player.gui.screen.railbow_config_frame then
        player.gui.screen.railbow_config_frame.destroy()
    else
        create_config_frame(player)
    end
end

local function close_gui(player)
    if player.gui.screen.railbow_config_frame then
        player.gui.screen.railbow_config_frame.destroy()
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
    end
end

local function gui_closed(e)
    local player = game.get_player(e.player_index)
    if not player then return end
    if e.element and e.element.name == "railbow_config_frame" then
        close_gui(player)
    end
end

local function selector_changed(event)
    local element = event.element
    local player_index = event.player_index
    if string.find(element.name, "railbow_tile_selector_") then
        local index = tonumber(string.match(element.name, "railbow_tile_selector_(%d+)"))
        if index then
            local jndex = index - 8
            if jndex <= 0 then
                jndex = jndex - 1
            end
            global.railbow_tools[player_index].tiles[jndex] = element.elem_value
        end
    end
end

local gui = {}

gui.events = {
    [defines.events.on_gui_click] = gui_click,
    [defines.events.on_gui_elem_changed] = selector_changed,
    [defines.events.on_gui_closed] = gui_closed
}

return gui