-- ============================================
-- RAYFIELD CUSTOM - Auto Farm Hub Pro
-- Version: 3.0
-- ============================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

-- ============================================
-- GUI SETUP
-- ============================================
local SG = Instance.new("ScreenGui")
SG.Name = "RayfieldHub"
SG.Parent = Player:WaitForChild("PlayerGui")
SG.ResetOnSpawn = false

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function CreateCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local function CreateStroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1.5
    s.Parent = obj
    return s
end

local function CreateShadow(obj, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, size or 10, 1, size or 10)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316048114"
    shadow.ImageTransparency = transparency or 0.6
    shadow.ZIndex = 0
    shadow.Parent = obj
    return shadow
end

-- ============================================
-- THEME SYSTEM
-- ============================================
local Themes = {
    Default = {
        Background = Color3.fromRGB(20, 20, 25),
        Topbar = Color3.fromRGB(30, 30, 38),
        Element = Color3.fromRGB(35, 35, 42),
        ElementHover = Color3.fromRGB(45, 45, 55),
        ElementActive = Color3.fromRGB(55, 55, 65),
        Accent = Color3.fromRGB(0, 200, 255),
        AccentHover = Color3.fromRGB(50, 220, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 190),
        TextDark = Color3.fromRGB(80, 80, 90),
        Stroke = Color3.fromRGB(50, 50, 60),
        ToggleOn = Color3.fromRGB(0, 200, 255),
        ToggleOff = Color3.fromRGB(60, 60, 70),
        ToggleKnob = Color3.fromRGB(255, 255, 255),
        TabActive = Color3.fromRGB(60, 60, 80),
        TabInactive = Color3.fromRGB(40, 40, 48),
        TabTextActive = Color3.fromRGB(255, 255, 255),
        TabTextInactive = Color3.fromRGB(180, 180, 190),
        Notification = Color3.fromRGB(30, 30, 38),
        NotificationAccent = Color3.fromRGB(0, 200, 255),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Topbar = Color3.fromRGB(220, 220, 230),
        Element = Color3.fromRGB(230, 230, 240),
        ElementHover = Color3.fromRGB(240, 240, 250),
        ElementActive = Color3.fromRGB(210, 210, 220),
        Accent = Color3.fromRGB(0, 150, 255),
        AccentHover = Color3.fromRGB(50, 170, 255),
        Text = Color3.fromRGB(30, 30, 40),
        TextDim = Color3.fromRGB(100, 100, 110),
        TextDark = Color3.fromRGB(150, 150, 160),
        Stroke = Color3.fromRGB(200, 200, 210),
        ToggleOn = Color3.fromRGB(0, 150, 255),
        ToggleOff = Color3.fromRGB(180, 180, 190),
        ToggleKnob = Color3.fromRGB(255, 255, 255),
        TabActive = Color3.fromRGB(0, 150, 255),
        TabInactive = Color3.fromRGB(200, 200, 210),
        TabTextActive = Color3.fromRGB(255, 255, 255),
        TabTextInactive = Color3.fromRGB(80, 80, 90),
        Notification = Color3.fromRGB(240, 240, 245),
        NotificationAccent = Color3.fromRGB(0, 150, 255),
    }
}

local CurrentTheme = "Default"
local Theme = Themes.Default

-- ============================================
-- VARIABLES
-- ============================================
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
    IsMinimized = false,
    IsOpen = true,
}

local Tabs = {}
local TabButtons = {}
local TabContents = {}
local CurrentTab = ""

local ToggleElements = {}
local LabelElements = {}

-- ============================================
-- HELPERS
-- ============================================
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

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================
local NotificationFrame
local NotificationText
local NotifQueue = {}
local IsShowingNotif = false

