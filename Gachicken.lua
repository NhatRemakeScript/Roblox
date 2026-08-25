-- ============================================
-- RAYFIELD CUSTOM - Auto Farm Hub
-- Version: 2.0
-- ============================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")

-- ============================================
-- GUI SETUP
-- ============================================
local SG = Instance.new("ScreenGui")
SG.Name = "RayfieldHub"
SG.Parent = Player:WaitForChild("PlayerGui")
SG.ResetOnSpawn = false

local function CreateCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local function CreateStroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Parent = obj
end

-- ============================================
-- THEME
-- ============================================
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Topbar = Color3.fromRGB(30, 30, 38),
    Element = Color3.fromRGB(35, 35, 42),
    ElementHover = Color3.fromRGB(45, 45, 55),
    Accent = Color3.fromRGB(0, 200, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(200, 200, 200),
    Stroke = Color3.fromRGB(50, 50, 60),
}

-- ============================================
-- VARIABLES
-- ============================================
local reb = false
local feeder = false
local ne = false
local autoTower = false
local towerCooldown = 0
local incubatorTimer = 0
local isOpen = true
local isMinimized = false
local rainbowHue = 0

-- ============================================
-- HELPERS
-- ============================================
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
    local startTime = tick()
    while tick() - startTime < 15 do
        local newDist = (root.Position - targetPos).Magnitude
        if newDist < 5 then return true end
        if humanoid.MoveDirection.Magnitude < 0.5 and newDist > 10 then break end
        wait(0.5)
    end
    return false
end

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Size = UDim2.new(0, 280, 0, 45)
NotificationFrame.Position = UDim2.new(1, -300, 0, -60)
NotificationFrame.BackgroundColor3 = Theme.Background
NotificationFrame.BackgroundTransparency = 0.1
NotificationFrame.Visible = false
NotificationFrame.Parent = SG
CreateCorner(NotificationFrame, 10)
CreateStroke(NotificationFrame, Theme.Accent, 2)

local NotificationText = Instance.new("TextLabel")
NotificationText.Size = UDim2.new(1, -20, 1, 0)
NotificationText.Position = UDim2.new(0, 10, 0, 0)
NotificationText.BackgroundTransparency = 1
NotificationText.Text = ""
NotificationText.TextColor3 = Theme.Text
NotificationText.TextSize = 14
NotificationText.Font = Enum.Font.GothamMedium
NotificationText.TextXAlignment = Enum.TextXAlignment.Left
NotificationText.TextYAlignment = Enum.TextYAlignment.Center
NotificationText.Parent = NotificationFrame

local notifQueue = {}
local isShowingNotif = false

local function ShowNotification(text, duration)
    table.insert(notifQueue, {text = text, duration = duration or 3})
    if not isShowingNotif then
        isShowingNotif = true
        spawn(function()
            while #notifQueue > 0 do
                local notif = table.remove(notifQueue, 1)
                NotificationFrame.Visible = true
                NotificationText.Text = notif.text
                NotificationFrame.Position = UDim2.new(1, -300, 0, -60)
                local tween = TS:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(1, -300, 0, 15)
                })
                tween:Play()
                tween.Completed:Wait()
                wait(notif.duration)
                local tween2 = TS:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(1, -300, 0, -60)
                })
                tween2:Play()
                tween2.Completed:Wait()
                NotificationFrame.Visible = false
                wait(0.2)
            end
            isShowingNotif = false
        end)
    end
end

-- ============================================
-- MAIN WINDOW
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Visible = true
MainFrame.Parent = SG
CreateCorner(MainFrame, 12)
local MainStroke = CreateStroke(MainFrame, Theme.Accent, 2)

-- Rainbow border
spawn(function()
    while true do
        rainbowHue = (rainbowHue + 0.005) % 1
        MainStroke.Color = Color3.fromHSV(rainbowHue, 1, 1)
        wait(0.01)
    end
end)

