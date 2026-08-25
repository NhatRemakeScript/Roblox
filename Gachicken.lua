local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Rayfield/refs/heads/main/source'))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local Settings = {
    AutoRebirth = false,
    AutoFeeder = false,
    CollectEgg = false,
    AutoTower = false,
}

local Status = {
    IsRebirthing = false,
    RebirthStartTime = 0,
    TowerCooldown = 0,
    IncubatorTimer = 0,
}

local function RandDelay(min, max)
    return math.random() * (max - min) + min
end

local function GetLeaderstats()
    return Player:FindFirstChild("leaderstats")
end

local function GetMoney()
    local ls = GetLeaderstats()
    if ls then
        local money = ls:FindFirstChild("Money") or ls:FindFirstChild("Cash")
        if money then return tonumber(money.Value) or 0 end
    end
    return 0
end

local function GetCurrentTower()
    local ls = GetLeaderstats()
    if ls then
        local tower = ls:FindFirstChild("Tower")
        if tower then return tonumber(tower.Value) or 0 end
    end
    return 0
end

local function GetCornPerSecond()
    local ls = GetLeaderstats()
    if ls then
        local corn = ls:FindFirstChild("Corn/s") or ls:FindFirstChild("Corn Farm")
        if corn then return tonumber(corn.Value) or 0 end
    end
    return 0
end

local function GetLevel()
    local ls = GetLeaderstats()
    if ls then
        local level = ls:FindFirstChild("Level")
        if level then return tonumber(level.Value) or 0 end
    end
    return 0
end

local function IsGuiVisible(gui)
    if not gui or not gui:IsA("GuiObject") then return false end
    local current = gui
    while current do
        if current:IsA("GuiObject") and not current.Visible then return false end
        current = current.Parent
    end
    if gui.AbsoluteSize.X <= 0 or gui.AbsoluteSize.Y <= 0 then return false end
    return true
end

local function IsRebirthReady()
    local notice = Player:WaitForChild("PlayerGui"):FindFirstChild("RebirthNotice")
    if not notice then return false end
    for _, gui in ipairs(notice:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            if gui.Text and gui.Text:upper():find("REBIRTH READY!") and IsGuiVisible(gui) then
                return true
            end
        end
    end
    return false
end

local function MoveToPosition(targetPos)
    local char = Player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return false end
    
    local distance = (root.Position - targetPos).Magnitude
    if distance < 3 then return true end
    
    humanoid:MoveTo(targetPos)
    local startTime = tick()
    while tick() - startTime < 10 do
        local newDist = (root.Position - targetPos).Magnitude
        if newDist < 5 then return true end
        if humanoid.MoveDirection.Magnitude < 0.5 and newDist > 10 then break end
        RunService.Heartbeat:Wait()
    end
    return false
end

spawn(function()
    while true do
        task.wait(60)
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end)

local function Notify(title, content, duration)
    if Rayfield and Rayfield.Notify then
        Rayfield:Notify({
            Title = title or "Auto Farm",
            Content = content or "",
            Duration = duration or 3.5
        })
    end
end

local MainWindow = Rayfield:CreateWindow({
    Name = "DucNhat 2.0.5",
    LoadingTitle = "Auto Farm Hub",
    LoadingSubtitle = "by DucNhat",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "DucNhat_AutoFarm"
    }
})

local MainTab = MainWindow:CreateTab("Main")

MainTab:CreateButton({
    Name = "Auto Rebirth",
    Callback = function()
        Settings.AutoRebirth = not Settings.AutoRebirth
        if Settings.AutoRebirth then
            Notify("Auto Rebirth", "Da bat Auto Rebirth")
            spawn(function()
                while Settings.AutoRebirth do
                    task.wait(RandDelay(0.5, 1.5))
                    pcall(function()
                        if IsRebirthReady() and not Status.IsRebirthing then
                            Status.IsRebirthing = true
                            Status.RebirthStartTime = tick()
                            Notify("Auto Rebirth", "Rebirth Ready! Dang thuc hien...")
                        end
                        
                        if Status.IsRebirthing then
                            if tick() - Status.RebirthStartTime < 8 then
                                pcall(function()
                                    if RS and RS.Remotes and RS.Remotes.Rebirth then
                                        RS.Remotes.Rebirth:InvokeServer()
                                    end
                                end)
                                task.wait(RandDelay(1, 2))
                            else
                                Status.IsRebirthing = false
                                Notify("Auto Rebirth", "Hoan thanh Rebirth!")
                            end
                        end
                    end)
                end
                Status.IsRebirthing = false
            end)
        else
            Notify("Auto Rebirth", "Da tat Auto Rebirth")
            Status.IsRebirthing = false
        end
    end
})

MainTab:CreateButton({
    Name = "Auto Feeder",
    Callback = function()
        Settings.AutoFeeder = not Settings.AutoFeeder
        if Settings.AutoFeeder then
            Notify("Auto Feeder", "Da bat Auto Feeder")
            spawn(function()
                while Settings.AutoFeeder do
                    task.wait(RandDelay(2, 4))
                    pcall(function()
                        local currentMoney = GetMoney()
                        local currentTower = GetCurrentTower()
                        
                        if currentTower == 0 then
                            if currentMoney >= 360 then
                                pcall(function()
                                    if RS and RS.Remotes and RS.Remotes.BuyGenerator then
                                        RS.Remotes.BuyGenerator:InvokeServer(1)
                                        Notify("Auto Feeder", "Da mua Generator 1!")
                                    end
                                end)
                            end
                        else
                            pcall(function()
                                if RS and RS.Remotes and RS.Remotes.UpgradeGenerator then
                                    RS.Remotes.UpgradeGenerator:InvokeServer(1)
                                end
                            end)
                        end
                    end)
                end
            end)
        else
            Notify("Auto Feeder", "Da tat Auto Feeder")
        end
    end
})