local function CreateNotificationSystem()
    NotificationFrame = Instance.new("Frame")
    NotificationFrame.Size = UDim2.new(0, 300, 0, 50)
    NotificationFrame.Position = UDim2.new(1, -320, 0, -70)
    NotificationFrame.BackgroundColor3 = Theme.Notification
    NotificationFrame.BackgroundTransparency = 0.1
    NotificationFrame.Visible = false
    NotificationFrame.ZIndex = 100
    NotificationFrame.Parent = SG
    CreateCorner(NotificationFrame, 12)
    local stroke = CreateStroke(NotificationFrame, Theme.NotificationAccent, 2)
    stroke.Transparency = 0.5
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 1, 0)
    icon.Position = UDim2.new(0, 5, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "⚡"
    icon.TextColor3 = Theme.NotificationAccent
    icon.TextSize = 18
    icon.Font = Enum.Font.GothamBold
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.TextYAlignment = Enum.TextYAlignment.Center
    icon.Parent = NotificationFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 50, 0, 18)
    title.Position = UDim2.new(0, 40, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "Auto Farm"
    title.TextColor3 = Theme.NotificationAccent
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Top
    title.Parent = NotificationFrame
    
    NotificationText = Instance.new("TextLabel")
    NotificationText.Size = UDim2.new(1, -45, 1, -22)
    NotificationText.Position = UDim2.new(0, 40, 0, 20)
    NotificationText.BackgroundTransparency = 1
    NotificationText.Text = ""
    NotificationText.TextColor3 = Theme.Text
    NotificationText.TextSize = 13
    NotificationText.Font = Enum.Font.GothamMedium
    NotificationText.TextXAlignment = Enum.TextXAlignment.Left
    NotificationText.TextYAlignment = Enum.TextYAlignment.Top
    NotificationText.TextWrapped = true
    NotificationText.Parent = NotificationFrame
end

local function ShowNotification(title, content, duration)
    if not NotificationFrame then CreateNotificationSystem() end
    
    table.insert(NotifQueue, {
        title = title or "Auto Farm",
        content = content or "",
        duration = duration or 3
    })
    
    if not IsShowingNotif then
        IsShowingNotif = true
        spawn(function()
            while #NotifQueue > 0 do
                local notif = table.remove(NotifQueue, 1)
                NotificationFrame.Visible = true
                NotificationFrame.BackgroundTransparency = 0.2
                NotificationText.Text = notif.content
                NotificationFrame.Position = UDim2.new(1, -320, 0, -70)
                
                local tween = TS:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(1, -320, 0, 15)
                })
                tween:Play()
                tween.Completed:Wait()
                
                task.wait(notif.duration)
                
                local tween2 = TS:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(1, -320, 0, -70)
                })
                tween2:Play()
                tween2.Completed:Wait()
                
                NotificationFrame.Visible = false
                task.wait(0.2)
            end
            IsShowingNotif = false
        end)
    end
end

-- ============================================
-- MAIN WINDOW
-- ============================================
local MainFrame
local Topbar
local ContentArea
local TabContainer
local Title

local function CreateMainWindow()
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 420, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.Visible = true
    MainFrame.ZIndex = 10
    MainFrame.Parent = SG
    CreateCorner(MainFrame, 12)
    CreateStroke(MainFrame, Theme.Accent, 1.5)
    CreateShadow(MainFrame, 20, 0.5)
    
    -- Topbar
    Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.Parent = MainFrame
    CreateCorner(Topbar, 12)
    
    -- Title
    Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -90, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡ DucNhat 2.0.5"
    Title.TextColor3 = Theme.Text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.Parent = Topbar
    
    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(1, -68, 0.5, -14)
    MinBtn.BackgroundColor3 = Theme.Element
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Theme.Text
    MinBtn.TextSize = 18
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Parent = Topbar
    CreateCorner(MinBtn, 28)
    CreateStroke(MinBtn, Theme.Stroke, 1)
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -14)
    CloseBtn.BackgroundColor3 = Theme.Element
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Topbar
    CreateCorner(CloseBtn, 28)
    CreateStroke(CloseBtn, Theme.Stroke, 1)
    
    -- Tab Container
    TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 0, 35)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    
    -- Content Area
    ContentArea = Instance.new("ScrollingFrame")
    ContentArea.Size = UDim2.new(1, -10, 1, -85)
    ContentArea.Position = UDim2.new(0, 5, 0, 75)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ScrollBarThickness = 4
    ContentArea.ScrollBarImageColor3 = Theme.Accent
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentArea.Parent = MainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = ContentArea
    
    -- Min/Max
    MinBtn.MouseButton1Click:Connect(function()
        Status.IsMinimized = not Status.IsMinimized
        if Status.IsMinimized then
            ContentArea.Visible = false
            TabContainer.Visible = false
            MainFrame.Size = UDim2.new(0, 420, 0, 40)
            MinBtn.Text = "+"
        else
            ContentArea.Visible = true
            TabContainer.Visible = true
            MainFrame.Size = UDim2.new(0, 420, 0, 380)
            MinBtn.Text = "−"
            task.wait(0.05)
            UpdateCanvas()
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Status.IsOpen = false
        MainFrame.Visible = false
        ShowNotification("📂", "Đã đóng menu, click bubble để mở lại", 2)
    end)
    
    -- Drag
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
end

