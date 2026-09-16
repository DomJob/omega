local omega_lab_icon = "__omega__/graphics/icons/omega-lab.png"

local omega_lab_recipe_category = {
    type = "recipe-category",
    name = "omega-lab"
}

-- Reuse the vanilla lab's collision box, selection box and sprite instead of
-- making new art. We still have to use "assembling-machine" as the base type
-- (not "lab") since labs can't have fluid_boxes.
local base_lab = data.raw["lab"]["lab"]

local purple_tint = {r = 0.55, g = 0.1, b = 0.8, a = 1}

-- table.deepcopy is a data-stage global. Tinting like this multiplies the
-- sprite's existing colors, so it won't look perfect, but it's the cheapest
-- way to get a distinct purple look without new art.
local lab_animation = table.deepcopy(base_lab.on_animation)
if lab_animation.layers then
    for _, layer in ipairs(lab_animation.layers) do
        layer.tint = purple_tint
    end
else
    lab_animation.tint = purple_tint
end

-- Derive the pipe connection point from the lab's own selection box so it
-- stays correct if you ever swap the base sprite for something else sized.
local lab_box = base_lab.selection_box
local south_edge = lab_box[2][2]

local omega_lab = {
    type = "assembling-machine",
    name = "omega-lab",
    icon = omega_lab_icon,
    icon_size = 64,
    flags = {"placeable-player", "player-creation"},
    minable = {
        mining_time = 0.2,
        result = "omega-lab"
    },
    max_health = base_lab.max_health,
    corpse = base_lab.corpse,
    dying_explosion = base_lab.dying_explosion,
    collision_box = base_lab.collision_box,
    selection_box = base_lab.selection_box,
    crafting_categories = {"omega-lab"},
    fixed_recipe = "omega-lab-research",
    crafting_speed = 1,
    ingredient_count = 1,
    module_slots = 3,
    allowed_effects = {"speed", "productivity"},
    show_recipe_icon = false,
    show_recipe_icon_on_map = false,
    energy_source = {
        type = "electric"
    },
    energy_usage = "60kW",
    fluid_boxes = {{
        production_type = "input",
        pipe_connections = {{
            flow_direction = "input",
            direction = defines.direction.south,
            position = {0, 1}
        }},
        volume = 10000,
        pipe_covers = pipecoverspictures()
    }},
    graphics_set = {
        animation = lab_animation
    }
}

local omega_lab_item = {
    type = "item",
    name = "omega-lab",
    icon = omega_lab_icon,
    icon_size = 64,
    subgroup = "production-machine",
    order = "z",
    place_result = "omega-lab",
    stack_size = 10
}

local omega_lab_craft_recipe = {
    type = "recipe",
    name = "omega-lab",
    enabled = true,
    energy_required = 10,
    ingredients = {{
        type = "item",
        name = "iron-gear-wheel",
        amount = 15
    }, {
        type = "item",
        name = "copper-plate",
        amount = 10
    }, {
        type = "item",
        name = "lab",
        amount = 1
    }},
    results = {{
        type = "item",
        name = "omega-lab",
        amount = 1
    }},
    icon = omega_lab_icon,
    icon_size = 64
}

local omega_lab_research_recipe = {
    type = "recipe",
    name = "omega-lab-research",
    categories = {"omega-lab"},
    enabled = true,
    hidden = true,
    energy_required = 10,
    ingredients = {{
        type = "fluid",
        name = "omega-fluid",
        amount = 10000
    }},
    results = {},
    icon = omega_lab_icon,
    icon_size = 64,
    hide_from_player_crafting = true
}

data:extend({omega_lab_recipe_category, omega_lab, omega_lab_item, omega_lab_craft_recipe,
             omega_lab_research_recipe})