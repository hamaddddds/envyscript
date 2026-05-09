local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "EnvyHub"
Junkie.identifier = "1091392"
Junkie.provider = "Envy"

local function verifyKey()
    local key = getgenv().SCRIPT_KEY
    
    if not key or key == "" then
        warn("[ENVY] No key provided! Execution stopped.")
        game.Players.LocalPlayer:Kick("No Envy Key provided!")
        return false
    end

    local result = Junkie.check_key(key)
    
    if result and result.valid then
        print("[ENVY] Key verified successfully! (" .. tostring(result.message) .. ")")
        return true
    else
        local errMsg = (result and result.error) or "Unknown validation error"
        warn("[ENVY] Key verification failed: " .. errMsg)
        game.Players.LocalPlayer:Kick("Invalid Envy Key: " .. errMsg)
        return false
    end
end

if verifyKey() then
    if getgenv().MAIN_SCRIPT_URL then
        loadstring(game:HttpGet(getgenv().MAIN_SCRIPT_URL))()
    end
end