-- ============================================
-- BUBBLE ICON
-- ============================================
local Bubble

local function CreateBubble()
    Bubble = Instance.new("TextButton")
    Bubble.Size = UDim2.new(0, 52, 0, 52)
    Bubble.Position = UDim2.new(0, 15, 0.5, -26)
    Bubble.BackgroundColor3 = Theme.Background
    Bubble.Text = "⚡"
    Bubble.TextColor3 = Theme.Accent
    Bubble.TextSize = 28
    Bubble.Font = Enum.Font.GothamBold
    Bubble.ZIndex = 20
    Bubble.Parent = SG
    CreateCorner(Bubble, 52)
    CreateStroke(Bubble, Theme.Accent, 2)
    CreateShadow(Bubble, 15, 0.4)
    
    -- Bubble glow
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1316048114"
    glow.ImageTransparency = 0.6
    glow.ImageColor3 = Theme.Accent
    glow.ZIndex = 0
    glow.Parent = Bubble
    
    Bubble.MouseButton1Click:Connect(function()
        Status.IsOpen = not Status.IsOpen
        MainFrame.Visible = Status.IsOpen
        if Status.IsOpen then
            ShowNotification("📂", "Đã mở menu!", 1.5)
        end
    end)
    
    -- Drag bubble
    local bdrag = {active = false, offset = Vector2.new(0, 0)}
    
    Bubble.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            bdrag.active = true
            bdrag.offset = Vector2.new(input.Position.X - Bubble.AbsolutePosition.X, 
                                        input.Position.Y - Bubble.AbsolutePosition.Y)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if bdrag.active and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newX = math.clamp(input.Position.X - bdrag.offset.X, 0, SG.AbsoluteSize.X - Bubble.AbsoluteSize.X)
            local newY = math.clamp(input.Position.Y - bdrag.offset.Y, 0, SG.AbsoluteSize.Y - Bubble.AbsoluteSize.Y)
            Bubble.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            bdrag.active = false
        end
    end)
end

-- ============================================
-- TAB SYSTEM
-- ============================================
local function UpdateCanvas()
    local h = 0
    for _, child in ipairs(ContentArea:GetChildren()) do
        if child:IsA("Frame") and child.Visible then
            h = h + child.AbsoluteSize.Y + 8
        end
    end
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, math.max(h, 0))
end

