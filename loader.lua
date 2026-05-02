--[[
    ENVY UNIVERSAL LOADER
    Supports: Driving Empire, DDS, and Oil Empire.
]]

local PlaceId = game.PlaceId
local ScriptKey = getgenv().SCRIPT_KEY

if not ScriptKey then
    warn("[ENVY] No Script Key found! Please use the loader from the Discord bot.")
    return
end

-- Game Mappings
if PlaceId == 3351674303 or PlaceId == 4901815153 then -- Driving Empire
    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/62519ca922088c8b14de3119e243f7a419eef043a6cdc30184a16a96f1f32e11/download"))()

elseif PlaceId == 131378148336503 then -- DDS
    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/c5d362d6d9949216afa44bd6c765ddac95fcab11482049635ffb3d93a2412e00/download"))()

elseif PlaceId == 107095834793267 then -- Oil Empire
    -- Link script Oil Empire menyusul
    warn("[ENVY] Oil Empire script coming soon!")
else
    warn("[ENVY] Game not supported! (ID: " .. tostring(PlaceId) .. ")")
end
