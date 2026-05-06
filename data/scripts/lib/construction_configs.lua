-- construction_configs.lua
-- Configurações centralizadas para o sistema de construção

CONSTRUCTION_SITE_ID = 23398
MATERIAL_PLANK = 5901
MATERIAL_NAIL = 953
TOOL_HAMMER = 3460
CONSTRUCTION_AID = 60000

CONSTRUCTION_RECIPES = {
    -- Walls
    [356] = { name = "Dirt Wall", planks = 5, nails = 2 },
    [357] = { name = "Stone Wall", planks = 10, nails = 5 },
    [1025] = { name = "Framework Wall", planks = 8, nails = 4 },
    [1281] = { name = "Framework Wall 1", planks = 7, nails = 16 },
    [1282] = { name = "Framework Wall 2", planks = 7, nails = 16 },
    [1284] = { name = "Framework Wall 3", planks = 7, nails = 16 },
    [1286] = { name = "Framework Wall 4", planks = 7, nails = 16 },
    [1287] = { name = "Framework Wall 5", planks = 7, nails = 16 },
    
    -- Floors
    [408] = { name = "Wooden Floor", planks = 4, nails = 2 },
    [409] = { name = "Marble Floor", planks = 2, nails = 10 },
    
    -- Furniture
    [2474] = { name = "Wooden Coffin", planks = 8, nails = 12 },
    [2582] = { name = "Wooden Chair", planks = 3, nails = 3 },
    
    -- Openings
    [1026] = { name = "Window", planks = 4, nails = 4 },
    [1211] = { name = "Door", planks = 6, nails = 8 }
}