local function CreateTab(name, icon)
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
    
    -- Tab Button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 30)
    btn.Position = UDim2.new(0, #Tabs * 85 + 10, 0.5, -15)
    btn.BackgroundColor3 = (#Tabs == 0) and Theme.TabActive or Theme.TabInactive
    btn.Text = (icon or "") .. " " .. name
    btn.TextColor3 = (#Tabs == 0) and Theme.TabTextActive or Theme.TabTextInactive
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = TabContainer
    CreateCorner(btn, 6)
    CreateStroke(btn, Theme.Stroke, 1)
    
    btn.MouseButton1Click:Connect(function()
        for tabName, tabContainer in pairs(TabContents) do
            tabContainer.Visible = (tabName == name)
        end
        for _, b in ipairs(TabContainer:GetChildren()) do
            if b:IsA("TextButton") then
                if b == btn then
                    b.BackgroundColor3 = Theme.TabActive
                    b.TextColor3 = Theme.TabTextActive
                else
                    b.BackgroundColor3 = Theme.TabInactive
                    b.TextColor3 = Theme.TabTextInactive
                end
            end
        end
        CurrentTab = name
        ContentArea.CanvasPosition = Vector2.new(0, 0)
        task.wait(0.05)
        UpdateCanvas()
    end)
    
    if #Tabs == 1 then
        CurrentTab = name
    end
    
    ContentArea.ChildAdded:Connect(function()
        task.wait(0.05)
        UpdateCanvas()
    end)
    
    return container
end

-- ============================================
-- UI ELEMENTS
-- ============================================
local function CreateToggle(parent, text, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Theme.Element
    frame.Parent = parent
    CreateCorner(frame, 8)
    local stroke = CreateStroke(frame, Theme.Stroke, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = frame
    
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 50, 0, 28)
    switch.Position = UDim2.new(1, -62, 0.5, -14)
    switch.BackgroundColor3 = defaultValue and Theme.ToggleOn or Theme.ToggleOff
    switch.Parent = frame
    CreateCorner(switch, 28)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = defaultValue and UDim2.new(0, 26, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    knob.BackgroundColor3 = Theme.ToggleKnob
    knob.Parent = switch
    CreateCorner(knob, 22)
    
    local shadow = CreateShadow(knob, 8, 0.3)
    shadow.Size = UDim2.new(1, 8, 1, 8)
    
    local state = defaultValue or false
    
    local function SetState(newState)
        state = newState
        local targetPos = state and UDim2.new(0, 26, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        local targetCol = state and Theme.ToggleOn or Theme.ToggleOff
        
        TS:Create(switch, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            BackgroundColor3 = targetCol
        }):Play()
        
        TS:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Position = targetPos
        }):Play()
        
        if callback then 
            pcall(function() callback(state) end)
        end
    end
    
    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = frame
    click.MouseButton1Click:Connect(function()
        SetState(not state)
    end)
    
    -- Hover effect
    frame.MouseEnter:Connect(function()
        TS:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Theme.ElementHover
        }):Play()
    end)
    
    frame.MouseLeave:Connect(function()
        TS:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Theme.Element
        }):Play()
    end)
    
    return {
        SetState = SetState,
        GetState = function() return state end,
        Frame = frame
    }
end

local function CreateLabel(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Theme.Element
    frame.Parent = parent
    CreateCorner(frame, 8)
    CreateStroke(frame, Theme.Stroke, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = frame
    
    return {
        Set = function(newText)
            label.Text = newText
        end,
        Get = function()
            return label.Text
        end,
        Frame = frame
    }
end

local function CreateButton(parent, text, callback)
    local frame = Instance.new("TextButton")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Theme.Element
    frame.Text = text
    frame.TextColor3 = Theme.Text
    frame.TextSize = 14
    frame.Font = Enum.Font.GothamMedium
    frame.Parent = parent
    CreateCorner(frame, 8)
    local stroke = CreateStroke(frame, Theme.Stroke, 1)
    
    -- Icon arrow
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.Position = UDim2.new(1, -35, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "→"
    arrow.TextColor3 = Theme.TextDim
    arrow.TextSize = 16
    arrow.Font = Enum.Font.GothamMedium
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.TextYAlignment = Enum.TextYAlignment.Center
    arrow.Parent = frame
    
    frame.MouseEnter:Connect(function()
        TS:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Theme.ElementHover
        }):Play()
        TS:Create(arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, -40, 0, 0)
        }):Play()
    end)
    
    frame.MouseLeave:Connect(function()
        TS:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Theme.Element
        }):Play()
        TS:Create(arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, -35, 0, 0)
        }):Play()
    end)
    
    frame.MouseButton1Click:Connect(function()
        if callback then 
            pcall(function() callback() end)
        end
    end)
    
    return frame
end

