local Library = {}
Library.__index = Library

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local COLORS = {
    BgDark      = Color3.fromRGB(12, 10, 24),
    BgPanel     = Color3.fromRGB(18, 14, 38),
    BgElement   = Color3.fromRGB(26, 20, 52),
    BgHover     = Color3.fromRGB(38, 28, 78),
    Accent      = Color3.fromRGB(120, 80, 255),
    Accent2     = Color3.fromRGB(0, 200, 255),
    Text        = Color3.fromRGB(235, 235, 255),
    TextDim     = Color3.fromRGB(150, 150, 190),
    ToggleOn    = Color3.fromRGB(0, 220, 180),
    ToggleOff   = Color3.fromRGB(70, 70, 100),
    Danger      = Color3.fromRGB(255, 70, 100),
}

local function safeParent()
    if gethui then return gethui() end
    if CoreGui and pcall(function() return CoreGui.Name end) then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function gradient(parent, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rotation or 0
    g.Parent = parent
    return g
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.Accent
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function newInstance(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function tween(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function dragify(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function rainbowStroke(inst)
    local s = stroke(inst, COLORS.Accent, 1.5, 0)
    local hue = 0
    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if not inst.Parent then conn:Disconnect() return end
        hue = (hue + dt * 0.25) % 1
        s.Color = Color3.fromHSV(hue, 0.8, 1)
    end)
    return s
end

local function makeDraggable(obj, dragTarget)
    dragify(obj, dragTarget)
end

local function playClick()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://6895079853"
        s.Volume = 0.25
        s.Parent = safeParent()
        s:Play()
        game:GetService("Debris"):AddItem(s, 1)
    end)
end

function Library.new(config)
    config = config or {}
    local self = setmetatable({}, Library)
    self.Config = config
    self.Tabs = {}
    self.Elements = {}
    self.Flags = {}
    self.Connections = {}
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    self.Open = true
    self:Build()
    return self
end

function Library:Build()
    local gui = newInstance("ScreenGui", {
        Name = "DN_GamingUI_" .. tostring(math.random(1, 1e9)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    }, safeParent())
    self.Gui = gui

    local main = newInstance("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 560, 0, 380),
        Position = UDim2.new(0.5, -280, 0.5, -190),
        BackgroundColor3 = COLORS.BgDark,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
    }, gui)
    corner(main, 14)
    gradient(main, COLORS.BgDark, Color3.fromRGB(24, 16, 48), 90)
    rainbowStroke(main)
    self.Main = main

    local shadow = newInstance("ImageLabel", {
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857472",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ZIndex = 0,
    }, main)

    local titleBar = newInstance("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = COLORS.BgPanel,
        BorderSizePixel = 0,
    }, main)
    corner(titleBar, 14)
    local tbCover = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = COLORS.BgPanel,
        BorderSizePixel = 0,
    }, titleBar)
    gradient(titleBar, COLORS.BgPanel, Color3.fromRGB(28, 18, 60), 0)
    self.TitleBar = titleBar

    local title = newInstance("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = self.Config.Title or "DN // GAMING UI",
        TextColor3 = COLORS.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, titleBar)
    gradient(title, COLORS.Accent2, COLORS.Accent, 0).Parent = title

    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = ColorSequence.new(COLORS.Accent2, COLORS.Accent)
    titleGrad.Parent = title

    local closeBtn = newInstance("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0, 4),
        BackgroundColor3 = COLORS.BgElement,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "✕",
        TextColor3 = COLORS.Text,
        TextSize = 14,
        AutoButtonColor = false,
    }, titleBar)
    corner(closeBtn, 8)
    closeBtn.MouseEnter:Connect(function() tween(closeBtn, 0.15, {BackgroundColor3 = COLORS.Danger}) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, 0.15, {BackgroundColor3 = COLORS.BgElement}) end)
    closeBtn.MouseButton1Click:Connect(function() self:Toggle(false) end)

    local minBtn = newInstance("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -76, 0, 4),
        BackgroundColor3 = COLORS.BgElement,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "—",
        TextColor3 = COLORS.Text,
        TextSize = 14,
        AutoButtonColor = false,
    }, titleBar)
    corner(minBtn, 8)
    minBtn.MouseButton1Click:Connect(function()
        local col = newInstance("Frame", {
            Size = UDim2.new(0, 48, 0, 48),
            Position = UDim2.new(0, 20, 0.5, -24),
            BackgroundColor3 = COLORS.BgPanel,
            BorderSizePixel = 0,
            Visible = false,
        }, self.Gui)
        corner(col, 24)
        rainbowStroke(col)
        local b = newInstance("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "DN",
            TextColor3 = COLORS.Accent2,
            TextSize = 14,
        }, col)
        self:Toggle(false)
        col.Visible = true
        b.MouseButton1Click:Connect(function()
            col:Destroy()
            self:Toggle(true)
        end)
        dragify(col, b)
    end)

    self:MakeDraggable(titleBar)

    local sidebar = newInstance("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundColor3 = COLORS.BgPanel,
        BorderSizePixel = 0,
    }, main)
    corner(sidebar, 12)
    self.Sidebar = sidebar

    local tabScroll = newInstance("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = COLORS.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, sidebar)
    local tabLayout = newInstance("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabScroll)
    self.TabScroll = tabScroll

    local content = newInstance("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -170, 1, -55),
        Position = UDim2.new(0, 160, 0, 45),
        BackgroundColor3 = COLORS.BgPanel,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, main)
    corner(content, 12)
    self.Content = content

    local mobileBtn = newInstance("TextButton", {
        Name = "MobileToggle",
        Size = UDim2.new(0, 56, 0, 56),
        Position = UDim2.new(0, 20, 0.5, -28),
        BackgroundColor3 = COLORS.BgPanel,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "UI",
        TextColor3 = COLORS.Text,
        TextSize = 16,
        Visible = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
        AutoButtonColor = false,
        ZIndex = 100,
    }, gui)
    corner(mobileBtn, 28)
    rainbowStroke(mobileBtn)
    dragify(mobileBtn, mobileBtn)
    mobileBtn.MouseButton1Click:Connect(function()
        self:Toggle(not self.Open)
        if not self.Open then mobileBtn.Visible = true end
    end)
    self.MobileBtn = mobileBtn

    self.NotifyHolder = newInstance("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -320, 0, 0),
        BackgroundTransparency = 1,
    }, gui)
    local nl = newInstance("UIListLayout", {
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, self.NotifyHolder)
    newInstance("UIPadding", {
        PaddingTop = UDim.new(0, 20),
    }, self.NotifyHolder)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.ToggleKey then
            self:Toggle(not self.Open)
        end
    end)
end

function Library:MakeDraggable(frame)
    dragify(self.Main, frame)
end

function Library:Toggle(state)
    self.Open = state
    if state then
        self.Main.Visible = true
        self.Main.Size = UDim2.new(0, 560, 0, 380)
        self.Main.Position = UDim2.new(0.5, -280, 0.5, -190)
        if self.MobileBtn then
            self.MobileBtn.Visible = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        end
    else
        self.Main.Visible = false
        if self.MobileBtn then
            self.MobileBtn.Visible = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        end
    end
end

function Library:Notify(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "Thông báo"
    local text = cfg.Text or ""
    local dur = cfg.Duration or 4
    local color = cfg.Color or COLORS.Accent

    local n = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = COLORS.BgPanel,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, self.NotifyHolder)
    corner(n, 10)
    local g = gradient(n, COLORS.BgPanel, COLORS.BgDark, 90)
    local s = stroke(n, color, 1.5, 0.2)
    n.BackgroundTransparency = 1

    local bar = newInstance("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
    }, n)
    gradient(bar, color, COLORS.Accent2, 90)

    local titleL = newInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = COLORS.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, n)

    local textL = newInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = COLORS.TextDim,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, n)

    n.Position = UDim2.new(1, 20, 0, 0)
    tween(n, 0.35, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(titleL, 0.3, {TextTransparency = 0})

    task.delay(dur, function()
        tween(n, 0.3, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1})
        task.wait(0.35)
        n:Destroy()
    end)
    return n
