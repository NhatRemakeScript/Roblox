local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")

local SG = Instance.new("ScreenGui")
SG.Name = "Menu"
SG.Parent = Player:WaitForChild("PlayerGui")

local rainbow = false
local rainbowHue = 0

local function C(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = o
end

local function S(o, c, t)
    local s = Instance.new("UIStroke")
    s.Color = c
    s.Thickness = t
    s.Parent = o
end

-- ================== NOTIFICATION SYSTEM ==================
local notificationFrame = Instance.new("Frame")
notificationFrame.Size = UDim2.new(0, 250, 0, 40)
notificationFrame.Position = UDim2.new(1, -260, 0, -50)
notificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
notificationFrame.Parent = SG
C(notificationFrame, 8)
S(notificationFrame, Color3.fromRGB(0, 200, 255), 1.5)

local notificationLabel = Instance.new("TextLabel")
notificationLabel.Size = UDim2.new(1, -20, 1, 0)
notificationLabel.Position = UDim2.new(0, 10, 0, 0)
notificationLabel.BackgroundTransparency = 1
notificationLabel.Text = ""
notificationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationLabel.TextSize = 13
notificationLabel.Font = Enum.Font.GothamMedium
notificationLabel.TextXAlignment = Enum.TextXAlignment.Left
notificationLabel.TextYAlignment = Enum.TextYAlignment.Center
notificationLabel.Parent = notificationFrame

notificationFrame.Visible = false

local notificationQueue = {}
local isShowingNotification = false

local function showNotification(text, duration)
    table.insert(notificationQueue, {text = text, duration = duration or 3})
    
    if not isShowingNotification then
        isShowingNotification = true
        spawn(function()
            while #notificationQueue > 0 do
                local notif = table.remove(notificationQueue, 1)

                notificationFrame.Visible = true
                notificationLabel.Text = notif.text

                notificationFrame.Position = UDim2.new(1, -260, 0, -50)
                local tweenDown = TS:Create(notificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(1, -260, 0, 10)
                })
                tweenDown:Play()
                tweenDown.Completed:Wait()

                wait(notif.duration)

                local tweenUp = TS:Create(notificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(1, -260, 0, -50)
                })
                tweenUp:Play()
                tweenUp.Completed:Wait()
                
                notificationFrame.Visible = false
                wait(0.2)
            end
            isShowingNotification = false
        end)
    end
end

-- ================== MAIN GUI ==================
local MF = Instance.new("Frame")
MF.Size = UDim2.new(0, 380, 0, 320)
MF.Position = UDim2.new(0.5, -190, 0.5, -160)
MF.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MF.Visible = false
MF.Parent = SG
C(MF, 12)
local mainStroke = S(MF, Color3.fromRGB(255, 0, 0), 1.5)

local function rainbowLoop()
    while true do
        rainbowHue = (rainbowHue + 0.01) % 1
        local col = Color3.fromHSV(rainbowHue, 1, 1)
        mainStroke.Color = col
        wait(0.01)
    end
end
spawn(rainbowLoop)

local TB = Instance.new("Frame")
TB.Size = UDim2.new(1, 0, 0, 35)
TB.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TB.Parent = MF
C(TB, 12)

local TT = Instance.new("TextLabel")
TT.Size = UDim2.new(1, -60, 1, 0)
TT.Position = UDim2.new(0, 15, 0, 0)
TT.BackgroundTransparency = 1
TT.Text = "⚡CC HUB 2.4.0"
TT.TextColor3 = Color3.fromRGB(255, 255, 255)
TT.TextSize = 16
TT.Font = Enum.Font.GothamBold
TT.TextXAlignment = Enum.TextXAlignment.Left
TT.TextYAlignment = Enum.TextYAlignment.Center
TT.Parent = TB

local CB = Instance.new("TextButton")
CB.Size = UDim2.new(0, 25, 0, 25)
CB.Position = UDim2.new(1, -35, 0.5, -12.5)
CB.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
CB.Text = "−"
CB.TextColor3 = Color3.fromRGB(255, 255, 255)
CB.TextSize = 18
CB.Font = Enum.Font.GothamBold
CB.Parent = TB
C(CB, 25)

local TC = Instance.new("Frame")
TC.Size = UDim2.new(1, 0, 0, 30)
TC.Position = UDim2.new(0, 0, 0, 35)
TC.BackgroundTransparency = 1
TC.Parent = MF