local function CreateParagraph(parent, title, content)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.BackgroundColor3 = Theme.Element
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = parent
    CreateCorner(frame, 8)
    CreateStroke(frame, Theme.Stroke, 1)
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 12, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or ""
    titleLabel.TextColor3 = Theme.Accent
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = frame
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -20, 0, 0)
    contentLabel.Position = UDim2.new(0, 12, 0, 30)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content or ""
    contentLabel.TextColor3 = Theme.TextDim
    contentLabel.TextSize = 13
    contentLabel.Font = Enum.Font.GothamMedium
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.Parent = frame
    
    return frame
end

-- ============================================
-- ANTI-AFK
-- ============================================
spawn(function()
    while true do
        task.wait(60)
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end)

-- ============================================
-- AUTO FARM LOGIC
-- ============================================

-- Auto Rebirth
local function AutoRebirthLoop()
    while Settings.AutoRebirth do
        task.wait(RandDelay(0.5, 1.5))
        pcall(function()
            if IsRebirthReady() and not Status.IsRebirthing then
                Status.IsRebirthing = true
                Status.RebirthStartTime = tick()
                ShowNotification("🔄", "Rebirth Ready! Đang thực hiện...")
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
                    ShowNotification("✅", "Hoàn thành Rebirth!")
                end
            end
        end)
    end
    Status.IsRebirthing = false
end

-- Auto Feeder
local function AutoFeederLoop()
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
                            ShowNotification("✅", "Đã mua Generator 1!")
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
end

-- Collect Egg
local function CollectEggLoop()
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
end

-- Auto Tower
local function AutoTowerLoop()
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
end

-- Start loops
spawn(function()
    while true do
        if Settings.AutoRebirth then AutoRebirthLoop() end
        task.wait(0.5)
    end
end)

spawn(function()
    while true do
        if Settings.AutoFeeder then AutoFeederLoop() end
        task.wait(0.5)
    end
end)

spawn(function()
    while true do
        if Settings.CollectEgg then CollectEggLoop() end
        task.wait(0.5)
    end
end)

spawn(function()
    while true do
        if Settings.AutoTower then AutoTowerLoop() end
        task.wait(0.5)
    end
end)

-- ============================================
-- CHANGE THEME
-- ============================================
local function ChangeTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = themeName
        Theme = Themes[themeName]
        
        -- Update MainFrame
        MainFrame.BackgroundColor3 = Theme.Background
        MainFrame.UIStroke.Color = Theme.Accent
        
        -- Update Topbar
        Topbar.BackgroundColor3 = Theme.Topbar
        Title.TextColor3 = Theme.Text
        
        -- Update all elements
        for _, child in ipairs(MainFrame:GetDescendants()) do
            if child:IsA("Frame") and child.BackgroundColor3 ~= Color3.fromRGB(255, 255, 255) then
                if child.Parent and child.Parent:IsA("ScrollingFrame") then
                    -- Content elements
                    if child.BackgroundColor3 == Themes.Default.Element or child.BackgroundColor3 == Themes.Light.Element then
                        child.BackgroundColor3 = Theme.Element
                    end
                    if child:FindFirstChild("UIStroke") then
                        child.UIStroke.Color = Theme.Stroke
                    end
                end
            end
            if child:IsA("TextLabel") then
                if child ~= Title then
                    if child.TextColor3 == Themes.Default.Text or child.TextColor3 == Themes.Light.Text then
                        child.TextColor3 = Theme.Text
                    end
                    if child.TextColor3 == Themes.Default.TextDim or child.TextColor3 == Themes.Light.TextDim then
                        child.TextColor3 = Theme.TextDim
                    end
                end
            end
            if child:IsA("TextButton") then
                if child.TextColor3 == Themes.Default.Text or child.TextColor3 == Themes.Light.Text then
                    child.TextColor3 = Theme.Text
                end
                if child.BackgroundColor3 == Themes.Default.TabActive or child.BackgroundColor3 == Themes.Light.TabActive then
                    child.BackgroundColor3 = Theme.TabActive
                    child.TextColor3 = Theme.TabTextActive
                end
                if child.BackgroundColor3 == Themes.Default.TabInactive or child.BackgroundColor3 == Themes.Light.TabInactive then
                    child.BackgroundColor3 = Theme.TabInactive
                    child.TextColor3 = Theme.TabTextInactive
                end
            end
        end
        
        -- Update Bubble
        Bubble.BackgroundColor3 = Theme.Background
        Bubble.TextColor3 = Theme.Accent
        Bubble.UIStroke.Color = Theme.Accent
        
        -- Update Notification
        if NotificationFrame then
            NotificationFrame.BackgroundColor3 = Theme.Notification
            NotificationFrame.UIStroke.Color = Theme.NotificationAccent
            if NotificationText then
                NotificationText.TextColor3 = Theme.Text
            end
        end
        
        ShowNotification("🎨", "Đã chuyển sang theme: " .. themeName, 2)
    end
