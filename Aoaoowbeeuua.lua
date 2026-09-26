local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local Toggles = Library.Toggles
local Options = Library.Options

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local fishOffsetX = 45
local fishOffsetY = 60
local PARENT_NAME = "ReelCounterGui"

local Window = Library:CreateWindow({
    Title = "FM-DNHUB",
    Footer = "Obsidian UI",
    Icon = 6687255998,
    NotifySide = "Right",
    ShowCustomCursor = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Player = Window:AddTab("Player", "user"),
}

local MainGroup = Tabs.Main:AddGroupbox({ Side = "Left", Name = "Auto", IconName = "boxes" })
local PlayerGroup = Tabs.Player:AddGroupbox({ Side = "Left", Name = "Player", IconName = "user" })

local state = {
    autoFishing = false,
    autoSkillZ = false,
    autoSkillX = false,
    autoSkillC = false,
    autoSkillV = false,
    speed = false,
    hideName = false,
    antiPause = false,
}

-- ==================== HÀM HỖ TRỢ ====================
local function hasFishingButton()
    local found = false
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc.Name == "FishingActionButton" and desc:IsA("ImageButton") and desc.Visible then
                        found = true
                    end
                end
            end
        end
    end)
    return found
end

local function getFishingButtonPosition()
    local pos = nil
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc.Name == "FishingActionButton" and desc:IsA("ImageButton") and desc.Visible then
                        local absPos = desc.AbsolutePosition
                        local absSize = desc.AbsoluteSize
                        pos = Vector2.new(
                            absPos.X + (absSize.X / 2) + fishOffsetX,
                            absPos.Y + (absSize.Y / 2) + fishOffsetY
                        )
                        return
                    end
                end
            end
        end
    end)
    return pos
end

