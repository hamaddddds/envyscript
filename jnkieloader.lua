--[[
    ENVY SILENT JNKIE LOADER
    This script verifies the key silently without showing the Jnkie UI.
]]

local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "EnvyHub"
Junkie.identifier = "1091392"
Junkie.provider = "Envy"

local function verifyKey()
    local key = getgenv().SCRIPT_KEY
    
    if not key or key == "" then
        warn("[ENVY] No key provided! Execution stopped.")
        return false
    end

    -- Silent check using Junkie Library
    local result = Junkie.check_key(key)
    
    if result and result.valid then
        print("[ENVY] Key verified successfully! (" .. tostring(result.message) .. ")")
        return true
    else
        local errMsg = (result and result.error) or "Unknown validation error"
        warn("[ENVY] Key verification failed: " .. errMsg)
        
        -- Optional: Kick player if key is invalid
        -- game.Players.LocalPlayer:Kick("Invalid Envy Key: " .. errMsg)
        return false
    end
end

-- Start Verification
if verifyKey() then
    -- SUCCESS: Load the actual game script here
    -- You can pass the actual script download link as a parameter or variable
    if getgenv().MAIN_SCRIPT_URL then
        loadstring(game:HttpGet(getgenv().MAIN_SCRIPT_URL))()
    else
        print("[ENVY] Key is valid, but no MAIN_SCRIPT_URL defined.")
    end
end