end

-- ============================================
-- INITIALIZE
-- ============================================
CreateMainWindow()
CreateBubble()
CreateNotificationSystem()

-- ============================================
-- CREATE TABS
-- ============================================

-- MAIN TAB
local MainTab = CreateTab("Main")
local toggleRefs = {}

-- Auto Rebirth
toggleRefs.AutoRebirth = CreateToggle(MainTab, "👼 Auto Rebirth", false, function(value)
    Settings.AutoRebirth = value
    if value then
        ShowNotification("✅", "Đã bật Auto Rebirth")
    else
        ShowNotification("⏹️", "Đã tắt Auto Rebirth")
    end
end)

-- Auto Feeder
toggleRefs.AutoFeeder = CreateToggle(MainTab, "🌾 Auto Feeder", false, function(value)
    Settings.AutoFeeder = value
    if value then
        ShowNotification("✅", "Đã bật Auto Feeder")
    else
        ShowNotification("⏹️", "Đã tắt Auto Feeder")
    end
end)

-- Collect Egg
toggleRefs.CollectEgg = CreateToggle(MainTab, "🥚 Collect Egg", false, function(value)
    Settings.CollectEgg = value
    if value then
        ShowNotification("✅", "Đã bật Collect Egg")
    else
        ShowNotification("⏹️", "Đã tắt Collect Egg")
    end
end)

-- Auto Tower
toggleRefs.AutoTower = CreateToggle(MainTab, "🗼 Auto Tower", false, function(value)
    Settings.AutoTower = value
    if value then
        Status.TowerCooldown = RandDelay(27.3, 29.5)
        ShowNotification("✅", "Đã bật Auto Tower")
    else
        Status.TowerCooldown = 0
        ShowNotification("⏹️", "Đã tắt Auto Tower")
    end
end)

-- STATS TAB
local StatsTab = CreateTab("Stats")

local MoneyLabel = CreateLabel(StatsTab, "💰 Money: 0")
local CornLabel = CreateLabel(StatsTab, "🌽 Corn/s: 0")
local TowerLabel = CreateLabel(StatsTab, "🗼 Tower: 0")
local LevelLabel = CreateLabel(StatsTab, "⭐ Level: 0")
local StatusLabel = CreateLabel(StatsTab, "📊 Status: Idle")

-- SETTINGS TAB
local SettingsTab = CreateTab("Settings")

-- Theme selector
local ThemeOptions = {"Default", "Light"}
local currentThemeOption = 0

local ThemeFrame = Instance.new("Frame")
ThemeFrame.Size = UDim2.new(1, 0, 0, 50)
ThemeFrame.BackgroundColor3 = Theme.Element
ThemeFrame.Parent = SettingsTab
CreateCorner(ThemeFrame, 8)
CreateStroke(ThemeFrame, Theme.Stroke, 1)

local ThemeLabel = Instance.new("TextLabel")
ThemeLabel.Size = UDim2.new(0.7, 0, 1, 0)
ThemeLabel.Position = UDim2.new(0, 14, 0, 0)
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.Text = "🎨 Theme: " .. CurrentTheme
ThemeLabel.TextColor3 = Theme.Text
ThemeLabel.TextSize = 14
ThemeLabel.Font = Enum.Font.GothamMedium
ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeLabel.TextYAlignment = Enum.TextYAlignment.Center
ThemeLabel.Parent = ThemeFrame

