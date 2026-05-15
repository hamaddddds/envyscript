local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "EnvyHub"
Junkie.identifier = "1091392"
Junkie.provider = "Envy"

if getgenv().EnvyLoaded then 
    warn("[ENVY] Script is already running!")
    return 
end
getgenv().EnvyLoaded = true

print("Game finded")
print("Executing : Loading...")
task.wait(0.5)

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
    local PlaceId = game.PlaceId

    -- Game Mappings (private - hidden inside Jnkie obfuscation)
    local gameScripts = {
        [3351674303]     = "62519ca922088c8b14de3119e243f7a419eef043a6cdc30184a16a96f1f32e11", -- Driving Empire
        [4901815153]     = "62519ca922088c8b14de3119e243f7a419eef043a6cdc30184a16a96f1f32e11", -- Driving Empire (Alt)
        [131378148336503] = "c5d362d6d9949216afa44bd6c765ddac95fcab11482049635ffb3d93a2412e00", -- DDS
        [89469502395769]  = "6ccb179ff34595f749f0853ea83b9710378e10d53a1ab6038e6bd9071d80b9c0", -- Kick ALB
        [8356562067]      = "71c2a27557c6a9c58a14c4c54d640e121b91cf1395c377ba95391c2011a591d7", -- Indo Voice
        [6911148748]      = "d878315dcdabb13eb31727b7c1cf521a480fc5a60d29de01a82cc777107a2a90", -- CDID Main
        [110369730911937]  = "d878315dcdabb13eb31727b7c1cf521a480fc5a60d29de01a82cc777107a2a90", -- CDID Jatim Map
    }

    local scriptHash = gameScripts[PlaceId]

    if scriptHash then
        local url = "https://api.jnkie.com/api/v1/luascripts/public/" .. scriptHash .. "/download"
        loadstring(game:HttpGet(url))()
    elseif getgenv().MAIN_SCRIPT_URL then
        -- Fallback: load from MAIN_SCRIPT_URL if set (for future games)
        loadstring(game:HttpGet(getgenv().MAIN_SCRIPT_URL))()
    else
        warn("[ENVY] Game not supported! (ID: " .. tostring(PlaceId) .. ")")
        game.Players.LocalPlayer:Kick("[ENVY] This game is not supported.")
    end
end
