if getgenv().EnvyLoaded then 
    warn("[ENVY] Script is already running!")
    return 
end
getgenv().EnvyLoaded = true

print("Game finded")
print("Executing : Loading (Slime RNG)...")
task.wait(0.5)

-- Paste RAW SCRIPT Slime RNG kamu langsung di bawah ini 
-- ATAU biarkan loadstring ini jika kamu upload raw-nya ke Vercel:
loadstring(game:HttpGet("https://envy-web-rho.vercel.app/raw/slimerng.lua"))()
