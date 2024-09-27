local filter = {
    "curved-rail",
    "straight-rail",
    "rail-signal",
    "rail-chain-signal",
}

data:extend({
  {
    type = "selection-tool",
    name = "railbow-selection-tool",
    icon = "__RailBow__/graphics/railbow-selection-tool.png",
    icon_size = 32,
    selection_color = {r = 1, g = 0, b = 0},
    selection_mode = {"buildable-type", "same-force"},
    selection_cursor_box_type = "entity",
    entity_filter_mode = "whitelist",
    entity_filters = filter,

    alt_selection_color = {r = 0, g = 1, b = 0},
    alt_selection_mode = {"nothing"},
    alt_selection_cursor_box_type = "entity",

    stack_size = 1,
    flags = {"hidden", "only-in-cursor", "not-stackable"},
  }
})