local function sendKeyPress(keyCode)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function clickCenter()
    pcall(function()
        local vpSize = workspace.CurrentCamera.ViewportSize
        local midX = (vpSize.X / 2) + fishOffsetX
        local midY = (vpSize.Y / 2) + fishOffsetY
        VirtualInputManager:SendMouseButtonEvent(midX, midY, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(midX, midY, 0, false, game, 0)
    end)
end

-- ==================== UI SCAN ====================
local function getTargetGui()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name == PARENT_NAME then
            return gui
        end
    end
    return nil
end

local function isElementTrulyVisible(inst)
    if not inst.Visible then return false end
    if inst.AbsoluteSize.X <= 0 or inst.AbsoluteSize.Y <= 0 then return false end

    local parent = inst.Parent
    while parent and parent ~= game do
        if parent:IsA("ScreenGui") then
            if not parent.Enabled then return false end
        elseif parent:IsA("GuiObject") then
            if not parent.Visible then return false end
            if parent.AbsoluteSize.X <= 0 or parent.AbsoluteSize.Y <= 0 then return false end
        elseif parent:IsA("CanvasGroup") then
            if parent.GroupTransparency >= 1 then return false end
        end
        parent = parent.Parent
    end
    return true
end

local function scanAndPress()
    local targetGui = getTargetGui()
    if not targetGui then return end

    local found = { Left = false, Right = false, Up = false }
    pcall(function()
        for _, desc in ipairs(targetGui:GetDescendants()) do
            if desc:IsA("GuiObject") and isElementTrulyVisible(desc) then
                if desc.Name == "Left" then found.Left = true
                elseif desc.Name == "Right" then found.Right = true
                elseif desc.Name == "Up" then found.Up = true
                end
            end
        end
    end)

    if found.Left then sendKeyPress(Enum.KeyCode.A) end
    if found.Right then sendKeyPress(Enum.KeyCode.D) end
    if found.Up then sendKeyPress(Enum.KeyCode.W) end
end

-- ==================== AUTO SKILL ====================
local skillThreads = {}

local function startSkillLoop(keyCode, stateKey)
    if skillThreads[stateKey] then
        task.cancel(skillThreads[stateKey])
        skillThreads[stateKey] = nil
    end
    skillThreads[stateKey] = task.spawn(function()
        while state.autoFishing and state[stateKey] do
            sendKeyPress(keyCode)
            task.wait(0.2)
        end
        skillThreads[stateKey] = nil
    end)
end

-- ==================== AUTO FISHING ====================
local function startAutoFishing()
    local lp = LocalPlayer
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = 0
        lp.Character.Humanoid.JumpPower = 0
    end

    task.spawn(function()
        while state.autoFishing do
            scanAndPress()
            task.wait(0.05)
        end
    end)

    task.spawn(function()
        while state.autoFishing do
            local waitStart = tick()
            while not hasFishingButton() and state.autoFishing and tick() - waitStart < 15 do task.wait(0.05) end
            if not state.autoFishing then break end

            task.wait(0.3)
            local fishingPos = getFishingButtonPosition()
            if fishingPos then
                VirtualInputManager:SendMouseButtonEvent(fishingPos.X, fishingPos.Y, 0, true, game, 0)
                task.wait(0.7)
                VirtualInputManager:SendMouseButtonEvent(fishingPos.X, fishingPos.Y, 0, false, game, 0)
            end

            local hideStart = tick()
            while hasFishingButton() and state.autoFishing and tick() - hideStart < 15 do task.wait(0.05) end
            if not state.autoFishing then break end

            local showStart = tick()
            while not hasFishingButton() and state.autoFishing and tick() - showStart < 15 do task.wait(0.05) end
            if not state.autoFishing then break end

            task.wait(0.3)
            fishingPos = getFishingButtonPosition()
            if fishingPos then
                VirtualInputManager:SendMouseButtonEvent(fishingPos.X, fishingPos.Y, 0, true, game, 0)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(fishingPos.X, fishingPos.Y, 0, false, game, 0)
            end

            hideStart = tick()
            while hasFishingButton() and state.autoFishing and tick() - hideStart < 15 do task.wait(0.05) end
            if not state.autoFishing then break end

            task.wait(1)
            clickCenter()
            task.wait(0.3)
        end
    end)

    if state.autoSkillZ then startSkillLoop(Enum.KeyCode.Z, "autoSkillZ") end
    if state.autoSkillX then startSkillLoop(Enum.KeyCode.X, "autoSkillX") end
    if state.autoSkillC then startSkillLoop(Enum.KeyCode.C, "autoSkillC") end
    if state.autoSkillV then startSkillLoop(Enum.KeyCode.V, "autoSkillV") end
end

local function stopAutoFishing()
    local lp = LocalPlayer
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = state.speed and 40 or 16
        lp.Character.Humanoid.JumpPower = 50
    end
end

-- ==================== ANTI GAME PAUSE ====================
local antiPauseThread = nil

local function startAntiPause()
    if antiPauseThread then
        task.cancel(antiPauseThread)
        antiPauseThread = nil
    end
    antiPauseThread = task.spawn(function()
        while state.antiPause do
            pcall(function()
                LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end)
            pcall(function()
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
            task.wait(60)
        end
        antiPauseThread = nil
    end)
end

local function stopAntiPause()
    if antiPauseThread then
        task.cancel(antiPauseThread)
        antiPauseThread = nil
    end
end

-- ==================== HIDE NAME (WORKSPACE NAMETAGS) ====================
local hideNameRunning = false
local hiddenLabels = {}

local function applyHideName()
    pcall(function()
        local playerName = LocalPlayer.Name

        -- Quét trong workspace
        local function scanContainer(container)
            for _, obj in ipairs(container:GetDescendants()) do
                -- Tìm BillboardGui hoặc TextLabel chứa tên player
                if obj:IsA("TextLabel") then
                    if obj.Text == playerName or obj.Text == "@" .. playerName then
                        if not hiddenLabels[obj] then
                            hiddenLabels[obj] = {
                                originalText = obj.Text,
                                originalVisible = obj.Visible,
                                originalTransparency = obj.TextTransparency,
                            }
                        end
                        if state.hideName then
                            obj.Text = ""
                            obj.Visible = false
                            obj.TextTransparency = 1
                        else
                            obj.Text = hiddenLabels[obj].originalText
                            obj.Visible = hiddenLabels[obj].originalVisible
                            obj.TextTransparency = hiddenLabels[obj].originalTransparency
                        end
                    end
                end
            end
        end

        -- Quét workspace
        scanContainer(workspace)

        -- Quét PlayerGui
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                scanContainer(gui)
            end
        end
    end)
end

local function startHideNameLoop()
    if hideNameRunning then return end
    hideNameRunning = true
    task.spawn(function()
        while state.hideName do
            applyHideName()
            task.wait(0.3)
        end
        hideNameRunning = false
    end)
end

local function restoreHideName()
    for obj, data in pairs(hiddenLabels) do
        pcall(function()
            if obj and obj.Parent then
                obj.Text = data.originalText
                obj.Visible = data.originalVisible
                obj.TextTransparency = data.originalTransparency
            end
        end)
    end
    hiddenLabels = {}
end

-- ==================== UI ====================
MainGroup:AddToggle("AutoFishing", {
    Text = "Auto Fishing",
    Tooltip = "Tự động câu cá + nhấn A/D/W khi UI Left/Right/Up hiện",
    Default = false,
    Callback = function(Value)
        state.autoFishing = Value
        if Value then startAutoFishing() else stopAutoFishing() end
    end,
})

MainGroup:AddToggle("AutoSkillZ", {
    Text = "Auto Skill Z",
    Default = false,
    Callback = function(Value)
        state.autoSkillZ = Value
        if Value and state.autoFishing then
            startSkillLoop(Enum.KeyCode.Z, "autoSkillZ")
        end
    end,
})

MainGroup:AddToggle("AutoSkillX", {
    Text = "Auto Skill X",
    Default = false,
    Callback = function(Value)
        state.autoSkillX = Value
        if Value and state.autoFishing then
            startSkillLoop(Enum.KeyCode.X, "autoSkillX")
        end
    end,
})

MainGroup:AddToggle("AutoSkillC", {
    Text = "Auto Skill C",
    Default = false,
    Callback = function(Value)
        state.autoSkillC = Value
        if Value and state.autoFishing then
            startSkillLoop(Enum.KeyCode.C, "autoSkillC")
        end
    end,
})

MainGroup:AddToggle("AutoSkillV", {
    Text = "Auto Skill V",
    Default = false,
    Callback = function(Value)
        state.autoSkillV = Value
        if Value and state.autoFishing then
            startSkillLoop(Enum.KeyCode.V, "autoSkillV")
        end
    end,
})

PlayerGroup:AddToggle("Speed", {
    Text = "Speed (40) + Anti Pause",
    Tooltip = "Tăng tốc độ di chuyển + chống AFK/pause",
    Default = false,
    Callback = function(Value)
        state.speed = Value
        state.antiPause = Value
        local lp = LocalPlayer
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = Value and 40 or 16
        end
        if Value then
            startAntiPause()
        else
            stopAntiPause()
        end
    end,
})

PlayerGroup:AddToggle("HideName", {
    Text = "Hide Name",
    Tooltip = "Xóa tên của bạn khỏi workspace Nametags (chỉ local)",
    Default = false,
    Callback = function(Value)
        state.hideName = Value
        if Value then
            startHideNameLoop()
        else
            restoreHideName()
        end
    end,
})

PlayerGroup:AddButton("KillMenu", {
    Text = "Kill Menu (Unload)",
    Func = function()
        state.autoFishing = false
        state.autoSkillZ = false
        state.autoSkillX = false
        state.autoSkillC = false
        state.autoSkillV = false
        state.speed = false
        state.hideName = false
        state.antiPause = false
        for key, thread in pairs(skillThreads) do
            task.cancel(thread)
            skillThreads[key] = nil
        end
        stopAntiPause()
        restoreHideName()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        Library:Unload()
    end,
})

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    if state.speed then
        char.Humanoid.WalkSpeed = 40
    end
    if state.autoFishing then
        startAutoFishing()
    end
end)

Library:Notify({
    Title = "FM-DNHUB",
    Description = "Đã load thành công!",
    Time = 5,
})
