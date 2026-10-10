local Library = {}
Library.__index = Library

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local C = {
    BgDark    = Color3.fromRGB(10, 8, 22),
    BgMain    = Color3.fromRGB(16, 12, 34),
    BgSide    = Color3.fromRGB(20, 15, 42),
    BgPage    = Color3.fromRGB(18, 13, 38),
    BgElem    = Color3.fromRGB(28, 21, 56),
    BgHover   = Color3.fromRGB(42, 30, 84),
    Accent    = Color3.fromRGB(130, 80, 255),
    Accent2   = Color3.fromRGB(0, 210, 255),
    Text      = Color3.fromRGB(238, 238, 255),
    TextDim   = Color3.fromRGB(150, 148, 190),
    On        = Color3.fromRGB(0, 220, 180),
    Off       = Color3.fromRGB(60, 58, 92),
    Danger    = Color3.fromRGB(255, 70, 100),
}

local function guiParent()
    if gethui then return gethui() end
    if CoreGui then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function mk(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function stroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.Accent
    s.Thickness = th or 1
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function grad(p, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 0
    g.Parent = p
    return g
end

local function tw(obj, t, props, style, dir)
    local a = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    a:Play()
    return a
end

local function dragify(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function rainbowStroke(inst)
    local s = stroke(inst, C.Accent, 1.5, 0)
    local hue = 0
    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if not inst.Parent then conn:Disconnect() return end
        hue = (hue + dt * 0.3) % 1
        s.Color = Color3.fromHSV(hue, 0.85, 1)
    end)
    return s
end

local function click()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://6895079853"
        s.Volume = 0.2
        s.Parent = guiParent()
        s:Play()
        game:GetService("Debris"):AddItem(s, 1)
    end)
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local W_W, W_H = isMobile and 340 or 600, isMobile and 420 or 400

function Library.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Library)
    self.Config = cfg
    self.Tabs = {}
    self.Flags = {}
    self.ToggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    self.Open = true
    self.IsMobile = isMobile
    self:Build()
    return self
end

