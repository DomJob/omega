-- omega-pid.lua  (require("omega-pid") from control.lua)

local CONFIG = {
  recipe_name  = "omega-output",
  fluid_name   = "omega-fluid",
  machine_name = "omega-machine",  -- rename to match your prototype

  step      = 0.01,   -- +/-1% per update
  interval  = 60,     -- ticks between updates (1 s)

  low_level  = 500,     -- level <= this counts as "empty"  -> raise bonus
  high_level = 500,  -- level >  this counts as "backed up" -> lower bonus
}

------------------------------------------------------------------------
-- State (persisted in `storage`, created lazily)
------------------------------------------------------------------------
local function get_state(force)
  storage.omega_pid = storage.omega_pid or { forces = {} }
  local s = storage.omega_pid.forces[force.index]
  if not s then
    s = {
      mult = 1,        -- 1 + bonus
      level = 0,       -- average omega-fluid per machine, last reading
      machines = 0,
      action = "hold",
    }
    storage.omega_pid.forces[force.index] = s
  end
  return s
end

------------------------------------------------------------------------
-- Read the output level of every omega-machine, grouped by force index
------------------------------------------------------------------------
local function read_levels()
  local totals = {}  -- [force_index] = { sum = fluid, count = machines }
  for _, surface in pairs(game.surfaces) do
    for _, e in pairs(surface.find_entities_filtered{ name = CONFIG.machine_name }) do
      local t = totals[e.force.index]
      if not t then
        t = { sum = 0, count = 0 }
        totals[e.force.index] = t
      end
      t.sum = t.sum + (e.get_fluid_contents()[CONFIG.fluid_name] or 0)
      t.count = t.count + 1
    end
  end
  return totals
end

------------------------------------------------------------------------
-- Update (every second)
------------------------------------------------------------------------
local function update()
  local totals = read_levels()

  for _, force in pairs(game.forces) do
    local recipe = force.recipes[CONFIG.recipe_name]
    if recipe then
      local s = get_state(force)
      local t = totals[force.index]

      if t and t.count > 0 then
        local level = t.sum / t.count   -- average, so multiple machines still work
        s.level, s.machines = level, t.count

        if level <= CONFIG.low_level then
          s.action = "RAISING"
          s.mult = s.mult * (1 + CONFIG.step)
        elseif level > CONFIG.high_level then
          s.action = "LOWERING"
          s.mult = s.mult * (1 - CONFIG.step)
        else
          s.action = "hold"
        end
        s.mult = math.max(1, s.mult)   -- floor at +0%, no upper cap
      else
        s.machines, s.action = 0, "no machine"
      end

      -- Written every update so reloads / recipe resets self-heal.
      recipe.productivity_bonus = s.mult - 1
    end
  end
end

script.on_nth_tick(CONFIG.interval, update)

------------------------------------------------------------------------
-- Debug: /omega-pid
------------------------------------------------------------------------
commands.add_command("omega-pid", "Show omega controller state", function(cmd)
  local player = game.get_player(cmd.player_index)
  if not player then return end
  local s = get_state(player.force)
  player.print(string.format(
    "[omega] bonus=%+.1f%% output=%.1f/s level=%.0f machines=%d -> %s",
    (s.mult - 1) * 100, 10 * s.mult, s.level, s.machines, s.action))
end)

return {}