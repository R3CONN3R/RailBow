--- @param frame LuaGuiElement
local function add_title_bar(frame)
    if frame.title_bar then
        frame.title_bar.destroy()
    end
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
end

--- @param frame LuaGuiElement
local function add_preset_list_header(frame)
    if frame.header then
        frame.header.destroy()
    end
    local header = frame.add{
        type = "flow",
        name = "header",
        direction = "horizontal"
    }

    local add_preset = header.add{
        type = "sprite-button",
        name = "railbow_add_preset_button",
        style = "tool_button_green",
        sprite = "utility/add",
        tooltip = {"tooltips.railbow-add-preset"}
    }

    local copy_preset = header.add{
        type = "sprite-button",
        name = "railbow_copy_preset_button",
        style = "tool_button",
        sprite = "utility/copy",
        tooltip = {"tooltips.railbow-copy-preset"}
    }

    add_preset.style.horizontal_align = "right"
end

--- @param frame LuaGuiElement
--- @param focus_on "selected" | "opened"
local function add_preset_list(frame, focus_on)
    if frame.preset_list then
        frame.preset_list.destroy()
    end
    local list = frame.add{
        type = "scroll-pane",
        name = "preset_list",
        direction = "vertical",
        vertical_scroll_policy = "auto",
        horizontal_scroll_policy = "never"
    }

    list.style.width = 200

    local railbow_tool = global.railbow_tools[frame.player_index]
    local presets = railbow_tool.presets

    if not focus_on then
        focus_on = "opened"
    end

    local focused_element
    for i, preset in pairs(presets) do
        local flow = list.add{
            type = "flow",
            name = "railbow_preset_flow_" .. i,
            direction = "horizontal"
        }
        flow.style.width = 175

        local radiobutton = flow.add{
            type = "radiobutton",
            name = "railbow_preset_activity_" .. i,
            state = i == railbow_tool.selected_preset,
            caption = "",
            tooltip = {"tooltips.railbow-select-preset"}
        }

        radiobutton.style.vertical_align = "center"

        local button = flow.add{
            type = "button",
            name = "railbow_preset_button_" .. i,
            caption = preset.name,
            enabled = i ~= railbow_tool.opened_preset,
            auto_toggle = true
        }
        button.style.width = 150

        if focus_on == "selected" and i == railbow_tool.selected_preset then
            focused_element = flow
        elseif focus_on == "opened" and i == railbow_tool.opened_preset then
            focused_element = flow
        end
    end
    if focused_element then
        list.scroll_to_element(focused_element)
    else
        list.scroll_to_top()
    end
end

--- @param flow LuaGuiElement
local function add_preset_list_frame(flow)
    if flow.preset_selection_frame then
        flow.preset_selection_frame.destroy()
    end
    local frame = flow.add{
        type = "frame",
        name = "preset_selection_frame",
        direction = "vertical"
    }

    frame.style.maximal_height = 200

    add_preset_list_header(frame)
    add_preset_list(frame, "opened")
end

--- @param frame LuaGuiElement
local function add_elem_choose_header(frame)
    if frame.header then
        frame.header.destroy()
    end
    local header = frame.add{
        type = "flow",
        name = "header",
        direction = "horizontal"
    }

    -- local switch = header.add{
    --     type = "button",
    --     name = "railbow_switch_button",
    --     caption = {"captions.railbow-switch"},
    --     style = "tool_button_green",
    --     tooltip = {"tooltips.railbow-switch"},
    --     mouse_button_filter = {"left"}
    -- }

    -- switch.style.width = 50

    -- if global.railbow_tools[frame.player_index].selected_preset == global.railbow_tools[frame.player_index].opened_preset then
    --     switch.toggled = true
    --     switch.enabled = false
    -- end

    local preset_name = header.add{
        type = "text-box",
        name = "railbow_preset_name",
        text = global.railbow_tools[frame.player_index].presets[global.railbow_tools[frame.player_index].opened_preset].name,
    }

    preset_name.style.width = 200

    header.add{
        type = "sprite-button",
        name = "railbow_delete_preset_button",
        sprite = "utility/trash",
        tooltip = {"tooltips.railbow-delete-preset"},
        style = "tool_button_red",
        mouse_button_filter = {"left"},
    }
end

--- @param frame LuaGuiElement
local function add_choose_elem_table(frame)
    if frame.table then
        frame.table.destroy()
    end
    local table = frame.add{
        type = "table",
        name = "table",
        column_count = 17
    }

    local railbow_tool = global.railbow_tools[frame.player_index]
    local selected_preset = railbow_tool.opened_preset
    local selected_tiles = railbow_tool.presets[selected_preset].tiles

    for i = -8, 8 do
        if i ~= 0 then
            table.add{
                type = "choose-elem-button",
                name = "railbow_tile_selector_" .. i,
                elem_type = "tile",
                tile = selected_tiles[i],
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

--- @param flow LuaGuiElement
local function add_choose_elem_frame(flow)
    local frame = flow.add{
        type = "frame",
        name = "tile_selection_frame",
        direction = "vertical"
    }

    add_elem_choose_header(frame)
    add_choose_elem_table(frame)
end

--- @param player LuaPlayer
local function create_railbow_window(player)
    local frame = player.gui.screen.add{
        type = "frame",
        name = "railbow_window",
        direction = "vertical"
    }
    frame.location = {75, 75}
    player.opened = frame

    add_title_bar(frame)

    frame.add{
        type = "flow",
        name = "configuration_flow",
        direction = "horizontal"
    }
    add_preset_list_frame(frame.configuration_flow)
    add_choose_elem_frame(frame.configuration_flow)
end

local gui_layout = {}
gui_layout.add_preset_list = add_preset_list
gui_layout.create_railbow_window = create_railbow_window
gui_layout.add_elem_choose_header = add_elem_choose_header
gui_layout.add_choose_elem_table = add_choose_elem_table

return gui_layout
