--[[
    ENVY UNIVERSAL LOADER (DEBUG VERSION)
    Automatically detects the game and loads the corresponding script using Jnkie Key System.
]]

local PlaceId = game.PlaceId
local ScriptKey = getgenv().SCRIPT_KEY

if not ScriptKey then
    warn("[ENVY] No Script Key found! Please use the loader from the Discord bot.")
    return
end

print("[ENVY] Debug: Script Key is set.")
print("[ENVY] Loading script for PlaceId: " .. tostring(PlaceId))

-- Game Mappings
local scriptUrl = ""
if PlaceId == 3351674303 or PlaceId == 4901815153 then -- Driving Empire
    scriptUrl = "https://api.jnkie.com/api/v1/luascripts/public/62519ca922088c8b14de3119e243f7a419eef043a6cdc30184a16a96f1f32e11/download"
else
    warn("[ENVY] This game (" .. tostring(PlaceId) .. ") is not supported yet!")
    return
end

-- Load execution with error handling
print("[ENVY] Fetching script from Jnkie...")
local success, content = pcall(function()
    return game:HttpGet(scriptUrl)
end)

if not success or not content or content == "" then
    warn("[ENVY] Failed to download script! Error: " .. tostring(content))
    return
end

print("[ENVY] Script downloaded (Size: " .. #content .. " bytes). Executing...")

local func, err = loadstring(content)
if not func then
    warn("[ENVY] Loadstring failed! Error: " .. tostring(err))
    return
end

local execSuccess, execErr = pcall(function()
    func()
end)

if not execSuccess then
    warn("[ENVY] Script execution failed! Error: " .. tostring(execErr))
else
    print("[ENVY] Script executed successfully!")
end
