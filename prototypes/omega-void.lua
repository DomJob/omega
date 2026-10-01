local omega_void = table.deepcopy(data.raw.tile["deepwater"])
omega_void.name = "omega-void"
omega_void.autoplace = nil
omega_void.fluid = nil
omega_void.map_color = {r = 0, g = 0, b = 0}
omega_void.effect_color = {r = 0, g = 0, b = 0, a = 1}
omega_void.effect_color_secondary = {r = 0, g = 0, b = 0, a = 1}
omega_void.tint = {r = 0, g = 0, b = 0, a = 1}

data:extend({omega_void})

local landfill = data.raw.item.landfill
if landfill and landfill.place_as_tile and landfill.place_as_tile.tile_condition then
  table.insert(landfill.place_as_tile.tile_condition, "omega-void")
end