end

function Library:CreateTab(name)
    local tab = { Name = name, Elements = {}, Buttons = {} }

    local btn = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = COLORS.BgElement,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Text = "  " .. name,
        TextColor3 = COLORS.TextDim,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    }, self.TabScroll)
    corner(btn, 8)

    local page = newInstance("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = COLORS.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, self.Content)
    newInstance("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)

    local pages = self.Tabs
    table.insert(pages, tab)
    tab.Button = btn
    tab.Page = page

    btn.MouseEnter:Connect(function()
        if not tab.Active then tween(btn, 0.15, {BackgroundColor3 = COLORS.BgHover, TextColor3 = COLORS.Text}) end
    end)
    btn.MouseLeave:Connect(function()
        if not tab.Active then tween(btn, 0.15, {BackgroundColor3 = COLORS.BgElement, TextColor3 = COLORS.TextDim}) end
    end)

    btn.MouseButton1Click:Connect(function()
        playClick()
        for _, t in ipairs(self.Tabs) do
            t.Active = false
            tween(t.Button, 0.15, {BackgroundColor3 = COLORS.BgElement, TextColor3 = COLORS.TextDim})
            t.Page.Visible = false
        end
        tab.Active = true
        tween(btn, 0.15, {BackgroundColor3 = COLORS.BgHover, TextColor3 = COLORS.Accent2})
        page.Visible = true
    end)

    if #self.Tabs == 1 then
        tab.Active = true
        btn.BackgroundColor3 = COLORS.BgHover
        btn.TextColor3 = COLORS.Accent2
        page.Visible = true
    end

    tab.AddButton = function(_, cfg)
        return self:MakeButton(page, cfg)
    end
    tab.AddToggle = function(_, cfg)
        return self:MakeToggle(page, cfg)
    end
    tab.AddDropdown = function(_, cfg)
        return self:MakeDropdown(page, cfg)
    end
    tab.AddSlider = function(_, cfg)
        return self:MakeSlider(page, cfg)
    end
    tab.AddInput = function(_, cfg)
        return self:MakeInput(page, cfg)
    end
    tab.AddLabel = function(_, cfg)
        return self:MakeLabel(page, cfg)
    end
    tab.AddSection = function(_, cfg)
        return self:MakeSection(page, cfg)
    end

    return tab
end

function Library:MakeSection(parent, cfg)
    local f = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
    }, parent)
    local l = newInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = cfg.Name or "SECTION",
        TextColor3 = COLORS.Accent2,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)
    local line = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.6,
    }, f)
    gradient(line, COLORS.Accent, COLORS.Accent2, 0)
    return f