local TMain = Instance.new("TextButton")
TMain.Size = UDim2.new(0, 100, 0, 25)
TMain.Position = UDim2.new(0.5, -110, 0.5, -12.5)
TMain.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
TMain.Text = "Main"
TMain.TextColor3 = Color3.fromRGB(255, 255, 255)
TMain.TextSize = 13
TMain.Font = Enum.Font.GothamMedium
TMain.Parent = TC
C(TMain, 6)

local TMisc = Instance.new("TextButton")
TMisc.Size = UDim2.new(0, 100, 0, 25)
TMisc.Position = UDim2.new(0.5, 10, 0.5, -12.5)
TMisc.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
TMisc.Text = "Stats"
TMisc.TextColor3 = Color3.fromRGB(200, 200, 200)
TMisc.TextSize = 13
TMisc.Font = Enum.Font.GothamMedium
TMisc.Parent = TC
C(TMisc, 6)

-- Scrolling frame
local CP = Instance.new("ScrollingFrame")
CP.Size = UDim2.new(1, -10, 1, -75)
CP.Position = UDim2.new(0, 5, 0, 70)
CP.BackgroundTransparency = 1
CP.BorderSizePixel = 0
CP.ScrollBarThickness = 4
CP.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
CP.CanvasSize = UDim2.new(0, 0, 0, 0)
CP.Parent = MF

local CL = Instance.new("UIListLayout")
CL.FillDirection = Enum.FillDirection.Vertical
CL.Padding = UDim.new(0, 8)
CL.SortOrder = Enum.SortOrder.LayoutOrder
CL.Parent = CP

-- ================== TOGGLE SYSTEM ==================
local function CreateToggle(parent, text, def, cb)
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(1, 0, 0, 35)
    fr.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    fr.Parent = parent
    C(fr, 8)
    S(fr, Color3.fromRGB(50, 50, 60), 1)

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -70, 1, 0)
    lb.Position = UDim2.new(0, 12, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = text
    lb.TextColor3 = Color3.fromRGB(220, 220, 220)
    lb.TextSize = 14
    lb.Font = Enum.Font.GothamMedium
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.TextYAlignment = Enum.TextYAlignment.Center
    lb.Parent = fr

    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 40, 0, 22)
    sw.Position = UDim2.new(1, -52, 0.5, -11)
    sw.BackgroundColor3 = def and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(60, 60, 70)
    sw.Parent = fr
    C(sw, 22)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = def and UDim2.new(0, 19, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = sw
    C(knob, 4)

    local state = def or false
    local function setState(ns)
        state = ns
        local targetPos = state and UDim2.new(0, 19, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        local targetCol = state and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(60, 60, 70)
        local targetRot = state and 45 or 0
        TS:Create(sw, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = targetCol}):Play()
        TS:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = targetPos, Rotation = targetRot}):Play()
        if cb then cb(state) end
    end

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = fr
    click.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return fr, setState
end

-- ================== TABS CONTENT ==================
local mainTab = Instance.new("Frame")
mainTab.Name = "MainTab"
mainTab.Size = UDim2.new(1, 0, 0, 0)
mainTab.BackgroundTransparency = 1
mainTab.AutomaticSize = Enum.AutomaticSize.Y
mainTab.Parent = CP

local mainLayout = Instance.new("UIListLayout")
mainLayout.FillDirection = Enum.FillDirection.Vertical
mainLayout.Padding = UDim.new(0, 8)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Parent = mainTab

local miscTab = Instance.new("Frame")
miscTab.Name = "MiscTab"
miscTab.Size = UDim2.new(1, 0, 0, 0)
miscTab.BackgroundTransparency = 1
miscTab.AutomaticSize = Enum.AutomaticSize.Y
miscTab.Visible = false
miscTab.Parent = CP

local miscLayout = Instance.new("UIListLayout")
miscLayout.FillDirection = Enum.FillDirection.Vertical
miscLayout.Padding = UDim.new(0, 8)
miscLayout.SortOrder = Enum.SortOrder.LayoutOrder
miscLayout.Parent = miscTab

-- ================== GLOBAL VARIABLES ==================
local reb = false
local feeder = false
local ne = false
local autoTower = false
local pauseTowerStart = false
local towerCooldown = 0

-- ================== ANTI-AFK ==================
spawn(function()
    while wait(60) do
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end)

-- ================== HELPER FUNCTIONS ==================
local function randDelay(min, max)
    return math.random(min * 100, max * 100) / 100
end

