if getgenv().EnvyLoaded then 
    warn("[ENVY] Script is already running!")
    return 
end
getgenv().EnvyLoaded = true

print("Game finded")
print("Executing : Loading (Slime RNG)...")
task.wait(0.5)

-- Paste RAW SCRIPT Slime RNG kamu langsung di bawah ini
-- Services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ========== KONFIGURASI REMOTE ==========
local RollEvent = ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes.RollService.RemoteFunction
local EquipEvent = ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes.InventoryService.RemoteFunction

-- ========== KONFIGURASI INTERVAL ==========
local AUTO_ROLL_INTERVAL = 4       -- interval auto roll (detik)
local AUTO_EQUIP_INTERVAL = 5      -- interval auto equip best (detik)

-- ========== LOAD WINDUI ==========
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ========== TEMA DENGAN SATURASI TINGGI (LATAR TETAP GELAP) ==========
WindUI:AddTheme({
    Name = "monokaipro",
    Background = Color3.fromRGB(39, 40, 34),
    BackgroundImageTransparency = 0,
    Accent = Color3.fromRGB(255, 50, 120),
    Outline = Color3.fromRGB(200, 100, 80),
    Text = Color3.fromRGB(248, 248, 242),
    Placeholder = Color3.fromRGB(117, 113, 94),
    Button = Color3.fromRGB(80, 200, 220),
    Icon = Color3.fromRGB(255, 220, 70),
})

WindUI:AddTheme({
    Name = "dracula",
    Background = Color3.fromRGB(40, 42, 54),
    BackgroundImageTransparency = 0,
    Accent = Color3.fromRGB(0, 255, 150),
    Outline = Color3.fromRGB(200, 100, 255),
    Text = Color3.fromRGB(248, 248, 242),
    Placeholder = Color3.fromRGB(68, 71, 90),
    Button = Color3.fromRGB(255, 80, 180),
    Icon = Color3.fromRGB(255, 220, 50),
})

WindUI:AddTheme({
    Name = "onepro",
    Background = Color3.fromRGB(40, 44, 52),
    BackgroundImageTransparency = 0,
    Accent = Color3.fromRGB(0, 200, 255),
    Outline = Color3.fromRGB(255, 150, 50),
    Text = Color3.fromRGB(171, 178, 191),
    Placeholder = Color3.fromRGB(60, 64, 72),
    Button = Color3.fromRGB(150, 255, 100),
    Icon = Color3.fromRGB(255, 180, 60),
})

WindUI:AddTheme({
    Name = "ayu-mist",
    Background = Color3.fromRGB(35, 38, 46),
    BackgroundImageTransparency = 0,
    Accent = Color3.fromRGB(255, 120, 80),
    Outline = Color3.fromRGB(100, 200, 200),
    Text = Color3.fromRGB(204, 208, 214),
    Placeholder = Color3.fromRGB(45, 49, 59),
    Button = Color3.fromRGB(80, 180, 255),
    Icon = Color3.fromRGB(255, 200, 70),
})

local availableThemes = {
    "Dark", "Light", "Crimson", "Mellowsi",
    "monokaipro", "onepro", "dracula", "ayu-mist"
}

-- ========== DISCORD WEBHOOK CONFIG ==========
local webhook_url = ""
local webhook_enabled = false
local last_webhook_msg_id = nil
local last_looted_item = "None"
local last_new_slime = { name = "None", rarity = "N/A", image = "" }

local function getAssetUrl(assetStr)
    if not assetStr or assetStr == "" or type(assetStr) ~= "string" then return "" end
    -- Handle both "rbxassetid://123" and raw numeric IDs
    local id = string.match(assetStr, "%d+")
    if id then
        -- Use the Roblox Thumbnail API which Discord can display
        return "https://www.roblox.com/asset-thumbnail/image?assetId=" .. id .. "&width=420&height=420&format=png"
    end
    return ""
end

