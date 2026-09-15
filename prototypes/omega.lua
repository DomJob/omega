local omega_icon = "__omega__/graphics/icons/omega-machine.png"
local omega_fluid_icon = "__omega__/graphics/icons/omega-fluid.png"
local omega_transmuter_icon = "__omega__/graphics/icons/omega-transmuter.png"

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

-- One connection point per free tile along each of the 15x15 machine's four edges (60 total).
-- Positions use the outermost tile's center (like vanilla chemical-plant), so the external
-- pipe stub lands adjacent to the entity instead of a tile further out. This must stay tied
-- to the 15x15 tile footprint, not the (smaller, purely visual) collision/selection box.
local function omega_machine_pipe_connections()
    local edge = 8
    local connections = {}
    for i = -7, 7 do
        table.insert(connections, {
            flow_direction = "output",
            direction = defines.direction.north,
            position = {i, -edge+1}
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
    -- No minable property + not-deconstructable => cannot be mined, deconstructed or removed.
    flags = {"placeable-neutral", "player-creation", "not-deconstructable", "not-rotatable", "not-upgradable"},
    max_health = 2000,
    -- Asymmetric: the sprite's smokestack pokes up further than the main frame, and the
    -- frame itself sits inset from the left/right edges of the (transparent-padded) image.
    collision_box = {{-8, -7}, {8, 8}},
    selection_box = {{-7, -6}, {7, 7}},
    tile_width = 15,
    tile_height = 15,
    crafting_categories = {"omega"},
    fixed_recipe = "omega-output",
    crafting_speed = 1,
    module_slots = 10,
    allowed_effects = {"productivity"},
    ignore_output_full = false,
    show_recipe_icon = false,
    show_recipe_icon_on_map = false,
    energy_source = {
        type = "void"
    },
    energy_usage = "1W",
    fluid_boxes = {{
        production_type = "output",
        volume = 1000,
        pipe_connections = omega_machine_pipe_connections()
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

local omega_transmuter_recipe_category = {
    type = "recipe-category",
    name = "omega-transmuter"
}

local omega_recipe = {
    type = "recipe",
    name = "omega-output",
    categories = {"omega"},
    enabled = true,
    hidden = true,
    energy_required = 5,
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

local function omega_transmuter_direction_graphics(direction, spec)
    local base = "__omega__/graphics/entity/omega-transmuter/omega-transmuter_" .. direction
    return {
        layers = {{
            filename = base .. ".png",
            priority = "high",
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.25,
            width = spec.body[1],
            height = spec.body[2],
            shift = spec.body[3],
            scale = 0.73
        }, {
            filename = base .. "-shadow.png",
            priority = "high",
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.25,
            width = spec.shadow[1],
            height = spec.shadow[2],
            shift = spec.shadow[3],
            draw_as_shadow = true,
            scale = 0.73
        }}
    }
end

-- Real per-direction sprite sizes/shifts copied from the vanilla offshore-pump prototype
-- (these assets are the renamed offshore-pump files, so the sheet layout matches exactly).
-- Static legs/glass overlays are omitted: assembling-machine layers require a uniform
-- frame_count, but those files are single-frame while body/shadow are 32-frame strips.
local omega_transmuter_direction_specs = {
    North = {
        body = {90, 162, {-1 / 32, -15 / 32}},
        shadow = {150, 134, {13 / 32, -7 / 32}}
    },
    East = {
        body = {124, 102, {15 / 32, -2 / 32}},
        shadow = {180, 66, {27 / 32, 8 / 32}}
    },
    South = {
        body = {92, 192, {-1 / 32, 0}},
        shadow = {164, 128, {15 / 32, 23 / 32}}
    },
    West = {
        body = {124, 102, {-15 / 32, -2 / 32}},
        shadow = {172, 66, {-3 / 32, 8 / 32}}
    }
}

local omega_transmuter = {
    type = "assembling-machine",
    name = "omega-transmuter",
    icon = omega_transmuter_icon,
    icon_size = 64,
    flags = {"placeable-player", "player-creation"},
    minable = {
        mining_time = 0.2,
        result = "omega-transmuter"
    },
    max_health = 250,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    -- Symmetric box matching the declared 1x2 tile footprint exactly (unlike vanilla
    -- offshore-pump's off-center box), so fluid connection rotation math stays correct.
    collision_box = {{-0.4, -0.9}, {0.4, 0.9}},
    selection_box = {{-0.5, -1}, {0.5, 1}},
    tile_width = 1,
    tile_height = 2,
    crafting_categories = {"omega-transmuter"},
    crafting_speed = 1,
    ingredient_count = 1,
    module_slots = 0,
    allowed_effects = {},
    energy_source = {
        type = "burner",
        fuel_categories = {"chemical"},
        effectivity = 1,
        fuel_inventory_size = 1,
        burnt_inventory_size = 1,
        smoke = {{
            name = "smoke",
            deviation = {0.1, 0.1},
            frequency = 10,
            position = {0.2, 1.5},
            starting_vertical_speed = 0.08
        }}
    },
    energy_usage = "100kW",
    fluid_boxes = {{
        production_type = "input",
        pipe_connections = {{
            flow_direction = "input",
            direction = defines.direction.north,
            position = {0, -0.5}
        }},
        volume = 100,
        base_area = 50,
        base_level = -1,
        pipe_covers = pipecoverspictures()
    }, {
        production_type = "output",
        pipe_connections = {{
            flow_direction = "output",
            direction = defines.direction.south,
            position = {0, 0.5}
        }},
        volume = 1000,
        base_area = 50,
        base_level = 1,
        pipe_covers = pipecoverspictures()
    }},
    graphics_set = {
        animation = {
            north = omega_transmuter_direction_graphics("North", omega_transmuter_direction_specs.North),
            east = omega_transmuter_direction_graphics("East", omega_transmuter_direction_specs.East),
            south = omega_transmuter_direction_graphics("South", omega_transmuter_direction_specs.South),
            west = omega_transmuter_direction_graphics("West", omega_transmuter_direction_specs.West)
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

local omega_transmuter_item = {
    type = "item",
    name = "omega-transmuter",
    icon = omega_transmuter_icon,
    icon_size = 64,
    subgroup = "production-machine",
    order = "z",
    place_result = "omega-transmuter",
    stack_size = 10
}

local omega_transmuter_craft_recipe = {
    type = "recipe",
    name = "omega-transmuter",
    enabled = true,
    energy_required = 2,
    ingredients = {{
        type = "item",
        name = "iron-plate",
        amount = 10
    }, {
        type = "item",
        name = "copper-plate",
        amount = 5
    }},
    results = {{
        type = "item",
        name = "omega-transmuter",
        amount = 1
    }},
    icon = omega_transmuter_icon,
    icon_size = 64
}

local function transmuter_recipe(result_name, result_type, result_amount)
    local icon_subpath = result_type == "fluid" and "fluid/" or ""
    return {
        type = "recipe",
        name = "omega-transmute-" .. result_name,
        categories = {"omega-transmuter"},
        enabled = true,
        energy_required = 10,
        ingredients = {{
            type = "fluid",
            name = "omega-fluid",
            amount = 100
        }},
        results = {{
            type = result_type,
            name = result_name,
            amount = result_amount
        }},
        icons = {{
            icon = "__base__/graphics/icons/" .. icon_subpath .. result_name .. ".png",
            icon_size = 64
        }},
        subgroup = "raw-material",
        order = "z"
    }
end

local omega_transmuter_recipes = {transmuter_recipe("coal", "item", 1), transmuter_recipe("iron-ore", "item", 1),
                                  transmuter_recipe("copper-ore", "item", 1), transmuter_recipe("wood", "item", 1),
                                  transmuter_recipe("stone", "item", 1), transmuter_recipe("water", "fluid", 100),
                                  transmuter_recipe("crude-oil", "fluid", 100)}

omega_transmuter_recipes[#omega_transmuter_recipes].enabled = false

for _, recipe in ipairs(omega_transmuter_recipes) do
    if recipe.results[1].type == "item" then
        table.insert(recipe.categories, "crafting-with-fluid")
    end
end

local omega_uranium_recipe = {
    type = "recipe",
    name = "omega-transmute-uranium-ore",
    categories = {"chemistry"},
    enabled = false,
    energy_required = 10,
    ingredients = {{
        type = "fluid",
        name = "omega-fluid",
        amount = 100
    }, {
        type = "fluid",
        name = "sulfuric-acid",
        amount = 100
    }},
    results = {{
        type = "item",
        name = "uranium-ore",
        amount = 1
    }},
    icons = {{
        icon = "__base__/graphics/icons/uranium-ore.png",
        icon_size = 64
    }},
    subgroup = "raw-material",
    order = "z"
}

local prototypes = {omega_fluid, omega_machine, omega_item, omega_recipe_category, omega_transmuter_recipe_category,
                    omega_recipe, omega_transmuter, omega_transmuter_item, omega_transmuter_craft_recipe,
                    omega_uranium_recipe}

for _, recipe in ipairs(omega_transmuter_recipes) do
    table.insert(prototypes, recipe)
end

table.insert(data.raw.technology["uranium-processing"].effects, {
    type = "unlock-recipe",
    recipe = "omega-transmute-uranium-ore"
})

table.insert(data.raw.technology["oil-processing"].effects, {
    type = "unlock-recipe",
    recipe = "omega-transmute-crude-oil"
})

data:extend(prototypes)
