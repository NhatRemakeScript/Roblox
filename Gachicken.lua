-- Load Obsidian Library
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

-- Tạo Window
local Win = Lib:CreateWindow("⚡ DucNhat HUB")

-- Tạo Tabs
local MainTab = Win:CreateTab("Main")
local StatsTab = Win:CreateTab("Stats")

-- ================== VARIABLES ==================
local reb = false
local feeder = false
local ne = false
local autoTower = false
local towerCooldown = 0

-- ================== HELPERS ==================
local function getMoney()
    local ls = game:GetService("Players").LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        local money = ls:FindFirstChild("Money") or ls:FindFirstChild("Cash")
        if money then return tonumber(money.Value) or 0 end
    end
    return 0
end

local function getCurrentTower()
    local ls = game:GetService("Players").LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        local tower = ls:FindFirstChild("Tower")
        if tower then return tonumber(tower.Value) or 0 end
    end
    return 0
end

-- ================== AUTO REBIRTH ==================
MainTab:CreateToggle("👼 Auto Rebirth", false, function(s)
    reb = s
    if s then
        spawn(function()
            while reb do
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.Rebirth:InvokeServer()
                end)
                wait(randDelay(2, 4))
            end
        end)
    end
end)

-- ================== AUTO FEEDER ==================
MainTab:CreateToggle("🌾 Auto Feeder", false, function(s)
    feeder = s
    if s then
        spawn(function()
            while feeder do
                pcall(function()
                    local currentTower = getCurrentTower()
                    local currentMoney = getMoney()
                    if currentTower == 0 then
                        if currentMoney >= 360 then
                            game:GetService("ReplicatedStorage").Remotes.BuyGenerator:InvokeServer(1)
                            Win:Notify("✅ Mua Generator 1!")
                        end
                    else
                        game:GetService("ReplicatedStorage").Remotes.UpgradeGenerator:InvokeServer(1)
                    end
                end)
                wait(randDelay(3, 5))
            end
        end)
    end
end)

-- ================== AUTO TOWER ==================
MainTab:CreateToggle("🗼 Auto Tower", false, function(s)
    autoTower = s
    if s then
        towerCooldown = randDelay(27.3, 29.5)
        spawn(function()
            while autoTower do
                if towerCooldown <= 0 then
                    local currentTower = getCurrentTower()
                    pcall(function()
                        if currentTower > 0 then
                            game:GetService("ReplicatedStorage").Remotes.TowerElevator:InvokeServer(currentTower + 1)
                            wait(randDelay(1, 2))
                            game:GetService("ReplicatedStorage").Remotes.TowerStart:InvokeServer()
                        else
                            game:GetService("ReplicatedStorage").Remotes.TowerStart:InvokeServer()
                        end
                    end)
                    towerCooldown = randDelay(27.3, 29.5)
                else
                    towerCooldown = towerCooldown - 0.1
                end
                wait(0.1)
            end
        end)
    end
end)

-- ================== NOTIFICATION TEST ==================
Win:Notify("✅ DucNhat HUB đã load thành công!", 5)
