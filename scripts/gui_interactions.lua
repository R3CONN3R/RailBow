local gui_elements = require("scripts.gui_elements")
local util = require("__core__.lualib.util")

local lib = {}
---@param player LuaPlayer
---@param tiles table<integer, string>|nil
---@param preset_name string|nil
function lib.add_preset(player, tiles, preset_name)
    local railbow_tool = global.railbow_tools[player.index]
    local presets = railbow_tool.presets
    local n_presets = #presets

    if not tiles then
        tiles = {}
    end

    if not preset_name then
        preset_name = "preset_" .. n_presets + 1
    end

    local new_preset = {
        name = preset_name,
        tiles = tiles,
        mode = "vote"
    }
    table.insert(global.railbow_tools[player.index].presets, new_preset)
    
    local list = player.gui.screen.railbow_window.configuration_flow.selection_frame.preset_list
    gui_elements.preset_selector(list, n_presets + 1)
end

--- @param flow LuaGuiElement
function lib.open_preset(flow)
    if flow.tile_selection_frame then
        flow.tile_selection_frame.destroy()
    end
    local tile_selection_frame = gui_elements.tile_selection_frame(flow)
    gui_elements.elem_choose_header(tile_selection_frame)
    gui_elements.choose_elem_table(tile_selection_frame)
end

--- @param player LuaPlayer
function lib.close_preset(player)
    local railbow_tool = global.railbow_tools[player.index]
    local conf = player.gui.screen.railbow_window.configuration_flow
    if conf.tile_selection_frame then
        conf.tile_selection_frame.destroy()
    end
    -- if railbow_tool.opened_preset then
    --     local list = conf.selection_frame.preset_list
    --     local flow = list["preset_flow_" .. railbow_tool.opened_preset]
    --     flow.preset_button.toggled = false
    -- end
    railbow_tool.opened_preset = nil

end

--- @param player LuaPlayer
--- @param index integer
--- @param toggled boolean
function lib.change_opened_preset(player, index, toggled)
    local railbow_tool = global.railbow_tools[player.index]

    local conflow = player.gui.screen.railbow_window.configuration_flow

    local previous_index = railbow_tool.opened_preset
    if not toggled then
        lib.close_preset(player)
        return
    end
    railbow_tool.opened_preset = index
    if not previous_index then
        lib.open_preset(conflow)
        return
    end
    if previous_index == index then
        player.print("err")
        return
    end
    
    local old_flow = conflow.selection_frame.preset_list["preset_flow_" .. previous_index]
    old_flow.preset_button.toggled = false

    if not railbow_tool.presets[index].tiles then
        railbow_tool.presets[index].tiles = {}
    end

    local opened_tiles = railbow_tool.presets[index].tiles
    local frame = conflow.tile_selection_frame

    frame.header.preset_name.text = railbow_tool.presets[index].name

    for i, element in pairs(frame.table.children) do
        if string.find(element.name, "tile_selector_") then
            local index_ = tonumber(element.name:match("([+-]?%d+)$"))
            if index then
                element.elem_value = opened_tiles[index_]
            end
        end
    end

end

function lib.delete_preset(player)
    local railbow_tool = global.railbow_tools[player.index]
    local opened_preset = railbow_tool.opened_preset
    local selected_preset = railbow_tool.selected_preset
    local presets = railbow_tool.presets
    local n_presets = #presets

    if n_presets == 1 then
        player.print("You can't delete the last preset.")
        return
    end

    table.remove(presets, opened_preset)
    if opened_preset <= selected_preset then
        if selected_preset == 1 then
            railbow_tool.selected_preset = 1
        else
            railbow_tool.selected_preset = selected_preset - 1
        end
    end

    railbow_tool.opened_preset = nil
    lib.close_preset(player)

    gui_elements.populate_preset_list(player.gui.screen.railbow_window.configuration_flow.selection_frame.preset_list)
end

function lib.copy_preset(player)
    local railbow_tool = global.railbow_tools[player.index]
    local opened_preset = railbow_tool.opened_preset
    local presets = railbow_tool.presets
    local n_presets = #presets

    local new_preset = {
        name = presets[opened_preset].name .. " - copy",
        tiles = util.table.deepcopy(presets[opened_preset].tiles),
        mode = "vote"
    }

    table.insert(presets, new_preset)
    gui_elements.preset_selector(player.gui.screen.railbow_window.configuration_flow.selection_frame.preset_list, n_presets + 1)
end

function lib.change_selected_preset(player, index)
    local railbow_tool = global.railbow_tools[player.index]
    local gui_list = player.gui.screen.railbow_window.configuration_flow.selection_frame.preset_list
    gui_list["preset_flow_" .. railbow_tool.selected_preset].preset_selection.state = false
    gui_list["preset_flow_" .. index].preset_selection.state = true
    railbow_tool.selected_preset = index
end


return lib