if getgenv().EnvyLoaded then 
    warn("[ENVY] Script is already running!")
    return 
end
getgenv().EnvyLoaded = true

print("Game finded")
print("Executing : Loading...")
task.wait(0.5)

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

elseif PlaceId == 89469502395769 then -- Kick ALB
    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/6ccb179ff34595f749f0853ea83b9710378e10d53a1ab6038e6bd9071d80b9c0/download"))()

elseif PlaceId == 8356562067 then -- Indo Voice
    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/71c2a27557c6a9c58a14c4c54d640e121b91cf1395c377ba95391c2011a591d7/download"))()

elseif PlaceId == 6911148748 then -- Luarmor Loader Game
    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/d878315dcdabb13eb31727b7c1cf521a480fc5a60d29de01a82cc777107a2a90/download"))()
else
    warn("[ENVY] Game not supported! (ID: " .. tostring(PlaceId) .. ")")
end