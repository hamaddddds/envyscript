if getgenv().EnvyLoaded then 
    warn("[ENVY] Script is already running!")
    return 
end
getgenv().EnvyLoaded = true

print("Game finded")
print("Executing : Loading (Keyless)...")
task.wait(0.5)

local PlaceId = game.PlaceId

-- Game Mappings (KEYLESS)
-- Mengambil raw script langsung dari hosting Vercel (tanpa key verification Jnkie)
if PlaceId == 3351674303 or PlaceId == 4901815153 then -- Driving Empire
    loadstring(game:HttpGet("https://envy-web-rho.vercel.app/raw/drivingempire.lua"))()

elseif PlaceId == 131378148336503 then -- DDS
    loadstring(game:HttpGet("https://envy-web-rho.vercel.app/raw/dds.lua"))()

elseif PlaceId == 89469502395769 then -- Kick ALB
    loadstring(game:HttpGet("https://envy-web-rho.vercel.app/raw/kickalb.lua"))()

else
    warn("[ENVY] Game not supported! (ID: " .. tostring(PlaceId) .. ")")
end