function Library:Build()
    local gui = mk("ScreenGui", {
        Name = "DN_UI_" .. tostring(math.random(1, 1e9)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    }, guiParent())
    self.Gui = gui

    local main = mk("Frame", {
        Name = "Main",
        Size = UDim2.new(0, W_W, 0, W_H),
        Position = UDim2.new(0.5, -W_W/2, 0.5, -W_H/2),
        BackgroundColor3 = C.BgMain,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
    }, gui)
    corner(main, 14)
    grad(main, C.BgMain, Color3.fromRGB(24, 16, 48), 90)
    rainbowStroke(main)
    self.Main = main

    local titleBar = mk("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = C.BgMain,
        BorderSizePixel = 0,
    }, main)
    corner(titleBar, 14)
    local titleCover = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundColor3 = C.BgMain,
        BorderSizePixel = 0,
    }, titleBar)

    local title = mk("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = self.Config.Title or "DN // GAMING UI",
        TextColor3 = C.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, titleBar)
    grad(title, C.Accent2, C.Accent, 0)

    local closeBtn = mk("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0, 5),
        BackgroundColor3 = C.BgElem,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "✕",
        TextColor3 = C.Text,
        TextSize = 14,
        AutoButtonColor = false,
    }, titleBar)
    corner(closeBtn, 8)
    closeBtn.MouseEnter:Connect(function() tw(closeBtn, 0.15, {BackgroundColor3 = C.Danger}) end)
    closeBtn.MouseLeave:Connect(function() tw(closeBtn, 0.15, {BackgroundColor3 = C.BgElem}) end)
    closeBtn.MouseButton1Click:Connect(function() self:Toggle(false) end)

    local minBtn = mk("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -76, 0, 5),
        BackgroundColor3 = C.BgElem,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "—",
        TextColor3 = C.Text,
        TextSize = 14,
        AutoButtonColor = false,
    }, titleBar)
    corner(minBtn, 8)
    minBtn.MouseEnter:Connect(function() tw(minBtn, 0.15, {BackgroundColor3 = C.BgHover}) end)
    minBtn.MouseLeave:Connect(function() tw(minBtn, 0.15, {BackgroundColor3 = C.BgElem}) end)
    minBtn.MouseButton1Click:Connect(function()
        self:Toggle(false)
        self:ShowFloating()
    end)

    dragify(main, titleBar)

    local sideW = isMobile and 0 or 148
    local sidePad = isMobile and 8 or 10
    local contentX = isMobile and 8 or (sideW + 16)
    local contentW = isMobile and -16 or -(sideW + 24)

    local sidebar = mk("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, sideW, 1, -54),
        Position = UDim2.new(0, sidePad, 0, 46),
        BackgroundColor3 = C.BgSide,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = not isMobile,
    }, main)
    corner(sidebar, 10)
    stroke(sidebar, C.Accent, 1, 0.7)
    self.Sidebar = sidebar

    local tabScroll = mk("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, sidebar)
    mk("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, tabScroll)
    self.TabScroll = tabScroll

    local mobileTabBar = mk("ScrollingFrame", {
        Size = UDim2.new(1, -16, 0, 36),
        Position = UDim2.new(0, 8, 0, 46),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Visible = isMobile,
    }, main)
    local mtl = mk("UIListLayout", {Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder}, mobileTabBar)
    self.MobileTabBar = mobileTabBar

    local contentTop = isMobile and 88 or 46
    local content = mk("Frame", {
        Name = "Content",
        Size = UDim2.new(1, contentW, 1, -(contentTop + 8)),
        Position = UDim2.new(0, contentX, 0, contentTop),
        BackgroundColor3 = C.BgPage,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, main)
    corner(content, 10)
    stroke(content, C.Accent, 1, 0.8)
    self.Content = content

    local mobileBtn = mk("TextButton", {
        Size = UDim2.new(0, 54, 0, 54),
        Position = UDim2.new(0, 20, 0.5, -27),
        BackgroundColor3 = C.BgMain,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "UI",
        TextColor3 = C.Text,
        TextSize = 15,
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 200,
    }, gui)
    corner(mobileBtn, 27)
    rainbowStroke(mobileBtn)
    dragify(mobileBtn, mobileBtn)
    mobileBtn.MouseButton1Click:Connect(function()
        self:Toggle(true)
        mobileBtn.Visible = false
    end)
    self.MobileBtn = mobileBtn

    self.NotifyHolder = mk("Frame", {
        Size = UDim2.new(0, isMobile and 240 or 300, 1, 0),
        Position = UDim2.new(1, isMobile and -252 or -320, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 300,
    }, gui)
    mk("UIListLayout", {Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder}, self.NotifyHolder)
    mk("UIPadding", {PaddingTop = UDim.new(0, 20)}, self.NotifyHolder)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.ToggleKey then
            self:Toggle(not self.Open)
        end
    end)
end

function Library:Toggle(state)
    self.Open = state
    if state then
        self.Main.Visible = true
        self.Main.Size = UDim2.new(0, W_W, 0, W_H)
        self.Main.Position = UDim2.new(0.5, -W_W/2, 0.5, -W_H/2)
        if self.MobileBtn then self.MobileBtn.Visible = false end
    else
        self.Main.Visible = false
    end
end

function Library:ShowFloating()
    if self.FloatingCol then self.FloatingCol:Destroy() end
    local col = mk("Frame", {
        Size = UDim2.new(0, 54, 0, 54),
        Position = UDim2.new(0, 20, 0.5, -27),
        BackgroundColor3 = C.BgMain,
        BorderSizePixel = 0,
        ZIndex = 200,
    }, self.Gui)
    corner(col, 27)
    rainbowStroke(col)
    local b = mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "DN",
        TextColor3 = C.Accent2,
        TextSize = 14,
    }, col)
    dragify(col, b)
    b.MouseButton1Click:Connect(function()
        col:Destroy()
        self.FloatingCol = nil
        self:Toggle(true)
    end)
    self.FloatingCol = col
end

function Library:Notify(cfg)
    cfg = cfg or {}
    local dur = cfg.Duration or 4
    local color = cfg.Color or C.Accent
    local n = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = C.BgMain,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, self.NotifyHolder)
    corner(n, 10)
    grad(n, C.BgMain, C.BgDark, 90)
    stroke(n, color, 1.5, 0.15)

    local bar = mk("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
    }, n)
    grad(bar, color, C.Accent2, 90)

    mk("TextLabel", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = cfg.Title or "Thông báo",
        TextColor3 = C.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, n)

    mk("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = cfg.Text or "",
        TextColor3 = C.TextDim,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, n)

    n.Position = UDim2.new(1, 20, 0, 0)
    tw(n, 0.35, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.delay(dur, function()
        tw(n, 0.3, {Position = UDim2.new(1, 20, 0, 0)})
        task.wait(0.35)
        n:Destroy()
    end)
    return n
end

function Library:CreateTab(name)
    local tab = {Name = name, Elements = {}, Active = false}

    local btnParent = self.IsMobile and self.MobileTabBar or self.TabScroll
    local btnSize = self.IsMobile and UDim2.new(0, 96, 1, 0) or UDim2.new(1, 0, 0, 34)

    local btn = mk("TextButton", {
        Size = btnSize,
        BackgroundColor3 = C.BgElem,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Text = self.IsMobile and name or ("  " .. name),
        TextColor3 = C.TextDim,
        TextSize = 13,
        TextXAlignment = self.IsMobile and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        ClipsDescendants = true,
    }, btnParent)
    corner(btn, 8)

    local page = mk("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = C.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, self.Content)
    mk("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)

    tab.Button = btn
    tab.Page = page
    table.insert(self.Tabs, tab)

    btn.MouseEnter:Connect(function()
        if not tab.Active then tw(btn, 0.15, {BackgroundColor3 = C.BgHover, TextColor3 = C.Text}) end
    end)
    btn.MouseLeave:Connect(function()
        if not tab.Active then tw(btn, 0.15, {BackgroundColor3 = C.BgElem, TextColor3 = C.TextDim}) end
    end)
    btn.MouseButton1Click:Connect(function()
        click()
        for _, t in ipairs(self.Tabs) do
            t.Active = false
            tw(t.Button, 0.15, {BackgroundColor3 = C.BgElem, TextColor3 = C.TextDim})
            t.Page.Visible = false
        end
        tab.Active = true
        tw(btn, 0.15, {BackgroundColor3 = C.BgHover, TextColor3 = C.Accent2})
        page.Visible = true
    end)

    if #self.Tabs == 1 then
        tab.Active = true
        btn.BackgroundColor3 = C.BgHover
        btn.TextColor3 = C.Accent2
        page.Visible = true
    end

    tab.AddButton = function(_, c) return self:MakeButton(page, c) end
    tab.AddToggle = function(_, c) return self:MakeToggle(page, c) end
    tab.AddDropdown = function(_, c) return self:MakeDropdown(page, c) end
    tab.AddSlider = function(_, c) return self:MakeSlider(page, c) end
    tab.AddInput = function(_, c) return self:MakeInput(page, c) end
    tab.AddLabel = function(_, c) return self:MakeLabel(page, c) end
    tab.AddSection = function(_, c) return self:MakeSection(page, c) end

    return tab
end

function Library:MakeSection(parent, cfg)
    local f = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
    }, parent)
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = cfg.Name or "SECTION",
        TextColor3 = C.Accent2,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)
    local line = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = C.Accent,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.5,
    }, f)
    grad(line, C.Accent, C.Accent2, 0)
    return f
