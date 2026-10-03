local omega_void = table.deepcopy(data.raw.tile["deepwater"])
omega_void.name = "omega-void"
omega_void.autoplace = nil
omega_void.fluid = nil
omega_void.map_color = {r = 0, g = 0, b = 0}
omega_void.effect_color = {r = 0, g = 0, b = 0, a = 1}
omega_void.effect_color_secondary = {r = 0, g = 0, b = 0, a = 1}

data:extend({omega_void})

-- Register as a water tile so the engine draws the grass -> void shoreline edge
-- (the "island" look), exactly like the VoidBlock reference does for its ocean.
if water_tile_type_names then
  table.insert(water_tile_type_names, "omega-void")
end

local landfill = data.raw.item.landfill
if landfill and landfill.place_as_tile and landfill.place_as_tile.tile_condition then
  table.insert(landfill.place_as_tile.tile_condition, "omega-void")
end

local landfill_recipe = data.raw.recipe.landfill
if landfill_recipe then
  if settings.startup["omega-void-island-mode"].value then
    landfill_recipe.enabled = true
    landfill_recipe.ingredients = {{type = "item", name = "stone", amount = 20}}
    landfill_recipe.results = {{type = "item", name = "landfill", amount = 1}}
  else
    landfill_recipe.enabled = false
    landfill_recipe.hidden = true
    landfill_recipe.hide_from_player_crafting = true
  end
end