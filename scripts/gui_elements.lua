local util = require("__core__/lualib/util")

local lib = {}

--- @param frame LuaGuiElement
--- @return LuaGuiElement
function lib.main_title_bar(frame)
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

    return title_bar
end

--- @param frame LuaGuiElement
--- @return LuaGuiElement
function lib.preset_list_header(frame)
    if frame.header then
        frame.header.destroy()
    end
    local header = frame.add{
        type = "flow",
        name = "header",
        direction = "horizontal"
    }

    header.add{
        type = "sprite-button",
        name = "railbow_add_preset_button",
        style = "tool_button_green",
        sprite = "utility/add",
        tooltip = {"tooltips.railbow-add-preset"}
    }

    header.add{
        type = "sprite-button",
        name = "railbow_copy_preset_button",
        style = "tool_button",
        sprite = "utility/copy",
        tooltip = {"tooltips.railbow-copy-preset"}
    }

    return header
end

--- @param list LuaGuiElement
--- @param index integer
--- @return LuaGuiElement
function lib.preset_selector(list, index)
    local flow
    if list["preset_flow_" .. index] then
        flow = list["preset_flow_" .. index]
        for _, child in pairs(flow.children) do
            child.destroy()
        end
    else
        flow = list.add{
            type = "flow",
            name = "preset_flow_" .. index,
            direction = "horizontal"
        }
    end
    local railbow_tool = util.table.deepcopy(global.railbow_tools[list.player_index])
    local preset = railbow_tool.presets[index]

    flow.style.width = 175

    flow.add{
        type = "radiobutton",
        name = "preset_selection",
        caption = "",
        tooltip = {"tooltips.railbow-select-preset"},
        state = index == railbow_tool.selected_preset
    }

    local button = flow.add{
        type = "button",
        name = "preset_button",
        caption = preset.name,
        auto_toggle = true,
        toggled = index == railbow_tool.opened_preset
    }
    button.style.width = 150

    return flow
end

--- @param frame LuaGuiElement
--- @return LuaGuiElement
function lib.preset_list(frame)
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
    list.style.maximal_height = 200

    return list
end

--- @param frame LuaGuiElement
--- @return LuaGuiElement
function lib.preset_selection_frame(frame)
    if frame.selection_frame then
        frame.selection_frame.destroy()
    end
    local selection_frame = frame.add{
        type = "frame",
        name = "selection_frame",
        direction = "vertical"
    }

    return selection_frame
end

--- @param list LuaGuiElement
function lib.populate_preset_list(list)
    local railbow_tool = util.table.deepcopy(global.railbow_tools[list.player_index])

    if list.children then
        for _, child in pairs(list.children) do
            child.destroy()
        end
    end

    for i, _ in pairs(railbow_tool.presets) do
        local elem = lib.preset_selector(list, i)
        if i == railbow_tool.selected_preset then
            elem.preset_selection.state = true
        end
        if i == railbow_tool.opened_preset then
            elem.preset_button.toggled = true
        end
    end
end

--- @param frame LuaGuiElement
--- @return LuaGuiElement
function lib.elem_choose_header(frame)
    local railbow_tool = util.table.deepcopy(global.railbow_tools[frame.player_index])
    if frame.elem_choose_header then
        frame.elem_choose_header.destroy()
    end

    local header = frame.add{
        type = "flow",
        name = "header",
        direction = "horizontal"
    }

    local preset_name = header.add{
        type = "text-box",
        name = "preset_name",
        text = railbow_tool.presets[railbow_tool.opened_preset].name,
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

    return header
end

--- @param frame LuaGuiElement
--- @return LuaGuiElement
function lib.choose_elem_table(frame)
    local railbow_tool = util.table.deepcopy(global.railbow_tools[frame.player_index])
    if frame.choose_elem_table then
        frame.choose_elem_table.destroy()
    end
    local table = frame.add{
        type = "table",
        name = "table",
        column_count = 17
    }

    local selected_preset = railbow_tool.opened_preset
    if not railbow_tool.presets[selected_preset].tiles then
        railbow_tool.presets[selected_preset].tiles = {}
    end
    local selected_tiles = railbow_tool.presets[selected_preset].tiles

    for i = -8, 8 do
        if i ~= 0 then
            table.add{
                type = "choose-elem-button",
                name = "tile_selector_" .. i,
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

    return table
end

--- @param frame LuaGuiElement
--- @return LuaGuiElement
function lib.tile_selection_frame(frame)
    if frame.tile_selection_frame then
        frame.tile_selection_frame.destroy()
    end
    local tile_selection_frame = frame.add{
        type = "frame",
        name = "tile_selection_frame",
        direction = "vertical"
    }

    return tile_selection_frame
end

return lib