local function isGuiActuallyVisible(gui)
    if not gui or not gui:IsA("GuiObject") then
        return false
    end
    local current = gui
    while current do
        if current:IsA("GuiObject") and not current.Visible then
            return false
        end
        current = current.Parent
    end
    if gui.AbsoluteSize.X <= 0 or gui.AbsoluteSize.Y <= 0 then
        return false
    end
    return true
end

local function isRebirthReadyVisible()
    local notice = Player:WaitForChild("PlayerGui"):FindFirstChild("RebirthNotice")
    if not notice then
        return false
    end
    for _, gui in ipairs(notice:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            if gui.Text and gui.Text:upper():find("REBIRTH READY!") and isGuiActuallyVisible(gui) then
                return true
            end
        end
    end
    return false
end

local function getRebirthNoticeStatus()
    local notice = Player:WaitForChild("PlayerGui"):FindFirstChild("RebirthNotice")
    if not notice then
        return "—"
    end
    local found = false
    local visibleOnScreen = false
    for _, gui in ipairs(notice:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            if gui.Text and gui.Text:upper():find("REBIRTH READY!") then
                found = true
                if isGuiActuallyVisible(gui) then
                    visibleOnScreen = true
                end
            end
        end
    end
    if not found then return "—" end
    return visibleOnScreen and "✔" or "✖"
end

local function getMoney()
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local money = ls:FindFirstChild("Money") or ls:FindFirstChild("Cash")
        if money then
            return tonumber(money.Value) or 0
        end
    end
    return 0
end

local function getCurrentTower()
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local tower = ls:FindFirstChild("Tower")
        if tower then
            return tonumber(tower.Value) or 0
        end
    end
    return 0
end

local function hasTowerContinue()
    local playerGui = Player:WaitForChild("PlayerGui")
    local tc = playerGui:FindFirstChild("TowerContinue")
    if not tc then return false end
    for _, child in ipairs(tc:GetDescendants()) do
        if child:IsA("GuiObject") and child.Visible and isGuiActuallyVisible(child) then
            return true
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
        if newDist < 5 then
            return true
        end
        if humanoid.MoveDirection.Magnitude < 0.5 and newDist > 10 then
            break
        end
        wait(0.5)
    end
    return false
end

-- ================== AUTO REBIRTH ==================
CreateToggle(mainTab, "👼 Auto Rebirth", false, function(s)
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
                        showNotification("🔄 Rebirth Ready! Gửi Rebirth...")
                    end
                    
                    if isRebirthing then
                        if tick() - rebirthStartTime < 10 then
                            pcall(function()
                                RS.Remotes.Rebirth:InvokeServer()
                            end)
                            wait(randDelay(1, 3))
                        else
                            isRebirthing = false
                            showNotification("✅ Hoàn thành Rebirth!")
                        end
                    end
                end)
                
                wait(randDelay(0.5, 1))
            end
        end)
    end
end)

-- ================== AUTO FEEDER (FIX HOÀN CHỈNH) ==================
CreateToggle(mainTab, "🌾 Auto Feeder", false, function(s)
    feeder = s
    if s then
        spawn(function()
            while feeder do
                pcall(function()
                    local currentTower = getCurrentTower()
                    local currentMoney = getMoney()
                    
                    if currentTower == 0 then
                        if currentMoney >= 360 then
                            pcall(function()
                                RS.Remotes.BuyGenerator:InvokeServer(1)
                            end)
                            showNotification("✅ Mua Generator 1 thành công!")
                        end
                    else
                        pcall(function()
                            RS.Remotes.UpgradeGenerator:InvokeServer(1)
                        end)
                    end
                end)
                
                wait(randDelay(1, 2))
            end
        end)
    end
end)

-- ================== COLLECT EGG ==================
local currentTarget = nil
local isWalking = false
local incubatorTimer = 0

