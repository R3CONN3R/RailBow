local Event = require('__stdlib__/stdlib/event/event')

local function on_shortcut(e)
    local name = e.input_name or e.prototype_name
    if name ~= "railbow-get-selection-tool" then
        return
    end
    local player = game.get_player(e.player_index)
    if not player then
        return
    end
    local cursor_stack = player.cursor_stack
    if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "railbow-selection-tool" then
        return
    end
    if not cursor_stack or not player.clear_cursor() then
        return
    end
    player.cursor_stack.set_stack{name = "railbow-selection-tool", count = 1}
end

Event.register(defines.events.on_lua_shortcut, on_shortcut)
Event.register("railbow-get-selection-tool", on_shortcut)
