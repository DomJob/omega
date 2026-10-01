local restricted_entities = {
  {name = "burner-mining-drill", type = "mining-drill"},
  {name = "electric-mining-drill", type = "mining-drill"},
  {name = "offshore-pump", type = "offshore-pump"},
  {name = "pumpjack", type = "mining-drill"}
}

local restricted_recipes = {}
for _, entry in ipairs(restricted_entities) do
  restricted_recipes[entry.name] = true

  local item = data.raw.item[entry.name]
  if item then
    item.hidden = true
  end

  local entity = data.raw[entry.type][entry.name]
  if entity then
    entity.hidden = true
    entity.minable = nil

    local flags = {}
    for _, flag in ipairs(entity.flags or {}) do
      if flag ~= "placeable-neutral" and flag ~= "placeable-player" then
        table.insert(flags, flag)
      end
    end
    entity.flags = flags
  end

  local recipe = data.raw.recipe[entry.name]
  if recipe then
    recipe.enabled = false
    recipe.hidden = true
    recipe.hide_from_player_crafting = true
  end
end

for _, technology in pairs(data.raw.technology) do
  for index = #(technology.effects or {}), 1, -1 do
    local effect = technology.effects[index]
    if effect.type == "unlock-recipe" and restricted_recipes[effect.recipe] then
      table.remove(technology.effects, index)
    end
  end
end