-- ============================================
-- TOPBAR
-- ============================================
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 38)
Topbar.BackgroundColor3 = Theme.Topbar
Topbar.Parent = MainFrame
CreateCorner(Topbar, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ DucNhat 2.0.5"
Title.TextColor3 = Theme.Text
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.Parent = Topbar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -38, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinBtn.Text = "−"
MinBtn.TextColor3 = Theme.Text
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Topbar
CreateCorner(MinBtn, 28)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -8, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Topbar
CreateCorner(CloseBtn, 28)

-- ============================================
-- TAB SYSTEM
-- ============================================
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 32)
TabContainer.Position = UDim2.new(0, 0, 0, 38)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local Tabs = {}
local CurrentTab = ""

local function CreateTabButton(name, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 28)
    btn.Position = UDim2.new(0, #Tabs * 85 + 10, 0.5, -14)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btn.Text = name
    btn.TextColor3 = Theme.TextDim
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = parent
    CreateCorner(btn, 6)
    return btn
end

-- ============================================
-- CONTENT AREA
-- ============================================
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -10, 1, -80)
ContentArea.Position = UDim2.new(0, 5, 0, 75)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 4
ContentArea.ScrollBarImageColor3 = Theme.Accent
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.FillDirection = Enum.FillDirection.Vertical
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentArea

-- ============================================
-- TAB CONTENT
-- ============================================
local TabContents = {}

local function CreateTab(name)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Visible = (#Tabs == 0)
    container.Parent = ContentArea
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container
    
    Tabs[name] = container
    TabContents[name] = container
    
    local btn = CreateTabButton(name, TabContainer)
    btn.MouseButton1Click:Connect(function()
        for tabName, tabContainer in pairs(TabContents) do
            tabContainer.Visible = (tabName == name)
        end
        for _, b in ipairs(TabContainer:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = (b == btn) and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 48)
                b.TextColor3 = (b == btn) and Theme.Text or Theme.TextDim
            end
        end
        CurrentTab = name
        ContentArea.CanvasPosition = Vector2.new(0, 0)
        task.wait(0.05)
        UpdateCanvas()
    end)
    
    if #Tabs == 1 then
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.TextColor3 = Theme.Text
        CurrentTab = name
    end
    
    return container
end

local function UpdateCanvas()
    local h = 0
    for _, child in ipairs(ContentArea:GetChildren()) do
        if child:IsA("Frame") and child.Visible then
            h = h + child.AbsoluteSize.Y + 8
        end
    end
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, math.max(h, 0))
end

ContentArea.ChildAdded:Connect(function()
    task.wait(0.05)
    UpdateCanvas()
end)

-- ============================================
-- UI ELEMENTS
-- ============================================
local function CreateToggle(parent, text, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Theme.Element
    frame.Parent = parent
    CreateCorner(frame, 8)
    CreateStroke(frame, Theme.Stroke, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -75, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = frame
    
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 48, 0, 26)
    switch.Position = UDim2.new(1, -60, 0.5, -13)
    switch.BackgroundColor3 = defaultValue and Theme.Accent or Color3.fromRGB(60, 60, 70)
    switch.Parent = frame
    CreateCorner(switch, 26)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = defaultValue and UDim2.new(0, 25, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switch
    CreateCorner(knob, 20)
    
    local state = defaultValue or false
    
    local function SetState(newState)
        state = newState
        local targetPos = state and UDim2.new(0, 25, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        local targetCol = state and Theme.Accent or Color3.fromRGB(60, 60, 70)
        TS:Create(switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetCol}):Play()
        TS:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
        if callback then callback(state) end
    end
    
    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = frame
    click.MouseButton1Click:Connect(function()
        SetState(not state)
    end)
    
    return SetState
end

local function CreateLabel(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = Theme.Element
    frame.Parent = parent
    CreateCorner(frame, 8)
    CreateStroke(frame, Theme.Stroke, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = frame
    
    return label
end

local function CreateButton(parent, text, callback)
    local frame = Instance.new("TextButton")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Theme.Element
    frame.Text = text
    frame.TextColor3 = Theme.Text
    frame.TextSize = 14
    frame.Font = Enum.Font.GothamMedium
    frame.Parent = parent
    CreateCorner(frame, 8)
    CreateStroke(frame, Theme.Stroke, 1)
    
    frame.MouseEnter:Connect(function()
        TS:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Theme.ElementHover}):Play()
    end)
    frame.MouseLeave:Connect(function()
        TS:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Theme.Element}):Play()
    end)
    
    frame.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return frame
