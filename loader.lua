--[[
    ENVY UNIVERSAL LOADER (SILENT MODE)
    Automatically detects the game, verifies key via Jnkie silently, and loads the script.
]]

local PlaceId = game.PlaceId
local ScriptKey = getgenv().SCRIPT_KEY

if not ScriptKey then
    warn("[ENVY] No Script Key found! Please use the loader from the Discord bot.")
    return
end

-- Game Mappings
local targetScript = ""
if PlaceId == 3351674303 or PlaceId == 4901815153 then -- Driving Empire
    targetScript = "https://api.jnkie.com/api/v1/luascripts/public/62519ca922088c8b14de3119e243f7a419eef043a6cdc30184a16a96f1f32e11/download"
else
    warn("[ENVY] This game (" .. tostring(PlaceId) .. ") is not supported yet!")
    return
end

-- Setup Silent Jnkie Loader
getgenv().MAIN_SCRIPT_URL = targetScript
loadstring(game:HttpGet("https://raw.githubusercontent.com/hamaddddds/envyscript/main/jnkieloader.lua"))()