CreateToggle(mainTab, "🥚 Collect Egg", false, function(s)
    ne = s
    if s then
        spawn(function()
            while ne do
                pcall(function()
                    incubatorTimer = incubatorTimer + 1
                    if incubatorTimer >= 30 then
                        pcall(function()
                            RS.Remotes.IncubatorClaim:InvokeServer()
                        end)
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
                wait(1)
            end
        end)
    end
end)

CreateToggle(mainTab, "🗼 Auto Tower", false, function(s)
    autoTower = s
    if s then
        local lastTowerContinueDecline = 0
        local isCountingDown = false
        local hasSentFirstTime = false
        local towerCooldown = 0
        local wasRebirthVisible = false
        local rebirthTimer = 0

        spawn(function()
            while autoTower do
                if not pauseTowerStart then
                    local towerContinueVisible = hasTowerContinue()
                    local rebirthReadyVisible = isRebirthReadyVisible()
                    
                    -- === GỬI LẦN ĐẦU NGAY KHI BẬT ===
                    if not hasSentFirstTime then
                        hasSentFirstTime = true
                        local currentTower = getCurrentTower()
                        pcall(function()
                            if currentTower > 0 then
                                RS.Remotes.TowerElevator:InvokeServer(currentTower + 1)
                                wait(randDelay(1, 2))
                                RS.Remotes.TowerStart:InvokeServer()
                            else
                                RS.Remotes.TowerStart:InvokeServer()
                            end
                        end)
                        showNotification("✅ Đã gửi Tower lần đầu!")
                        
                    -- === PHÁT HIỆN REBIRTH READY ===
                    elseif rebirthReadyVisible then
                        if not wasRebirthVisible then
                            -- Lần đầu phát hiện rebirth
                            wasRebirthVisible = true
                            isCountingDown = true
                            towerCooldown = 10
                            rebirthTimer = tick()
                            
                            pcall(function()
                                RS.Remotes.TowerSurrender:InvokeServer()
                            end)
                            showNotification("🔄 Rebirth Ready! Đếm 10 giây...")
                        else
                            -- Vẫn đang trong trạng thái rebirth
                            if isCountingDown then
                                if towerCooldown > 0 then
                                    towerCooldown = towerCooldown - 0.1
                                end
                                
                                if towerCooldown <= 0 then
                                    -- Sau 10 giây → gửi TowerStart
                                    pcall(function()
                                        RS.Remotes.TowerStart:InvokeServer()
                                    end)
                                    showNotification("✅ Gửi Tower Start sau Rebirth!")
                                    
                                    -- Reset trạng thái
                                    isCountingDown = false
                                    towerCooldown = 0
                                    wasRebirthVisible = false
                                end
                            end
                        end
                        
                    -- === TOWERCONTINUE HIỆN → ĐẾM 20 GIÂY ===
                    elseif towerContinueVisible then
                        if not isCountingDown then
                            isCountingDown = true
                            towerCooldown = 20
                            showNotification("🕒 Đếm 20 giây...")
                        end
                        
                        if towerCooldown > 0 then
                            towerCooldown = towerCooldown - 0.1
                        end
                        
                        if towerCooldown <= 0 then
                            local currentTower = getCurrentTower()
                            pcall(function()
                                if currentTower > 0 then
                                    RS.Remotes.TowerElevator:InvokeServer(currentTower + 1)
                                    wait(randDelay(1, 2))
                                    RS.Remotes.TowerStart:InvokeServer()
                                else
                                    RS.Remotes.TowerStart:InvokeServer()
                                end
                            end)
                            
                            isCountingDown = false
                            towerCooldown = 0
                            showNotification("✅ Đã gửi Tower Start!")
                        end
                        
                    -- === KHÔNG CÓ GÌ → RESET ===
                    else
                        isCountingDown = false
                        towerCooldown = 0
                        wasRebirthVisible = false
                    end
                end
                wait(0.1)
            end
        end)

        -- Vòng lặp gửi TowerContinueDecline
        spawn(function()
            while autoTower do
                if hasTowerContinue() and (tick() - lastTowerContinueDecline > 1.0) then
                    pcall(function()
                        RS.Remotes.TowerContinueDecline:FireServer()
                    end)
                    lastTowerContinueDecline = tick()
                end
                wait(0.5)
            end
        end)
    else
        pauseTowerStart = false
    end
end)
-- ================== TOWER INFO FRAME ==================
local towerInfoFrame = Instance.new("Frame")
towerInfoFrame.Size = UDim2.new(1, 0, 0, 50)
towerInfoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
towerInfoFrame.Parent = mainTab
C(towerInfoFrame, 8)
S(towerInfoFrame, Color3.fromRGB(50, 50, 60), 1)

local towerInfoLabel = Instance.new("TextLabel")
towerInfoLabel.Size = UDim2.new(1, -10, 1, -10)
towerInfoLabel.Position = UDim2.new(0, 5, 0, 5)
towerInfoLabel.BackgroundTransparency = 1
towerInfoLabel.Text = "TowerCD: N/A\nText: —\nCurrentTower: N/A"
towerInfoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
towerInfoLabel.TextSize = 12
towerInfoLabel.Font = Enum.Font.GothamMedium
towerInfoLabel.TextWrapped = true
towerInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
towerInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
towerInfoLabel.Parent = towerInfoFrame

local function updateTowerInfo()
    local cdText = "N/A"
    if autoTower then
        cdText = string.format("%.1fs", towerCooldown)
    end
    local textStatus = getRebirthNoticeStatus()
    local currentTower = "N/A"
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local tower = ls:FindFirstChild("Tower")
        if tower then
            currentTower = tostring(tower.Value)
        end
    end
    towerInfoLabel.Text = "🕒 TowerCD: " .. cdText .. "\n💬 Text: " .. textStatus .. "\n🗼 CurrentTower: " .. currentTower
end

spawn(function()
    while true do
        updateTowerInfo()
        wait(0.5)
    end
end)

-- ================== STATS TAB ==================
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, 0, 1, 0)
statsFrame.Position = UDim2.new(0, 0, 0, 0)
statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
statsFrame.Parent = miscTab
C(statsFrame, 8)
S(statsFrame, Color3.fromRGB(255, 215, 0), 1.5)

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -20, 0, 30)
statsTitle.Position = UDim2.new(0, 10, 0, 15)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "📊 PLAYER STATS"
statsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
statsTitle.TextSize = 16
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextXAlignment = Enum.TextXAlignment.Center
statsTitle.Parent = statsFrame