end

-- ============================================
-- ANTI-AFK
-- ============================================
spawn(function()
    while wait(60) do
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end)

-- ============================================
-- CREATE TABS
-- ============================================

-- MAIN TAB
local MainTab = CreateTab("Main")

-- Auto Rebirth
local rebirthState = false
CreateToggle(MainTab, "👼 Auto Rebirth", false, function(s)
    reb = s
    rebirthState = s
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
                        ShowNotification("🔄 Rebirth Ready!")
                    end
                    if isRebirthing then
                        if tick() - rebirthStartTime < 10 then
                            pcall(function() RS.Remotes.Rebirth:InvokeServer() end)
                            wait(randDelay(2, 4))
                        else
                            isRebirthing = false
                            ShowNotification("✅ Hoàn thành Rebirth!")
                        end
                    end
                end)
                wait(randDelay(1, 2))
            end
        end)
    end
end)

-- Auto Feeder
CreateToggle(MainTab, "🌾 Auto Feeder", false, function(s)
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
                            ShowNotification("✅ Mua Generator 1!")
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

-- Collect Egg
CreateToggle(MainTab, "🥚 Collect Egg", false, function(s)
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
                                moveToPosition(targetPos)
                            end
                        end
                    end
                end)
                wait(2)
            end
        end)
    end
end)

-- Auto Tower
CreateToggle(MainTab, "🗼 Auto Tower", false, function(s)
    autoTower = s
    if s then
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
end)

-- STATS TAB
local StatsTab = CreateTab("Stats")

local moneyLabel = CreateLabel(StatsTab, "💰 Money: 0")
local cornLabel = CreateLabel(StatsTab, "🌽 Corn/s: 0")
local towerLabel = CreateLabel(StatsTab, "🗼 Tower: 0")
local levelLabel = CreateLabel(StatsTab, "⭐ Level: 0")

-- SETTINGS TAB
local SettingsTab = CreateTab("Settings")

CreateButton(SettingsTab, "🔵 Toggle Theme", function()
    if Theme.Background == Color3.fromRGB(20, 20, 25) then
        -- Light theme
        Theme.Background = Color3.fromRGB(240, 240, 245)
        Theme.Topbar = Color3.fromRGB(220, 220, 230)
        Theme.Element = Color3.fromRGB(230, 230, 240)
        Theme.ElementHover = Color3.fromRGB(240, 240, 250)
        Theme.Text = Color3.fromRGB(30, 30, 40)
        Theme.TextDim = Color3.fromRGB(80, 80, 90)
        Theme.Stroke = Color3.fromRGB(200, 200, 210)
    else
        -- Dark theme
        Theme.Background = Color3.fromRGB(20, 20, 25)
        Theme.Topbar = Color3.fromRGB(30, 30, 38)
        Theme.Element = Color3.fromRGB(35, 35, 42)
        Theme.ElementHover = Color3.fromRGB(45, 45, 55)
        Theme.Text = Color3.fromRGB(255, 255, 255)
        Theme.TextDim = Color3.fromRGB(200, 200, 200)
        Theme.Stroke = Color3.fromRGB(50, 50, 60)
    end
    
    -- Update UI
    MainFrame.BackgroundColor3 = Theme.Background
    Topbar.BackgroundColor3 = Theme.Topbar
    Title.TextColor3 = Theme.Text
    
    for _, child in ipairs(MainFrame:GetDescendants()) do
        if child:IsA("TextLabel") then
            if child ~= Title then
                child.TextColor3 = Theme.Text
            end
        end
        if child:IsA("Frame") and child.BackgroundColor3 ~= Color3.fromRGB(255, 255, 255) then
            if child.BackgroundColor3 ~= Color3.fromRGB(60, 60, 70) then
                -- Skip some frames
            end
        end
    end
end)

