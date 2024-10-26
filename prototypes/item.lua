local filter = {
    "curved-rail-a",
    "curved-rail-b",
    "straight-rail",
    "half-diagonal-rail",
    "rail-signal",
    "rail-chain-signal",
}

data:extend({
  {
    type = "selection-tool",
    name = "railbow-selection-tool",
    icon = "__RailBow__/graphics/railbow-selection-tool.png",
    icon_size = 64,
    select = {
      border_color = { r = 1, g = 0.5, b = 0 },
      cursor_box_type = "train-visualization",
      mode = "any-entity",
      entity_filters = filter
    },

    alt_select = {
      border_color = { r = 1, g = 0.5, b = 0 },
      cursor_box_type = "train-visualization",
      mode = "any-entity",
      entity_filters = filter
    },
    

    stack_size = 1,
    flags = {"hide-from-bonus-gui", "only-in-cursor", "not-stackable"},
  }
})