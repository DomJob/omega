local omega_icon = "__omega__/graphics/icons/omega-machine.png"
local omega_fluid_icon = "__omega__/graphics/icons/omega-fluid.png"

local omega_fluid = {
    type = "fluid",
    name = "omega-fluid",
    icon = omega_fluid_icon,
    icon_size = 64,
    default_temperature = 15,
    max_temperature = 100,
    auto_barrel = true,
    heat_capacity = "0.1kJ",
    base_color = {
        r = 0.5,
        g = 0.0,
        b = 0.5
    },
    flow_color = {
        r = 0.5,
        g = 0.0,
        b = 0.5
    },
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    order = "z"
}

local function omega_machine_pipe_connections()
    local edge = 8
    local connections = {}
    for i = -7, 7 do
        table.insert(connections, {
            flow_direction = "output",
            direction = defines.direction.north,
            position = {i, -edge + 1}
        })
        table.insert(connections, {
            flow_direction = "output",
            direction = defines.direction.south,
            position = {i, edge}
        })
        table.insert(connections, {
            flow_direction = "output",
            direction = defines.direction.east,
            position = {edge, i}
        })
        table.insert(connections, {
            flow_direction = "output",
            direction = defines.direction.west,
            position = {-edge, i}
        })
    end
    return connections
end

local omega_machine = {
    type = "assembling-machine",
    name = "omega-machine",
    icon = omega_icon,
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation", "not-deconstructable", "not-rotatable", "not-upgradable"},
    max_health = 2000,
    collision_box = {{-8, -7}, {8, 8}},
    selection_box = {{-8, -7}, {8, 8}},
    tile_width = 15,
    tile_height = 15,
    crafting_categories = {"omega"},
    fixed_recipe = "omega-output",
    crafting_speed = 1,
    module_slots = 0,
    allowed_effects = {"productivity"},
    ignore_output_full = true,
    show_recipe_icon = false,
    show_recipe_icon_on_map = false,
    energy_source = {
        type = "void"
    },
    energy_usage = "1W",
    fluid_boxes = {{
        production_type = "output",
        volume = 1000,
        pipe_connections = omega_machine_pipe_connections(),
    }},
    graphics_set = {
        animation = {
            filename = "__omega__/graphics/entity/omega-machine.png",
            priority = "high",
            width = 544,
            height = 576,
            frame_count = 1,
            shift = {0, 0},
            scale = 1
        }
    },
    resistances = {{
        type = "fire",
        percent = 100
    }, {
        type = "physical",
        percent = 100
    }, {
        type = "impact",
        percent = 100
    }}
}

local omega_item = {
    type = "item",
    name = "omega-machine",
    icon = omega_icon,
    icon_size = 64,
    subgroup = "production-machine",
    order = "z",
    place_result = "omega-machine",
    stack_size = 10
}

local omega_recipe_category = {
    type = "recipe-category",
    name = "omega"
}

local omega_recipe = {
    type = "recipe",
    name = "omega-output",
    categories = {"omega"},
    enabled = true,
    hidden = true,
    energy_required = 1,
    allow_productivity = true,
    maximum_productivity = 1000000,
    ingredients = {},
    results = {{
        type = "fluid",
        name = "omega-fluid",
        amount = 100
    }},
    icon = omega_fluid_icon,
    icon_size = 64,
    hide_from_player_crafting = true
}

data:extend({omega_fluid, omega_machine, omega_item, omega_recipe_category, omega_recipe})