local function getPlayerSlimesFolder()
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then 
        return workspace:FindFirstChild("Gameplay1") and workspace.Gameplay1:FindFirstChild("Slimes") 
    end

    local bestFolder = nil
    local closestDist = math.huge
    
    for _, plot in pairs(workspace:GetChildren()) do
        if string.sub(plot.Name, 1, 8) == "Gameplay" then
            local slimesFolder = plot:FindFirstChild("Slimes")
            if slimesFolder then
                local slimes = slimesFolder:GetChildren()
                if #slimes > 0 then
                    local firstSlime = slimes[1]
                    local slimePart = firstSlime:FindFirstChild("HumanoidRootPart") or firstSlime.PrimaryPart or firstSlime:FindFirstChildWhichIsA("BasePart")
                    if slimePart then
                        local dist = (slimePart.Position - rootPart.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            bestFolder = slimesFolder
                        end
                    end
                end
            end
        end
    end
    
    return bestFolder or (workspace:FindFirstChild("Gameplay1") and workspace.Gameplay1:FindFirstChild("Slimes"))
end

local function updateWebhook()
    if not webhook_enabled or webhook_url == "" then return end
    
    local root = LocalPlayer.PlayerGui:FindFirstChild("Root")
    if not root then return end
    
    -- Extract Data dari UI
    local money = "0"
    local goop = "0"
    pcall(function()
        money = root.LeftSideBar.CounterStack.CoinCounter.CounterRow.Amount.TextLabel.Text
        goop = root.LeftSideBar.CounterStack.GoopCounter.CounterRow.Amount.TextLabel.Text
    end)
    
    -- Equipped Slimes Gathering (Syncing Workspace names with GUI stats)
    local equipped_slimes_list = {}
    pcall(function()
        local container = root.Inventory.PageInventoryContent.SlimesPage.EquippedSlimesFrame.Container
        
        -- Get all slime names from Workspace (Primary Source for Names)
        local workspaceNames = {}
        pcall(function()
            local slimesFolder = getPlayerSlimesFolder()
            if slimesFolder then
                local slimes = slimesFolder:GetChildren()
                for _, model in ipairs(slimes) do
                    local name = "Unknown"
                    pcall(function()
                        local content = model.SlimeInfoBillboard.Content
                        local nameInst = content:FindFirstChild("Name")
                        if nameInst then
                            local text = nameInst.Text
                            if nameInst:IsA("StringValue") then text = nameInst.Value end
                            if text and text ~= "" then name = text end
                        end
                    end)
                    table.insert(workspaceNames, name)
                end
            end
        end)
        
        -- Get all valid frames from GUI (Primary Source for Stats)
        local guiFrames = {}
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChild("SlimeButton") then
                table.insert(guiFrames, child)
            end
        end
        
        -- Match them by index
        local maxItems = math.max(#workspaceNames, #guiFrames)
        for i = 1, maxItems do
            local name = workspaceNames[i] or "Equipped Slime"
            local frame = guiFrames[i]
            local level = "Lv. 1"
            local rarity = "N/A"
            
            if frame then
                local btn = frame.SlimeButton
                -- Level (Cleaned)
                pcall(function()
                    local lvlLabel = btn.TextLabelFrame.TextLabel
                    local raw = lvlLabel.ContentText or lvlLabel.Text
                    if raw and raw ~= "" then
                        local num = string.match(raw, "%d+")
                        if num then
                            level = "Lv. " .. num
                        else
                            -- Handle things like "Max" or "Lv. Max"
                            if string.match(string.lower(raw), "max") then
                                level = "Lv. Max"
                            else
                                level = raw
                            end
                        end
                    end
                end)
                -- Rarity (GetChildren()[3])
                pcall(function()
                    local rarityLabel = btn:GetChildren()[3].TextLabel
                    local rawRarity = rarityLabel.ContentText or rarityLabel.Text
                    if rawRarity and rawRarity ~= "" then
                        rarity = rawRarity
                    end
                end)
            end
            
            if name ~= "Equipped Slime" or rarity ~= "N/A" then
                table.insert(equipped_slimes_list, string.format("🔹 **%s** — `%s` | *%s*", name, level, rarity))
            end
        end
    end)
    
    local items_inventory_list = {}
    pcall(function()
        local consumablesList = root.Inventory.PageItemsContent.ItemsInventoryPage.DefaultItemsView.ConsumablesPanel.ConsumablesList
        for _, child in pairs(consumablesList:GetChildren()) do
            if string.find(child.Name, "ItemButton") then
                local itemName = string.gsub(child.Name, "ItemButton", "")
                local amount = "1"
                
                pcall(function()
                    local countLabel = child:FindFirstChild("Amount") and child.Amount:FindFirstChild("TextLabel")
                    if countLabel then amount = countLabel.Text end
                end)
                
                table.insert(items_inventory_list, string.format("• %s: `%s`", itemName, amount))
            end
        end
    end)
    
    local equipped_str = #equipped_slimes_list > 0 and table.concat(equipped_slimes_list, "\n") or "None"
    local items_str = #items_inventory_list > 0 and table.concat(items_inventory_list, "\n") or "Empty"
    
    -- Construction of Embed
    local embed = {
        ["title"] = "✨ **SLIME RNG AUTOMATION** ✨",
        ["color"] = 0x00FFAA,
        ["fields"] = {
            { 
                ["name"] = "⚔️ **EQUIPPED SLIMES**", 
                ["value"] = equipped_str, 
                ["inline"] = false 
            },
            { 
                ["name"] = "💰 **MONEY**", 
                ["value"] = "`" .. money .. "`", 
                ["inline"] = true 
            },
            { 
                ["name"] = "🧪 **GOOP**", 
                ["value"] = "`" .. goop .. "`", 
                ["inline"] = true 
            },
            { 
                ["name"] = "🎒 **ITEMS INVENTORY**", 
                ["value"] = items_str, 
                ["inline"] = false 
            },
            { 
                ["name"] = "📦 **LAST LOOT**", 
                ["value"] = "`" .. last_looted_item .. "`", 
                ["inline"] = false 
            },
            { 
                ["name"] = "🆕 **LAST ROLL RESULT**", 
                ["value"] = string.format("```fix\n%s (%s)\n```", last_new_slime.name, last_new_slime.rarity), 
                ["inline"] = false 
            }
        },
        ["footer"] = { 
            ["text"] = "Status: Active | " .. os.date("%X")
        },
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    local payload = game:GetService("HttpService"):JSONEncode({
        ["embeds"] = { embed }
    })
    
    local url = webhook_url
    local method = "POST"
    
    if last_webhook_msg_id then
        url = webhook_url .. "/messages/" .. last_webhook_msg_id
        method = "PATCH"
    else
        url = webhook_url .. "?wait=true"
    end
    
    local req_func = (syn and syn.request) or (http and http.request) or http_request or request
    if not req_func then return end

    pcall(function()
        local response = req_func({
            Url = url,
            Method = method,
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload
        })
        
        if response and method == "POST" then
            local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(response.Body) end)
            if ok and data and data.id then
                last_webhook_msg_id = data.id
            end
        end
    end)
end

local function webhookLoop()
    while true do
        if webhook_enabled then
            updateWebhook()
        end
        task.wait(2) -- Changed to 2s to be safe with Discord Rate Limits (max 30 req/min)
    end
end
task.spawn(webhookLoop)

-- ========== BUAT WINDOW ==========
local Window = WindUI:CreateWindow({
    Title = "Slime RNG",
    Icon = "astroid",
    Resizable = true,
    AutoScale = true,
    Theme = "monokaipro",
    Size = UDim2.fromOffset(680, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.RightShift,
    OpenButton = {
        Enabled = true,
        Title = "Open UI",
        Draggable = true,
    }
})

-- ========== SECTION & TAB ==========
local MainSection = Window:Section({
    Title = "Main",
    Icon = "maximize",
    Opened = true,
})

local FarmTab = MainSection:Tab({
    Title = "Farm",
    Icon = "hand-coins",
})

local MiscTab = MainSection:Tab({
    Title = "Misc",
    Icon = "box",
})

local ConfigTab = Window:Tab({
    Title = "Config",
    Icon = "settings",
})

-- ========== LOGIKA AUTO ROLL ==========
local autoRollEnabled = false
local autoRollToggle = nil

local function fireRoll()
    pcall(function()
        RollEvent:InvokeServer("requestRoll")
        task.delay(0.5, function()
            local root = LocalPlayer.PlayerGui:FindFirstChild("Root")
            if root then
                local rarityLabel = root:FindFirstChild("ImageLabel") and root.ImageLabel:FindFirstChild("Rarity") and root.ImageLabel.Rarity:FindFirstChild("TextLabel")
                if rarityLabel and rarityLabel.Visible then
                    local rarityText = rarityLabel.Text
                    local nameStr = "Unknown Slime"
                    
                    -- Hook name langsung dari UI TextLabel
                    pcall(function()
                        local directName = root.ImageLabel:FindFirstChild("Name") or root.ImageLabel:FindFirstChild("SlimeName") or root.ImageLabel:FindFirstChild("Title")
                        if directName and directName:IsA("TextLabel") and directName.Text ~= "" then
                            nameStr = directName.Text
                        end
                    end)
                    
                    -- Fallback: Cari TextLabel apapun di dalam popup yang bukan Rarity
                    if nameStr == "Unknown Slime" then
                        pcall(function()
                            for _, child in pairs(root.ImageLabel:GetDescendants()) do
                                if child:IsA("TextLabel") and child.Visible and child.Text ~= "" and child.Text ~= rarityText then
                                    -- Abaikan label level
                                    if not string.match(string.lower(child.Text), "^lv") and not string.match(string.lower(child.Text), "level") then
                                        nameStr = child.Text
                                        break
                                    end
                                end
                            end
                        end)
                    end
                    
                    last_new_slime.rarity = rarityText
                    last_new_slime.name = nameStr
                end
            end
        end)
    end)
end

local function autoRollLoop()
    while autoRollEnabled do
        fireRoll()
        local start = os.clock()
        while autoRollEnabled and (os.clock() - start) < AUTO_ROLL_INTERVAL do
            task.wait(0.1)
        end
    end
end

local function setAutoRoll(enabled)
    if autoRollEnabled == enabled then return end
    autoRollEnabled = enabled
    if autoRollEnabled then
        task.spawn(autoRollLoop)
    end
    if autoRollToggle then
        autoRollToggle:SetValue(autoRollEnabled)
    end
end

-- ========== LOGIKA AUTO EQUIP BEST ==========
local autoEquipEnabled = false
local autoEquipToggle = nil

local function fireEquip()
    pcall(EquipEvent.InvokeServer, EquipEvent, "requestEquipBest")
end

local function autoEquipLoop()
    while autoEquipEnabled do
        fireEquip()
        local start = os.clock()
        while autoEquipEnabled and (os.clock() - start) < AUTO_EQUIP_INTERVAL do
            task.wait(0.1)
        end
    end
end

local function setAutoEquip(enabled)
    if autoEquipEnabled == enabled then return end
    autoEquipEnabled = enabled
    if autoEquipEnabled then
        task.spawn(autoEquipLoop)
    end
    if autoEquipToggle then
        autoEquipToggle:SetValue(autoEquipEnabled)
    end
end

-- ========== ELEMEN UI DI TAB FARM ==========
autoRollToggle = FarmTab:Toggle({
    Title = "Auto Roll",
    Description = "Kirim request roll setiap " .. AUTO_ROLL_INTERVAL .. " detik",
    Icon = "rotate-cw",
    Value = false,
    Callback = function(val)
        setAutoRoll(val)
    end
})

autoEquipToggle = FarmTab:Toggle({
    Title = "Auto Equip Best",
    Description = "Equip perlengkapan terbaik setiap " .. AUTO_EQUIP_INTERVAL .. " detik",
    Icon = "sword",   -- icon pedang (lucide)
    Value = false,
    Callback = function(val)
        setAutoEquip(val)
    end
})

-- ========== DROPDOWN THEME ==========
ConfigTab:Dropdown({
    Title = "Theme",
    Description = "Pilih tema – warna aksen, tombol, ikon lebih jenuh (latar gelap)",
    Icon = "palette",
    Values = availableThemes,
    Value = "monokaipro",
    Callback = function(val)
        WindUI:SetTheme(val)

    end
})

-- ========== SLIDER AUTO ROLL DELAY ==========
ConfigTab:Slider({
    Title = "Auto Roll Delay",
    Desc = "Delay between rolls 0-4(sec)",
    Step = 1,
    Value = {
        Min = 0,
        Max = 4,
        Default = 4,
    },
    Callback = function(value)
        AUTO_ROLL_INTERVAL = value
        if value == 0 then
            setAutoRoll(false)
        end
    end
})

ConfigTab:Section({ Title = "Discord Webhook" })

ConfigTab:Input({
    Title = "Webhook URL",
    Placeholder = "Paste your discord webhook link here...",
    Callback = function(val)
        webhook_url = val
    end
})

ConfigTab:Toggle({
    Title = "Enable Webhook Logging",
    Value = false,
    Callback = function(val)
        webhook_enabled = val
    end
})



-- ========== AUTO LOOT COLLECTION ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LootEvent = ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes.LootService.RemoteEvent

local autoLootEnabled = false
local autoLootToggle = nil
local LootLog = nil

local LOOT_ITEMS = {
    -- Food
    "apple", "avocado", "banana", "broccoli", "carrot",
    "cherries", "chicken", "drumstick", "grapes", "pizza", "watermelon",
    -- Dice & Potions
    "bigDice", "coinPotion", "hugeDice", "invertedDice",
    "luckPotion", "rollSpeedPotion", "shinyDice", "ultraLuckPotion",
}

local function claimLoot(lootModel)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, itemName in ipairs(LOOT_ITEMS) do
        local item = lootModel:FindFirstChild(itemName)
        if item then
            local touchInterest = item:FindFirstChild("TouchInterest")
            if touchInterest then
                pcall(function()
                    firetouchinterest(item, root, 0)
                    task.wait(0.1)
                    firetouchinterest(item, root, 1)
                end)
                return itemName
            end
        end
    end

    -- Fallback: try all children
    for _, child in pairs(lootModel:GetChildren()) do
        local touchInterest = child:FindFirstChild("TouchInterest")
        if touchInterest then
            pcall(function()
                firetouchinterest(child, root, 0)
                task.wait(0.1)
                firetouchinterest(child, root, 1)
            end)
            return child.Name
        end
    end

    return nil
end

-- Listen for loot events from server
LootEvent.OnClientEvent:Connect(function(eventName, data)
    if eventName == "lootAdded" and data then
        local uniqueId = data.uniqueId
        local lootId = data.lootId or "Unknown"



        -- Update UI log
        pcall(function()
            if LootLog then
                LootLog:SetDesc(string.format("Item: %s\nID: %s", lootId, tostring(uniqueId)))
            end
            last_looted_item = lootId
        end)

        if not autoLootEnabled then return end

        -- Wait for loot to appear in workspace
        task.spawn(function()
            local lootFolder = workspace:WaitForChild("Loot", 5)
            if not lootFolder then return end

            local lootModel
            local attempts = 0
            repeat
                lootModel = lootFolder:FindFirstChild(tostring(uniqueId))
                task.wait(0.1)
                attempts = attempts + 1
            until lootModel or attempts > 50

            if lootModel then
                local claimed = claimLoot(lootModel)
                if claimed then

                    pcall(function()
                        if LootLog then
                            LootLog:SetDesc(string.format("Claimed: %s\nID: %s", claimed, tostring(uniqueId)))
                        end
                    end)
                end
            end
        end)
    end
end)

-- Also auto-claim any existing loot in workspace
local function claimAllExistingLoot()
    local lootFolder = workspace:FindFirstChild("Loot")
    if not lootFolder then return end

    for _, lootModel in pairs(lootFolder:GetChildren()) do
        if autoLootEnabled then
            local claimed = claimLoot(lootModel)
            if claimed then

            end
            task.wait(0.15)
        end
    end
end

-- UI Toggle for Auto Loot
autoLootToggle = FarmTab:Toggle({
    Title = "Auto Loot",
    Description = "Auto claim loot drops tanpa harus touch",
    Icon = "package",
    Value = false,
    Callback = function(val)
        autoLootEnabled = val
        if val then
            task.spawn(claimAllExistingLoot)
        end
    end
})

LootLog = FarmTab:Paragraph({
    Title = "Loot Log",
    Desc = "Waiting for loot...",
})

-- ========== AUTO FEED ==========
local InventoryEvent = ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes.InventoryService.RemoteFunction

local FOOD_ITEMS = {
    "apple", "avocado", "banana", "broccoli", "carrot",
    "cherries", "chicken", "drumstick", "grapes", "pizza", "watermelon"
}

local SlimeNameMapping = {}

local function processSlimeName(displayName, internalName, uniqueSet, outList)
    if not displayName or type(displayName) ~= "string" or displayName == "" then return end
    if string.find(displayName, "Lv%.") then return end
    
    local cleanName = string.gsub(displayName, "[%-_]", " ")
    cleanName = string.gsub(cleanName, "%s+", " ")
    cleanName = string.match(cleanName, "^%s*(.-)%s*$")
    if cleanName == "" then cleanName = displayName end
    
    -- Handle duplicate names (e.g. multiple "Shiny Orca" equipped)
    local finalCleanName = cleanName
    local counter = 2
    while uniqueSet[finalCleanName] do
        finalCleanName = cleanName .. " " .. counter
        counter = counter + 1
    end
    
    uniqueSet[finalCleanName] = true
    SlimeNameMapping[finalCleanName] = internalName or displayName
    table.insert(outList, finalCleanName)
end

local function getEquippedSlimes()
    local slimes = {}
    local uniqueSlimes = {}
    pcall(function()
        local slimesFolder = getPlayerSlimesFolder()
        if slimesFolder then
            for _, child in pairs(slimesFolder:GetChildren()) do
                -- Extract raw unique code from the model's name (e.g. ".1c9e63a6...#1" -> ".1c9e63a6...")
                local internalId = child.Name
                if string.find(internalId, "#") then
                    internalId = string.match(internalId, "^(.-)#")
                end
                
                local hasDisplayName = false
                local billboard = child:FindFirstChild("SlimeInfoBillboard")
                if billboard then
                    local content = billboard:FindFirstChild("Content")
                    if content then
                        local nameInst = content:FindFirstChild("Name")
                        if nameInst then
                            pcall(function()
                                local text = nameInst.Text
                                if nameInst:IsA("StringValue") then text = nameInst.Value end
                                processSlimeName(text, internalId, uniqueSlimes, slimes)
                                hasDisplayName = true
                            end)
                        end
                    end
                end
                
                if not hasDisplayName then
                    -- Fallback to the extracted ID if no Billboard is found
                    processSlimeName(internalId, internalId, uniqueSlimes, slimes)
                end
            end
        end
    end)
    table.sort(slimes, function(a, b) return string.lower(a) < string.lower(b) end)
    if #slimes == 0 then table.insert(slimes, "None") end
    return slimes
end

local function getInventorySlimes()
    local slimes = {}
    local uniqueSlimes = {}
    pcall(function()
        local scrollingFrame = LocalPlayer.PlayerGui.Root.Inventory.PageInventoryContent.SlimesPage.ScrollingFrame
        for _, child in pairs(scrollingFrame:GetChildren()) do
            if string.find(child.Name, "InventorySlime_") then
                local originalName = string.gsub(child.Name, "InventorySlime_", "")
                processSlimeName(originalName, originalName, uniqueSlimes, slimes)
            end
        end
    end)
    table.sort(slimes, function(a, b) return string.lower(a) < string.lower(b) end)
    if #slimes == 0 then table.insert(slimes, "None") end
    return slimes
end

local FoodNameMapping = {}

local function getAvailableFoods()
    local foods = {}
    local uniqueFoods = {}
    FoodNameMapping = {}
    
    local isFoodLookup = {}
    for _, food in ipairs(FOOD_ITEMS) do
        isFoodLookup[string.lower(food)] = food
    end
    
    pcall(function()
        local consumablesList = LocalPlayer.PlayerGui.Root.Inventory.PageItemsContent.ItemsInventoryPage.DefaultItemsView.ConsumablesPanel.ConsumablesList
        for _, child in pairs(consumablesList:GetChildren()) do
            if string.find(child.Name, "ItemButton") then
                local internalName = string.gsub(child.Name, "ItemButton", "")
                
                local matchedFood = isFoodLookup[string.lower(internalName)]
                if matchedFood then
                    local displayName = matchedFood
                    pcall(function()
                        local textLabel = child:FindFirstChild("TextLabelFrame") and child.TextLabelFrame:FindFirstChild("TextLabel")
                        if textLabel and textLabel.Text ~= "" then
                            displayName = textLabel.Text
                        end
                    end)
                    
                    if not uniqueFoods[displayName] then
                        uniqueFoods[displayName] = true
                        FoodNameMapping[displayName] = matchedFood
                        table.insert(foods, displayName)
                    end
                end
            end
        end
    end)
    
    table.sort(foods, function(a, b) return string.lower(a) < string.lower(b) end)
    if #foods == 0 then table.insert(foods, "None") end
    return foods
end

local selectedSlime = ""
local selectedFood = "None"
local autoFeedEnabled = false

local EquippedDropdown = MiscTab:Dropdown({
    Title = "Equipped Slimes",
    Description = "Select from equipped slimes",
    Icon = "swords",
    Values = getEquippedSlimes(),
    Value = "None",
    Callback = function(val)
        if val ~= "None" then
            selectedSlime = SlimeNameMapping[val] or val
        end
    end
})

local InventoryDropdown = MiscTab:Dropdown({
    Title = "Inventory Slimes",
    Description = "Select from inventory slimes",
    Icon = "backpack",
    Values = getInventorySlimes(),
    Value = "None",
    Callback = function(val)
        if val ~= "None" then
            selectedSlime = SlimeNameMapping[val] or val
        end
    end
})

MiscTab:Button({
    Title = "Refresh Lists",
    Desc = "Update dropdown lists for slimes and foods",
    Icon = "refresh-cw",
    Callback = function()
        SlimeNameMapping = {}
        FoodNameMapping = {}
        pcall(function()
            EquippedDropdown:Refresh(getEquippedSlimes())
            InventoryDropdown:Refresh(getInventorySlimes())
            FoodDropdown:Refresh(getAvailableFoods())
        end)
    end
})

local FoodDropdown = MiscTab:Dropdown({
    Title = "Select Food",
    Description = "Select food from inventory",
    Icon = "apple",
    Values = getAvailableFoods(),
    Value = "None",
    Callback = function(val)
        if val ~= "None" and val ~= nil then
            selectedFood = FoodNameMapping[val] or val
        end
    end
})

local function hasFood(foodName)
    local found = false
    pcall(function()
        local consumablesList = LocalPlayer.PlayerGui.Root.Inventory.PageItemsContent.ItemsInventoryPage.DefaultItemsView.ConsumablesPanel.ConsumablesList
        for _, child in pairs(consumablesList:GetChildren()) do
            if string.find(string.lower(child.Name), string.lower(foodName) .. "itembutton") then
                found = true
                break
            end
        end
    end)
    return found
end

local function autoFeedLoop()
    while autoFeedEnabled do
        if selectedSlime ~= "" and selectedSlime ~= "None" and selectedFood ~= "" and selectedFood ~= "None" then
            if hasFood(selectedFood) then
                local currentSlime = selectedSlime
                local currentFood = selectedFood
                task.spawn(function()
                    pcall(function()
                        InventoryEvent:InvokeServer("requestUseFood", currentFood, currentSlime, 1)
                    end)
                end)
            end
        end
        task.wait(1)
    end
end

MiscTab:Toggle({
    Title = "Auto Feed",
    Description = "Auto feed ur slime",
    Icon = "utensils",
    Value = false,
    Callback = function(val)
        autoFeedEnabled = val
        if val then
            task.spawn(autoFeedLoop)
        end
    end
})

-- Auto-refresh Food Dropdown when inventory changes
pcall(function()
    local consumablesList = LocalPlayer.PlayerGui.Root.Inventory.PageItemsContent.ItemsInventoryPage.DefaultItemsView.ConsumablesPanel.ConsumablesList
    
    local function onInventoryChanged()
        pcall(function()
            FoodDropdown:Refresh(getAvailableFoods())
        end)
    end
    
    consumablesList.ChildAdded:Connect(onInventoryChanged)
    consumablesList.ChildRemoved:Connect(onInventoryChanged)
end)
-- ATAU biarkan loadstring ini jika kamu upload raw-nya ke Vercel:
loadstring(game:HttpGet("https://envy-web-rho.vercel.app/raw/slimerng.lua"))()