local ThemeBtn = Instance.new("TextButton")
ThemeBtn.Size = UDim2.new(0, 60, 0, 30)
ThemeBtn.Position = UDim2.new(1, -72, 0.5, -15)
ThemeBtn.BackgroundColor3 = Theme.Accent
ThemeBtn.Text = "Đổi"
ThemeBtn.TextColor3 = Theme.Text
ThemeBtn.TextSize = 13
ThemeBtn.Font = Enum.Font.GothamMedium
ThemeBtn.Parent = ThemeFrame
CreateCorner(ThemeBtn, 6)

ThemeBtn.MouseButton1Click:Connect(function()
    currentThemeOption = (currentThemeOption + 1) % 2
    local newTheme = ThemeOptions[currentThemeOption + 1]
    ChangeTheme(newTheme)
    ThemeLabel.Text = "🎨 Theme: " .. newTheme
end)

-- Reset Button
CreateButton(SettingsTab, "🔄 Reset All Settings", function()
    for name, toggle in pairs(toggleRefs) do
        if toggle and toggle.SetState then
            toggle:SetState(false)
        end
    end
    
    Settings.AutoRebirth = false
    Settings.AutoFeeder = false
    Settings.CollectEgg = false
    Settings.AutoTower = false
    Status.TowerCooldown = 0
    Status.IncubatorTimer = 0
    Status.IsRebirthing = false
    
    ShowNotification("✅", "Đã reset tất cả cài đặt!")
end)

-- INFO TAB
local InfoTab = CreateTab("Info")

CreateParagraph(InfoTab, "📌 Hướng dẫn sử dụng", 
    "1. Bật/Tắt các tính năng ở tab Main\n" ..
    "2. Xem thông tin ở tab Stats\n" ..
    "3. Tùy chỉnh giao diện ở tab Settings\n" ..
    "4. Click bubble ⚡ để mở/đóng menu"
)

CreateParagraph(InfoTab, "⚡ Tính năng", 
    "• Auto Rebirth: Tự động rebirth khi đủ điều kiện\n" ..
    "• Auto Feeder: Tự động mua và nâng cấp generator\n" ..
    "• Collect Egg: Tự động thu thập trứng\n" ..
    "• Auto Tower: Tự động chơi tower"
)

-- ============================================
-- UPDATE STATS
-- ============================================
spawn(function()
    local statusText = "Idle"
    while true do
        task.wait(1)
        pcall(function()
            local money = GetMoney()
            local corn = GetCornPerSecond()
            local tower = GetCurrentTower()
            local level = GetLevel()
            
            MoneyLabel:Set("💰 Money: " .. tostring(money))
            CornLabel:Set("🌽 Corn/s: " .. tostring(corn))
            TowerLabel:Set("🗼 Tower: " .. tostring(tower))
            LevelLabel:Set("⭐ Level: " .. tostring(level))
            
            -- Update status
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
            StatusLabel:Set("📊 Status: " .. statusText)
        end)
    end
end)

-- ============================================
-- INIT COMPLETE
-- ============================================
print("✅ Auto Farm Hub Pro đã được tải thành công!")
print("⚡ DucNhat 2.0.5 - Custom Rayfield")

ShowNotification("🚀", "Auto Farm Hub Pro đã sẵn sàng!", 3)

-- ============================================
-- KEYBINDS
-- ============================================
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.K then
        Status.IsOpen = not Status.IsOpen
        MainFrame.Visible = Status.IsOpen
        if Status.IsOpen then
            ShowNotification("📂", "Đã mở menu!", 1.5)
        end
    end
    
    if input.KeyCode == Enum.KeyCode.R and input.KeyCode == Enum.KeyCode.LeftControl then
        for name, toggle in pairs(toggleRefs) do
            if toggle and toggle.SetState then
                toggle:SetState(false)
            end
        end
        Settings.AutoRebirth = false
        Settings.AutoFeeder = false
        Settings.CollectEgg = false
        Settings.AutoTower = false
        Status.TowerCooldown = 0
        Status.IncubatorTimer = 0
        Status.IsRebirthing = false
        ShowNotification("🔄", "Đã reset tất cả!", 2)
    end
end)

print("📌 Phím tắt:")
print("   K - Mở/đóng menu")
print("   Ctrl + R - Reset tất cả")
