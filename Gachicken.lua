-- ================== LOAD LIBRARY ==================
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

-- ================== TẠO WINDOW ==================
local Window = Library:CreateWindow({
    Title = "Settings",
    Footer = "VN Hub",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
    AutoShow = true,
})

-- ================== TẠO TABS ==================
local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Stats = Window:AddTab("Stats", "settings"),
}

-- ================== GROUPBOXES ==================
local LeftGroupBox = Tabs.Main:AddGroupbox({
    Side = "Left",
    Name = "Auto Farm",
    IconName = "boxes",
})

local RightGroupBox = Tabs.Main:AddGroupbox({
    Side = "Right",
    Name = "Thông tin",
    IconName = "info",
})

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
LeftGroupBox:AddToggle("AutoRebirth", {
    Text = "👼 Auto Rebirth",
    Tooltip = "Tự động rebirth khi Rebirth Ready",
    Default = false,
    Callback = function(Value)
        if Value then
            spawn(function()
                local isRebirthing = false
                local rebirthStartTime = 0
                while Toggles.AutoRebirth.Value do
                    pcall(function()
                        local rebirthReady = isRebirthReadyVisible()
                        if rebirthReady and not isRebirthing then
                            isRebirthing = true
                            rebirthStartTime = tick()
                            Library:Notify({
                                Title = "🔄 Rebirth Ready!",
                                Description = "Đang gửi Rebirth...",
                                Time = 3,
                            })
                        end
                        if isRebirthing then
                            if tick() - rebirthStartTime < 10 then
                                pcall(function() RS.Remotes.Rebirth:InvokeServer() end)
                                wait(randDelay(2, 4))
                            else
                                isRebirthing = false
                                Library:Notify({
                                    Title = "✅ Hoàn thành Rebirth!",
                                    Description = "Đã rebirth thành công",
                                    Time = 3,
                                })
                            end
                        end
                    end)
                    wait(randDelay(1, 2))
                end
            end)
        end
    end,
})

-- ================== AUTO FEEDER ==================
LeftGroupBox:AddToggle("AutoFeeder", {
    Text = "🌾 Auto Feeder",
    Tooltip = "Tự động mua và nâng cấp Generator 1",
    Default = false,
    Callback = function(Value)
        if Value then
            spawn(function()
                while Toggles.AutoFeeder.Value do
                    pcall(function()
                        local currentTower = getCurrentTower()
                        local currentMoney = getMoney()
                        if currentTower == 0 then
                            if currentMoney >= 360 then
                                pcall(function() RS.Remotes.BuyGenerator:InvokeServer(1) end)
                                Library:Notify({
                                    Title = "✅ Mua Generator 1!",
                                    Description = "Đã mua thành công",
                                    Time = 3,
                                })
                            end
                        else
                            pcall(function() RS.Remotes.UpgradeGenerator:InvokeServer(1) end)
                        end
                    end)
                    wait(randDelay(3, 5))
                end
            end)
        end
    end,
})

-- ================== AUTO TOWER ==================
LeftGroupBox:AddToggle("AutoTower", {
    Text = "🗼 Auto Tower",
    Tooltip = "Tự động leo tháp",
    Default = false,
    Callback = function(Value)
        if Value then
            spawn(function()
                local towerCooldown = randDelay(27.3, 29.5)
                local wasRebirthVisible = false
                
                while Toggles.AutoTower.Value do
                    -- Gửi TowerStart/Elevator
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
                    
                    -- Kiểm tra Rebirth Ready để surrender
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
                        Library:Notify({
                            Title = "🏳️ Đã đầu hàng tháp!",
                            Description = "Rebirth Ready đã xuất hiện",
                            Time = 3,
                        })
                        wait(10)
                    elseif not isVisibleNow then
                        wasRebirthVisible = false
                    end
                    
                    wait(0.1)
                end
            end)
        end
    end,
})

-- ================== COLLECT EGG ==================
LeftGroupBox:AddToggle("CollectEgg", {
    Text = "🥚 Collect Egg",
    Tooltip = "Tự động thu trứng",
    Default = false,
    Callback = function(Value)
        if Value then
            spawn(function()
                local incubatorTimer = 0
                while Toggles.CollectEgg.Value do
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
    end,
})

-- ================== LABEL TOWER INFO ==================
local towerInfoLabel = RightGroupBox:AddLabel("🕒 TowerCD: N/A\n💬 Text: —\n🗼 CurrentTower: N/A", true, "TowerInfo")

spawn(function()
    while true do
        local towerCooldownText = "N/A"
        -- Lấy giá trị từ Toggles nếu cần
        
        local textStatus = "—"
        local notice = Player:WaitForChild("PlayerGui"):FindFirstChild("RebirthNotice")
        if notice then
            for _, gui in ipairs(notice:GetDescendants()) do
                if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                    if gui.Text and gui.Text:upper():find("REBIRTH READY!") then
                        if isGuiActuallyVisible(gui) then
                            textStatus = "✔"
                        else
                            textStatus = "✖"
                        end
                        break
                    end
                end
            end
        end
        
        local currentTower = getCurrentTower()
        Options.TowerInfo:SetText("🕒 TowerCD: N/A\n💬 Text: " .. textStatus .. "\n🗼 CurrentTower: " .. currentTower)
        wait(0.5)
    end
end)

-- ================== STATS TAB ==================
local StatsGroup = Tabs.Stats:AddGroupbox({
    Side = "Left",
    Name = "Player Stats",
    IconName = "info",
})

local statsLabel = StatsGroup:AddLabel("📊 Đang tải stats...", true, "StatsLabel")

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
            
            Options.StatsLabel:SetText(text)
        end
        wait(1)
    end
end)

-- ================== THÔNG BÁO LOAD ==================
Library:Notify({
    Title = "✅ DucNhat HUB 2.2.0",
    Description = "Đã load thành công!",
    Time = 5,
})
