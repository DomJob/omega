-- omega-pid.lua  (require("omega-pid") from control.lua)

local CONFIG = {
  recipe_name = "omega-recipe-placeholder",
}
CONFIG.recipe_name = "omega-output"

CONFIG.fluid_name      = "omega-fluid"
CONFIG.base_rate       = 10     -- fluid/s at 0% bonus
CONFIG.step            = 0.01   -- +/-1% per update
CONFIG.interval        = 600    -- ticks between updates (10 s)
CONFIG.window_samples  = 60     -- 60 x 10 s = 10 minutes
CONFIG.buffer_target   = 1.05   -- keep supply at 105% of consumption
CONFIG.buffer_entities = { "omega-machine" } -- add "storage-tank" if wanted

------------------------------------------------------------------------
-- State (persisted in `storage`)
------------------------------------------------------------------------
local function get_state(force)
  storage.omega_pid = storage.omega_pid or { forces = {} }
  local s = storage.omega_pid.forces[force.index]
  if not s then
    s = {
      mult = 1,          -- 1 + bonus
      samples = {},      -- each: { potential = fluid, stock = fluid }
      consumed = 0, supply = 0, starved = false,
    }
    storage.omega_pid.forces[force.index] = s
  end
  return s
end

------------------------------------------------------------------------
-- Measurements
------------------------------------------------------------------------
local function consumed_last_10min(force)
  local total = 0
  for _, surface in pairs(game.surfaces) do
    local stats = force.get_fluid_production_statistics(surface)
    if stats and stats.valid then
      total = total + stats.get_flow_count{
        name = CONFIG.fluid_name, category = "input",
        precision_index = defines.flow_precision_index.ten_minutes,
        count = true,
      }
    end
  end
  return total
end

local function stored_fluid(force)
  local total = 0
  for _, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered{
      name = CONFIG.buffer_entities, force = force,
    }
    for _, e in pairs(entities) do
      total = total + (e.get_fluid_contents()[CONFIG.fluid_name] or 0)
    end
  end
  return total
end

------------------------------------------------------------------------
-- Update (every 10 s)
------------------------------------------------------------------------
local function update_force(force)
  local recipe = force.recipes[CONFIG.recipe_name]
  if not recipe then return end
  local s = get_state(force)

  -- 1. Log what the machine could produce in the last 10 s, plus current stock.
  local seconds = CONFIG.interval / 60
  table.insert(s.samples, {
    potential = CONFIG.base_rate * s.mult * seconds,
    stock = stored_fluid(force),
  })
  while #s.samples > CONFIG.window_samples do
    table.remove(s.samples, 1)
  end

  -- 2. Supply over the window = potential production + backlog at window start.
  local potential = 0
  for _, smp in ipairs(s.samples) do potential = potential + smp.potential end
  local supply = potential + s.samples[1].stock
  local consumed = consumed_last_10min(force)

  s.consumed, s.supply = consumed, supply

  -- 3. Target: supply should be 5% above consumption.
  s.starved = supply < CONFIG.buffer_target * consumed
  if s.starved then
    s.mult = s.mult * (1 + CONFIG.step)
  else
    s.mult = s.mult * (1 - CONFIG.step)
  end
  s.mult = math.max(1, s.mult)  -- floor at 0% bonus, no upper cap

  recipe.productivity_bonus = s.mult - 1
end

script.on_nth_tick(CONFIG.interval, function()
  for _, force in pairs(game.forces) do
    update_force(force)
  end
end)

commands.add_command("omega-pid", "Show omega controller state", function(cmd)
  local player = game.get_player(cmd.player_index)
  if not player then return end
  local s = get_state(player.force)
  player.print(string.format(
    "[omega] bonus=%+.1f%% output=%.1f/s consumed(10m)=%.0f supply(10m)=%.0f target=%.0f starved=%s",
    (s.mult - 1) * 100, CONFIG.base_rate * s.mult, s.consumed, s.supply,
    CONFIG.buffer_target * s.consumed, tostring(s.starved)))
end)

return {}