end

function Library:MakeLabel(parent, cfg)
    local f = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
    }, parent)
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = cfg.Text or "Label",
        TextColor3 = C.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)
    return f
end

function Library:MakeButton(parent, cfg)
    local btn = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = C.BgElem,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Text = cfg.Text or "Button",
        TextColor3 = C.Text,
        TextSize = 13,
        AutoButtonColor = false,
    }, parent)
    corner(btn, 8)
    local s = stroke(btn, C.Accent, 1, 0.5)
    btn.MouseEnter:Connect(function()
        tw(btn, 0.15, {BackgroundColor3 = C.BgHover})
        tw(s, 0.15, {Transparency = 0})
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, 0.15, {BackgroundColor3 = C.BgElem})
        tw(s, 0.15, {Transparency = 0.5})
    end)
    btn.MouseButton1Click:Connect(function()
        click()
        if cfg.Callback then pcall(cfg.Callback) end
    end)
    return btn
end

function Library:MakeToggle(parent, cfg)
    local state = cfg.Default or false
    local flag = cfg.Flag

    local f = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = C.BgElem,
        BorderSizePixel = 0,
    }, parent)
    corner(f, 8)

    mk("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = cfg.Text or "Toggle",
        TextColor3 = C.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)

    local switch = mk("Frame", {
        Size = UDim2.new(0, 44, 0, 22),
        Position = UDim2.new(1, -56, 0.5, -11),
        BackgroundColor3 = state and C.On or C.Off,
        BorderSizePixel = 0,
    }, f)
    corner(switch, 11)

    local knob = mk("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        BackgroundColor3 = C.Text,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, switch)
    corner(knob, 9)

    local hit = mk("TextButton", {
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(1, -64, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 5,
    }, f)

    local function setState(v)
        state = v
        tw(switch, 0.2, {BackgroundColor3 = v and C.On or C.Off})
        tw(knob, 0.2, {Position = v and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
        if flag then self.Flags[flag] = v end
        if cfg.Callback then pcall(cfg.Callback, v) end
    end

    hit.MouseButton1Click:Connect(function()
        click()
        setState(not state)
    end)

    if flag then self.Flags[flag] = state end
    return {Set = setState, Get = function() return state end, Frame = f}
end

function Library:MakeSlider(parent, cfg)
    local min = cfg.Min or 0
    local max = cfg.Max or 100
    local val = cfg.Default or min
    local flag = cfg.Flag

    local f = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = C.BgElem,
        BorderSizePixel = 0,
    }, parent)
    corner(f, 8)

    mk("TextLabel", {
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 12, 0, 5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = cfg.Text or "Slider",
        TextColor3 = C.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)

    local valLbl = mk("TextLabel", {
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -70, 0, 5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = tostring(val),
        TextColor3 = C.Accent2,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, f)

    local track = mk("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 34),
        BackgroundColor3 = C.BgDark,
        BorderSizePixel = 0,
    }, f)
    corner(track, 3)

    local fill = mk("Frame", {
        Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = C.Accent,
        BorderSizePixel = 0,
    }, track)
    corner(fill, 3)
    grad(fill, C.Accent, C.Accent2, 0)

    local knob = mk("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((val - min) / (max - min), -7, 0.5, -7),
        BackgroundColor3 = C.Text,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, track)
    corner(knob, 7)
    stroke(knob, C.Accent2, 1.5, 0)

    local hit = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 5,
    }, f)

    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * rel + 0.5)
        val = v
        valLbl.Text = tostring(v)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        if flag then self.Flags[flag] = v end
        if cfg.Callback then pcall(cfg.Callback, v) end
    end

    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    if flag then self.Flags[flag] = val end
    return {Set = function(v) val = v; valLbl.Text = tostring(v) end, Get = function() return val end}
