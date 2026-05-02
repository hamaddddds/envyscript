--[[
    ENVY UNIVERSAL LOADER
    Automatically detects the game and loads the corresponding script using Jnkie Key System.
]]

local PlaceId = game.PlaceId
local ScriptKey = getgenv().SCRIPT_KEY

if not ScriptKey then
    warn("[ENVY] No Script Key found! Please use the loader from the Discord bot.")
    return
end

print("[ENVY] Loading script for PlaceId: " .. tostring(PlaceId))

-- Game Mappings
if PlaceId == 3351674303 or PlaceId == 4901815153 then -- Driving Empire
    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/62519ca922088c8b14de3119e243f7a419eef043a6cdc30184a16a96f1f32e11/download"))()
-- elseif PlaceId == 12345678 then -- Add more games here
--    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/HASH_GAME_LAIN/download"))()
else
    warn("[ENVY] This game is not supported yet!")
end
