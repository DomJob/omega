local omega_transmuter_icon = "__omega__/graphics/icons/omega-transmuter.png"

local omega_transmuter_recipe_category = {
    type = "recipe-category",
    name = "omega-transmuter"
}

-- Purple tint applied to the borrowed offshore-pump graphics.
local omega_transmuter_tint = {r = 0.55, g = 0.25, b = 1, a = 1}

-- Recursively walks a sprite/animation table (layers, north/east/south/west,
-- sheets, hr_version, etc.) and tints every leaf image definition it finds,
-- skipping anything marked as a shadow so shadows stay black.
local function apply_tint(node, tint)
    if type(node) ~= "table" then
        return
    end
    if (node.filename or node.stripes) and not node.draw_as_shadow then
        node.tint = tint
    end
    for _, value in pairs(node) do
        if type(value) == "table" then
            apply_tint(value, tint)
        end
    end
end

local base_offshore_pump = data.raw["offshore-pump"]["offshore-pump"]
if not base_offshore_pump then
    error("omega-transmuter: could not find base offshore-pump prototype to borrow graphics from")
end

local omega_transmuter_graphics_set = table.deepcopy(base_offshore_pump.graphics_set)
apply_tint(omega_transmuter_graphics_set, omega_transmuter_tint)

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
    -- Borrowed straight from the offshore pump so the collision/selection
    -- boxes actually match the sprite we're reusing, instead of guessed values.
    collision_box = table.deepcopy(base_offshore_pump.collision_box),
    selection_box = table.deepcopy(base_offshore_pump.selection_box),
    tile_width = base_offshore_pump.tile_width,
    tile_height = base_offshore_pump.tile_height,
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
            position = {0, -1}
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
            position = {0, 0}
        }},
        volume = 1000,
        base_area = 50,
        base_level = 1,
        pipe_covers = pipecoverspictures()
    }},
    graphics_set = omega_transmuter_graphics_set,
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