CreateButton(SettingsTab, "🔄 Reset All Settings", function()
    reb = false
    feeder = false
    ne = false
    autoTower = false
    towerCooldown = 0
    incubatorTimer = 0
    ShowNotification("✅ Đã reset tất cả cài đặt!")
end)

-- ============================================
-- UPDATE STATS
-- ============================================
spawn(function()
    while true do
        pcall(function()
            local money = getMoney()
            local corn = getCornPerSecond()
            local tower = getCurrentTower()
            local level = getLevel()
            
            moneyLabel.Text = "💰 Money: " .. tostring(money)
            cornLabel.Text = "🌽 Corn/s: " .. tostring(corn)
            towerLabel.Text = "🗼 Tower: " .. tostring(tower)
            levelLabel.Text = "⭐ Level: " .. tostring(level)
        end)
        wait(1)
    end
end)

-- ============================================
-- DRAG FUNCTIONALITY
-- ============================================
local dragData = {active = false, offset = Vector2.new(0, 0)}

Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.active = true
        dragData.offset = Vector2.new(input.Position.X - MainFrame.AbsolutePosition.X, 
                                       input.Position.Y - MainFrame.AbsolutePosition.Y)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragData.active and input.UserInputType == Enum.UserInputType.MouseMovement then
        local newX = math.clamp(input.Position.X - dragData.offset.X, 0, SG.AbsoluteSize.X - MainFrame.AbsoluteSize.X)
        local newY = math.clamp(input.Position.Y - dragData.offset.Y, 0, SG.AbsoluteSize.Y - MainFrame.AbsoluteSize.Y)
        MainFrame.Position = UDim2.new(0, newX, 0, newY)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.active = false
    end
end)

-- ============================================
-- MINIMIZE / CLOSE
-- ============================================
local isMinimized = false

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentArea.Visible = false
        TabContainer.Visible = false
        MainFrame.Size = UDim2.new(0, 400, 0, 38)
        MinBtn.Text = "+"
    else
        ContentArea.Visible = true
        TabContainer.Visible = true
        MainFrame.Size = UDim2.new(0, 400, 0, 350)
        MinBtn.Text = "−"
        task.wait(0.05)
        UpdateCanvas()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ShowNotification("👋 Đã đóng menu, click bubble để mở lại")
end)

-- ============================================
-- BUBBLE ICON
-- ============================================
local Bubble = Instance.new("TextButton")
Bubble.Size = UDim2.new(0, 50, 0, 50)
Bubble.Position = UDim2.new(0, 15, 0.5, -25)
Bubble.BackgroundColor3 = Theme.Background
Bubble.Text = "⚡"
Bubble.TextColor3 = Theme.Accent
Bubble.TextSize = 26
Bubble.Font = Enum.Font.GothamBold
Bubble.Parent = SG
CreateCorner(Bubble, 50)
CreateStroke(Bubble, Theme.Accent, 2)

local isOpen = true
Bubble.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    MainFrame.Visible = isOpen
    if isOpen then
        ShowNotification("📂 Đã mở menu!")
    end
end)

-- Drag bubble
local bubbleDrag = {active = false, offset = Vector2.new(0, 0)}

Bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        bubbleDrag.active = true
        bubbleDrag.offset = Vector2.new(input.Position.X - Bubble.AbsolutePosition.X, 
                                        input.Position.Y - Bubble.AbsolutePosition.Y)
    end
end)

UIS.InputChanged:Connect(function(input)
    if bubbleDrag.active and input.UserInputType == Enum.UserInputType.MouseMovement then
        local newX = math.clamp(input.Position.X - bubbleDrag.offset.X, 0, SG.AbsoluteSize.X - Bubble.AbsoluteSize.X)
        local newY = math.clamp(input.Position.Y - bubbleDrag.offset.Y, 0, SG.AbsoluteSize.Y - Bubble.AbsoluteSize.Y)
        Bubble.Position = UDim2.new(0, newX, 0, newY)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        bubbleDrag.active = false
    end
end)

-- ============================================
-- INIT
-- ============================================
UpdateCanvas()
ShowNotification("✅ Auto Farm Hub đã sẵn sàng!", 2)
print("⚡ DucNhat 2.0.5 - Auto Farm Hub loaded!")