local function createHexStat(parent, position, emoji, label, value)
    local hexFrame = Instance.new("Frame")
    hexFrame.Size = UDim2.new(1, -20, 0, 45)
    hexFrame.Position = position
    hexFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    hexFrame.Parent = parent
    C(hexFrame, 12)
    S(hexFrame, Color3.fromRGB(255, 215, 0), 1.5)

    local emojiLabel = Instance.new("TextLabel")
    emojiLabel.Size = UDim2.new(0, 40, 1, 0)
    emojiLabel.Position = UDim2.new(0, 10, 0, 0)
    emojiLabel.BackgroundTransparency = 1
    emojiLabel.Text = emoji
    emojiLabel.TextSize = 22
    emojiLabel.TextXAlignment = Enum.TextXAlignment.Center
    emojiLabel.TextYAlignment = Enum.TextYAlignment.Center
    emojiLabel.Parent = hexFrame

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0, 120, 1, 0)
    labelText.Position = UDim2.new(0, 55, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.TextSize = 14
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.TextYAlignment = Enum.TextYAlignment.Center
    labelText.Parent = hexFrame

    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(1, -185, 1, 0)
    valueText.Position = UDim2.new(0, 175, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = value
    valueText.TextColor3 = Color3.fromRGB(255, 215, 0)
    valueText.TextSize = 15
    valueText.Font = Enum.Font.GothamBold
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.TextYAlignment = Enum.TextYAlignment.Center
    valueText.Parent = hexFrame

    return valueText
end

local cornValue, towerValue, moneyValue, levelValue

local function createAllStats()
    cornValue = createHexStat(statsFrame, UDim2.new(0, 10, 0, 55), "🌽", "Corn Farm:", "0/s")
    towerValue = createHexStat(statsFrame, UDim2.new(0, 10, 0, 105), "🗼", "Tower:", "0")
    moneyValue = createHexStat(statsFrame, UDim2.new(0, 10, 0, 155), "💰", "Money:", "0")
    levelValue = createHexStat(statsFrame, UDim2.new(0, 10, 0, 205), "⭐", "Level:", "0")
end

createAllStats()

local function updateStats()
    local ls = Player:FindFirstChild("leaderstats")
    if not ls then
        cornValue.Text = "N/A"
        towerValue.Text = "N/A"
        moneyValue.Text = "N/A"
        levelValue.Text = "N/A"
        return
    end

    local corn = ls:FindFirstChild("Corn/s") or ls:FindFirstChild("Corn Farm")
    local tower = ls:FindFirstChild("Tower")
    local money = ls:FindFirstChild("Money") or ls:FindFirstChild("Cash")
    local level = ls:FindFirstChild("Level")

    if corn then
        cornValue.Text = tostring(corn.Value) .. "/s"
    else
        cornValue.Text = "N/A"
    end

    if tower then
        towerValue.Text = tostring(tower.Value)
    else
        towerValue.Text = "N/A"
    end

    if money then
        moneyValue.Text = tostring(money.Value)
    else
        moneyValue.Text = "N/A"
    end

    if level then
        levelValue.Text = tostring(level.Value)
    else
        levelValue.Text = "N/A"
    end
end

spawn(function()
    while true do
        updateStats()
        wait(1)
    end
end)

-- ================== CANVAS + TAB SWITCH ==================
local function calcCanvas()
    local h = 0
    for _, ch in ipairs(CP:GetChildren()) do
        if ch:IsA("Frame") and ch.Visible then
            h = h + ch.AbsoluteSize.Y + 8
        end
    end
    CP.CanvasSize = UDim2.new(0, 0, 0, math.max(h, 0))
end

local function switchTab(tn)
    if tn == "Main" then
        mainTab.Visible = true
        miscTab.Visible = false
        TMain.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        TMain.TextColor3 = Color3.fromRGB(255, 255, 255)
        TMisc.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        TMisc.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        mainTab.Visible = false
        miscTab.Visible = true
        TMisc.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        TMisc.TextColor3 = Color3.fromRGB(255, 255, 255)
        TMain.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        TMain.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    CP.CanvasPosition = Vector2.new(0, 0)
    task.wait(0.05)
    calcCanvas()
end

TMain.MouseButton1Click:Connect(function()
    switchTab("Main")
end)
TMisc.MouseButton1Click:Connect(function()
    switchTab("Stats")
end)

local function onToggleAdded()
    task.wait(0.05)
    calcCanvas()
end
mainTab.ChildAdded:Connect(onToggleAdded)
miscTab.ChildAdded:Connect(onToggleAdded)

switchTab("Main")

-- ================== BUBBLE ICON (FIX LỖI) ==================
local bubble = Instance.new("ImageButton")
bubble.Size = UDim2.new(0, 50, 0, 50)
bubble.Position = UDim2.new(0, 15, 0.5, -25)
bubble.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
bubble.Image = "rbxassetid://2015193"  -- Dùng ID ảnh mặc định
bubble.ImageColor3 = Color3.fromRGB(255, 255, 255)
bubble.ImageTransparency = 0
bubble.Parent = SG
C(bubble, 50)
S(bubble, Color3.fromRGB(0, 200, 255), 2)

local bl = Instance.new("TextLabel")
bl.Size = UDim2.new(1, 0, 1, 0)
bl.BackgroundTransparency = 1
bl.Text = "⚡"
bl.TextColor3 = Color3.fromRGB(255, 255, 255)
bl.TextSize = 20
bl.Font = Enum.Font.GothamBold
bl.TextScaled = true
bl.Parent = bubble

local open = false
bubble.MouseButton1Click:Connect(function()
    open = not open
    MF.Visible = open
end)

-- Kéo thả menu chính
local drag = {active = false, offset = Vector2.new(0, 0)}
TB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag.active = true
        drag.offset = Vector2.new(i.Position.X - MF.AbsolutePosition.X, i.Position.Y - MF.AbsolutePosition.Y)
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag.active and i.UserInputType == Enum.UserInputType.MouseMovement then
        local nx = math.clamp(i.Position.X - drag.offset.X, 0, SG.AbsoluteSize.X - MF.AbsoluteSize.X)
        local ny = math.clamp(i.Position.Y - drag.offset.Y, 0, SG.AbsoluteSize.Y - MF.AbsoluteSize.Y)
        MF.Position = UDim2.new(0, nx, 0, ny)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag.active = false
    end
end)

-- Kéo thả bubble
local bdrag = {active = false, offset = Vector2.new(0, 0)}
bubble.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        bdrag.active = true
        bdrag.offset = Vector2.new(i.Position.X - bubble.AbsolutePosition.X, i.Position.Y - bubble.AbsolutePosition.Y)
    end
end)
UIS.InputChanged:Connect(function(i)
    if bdrag.active and i.UserInputType == Enum.UserInputType.MouseMovement then
        local nx = math.clamp(i.Position.X - bdrag.offset.X, 0, SG.AbsoluteSize.X - bubble.AbsoluteSize.X)
        local ny = math.clamp(i.Position.Y - bdrag.offset.Y, 0, SG.AbsoluteSize.Y - bubble.AbsoluteSize.Y)
        bubble.Position = UDim2.new(0, nx, 0, ny)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        bdrag.active = false
    end
end)

-- Nút thu nhỏ / phóng to menu
local min = false
CB.MouseButton1Click:Connect(function()
    min = not min
    if min then
        CP.Visible = false
        TC.Visible = false
        MF.Size = UDim2.new(0, 380, 0, 35)
        CB.Text = "+"
    else
        CP.Visible = true
        TC.Visible = true
        MF.Size = UDim2.new(0, 380, 0, 320)
        CB.Text = "−"
        task.wait(0.05)
        calcCanvas()
    end
end)