end

function Library:MakeInput(parent, cfg)
    local f = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = C.BgElem,
        BorderSizePixel = 0,
    }, parent)
    corner(f, 8)
    local s = stroke(f, C.Accent, 1, 0.7)

    local box = mk("TextBox", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = cfg.Default or "",
        PlaceholderText = cfg.Placeholder or "Nhập...",
        PlaceholderColor3 = C.TextDim,
        TextColor3 = C.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, f)

    box.Focused:Connect(function()
        tw(f, 0.15, {BackgroundColor3 = C.BgHover})
        tw(s, 0.15, {Transparency = 0})
    end)
    box.FocusLost:Connect(function()
        tw(f, 0.15, {BackgroundColor3 = C.BgElem})
        tw(s, 0.15, {Transparency = 0.7})
        if cfg.Callback then pcall(cfg.Callback, box.Text) end
    end)
    return box
end

function Library:MakeDropdown(parent, cfg)
    local options = cfg.Options or {}
    local multi = cfg.Multi or false
    local selected = cfg.Default or (multi and {} or (options[1] or ""))
    local open = false
    local flag = cfg.Flag

    local f = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = C.BgElem,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, parent)
    corner(f, 8)

    local header = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 5,
    }, f)

    mk("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = cfg.Text or "Dropdown",
        TextColor3 = C.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)

    local valLbl = mk("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = multi and (#selected > 0 and table.concat(selected, ", ") or "Chọn...") or tostring(selected),
        TextColor3 = C.Accent2,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, f)

    local arrow = mk("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -26, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "▼",
        TextColor3 = C.Accent2,
        TextSize = 10,
    }, f)

    local list = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundColor3 = C.BgDark,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, f)
    mk("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, list)

    local function refreshVal()
        if multi then
            valLbl.Text = #selected > 0 and table.concat(selected, ", ") or "Chọn..."
        else
            valLbl.Text = tostring(selected)
        end
        if flag then self.Flags[flag] = selected end
    end

    for i, opt in ipairs(options) do
        local ib = mk("TextButton", {
            Size = UDim2.new(1, -8, 0, 28),
            Position = UDim2.new(0, 4, 0, 4 + (i - 1) * 30),
            BackgroundColor3 = C.BgElem,
            BorderSizePixel = 0,
            Font = Enum.Font.Gotham,
            Text = tostring(opt),
            TextColor3 = C.Text,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 6,
        }, list)
        corner(ib, 6)
        ib.MouseEnter:Connect(function() tw(ib, 0.12, {BackgroundColor3 = C.BgHover}) end)
        ib.MouseLeave:Connect(function() tw(ib, 0.12, {BackgroundColor3 = C.BgElem}) end)
        ib.MouseButton1Click:Connect(function()
            click()
            if multi then
                local found = false
                for k, v in ipairs(selected) do
                    if v == opt then table.remove(selected, k); found = true; break end
                end
                if not found then table.insert(selected, opt) end
            else
                selected = opt
                open = false
                tw(f, 0.25, {Size = UDim2.new(1, 0, 0, 38)})
                tw(arrow, 0.2, {Rotation = 0})
                tw(list, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
            end
            refreshVal()
            if cfg.Callback then pcall(cfg.Callback, selected) end
        end)
    end

    header.MouseButton1Click:Connect(function()
        click()
        open = not open
        local h = #options * 30 + 8
        if open then
            tw(f, 0.25, {Size = UDim2.new(1, 0, 0, 38 + h)})
            tw(list, 0.25, {Size = UDim2.new(1, 0, 0, h)})
            tw(arrow, 0.2, {Rotation = 180})
        else
            tw(f, 0.25, {Size = UDim2.new(1, 0, 0, 38)})
            tw(list, 0.25, {Size = UDim2.new(1, 0, 0, 0)})
            tw(arrow, 0.2, {Rotation = 0})
        end
    end)

    refreshVal()
    return {Set = function(v) selected = v; refreshVal() end, Get = function() return selected end}
end

return Library
