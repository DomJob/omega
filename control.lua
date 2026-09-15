local function ensure_omega_device(surface)
  if not surface then
    return
  end

  local existing = surface.find_entity("omega-machine", {0, 0})
  if not existing then
    existing = surface.create_entity({
      name = "omega-machine",
      position = {0, 0},
      force = "player",
      create_build_effect_smoke = false
    })
  end

  if existing and existing.valid then
    existing.destructible = false
  end
end

local function prepare_surface(surface)
  if not surface then
    return
  end

  local map_gen = surface.map_gen_settings
  if map_gen then
    -- Resources, trees and enemies are wiped per-chunk in on_chunk_generated, so
    -- autoplace is left untouched here. Zeroing a spot-based control's `size`
    -- (e.g. coal) makes its spot-noise expression divide by zero -> NaN crash.
    map_gen.peaceful_mode = true
    surface.map_gen_settings = map_gen
  end

  surface.always_day = true
end

local function setup_player(player)
  if not player then
    return
  end

  -- Leave the intro cutscene immediately if the player is in one.
  if player.controller_type == defines.controllers.cutscene then
    pcall(function() player.exit_cutscene() end)
  end

  -- Empty every personal inventory the player might have started with.
  for _, inv_id in pairs({
    defines.inventory.character_main,
    defines.inventory.character_guns,
    defines.inventory.character_ammo,
    defines.inventory.character_trash
  }) do
    local inventory = player.get_inventory(inv_id)
    if inventory then
      inventory.clear()
    end
  end
  player.clear_cursor()

  local main_inventory = player.get_inventory(defines.inventory.character_main)
  if main_inventory then
    main_inventory.insert({name = "omega-transmuter", count = 1})
    main_inventory.insert({name = "coal", count = 1})
  end

  -- Drop the player just outside the 15x15 device so they are not trapped inside it.
  local surface = player.surface
  local spawn = {0, 10}
  local safe = surface.find_non_colliding_position("character", spawn, 32, 1)
  player.teleport(safe or spawn, surface)
end

local function disable_freeplay_gifts()
  if not (remote and remote.interfaces["freeplay"]) then
    return
  end
  pcall(function() remote.call("freeplay", "set_skip_intro", true) end)
  pcall(function() remote.call("freeplay", "set_disable_crashsite", true) end)
  pcall(function() remote.call("freeplay", "set_created_items", {}) end)
  pcall(function() remote.call("freeplay", "set_respawn_items", {}) end)
end

script.on_init(function()
  disable_freeplay_gifts()

  for _, surface in pairs(game.surfaces) do
    prepare_surface(surface)
  end

  game.map_settings.enemy_evolution.enabled = false
  game.map_settings.enemy_expansion.enabled = false
  game.map_settings.pollution.enabled = false

  for _, player in pairs(game.players) do
    setup_player(player)
  end

  ensure_omega_device(game.surfaces[1])
end)

script.on_configuration_changed(function(event)
  disable_freeplay_gifts()

  -- Only reset players on a fresh install of this mod, not on every version bump/reload.
  local changes = event and event.mod_changes and event.mod_changes["omega"]
  local is_new_install = changes and not changes.old_version
  if is_new_install then
    for _, player in pairs(game.players) do
      setup_player(player)
    end
  end

  ensure_omega_device(game.surfaces[1])
end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  if not player then
    return
  end
  ensure_omega_device(player.surface)
  setup_player(player)
end)

script.on_event(defines.events.on_chunk_generated, function(event)
  local surface = event.surface
  local area = event.area

  local tiles = {}
  for x = area.left_top.x, area.right_bottom.x - 1 do
    for y = area.left_top.y, area.right_bottom.y - 1 do
      table.insert(tiles, {name = "grass-1", position = {x, y}})
    end
  end

  surface.set_tiles(tiles, false, true, true)
  surface.destroy_decoratives({area = area})

  local entities = surface.find_entities_filtered({area = area})
  for _, entity in pairs(entities) do
    if entity.valid and entity.type ~= "character" and entity.name ~= "omega-machine" then
      entity.destroy({force = true})
    end
  end
end)

