-- construction_configs.lua
-- Configurações centralizadas para o sistema de construção

CONSTRUCTION_SITE_ID = 23398
MATERIAL_PLANK = 5901
MATERIAL_NAIL = 953
TOOL_HAMMER = 3460
CONSTRUCTION_AID = 60000

CONSTRUCTION_RECIPES = {
    -- === Walls ===
    [1281] = { name = "Framework Wall 1", planks = 7, nails = 16 },
    [1282] = { name = "Framework Wall 2", planks = 7, nails = 16 },
    [1284] = { name = "Framework Wall 3", planks = 7, nails = 16 },
    [1286] = { name = "Framework Wall 4", planks = 7, nails = 16 },
    [1287] = { name = "Framework Wall 5", planks = 7, nails = 16 },
    [5153] = { name = "Framework Wall 6", planks = 10, nails = 5 },
    [5152] = { name = "Framework Wall 7", planks = 10, nails = 5 },
    [5154] = { name = "Framework Wall 8", planks = 10, nails = 5 },
    [1283] = { name = "Framework Wall 9", planks = 10, nails = 5 },
    [9309] = { name = "Framework Wall 10", planks = 10, nails = 5 },
    [9310] = { name = "Framework Wall 11", planks = 10, nails = 5 },
    [9311] = { name = "Framework Wall 12", planks = 10, nails = 5 },
    [9312] = { name = "Framework Wall 13", planks = 10, nails = 5 },
    [9313] = { name = "Framework Wall 14", planks = 10, nails = 5 },
    [9314] = { name = "Framework Wall 15", planks = 10, nails = 5 },
    [9315] = { name = "Framework Wall 16", planks = 10, nails = 5 },
    [9331] = { name = "Framework Wall 17", planks = 10, nails = 5 },
    [9330] = { name = "Framework Wall 18", planks = 10, nails = 5 },
    [9329] = { name = "Framework Wall 19", planks = 10, nails = 5 },
    [9328] = { name = "Framework Wall 20", planks = 10, nails = 5 },
    
    -- === Modern Stone Walls ===
    [17195] = { name = "Modern Stone Wall 1", planks = 10, nails = 5 },
    [17196] = { name = "Modern Stone Wall 2", planks = 10, nails = 5 },
    [17197] = { name = "Modern Stone Wall 3", planks = 10, nails = 5 },
    [17198] = { name = "Modern Stone Wall 4", planks = 10, nails = 5 },
    [17199] = { name = "Modern Stone Wall 5", planks = 10, nails = 5 },
    [17200] = { name = "Modern Stone Wall 6", planks = 10, nails = 5 },
    [17135] = { name = "Modern Stone Wall 7", planks = 10, nails = 5 },
    [17098] = { name = "Modern Stone Wall 8", planks = 10, nails = 5 },
    [17138] = { name = "Modern Stone Wall 9", planks = 10, nails = 5 },

    -- === Floors ===
    [408] = { name = "Wooden Floor", planks = 4, nails = 2 },
    [409] = { name = "Marble Floor", planks = 2, nails = 10 },
    [429] = { name = "Stone Tile", planks = 4, nails = 2 },
    [417] = { name = "Tiled Floor", planks = 4, nails = 2 },
    [17516] = { name = "Parquet Floor 1", planks = 4, nails = 2 },
    [17517] = { name = "Parquet Floor 2", planks = 4, nails = 2 },
    [17518] = { name = "Parquet Floor 3", planks = 4, nails = 2 },
    [16489] = { name = "Grimmy Wooden Plank 1", planks = 4, nails = 2 },
    [16488] = { name = "Grimmy Wooden Plank 2", planks = 4, nails = 2 },
    [16487] = { name = "Grimmy Wooden Plank 3", planks = 4, nails = 2 },
    
    -- === Windows ===
    [6437] = { name = "Framework Window 1", planks = 6, nails = 4 },
    [6438] = { name = "Framework Window 2", planks = 6, nails = 4 },
    [9349] = { name = "Framework Window 3", planks = 6, nails = 4 },
    [9350] = { name = "Framework Window 4", planks = 6, nails = 4 },
    [1734] = { name = "Framework Window 5", planks = 6, nails = 4 },
    [1735] = { name = "Framework Window 6", planks = 6, nails = 4 },
    [17164] = { name = "Modern Stone Window 1", planks = 6, nails = 4 },
    [17166] = { name = "Modern Stone Window 2", planks = 6, nails = 4 },
    [17695] = { name = "Modern Stone Window 3", planks = 6, nails = 4 },
    [17694] = { name = "Modern Stone Window 4", planks = 6, nails = 4 },

    -- === Doors ===
    [1641] = { name = "Framework Door 1", planks = 8, nails = 8 },
    [1639] = { name = "Framework Door 2", planks = 8, nails = 8 },
    [17563] = { name = "Modern Stone Door 1", planks = 8, nails = 8 },
    [17572] = { name = "Modern Stone Door 2", planks = 8, nails = 8 },
    
    -- === Stairs ===
    [433] = { name = "Ladder Down", planks = 4, nails = 8 },
    [1948] = { name = "Ladder Up", planks = 4, nails = 8 },

    -- === Hangables ===
    [2907] = { name = "Wall Lamp (Left)", planks = 2, nails = 2 },
    [2909] = { name = "Wall Lamp (Right)", planks = 2, nails = 2 },
    [9517] = { name = "Stone Ledge (Left)", planks = 4, nails = 4 },
    [9516] = { name = "Stone Ledge (Right)", planks = 4, nails = 4 },
    [2598] = { name = "Blackboard", planks = 5, nails = 5 },
    [2931] = { name = "Lit Torch Bearer (Left)", planks = 3, nails = 3 },
    [2929] = { name = "Lit Torch Bearer (Right)", planks = 3, nails = 3 },
    [2605] = { name = "Hangable Trophy", planks = 5, nails = 5 },

    -- === Furniture ===
    [17388] = { name = "Dark Brown Counter 1", planks = 8, nails = 10 },
    [17389] = { name = "Dark Brown Counter 2", planks = 8, nails = 10 },
    [17390] = { name = "Dark Brown Counter 3", planks = 8, nails = 10 },

    -- === Roofs ===
    [1165] = { name = "Tiled Roof 1", planks = 5, nails = 5 },
    [1160] = { name = "Tiled Roof 2", planks = 5, nails = 5 },
    [1159] = { name = "Tiled Roof 3", planks = 5, nails = 5 },
    [1164] = { name = "Tiled Roof 4", planks = 5, nails = 5 },
    [1166] = { name = "Tiled Roof 5", planks = 5, nails = 5 },
    [1161] = { name = "Tiled Roof 6", planks = 5, nails = 5 },
    [1158] = { name = "Tiled Roof 7", planks = 5, nails = 5 },
    [1157] = { name = "Tiled Roof 8", planks = 5, nails = 5 },
    [1162] = { name = "Tiled Roof 9", planks = 5, nails = 5 },
    [1163] = { name = "Tiled Roof 10", planks = 5, nails = 5 }
}