end

function Library:MakeLabel(parent, cfg)
    local f = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
    }, parent)
    newInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = cfg.Text or "Label",
        TextColor3 = COLORS.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)
    return f
end

function Library:MakeButton(parent, cfg)
    local btn = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = COLORS.BgElement,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Text = cfg.Text or "Button",
        TextColor3 = COLORS.Text,
        TextSize = 13,
        AutoButtonColor = false,
    }, parent)
    corner(btn, 8)
    local s = stroke(btn, COLORS.Accent, 1, 0.4)

    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, {BackgroundColor3 = COLORS.BgHover})
        tween(s, 0.15, {Transparency = 0})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, {BackgroundColor3 = COLORS.BgElement})
        tween(s, 0.15, {Transparency = 0.4})
    end)
    btn.MouseButton1Click:Connect(function()
        playClick()
        if cfg.Callback then pcall(cfg.Callback) end
    end)
    return btn
end

function Library:MakeToggle(parent, cfg)
    local state = cfg.Default or false
    local flag = cfg.Flag

    local f = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = COLORS.BgElement,
        BorderSizePixel = 0,
    }, parent)
    corner(f, 8)

    local lbl = newInstance("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = cfg.Text or "Toggle",
        TextColor3 = COLORS.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)

    local switch = newInstance("Frame", {
        Size = UDim2.new(0, 44, 0, 22),
        Position = UDim2.new(1, -56, 0.5, -11),
        BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff,
        BorderSizePixel = 0,
    }, f)
    corner(switch, 11)

    local knob = newInstance("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        BackgroundColor3 = COLORS.Text,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, switch)
    corner(knob, 9)

    local btn = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    }, f)

    local function setState(v)
        state = v
        tween(switch, 0.2, {BackgroundColor3 = v and COLORS.ToggleOn or COLORS.ToggleOff})
        tween(knob, 0.2, {Position = v and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
        if flag then self.Flags[flag] = v end
        if cfg.Callback then pcall(cfg.Callback, v) end
    end

    btn.MouseButton1Click:Connect(function()
        playClick()
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

    local f = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = COLORS.BgElement,
        BorderSizePixel = 0,
    }, parent)
    corner(f, 8)

    local lbl = newInstance("TextLabel", {
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 12, 0, 4),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = cfg.Text or "Slider",
        TextColor3 = COLORS.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)

    local valLbl = newInstance("TextLabel", {
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -70, 0, 4),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = tostring(val),
        TextColor3 = COLORS.Accent2,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, f)

    local track = newInstance("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 32),
        BackgroundColor3 = COLORS.BgDark,
        BorderSizePixel = 0,
    }, f)
    corner(track, 3)

    local fill = newInstance("Frame", {
        Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
    }, track)
    corner(fill, 3)
    gradient(fill, COLORS.Accent, COLORS.Accent2, 0)

    local knob = newInstance("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((val - min) / (max - min), -7, 0.5, -7),
        BackgroundColor3 = COLORS.Text,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, track)
    corner(knob, 7)
    stroke(knob, COLORS.Accent2, 1.5, 0)

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

    track.InputBegan:Connect(function(input)
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
    return {Set = function(v) val = v; update({Position = Vector3.new(track.AbsolutePosition.X + track.AbsoluteSize.X * ((v - min) / (max - min)), 0, 0)}) end, Get = function() return val end}
end

function Library:MakeInput(parent, cfg)
    local f = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = COLORS.BgElement,
        BorderSizePixel = 0,
    }, parent)
    corner(f, 8)

    local box = newInstance("TextBox", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = cfg.Default or "",
        PlaceholderText = cfg.Placeholder or "Nhập...",
        PlaceholderColor3 = COLORS.TextDim,
        TextColor3 = COLORS.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, f)

    box.Focused:Connect(function()
        tween(f, 0.15, {BackgroundColor3 = COLORS.BgHover})
    end)
    box.FocusLost:Connect(function()
        tween(f, 0.15, {BackgroundColor3 = COLORS.BgElement})
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

    local f = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = COLORS.BgElement,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, parent)
    corner(f, 8)

    local header = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Text = "",
    }, f)

    local lbl = newInstance("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = cfg.Text or "Dropdown",
        TextColor3 = COLORS.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)

    local valLbl = newInstance("TextLabel", {
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -150, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = multi and (#selected > 0 and table.concat(selected, ", ") or "Chọn...") or tostring(selected),
        TextColor3 = COLORS.Accent2,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, f)

    local arrow = newInstance("TextLabel", {
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "▼",
        TextColor3 = COLORS.Accent2,
        TextSize = 10,
    }, f)

    local list = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = COLORS.BgDark,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, f)

    local listLayout = newInstance("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)

    local function refreshVal()
        if multi then
            valLbl.Text = #selected > 0 and table.concat(selected, ", ") or "Chọn..."
        else
            valLbl.Text = tostring(selected)
        end
        if flag then self.Flags[flag] = selected end
    end

    local itemButtons = {}
    for i, opt in ipairs(options) do
        local ib = newInstance("TextButton", {
            Size = UDim2.new(1, -8, 0, 26),
            Position = UDim2.new(0, 4, 0, 4 + (i - 1) * 28),
            BackgroundColor3 = COLORS.BgElement,
            BorderSizePixel = 0,
            Font = Enum.Font.Gotham,
            Text = tostring(opt),
            TextColor3 = COLORS.Text,
            TextSize = 12,
            AutoButtonColor = false,
        }, list)
        corner(ib, 6)
        table.insert(itemButtons, ib)

        ib.MouseEnter:Connect(function() tween(ib, 0.12, {BackgroundColor3 = COLORS.BgHover}) end)
        ib.MouseLeave:Connect(function() tween(ib, 0.12, {BackgroundColor3 = COLORS.BgElement}) end)
        ib.MouseButton1Click:Connect(function()
            playClick()
            if multi then
                local found = false
                for k, v in ipairs(selected) do
                    if v == opt then table.remove(selected, k); found = true; break end
                end
                if not found then table.insert(selected, opt) end
            else
                selected = opt
                open = false
                tween(f, 0.25, {Size = UDim2.new(1, 0, 0, 36)})
                tween(arrow, 0.2, {Rotation = 0})
                tween(list, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
            end
            refreshVal()
            if cfg.Callback then pcall(cfg.Callback, selected) end
        end)
    end

    list.Size = UDim2.new(1, 0, 0, #options * 28 + 8)

    header.MouseButton1Click:Connect(function()
        playClick()
        open = not open
        if open then
            local h = #options * 28 + 8
            tween(f, 0.25, {Size = UDim2.new(1, 0, 0, 36 + h)})
            tween(list, 0.25, {Size = UDim2.new(1, 0, 0, h)})
            tween(arrow, 0.2, {Rotation = 180})
        else
            tween(f, 0.25, {Size = UDim2.new(1, 0, 0, 36)})
            tween(list, 0.25, {Size = UDim2.new(1, 0, 0, 0)})
            tween(arrow, 0.2, {Rotation = 0})
        end
    end)

    refreshVal()
    return {Set = function(v) selected = v; refreshVal() end, Get = function() return selected end}
end

return Library
