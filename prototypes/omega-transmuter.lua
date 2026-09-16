local omega_transmuter_icon = "__omega__/graphics/icons/omega-transmuter.png"

local omega_transmuter_recipe_category = {
    type = "recipe-category",
    name = "omega-transmuter"
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
    if recipe.results[1].type == "fluid" then
        table.insert(recipe.categories, "chemistry")
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

data:extend({omega_transmuter_recipe_category, omega_transmuter, omega_transmuter_item,
             omega_transmuter_craft_recipe, omega_uranium_recipe})

for _, recipe in ipairs(omega_transmuter_recipes) do
    data:extend({recipe})
end

table.insert(data.raw.technology["uranium-processing"].effects, {
    type = "unlock-recipe",
    recipe = "omega-transmute-uranium-ore"
})

table.insert(data.raw.technology["oil-processing"].effects, {
    type = "unlock-recipe",
    recipe = "omega-transmute-crude-oil"
})
