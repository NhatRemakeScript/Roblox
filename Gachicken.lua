-- ================== LOAD OBSIDIAN LIBRARY ==================
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

-- ================== TẠO WINDOW ==================
local Win = Lib:CreateWindow("⚡ DucNhat HUB 2.0.9")

-- ================== TẠO TABS ==================
local MainTab = Win:CreateTab("Main")
local StatsTab = Win:CreateTab("Stats")

-- ================== SERVICES ==================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")

-- ================== HELPERS ==================
local function randDelay(min, max)
    return math.random(min * 100, max * 100) / 100
end

local function getMoney()
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local money = ls:FindFirstChild("Money") or ls:FindFirstChild("Cash")
        if money then return tonumber(money.Value) or 0 end
    end
    return 0
end

local function getCurrentTower()
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local tower = ls:FindFirstChild("Tower")
        if tower then return tonumber(tower.Value) or 0 end
    end
    return 0
end

local function isGuiActuallyVisible(gui)
    if not gui or not gui:IsA("GuiObject") then return false end
    local current = gui
    while current do
        if current:IsA("GuiObject") and not current.Visible then return false end
        current = current.Parent
    end
    if gui.AbsoluteSize.X <= 0 or gui.AbsoluteSize.Y <= 0 then return false end
    return true
end

local function isRebirthReadyVisible()
    local notice = Player:WaitForChild("PlayerGui"):FindFirstChild("RebirthNotice")
    if not notice then return false end
    for _, gui in ipairs(notice:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            if gui.Text and gui.Text:upper():find("REBIRTH READY!") and isGuiActuallyVisible(gui) then
                return true
            end
        end
    end
    return false
end

-- ================== ANTI-AFK ==================
spawn(function()
    while wait(60) do
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end)

-- ================== AUTO REBIRTH ==================
local reb = false

MainTab:CreateToggle("👼 Auto Rebirth", false, function(s)
    reb = s
    if s then
        spawn(function()
            local isRebirthing = false
            local rebirthStartTime = 0
            while reb do
                pcall(function()
                    local rebirthReady = isRebirthReadyVisible()
                    if rebirthReady and not isRebirthing then
                        isRebirthing = true
                        rebirthStartTime = tick()
                        Win:Notify("🔄 Rebirth Ready!")
                    end
                    if isRebirthing then
                        if tick() - rebirthStartTime < 10 then
                            pcall(function() RS.Remotes.Rebirth:InvokeServer() end)
                            wait(randDelay(2, 4))
                        else
                            isRebirthing = false
                            Win:Notify("✅ Hoàn thành Rebirth!")
                        end
                    end
                end)
                wait(randDelay(1, 2))
            end
        end)
    end
end)

-- ================== AUTO FEEDER ==================
local feeder = false

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
                            pcall(function() RS.Remotes.BuyGenerator:InvokeServer(1) end)
                            Win:Notify("✅ Mua Generator 1!")
                        end
                    else
                        pcall(function() RS.Remotes.UpgradeGenerator:InvokeServer(1) end)
                    end
                end)
                wait(randDelay(3, 5))
            end
        end)
    end
end)

-- ================== AUTO TOWER ==================
local autoTower = false
local towerCooldown = 0

MainTab:CreateToggle("🗼 Auto Tower", false, function(s)
    autoTower = s
    if s then
        towerCooldown = randDelay(27.3, 29.5)
        local wasRebirthVisible = false
        
        spawn(function()
            while autoTower do
                if towerCooldown > 0 then
                    towerCooldown = towerCooldown - 0.1
                end
                
                if towerCooldown <= 0 then
                    local currentTower = getCurrentTower()
                    pcall(function()
                        if currentTower > 0 then
                            pcall(function() RS.Remotes.TowerElevator:InvokeServer(currentTower + 1) end)
                            wait(randDelay(1, 2))
                            pcall(function() RS.Remotes.TowerStart:InvokeServer() end)
                        else
                            pcall(function() RS.Remotes.TowerStart:InvokeServer() end)
                        end
                    end)
                    towerCooldown = randDelay(27.3, 29.5)
                end
                
                wait(0.1)
            end
        end)
        
        spawn(function()
            while autoTower do
                local isVisibleNow = false
                local notice = Player:WaitForChild("PlayerGui"):FindFirstChild("RebirthNotice")
                if notice then
                    for _, gui in ipairs(notice:GetDescendants()) do
                        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                            if gui.Text and gui.Text:upper():find("REBIRTH READY!") and isGuiActuallyVisible(gui) then
                                isVisibleNow = true
                                break
                            end
                        end
                    end
                end
                
                if isVisibleNow and not wasRebirthVisible then
                    wasRebirthVisible = true
                    pcall(function() RS.Remotes.TowerSurrender:InvokeServer() end)
                    Win:Notify("🏳️ Đã đầu hàng tháp!")
                    wait(10)
                elseif not isVisibleNow then
                    wasRebirthVisible = false
                end
                
                wait(0.8)
            end
        end)
    else
        towerCooldown = 0
    end
end)

-- ================== COLLECT EGG ==================
local ne = false
local incubatorTimer = 0

MainTab:CreateToggle("🥚 Collect Egg", false, function(s)
    ne = s
    if s then
        spawn(function()
            while ne do
                pcall(function()
                    incubatorTimer = incubatorTimer + 1
                    if incubatorTimer >= 30 then
                        pcall(function() RS.Remotes.IncubatorClaim:InvokeServer() end)
                        incubatorTimer = 0
                    end
                    
                    local char = Player.Character
                    if not char then wait(1) return end
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChild("Humanoid")
                    if not root or not humanoid then wait(1) return end
                    
                    local egg = nil
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("Model") and v.Name:find("NestEgg") then
                            local ow = v:FindFirstChild("owner") or v:FindFirstChild("Owner") or v:FindFirstChild("OwnerName")
                            if ow and ow.Value == Player.Name then
                                egg = v
                                break
                            end
                        end
                    end
                    
                    if egg then
                        local pos = egg:FindFirstChild("HumanoidRootPart") or egg:FindFirstChild("PrimaryPart") or egg:FindFirstChildWhichIsA("BasePart")
                        if pos then
                            local targetPos = pos.Position + Vector3.new(0, 2, 0)
                            local distance = (root.Position - targetPos).Magnitude
                            if distance > 5 then
                                humanoid:MoveTo(targetPos)
                                wait(2)
                            end
                        end
                    end
                end)
                wait(2)
            end
        end)
    end
end)

-- ================== STATS LABEL ==================
local statsLabel = StatsTab:CreateLabel("📊 Đang tải stats...")

spawn(function()
    while true do
        local ls = Player:FindFirstChild("leaderstats")
        if ls then
            local corn = ls:FindFirstChild("Corn/s") or ls:FindFirstChild("Corn Farm")
            local tower = ls:FindFirstChild("Tower")
            local money = ls:FindFirstChild("Money") or ls:FindFirstChild("Cash")
            local level = ls:FindFirstChild("Level")
            
            local text = "📊 PLAYER STATS\n\n"
            if corn then text = text .. "🌽 Corn Farm: " .. corn.Value .. "/s\n" end
            if tower then text = text .. "🗼 Tower: " .. tower.Value .. "\n" end
            if money then text = text .. "💰 Money: " .. money.Value .. "\n" end
            if level then text = text .. "⭐ Level: " .. level.Value .. "\n" end
            
            statsLabel:SetText(text)
        end
        wait(1)
    end
end)

-- ================== NOTIFICATION LOAD ==================
Win:Notify("✅ DucNhat HUB đã load thành công!", 5)
