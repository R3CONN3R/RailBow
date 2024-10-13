local gui_layout = require("scripts.gui_layout")

local function add_preset(player)
    local railbow_tool = global.railbow_tools[player.index]
    local presets = railbow_tool.presets
    local n_presets = #presets
    local new_preset = {
        name = "preset_" .. n_presets + 1,
        tiles = {},
        mode = "vote"
    }
    for i = -8, 8 do
        if i ~= 0 then
            new_preset.tiles[i] = nil
        end
    end
    table.insert(global.railbow_tools[player.index].presets, new_preset)

    gui_layout.add_preset_list(player.gui.screen.railbow_window.configuration_flow.preset_selection_frame, "opened")
end

local function change_preset(player, index)
    global.railbow_tools[player.index].opened_preset = index

    local railbow_tool = global.railbow_tools[player.index]
    local opened_preset = railbow_tool.opened_preset
    if not railbow_tool.presets[opened_preset].tiles then
        railbow_tool.presets[opened_preset].tiles = {}
    end
    local opened_tiles = railbow_tool.presets[opened_preset].tiles

    gui_layout.add_preset_list(player.gui.screen.railbow_window.configuration_flow.preset_selection_frame, "opened")

    local frame = player.gui.screen.railbow_window.configuration_flow.tile_selection_frame

    frame.header.railbow_preset_name.text = railbow_tool.presets[opened_preset].name

    for i, element in pairs(frame.table.children) do
        if string.find(element.name, "railbow_tile_selector_") then
            local index_ = tonumber(element.name:match("([+-]?%d+)$"))
            if index then
                element.elem_value = opened_tiles[index_]
            end
        end
    end
end

local function delete_preset(player)
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
    if opened_preset == selected_preset then
        railbow_tool.selected_preset = opened_preset - 1
    end

    change_preset(player, opened_preset - 1)
    gui_layout.add_preset_list(player.gui.screen.railbow_window.configuration_flow.preset_selection_frame, "opened")
end

local function copy_preset(player)
    local railbow_tool = global.railbow_tools[player.index]
    local opened_preset = railbow_tool.opened_preset
    local presets = railbow_tool.presets
    local n_presets = #presets

    local new_preset = {
        name = presets[opened_preset].name .. " - copy",
        tiles = {},
        mode = "vote"
    }
    for i = -8, 8 do
        if i ~= 0 then
            new_preset.tiles[i] = presets[opened_preset].tiles[i]
        end
    end
    table.insert(presets, new_preset)

    gui_layout.add_preset_list(player.gui.screen.railbow_window.configuration_flow.preset_selection_frame, "opened")
end

local gui_updates = {}
gui_updates.add_preset = add_preset
gui_updates.change_preset = change_preset
gui_updates.delete_preset = delete_preset
gui_updates.copy_preset = copy_preset

return gui_updates