--[[
    Rayfield Interface Suite - Tích hợp Auto Farm
    Version: 1.0
]]

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Rayfield/refs/heads/main/source'))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")

-- ================== NOTIFICATION ==================
local function showNotification(text, duration)
    Rayfield:Notify({
        Title = "Auto Farm",
        Content = text,
        Duration = duration or 3.5
    })
end

-- ================== VARIABLES ==================
local reb = false
local feeder = false
local ne = false
local autoTower = false
local towerCooldown = 0
local incubatorTimer = 0

-- ================== HELPERS ==================
local function randDelay(min, max)
    return math.random() * (max - min) + min
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

local function getCornPerSecond()
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local corn = ls:FindFirstChild("Corn/s") or ls:FindFirstChild("Corn Farm")
        if corn then return tonumber(corn.Value) or 0 end
    end
    return 0
end

local function getLevel()
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local level = ls:FindFirstChild("Level")
        if level then return tonumber(level.Value) or 0 end
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

local function moveToPosition(targetPos)
    local char = Player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return false end
    local distance = (root.Position - targetPos).Magnitude
    if distance < 1 then
        humanoid:MoveTo(root.Position)
        return true
    end
    humanoid:MoveTo(targetPos)
    local isWalking = true
    local startTime = tick()
    while isWalking and tick() - startTime < 15 do
        local newDist = (root.Position - targetPos).Magnitude
        if newDist < 5 then return true end
        if humanoid.MoveDirection.Magnitude < 0.5 and newDist > 10 then break end
        wait(0.5)
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

-- ================== TẠO WINDOW ==================
local Window = Rayfield:CreateWindow({
    Name = "⚡ DucNhat 2.0.5",
    LoadingTitle = "Auto Farm Hub",
    LoadingSubtitle = "by DucNhat",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "DucNhat_AutoFarm"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvite",
        RememberJoins = true
    },
    KeySystem = false
})

-- ================== TAB: MAIN ==================
local MainTab = Window:CreateTab("Main", "10137941941")

-- Auto Rebirth
local RebirthToggle = MainTab:CreateToggle({
    Name = "👼 Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(Value)
        reb = Value
        if Value then
            spawn(function()
                local isRebirthing = false
                local rebirthStartTime = 0
                while reb do
                    pcall(function()
                        local rebirthReady = isRebirthReadyVisible()
                        if rebirthReady and not isRebirthing then
                            isRebirthing = true
                            rebirthStartTime = tick()
                            showNotification("🔄 Rebirth Ready!")
                        end
                        if isRebirthing then
                            if tick() - rebirthStartTime < 10 then
                                pcall(function() RS.Remotes.Rebirth:InvokeServer() end)
                                wait(randDelay(2, 4))
                            else
                                isRebirthing = false
                                showNotification("✅ Hoàn thành Rebirth!")
                            end
                        end
                    end)
                    wait(randDelay(1, 2))
                end
            end)
        end
    end
})

-- Auto Feeder
local FeederToggle = MainTab:CreateToggle({
    Name = "🌾 Auto Feeder",
    CurrentValue = false,
    Flag = "AutoFeeder",
    Callback = function(Value)
        feeder = Value
        if Value then
            spawn(function()
                while feeder do
                    pcall(function()
                        local currentTower = getCurrentTower()
                        local currentMoney = getMoney()
                        if currentTower == 0 then
                            if currentMoney >= 360 then
                                pcall(function() RS.Remotes.BuyGenerator:InvokeServer(1) end)
                                showNotification("✅ Mua Generator 1!")
                            end
                        else
                            pcall(function() RS.Remotes.UpgradeGenerator:InvokeServer(1) end)
                        end
                    end)
                    wait(randDelay(3, 5))
                end
            end)
        end
    end
})

-- Collect Egg
local CollectEggToggle = MainTab:CreateToggle({
    Name = "🥚 Collect Egg",
    CurrentValue = false,
    Flag = "CollectEgg",
    Callback = function(Value)
        ne = Value
        if Value then
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
                                    moveToPosition(targetPos)
                                end
                            end
                        end
                    end)
                    wait(2)
                end
            end)
        end
    end
})

-- Auto Tower
local TowerToggle = MainTab:CreateToggle({
    Name = "🗼 Auto Tower",
    CurrentValue = false,
    Flag = "AutoTower",
    Callback = function(Value)
        autoTower = Value
        if Value then
            towerCooldown = randDelay(27.3, 29.5)
            spawn(function()
                while autoTower do
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
                    else
                        towerCooldown = towerCooldown - 0.1
                    end
                    wait(0.1)
                end
            end)
        else
            towerCooldown = 0
        end
    end
})

-- ================== TAB: STATS ==================
local StatsTab = Window:CreateTab("Stats", "10137941941")

-- Tạo Label cho Stats
local MoneyLabel = StatsTab:CreateLabel("💰 Money: 0")
local CornLabel = StatsTab:CreateLabel("🌽 Corn/s: 0")
local TowerLabel = StatsTab:CreateLabel("🗼 Tower: 0")
local LevelLabel = StatsTab:CreateLabel("⭐ Level: 0")

-- ================== TAB: SETTINGS ==================
local SettingsTab = Window:CreateTab("Settings", "10137941941")

-- Theme Selector
SettingsTab:CreateDropdown({
    Name = "🎨 Theme",
    Options = {"Default", "Light"},
    CurrentOption = "Default",
    Flag = "Theme",
    Callback = function(Option)
        Rayfield:ChangeTheme(Option)
    end
})

-- Notification Duration
SettingsTab:CreateSlider({
    Name = "⏱️ Notification Duration",
    Range = {2, 10},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = 6.5,
    Flag = "NotifDuration",
    Callback = function(Value)
        Rayfield.NotificationDuration = Value
    end
})

-- ================== UPDATE STATS ==================
spawn(function()
    while true do
        pcall(function()
            local money = getMoney()
            local corn = getCornPerSecond()
            local tower = getCurrentTower()
            local level = getLevel()
            
            MoneyLabel:Set("💰 Money: " .. tostring(money))
            CornLabel:Set("🌽 Corn/s: " .. tostring(corn))
            TowerLabel:Set("🗼 Tower: " .. tostring(tower))
            LevelLabel:Set("⭐ Level: " .. tostring(level))
        end)
        wait(1)
    end
end)

print("✅ Auto Farm Hub đã được tải thành công!")
print("⚡ DucNhat 2.0.5 - Rayfield Interface")