MainTab:CreateButton({
    Name = "Collect Egg",
    Callback = function()
        Settings.CollectEgg = not Settings.CollectEgg
        if Settings.CollectEgg then
            Notify("Collect Egg", "Da bat Collect Egg")
            spawn(function()
                while Settings.CollectEgg do
                    task.wait(1.5)
                    pcall(function()
                        Status.IncubatorTimer = Status.IncubatorTimer + 1
                        if Status.IncubatorTimer >= 30 then
                            pcall(function()
                                if RS and RS.Remotes and RS.Remotes.IncubatorClaim then
                                    RS.Remotes.IncubatorClaim:InvokeServer()
                                    Status.IncubatorTimer = 0
                                end
                            end)
                        end
                        
                        local char = Player.Character
                        if not char then return end
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        
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
                                if (root.Position - targetPos).Magnitude > 5 then
                                    MoveToPosition(targetPos)
                                end
                            end
                        end
                    end)
                end
            end)
        else
            Notify("Collect Egg", "Da tat Collect Egg")
        end
    end
})

MainTab:CreateButton({
    Name = "Auto Tower",
    Callback = function()
        Settings.AutoTower = not Settings.AutoTower
        if Settings.AutoTower then
            Status.TowerCooldown = RandDelay(27.3, 29.5)
            Notify("Auto Tower", "Da bat Auto Tower")
            spawn(function()
                while Settings.AutoTower do
                    task.wait(0.1)
                    if Status.TowerCooldown <= 0 then
                        pcall(function()
                            local currentTower = GetCurrentTower()
                            if RS and RS.Remotes then
                                if currentTower > 0 and RS.Remotes.TowerElevator then
                                    RS.Remotes.TowerElevator:InvokeServer(currentTower + 1)
                                    task.wait(RandDelay(1, 2))
                                end
                                if RS.Remotes.TowerStart then
                                    RS.Remotes.TowerStart:InvokeServer()
                                end
                            end
                            Status.TowerCooldown = RandDelay(27.3, 29.5)
                        end)
                    else
                        Status.TowerCooldown = Status.TowerCooldown - 0.1
                    end
                end
            end)
        else
            Status.TowerCooldown = 0
            Notify("Auto Tower", "Da tat Auto Tower")
        end
    end
})

local StatsTab = MainWindow:CreateTab("Stats")

local MoneyLabel = StatsTab:CreateLabel("Money: 0")
local CornLabel = StatsTab:CreateLabel("Corn/s: 0")
local TowerLabel = StatsTab:CreateLabel("Tower: 0")
local LevelLabel = StatsTab:CreateLabel("Level: 0")
local StatusLabel = StatsTab:CreateLabel("Status: Idle")

local SettingsTab = MainWindow:CreateTab("Settings")

SettingsTab:CreateDropdown({
    Name = "Theme",
    Options = {"Default", "Light"},
    CurrentOption = "Default",
    Flag = "Theme",
    Callback = function(Option)
        Rayfield:ChangeTheme(Option)
        Notify("Theme", "Da chuyen sang theme: " .. Option)
    end
})

SettingsTab:CreateButton({
    Name = "Reset All Settings",
    Callback = function()
        Settings.AutoRebirth = false
        Settings.AutoFeeder = false
        Settings.CollectEgg = false
        Settings.AutoTower = false
        Status.TowerCooldown = 0
        Status.IncubatorTimer = 0
        Status.IsRebirthing = false
        Notify("Reset", "Da reset tat ca cai dat!")
    end
})

spawn(function()
    local statusText = "Idle"
    while true do
        task.wait(1)
        pcall(function()
            local money = GetMoney()
            local corn = GetCornPerSecond()
            local tower = GetCurrentTower()
            local level = GetLevel()
            
            MoneyLabel:Set("Money: " .. tostring(money))
            CornLabel:Set("Corn/s: " .. tostring(corn))
            TowerLabel:Set("Tower: " .. tostring(tower))
            LevelLabel:Set("Level: " .. tostring(level))
            
            local statuses = {}
            if Settings.AutoRebirth then table.insert(statuses, "Rebirth") end
            if Settings.AutoFeeder then table.insert(statuses, "Feeder") end
            if Settings.CollectEgg then table.insert(statuses, "Egg") end
            if Settings.AutoTower then table.insert(statuses, "Tower") end
            
            if #statuses > 0 then
                statusText = table.concat(statuses, " | ")
            else
                statusText = "Idle"
            end
            StatusLabel:Set("Status: " .. statusText)
        end)
    end
end)

local InfoTab = MainWindow:CreateTab("Info")

InfoTab:CreateParagraph({
    Title = "Huong dan su dung",
    Content = "1. Bat/Tat cac tinh nang o tab Main\n2. Xem thong tin o tab Stats\n3. Tuy chinh giao dien o tab Settings"
})

InfoTab:CreateParagraph({
    Title = "Tinh nang",
    Content = "Auto Rebirth: Tu dong rebirth khi du dieu kien\nAuto Feeder: Tu dong mua va nang cap generator\nCollect Egg: Tu dong thu thap trung\nAuto Tower: Tu dong choi tower"
})

print("DucNhat 2.0.5 - Auto Farm Hub loaded!")
Notify("Auto Farm", "Auto Farm Hub da san sang!", 3)
