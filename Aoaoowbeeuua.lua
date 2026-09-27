local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local Toggles = Library.Toggles
local Options = Library.Options

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local VU = game:GetService("VirtualUser")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local FISH_GUI = "Rod"
local REEL_GUI = "ReelCounterGui"
local ISLANDS = {"desert","fossil","jungle","snow","starter","volcano"}
local SKILLS = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}

local W = Library:CreateWindow({Title="FM-DNHUB",Footer="Obsidian UI",Icon=6687255998,NotifySide="Right",ShowCustomCursor=true,AutoShow=true})
local Main = W:AddTab("Main", "user")
local Tele = W:AddTab("Teleport", "map-pin")
local Plr = W:AddTab("Player", "user")
local MG = Main:AddGroupbox({Side="Left",Name="Auto",IconName="boxes"})
local SG = Main:AddGroupbox({Side="Right",Name="Sell",IconName="dollar-sign"})
local TG = Tele:AddGroupbox({Side="Left",Name="Teleport",IconName="map-pin"})
local PG2 = Plr:AddGroupbox({Side="Left",Name="Player",IconName="user"})

local st = {fish=false,bypass=false,skill=false,sell=false,speed=false,hname=false}
local island = "snow"
local sellInt = 300
local plat = nil
local uiSince = {L=nil,R=nil,U=nil}

LP.Idled:Connect(function() pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end)
task.spawn(function()
    while true do pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) task.wait(30) end
end)

local pkt = RS:WaitForChild("Stardust"):WaitForChild("Packages"):WaitForChild("Packet"):WaitForChild("RemoteEvent")
local cnt = 0
local synced = false

pcall(function()
    local mt = getrawmetatable(pkt)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        if self == pkt and getnamecallmethod() == "FireServer" then
            for _, v in ipairs({...}) do
                if typeof(v) == "buffer" and buffer.len(v) >= 2 then cnt = buffer.readu8(v, 1) synced = true end
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

local function sendPkt(op, pl)
    cnt = (cnt + 1) % 256
    local len = 2 + (pl and #pl or 0)
    local b = buffer.create(len)
    buffer.writeu8(b, 0, string.byte(op))
    buffer.writeu8(b, 1, cnt)
    if pl then for i = 1, #pl do buffer.writeu8(b, 1 + i, pl[i]) end end
    pcall(function() pkt:FireServer(b) end)
end

local function createPlat()
    pcall(function()
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        if plat and plat.Parent then plat:Destroy() end
        local p = Instance.new("Part")
        p.Name = "FishPlat"
        p.Size = Vector3.new(15, 1, 15)
        p.Position = h.Position - Vector3.new(0, 3.5, 0)
        p.Anchored = true
        p.CanCollide = true
        p.Transparency = 1
        p.CanQuery = false
        p.CanTouch = false
        p.Parent = workspace
        plat = p
        h.CFrame = CFrame.new(p.Position + Vector3.new(0, 3.5, 0)) * (h.CFrame - h.CFrame.Position)
    end)
end

local function removePlat()
    pcall(function() if plat and plat.Parent then plat:Destroy() end plat = nil end)
end

local function hasBtn()
    local f = false
    pcall(function()
        for _, g in ipairs(PG:GetChildren()) do
            if g:IsA("ScreenGui") and g.Enabled and g.Name == FISH_GUI then
                for _, d in ipairs(g:GetDescendants()) do
                    if d.Name == "FishingActionButton" and d:IsA("ImageButton") and d.Visible then f = true end
                end
            end
        end
    end)
    return f
end

local function clickHold(d)
    pcall(function()
        local vp = workspace.CurrentCamera.ViewportSize
        VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, true, game, 0)
        task.wait(d or 0.7)
        VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, false, game, 0)
    end)
end

local function clickQuick()
    pcall(function()
        local vp = workspace.CurrentCamera.ViewportSize
        VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, true, game, 0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, false, game, 0)
    end)
end

local function sendKey(k)
    pcall(function()
        VIM:SendKeyEvent(true, k, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, k, false, game)
    end)
end

local function vis(i)
    if not i.Visible or i.AbsoluteSize.X <= 0 or i.AbsoluteSize.Y <= 0 then return false end
    local p = i.Parent
    while p and p ~= game do
        if p:IsA("ScreenGui") and not p.Enabled then return false end
        if p:IsA("GuiObject") and (not p.Visible or p.AbsoluteSize.X <= 0 or p.AbsoluteSize.Y <= 0) then return false end
        if p:IsA("CanvasGroup") and p.GroupTransparency >= 1 then return false end
        p = p.Parent
    end
    return true
end

local function scanMini()
    local tg
    for _, g in ipairs(PG:GetChildren()) do if g:IsA("ScreenGui") and g.Name == REEL_GUI then tg = g break end end
    if not tg then return end
    local f = {L=false,R=false,U=false}
    pcall(function()
        for _, d in ipairs(tg:GetDescendants()) do
            if d:IsA("GuiObject") and vis(d) then
                if d.Name == "Left" then f.L = true
                elseif d.Name == "Right" then f.R = true
                elseif d.Name == "Up" then f.U = true end
            end
        end
    end)
    local n = tick()
    if f.L then if not uiSince.L then uiSince.L = n end if n - uiSince.L >= 0.2 then sendKey(Enum.KeyCode.A) uiSince.L = nil end else uiSince.L = nil end
    if f.R then if not uiSince.R then uiSince.R = n end if n - uiSince.R >= 0.2 then sendKey(Enum.KeyCode.D) uiSince.R = nil end else uiSince.R = nil end
    if f.U then if not uiSince.U then uiSince.U = n end if n - uiSince.U >= 0.2 then sendKey(Enum.KeyCode.W) uiSince.U = nil end else uiSince.U = nil end
end

local function startBypass()
    task.spawn(function() while st.bypass do scanMini() task.wait(0.05) end end)
end

local function teleTo(cf)
    pcall(function()
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        h.CFrame = cf
        h.AssemblyLinearVelocity = Vector3.zero
        h.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function resetC()
    pcall(function()
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
    end)
end

local skillT
local function startSkill()
    if skillT then task.cancel(skillT); skillT = nil end
    skillT = task.spawn(function()
        while st.fish and st.skill do
            for _, k in ipairs(SKILLS) do
                if not (st.fish and st.skill) then break end
                sendKey(k)
            end
            task.wait(0.2)
        end
        skillT = nil
    end)
end

-- FISHING LOGIC MỚI
local function startFish()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 0
        LP.Character.Humanoid.JumpPower = 0
        resetC()
    end
    createPlat()

    task.spawn(function()
        while st.fish do
            pcall(function()
                local c = LP.Character
                if c and plat and plat.Parent then
                    local h = c:FindFirstChild("HumanoidRootPart")
                    if h then plat.Position = Vector3.new(h.Position.X, plat.Position.Y, h.Position.Z) end
                end
            end)
            task.wait(0.5)
        end
    end)

    task.spawn(function()
        while st.fish do
            -- Bước 1: Đợi gui câu hiện
            while not hasBtn() and st.fish do task.wait(0.05) end
            if not st.fish then break end

            -- Bước 2: Đợi 0.3s rồi nhấn giữ 0.7s
            task.wait(0.3)
            clickHold(0.7)

            -- Bước 3: Đợi gui câu hiện lại
            while not hasBtn() and st.fish do task.wait(0.05) end
            if not st.fish then break end

            -- Bước 4: Đợi 0.3s rồi nhấn 1 cái
            task.wait(0.3)
            clickQuick()

            -- Bước 5: Đợi gui câu ẩn
            while hasBtn() and st.fish do task.wait(0.05) end
            if not st.fish then break end

            -- Bước 6: Đợi 1s rồi nhấn 1 cái
            task.wait(1)
            clickQuick()
        end
    end)

    if st.skill then startSkill() end
end

local function stopFish()
    removePlat()
    pcall(function()
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = st.speed and 40 or 16 h.JumpPower = 50 end
    end)
end

local function findNPC()
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local mp = c.HumanoidRootPart.Position
    local best, bd = nil, math.huge
    for _, o in ipairs(workspace:GetDescendants()) do
        local n = string.lower(o.Name)
        if string.find(n, "seller") or string.find(n, "fish_seller") or string.find(n, "fishseller") then
            local p
            if o:IsA("Model") then p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
            elseif o:IsA("BasePart") then p = o end
            if p then
                local d = (mp - p.Position).Magnitude
                if d < bd then bd = d best = p end
            end
        end
    end
    return best
end

local function doSell()
    Library:Notify({Title="Sell",Description="Đang sync...",Time=2})
    local s = tick()
    while not synced and tick() - s < 1 do task.wait(0.05) end

    local wasFish = st.fish
    if wasFish then st.fish = false removePlat() task.wait(0.3) end

    pcall(function()
        local c = LP.Character
        if c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then t.Parent = LP:FindFirstChild("Backpack") end end end
    end)

    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then
        if wasFish then st.fish = true; startFish() end
        return false
    end
    local oldCF = c.HumanoidRootPart.CFrame

    local npc = findNPC()
    if not npc then
        Library:Notify({Title="Sell",Description="Không tìm thấy NPC",Time=3})
        if wasFish then st.fish = true; startFish() end
        return false
    end

    teleTo(CFrame.new(npc.Position + Vector3.new(0, 3, 5)))

    for i = 1, 5 do sendPkt("Z") task.wait(0.1) end
    task.wait(0.2)
    sendPkt("d")
    task.wait(0.2)
    sendPkt("d")
    task.wait(0.2)
    sendPkt("a", {0x01})

    task.wait(0.3)
    teleTo(oldCF)
    resetC()
    task.wait(0.3)

    if wasFish then st.fish = true; startFish() end
    Library:Notify({Title="Sell",Description="Đã sell xong!",Time=2})
    return true
end

local function startSell()
    task.spawn(function()
        while st.sell do
            for i = sellInt, 1, -1 do if not st.sell then break end task.wait(1) end
            if not st.sell then break end
            doSell()
            task.wait(1)
        end
    end)
end

local function findIsland(n)
    local t = "island_" .. n
    for _, o in ipairs(workspace:GetDescendants()) do if string.lower(o.Name) == t then return o end end
end

local function findSpawn(i)
    if not i then return nil end
    for _, d in ipairs(i:GetDescendants()) do if d:IsA("SpawnLocation") then return d end end
    for _, d in ipairs(i:GetDescendants()) do if d:IsA("BasePart") and string.find(string.lower(d.Name), "spawn") then return d end end
    if i:IsA("Model") and i.PrimaryPart then return i.PrimaryPart end
    for _, d in ipairs(i:GetChildren()) do if d:IsA("BasePart") then return d end end
end

local function teleIsland(n)
    local i = findIsland(n)
    if not i then Library:Notify({Title="Teleport",Description="Không tìm thấy island_"..n,Time=3}) return end
    local sp = findSpawn(i)
    if not sp then Library:Notify({Title="Teleport",Description="Không có spawn",Time=3}) return end
    teleTo(CFrame.new(sp.Position + Vector3.new(0, 5, 0)))
    resetC()
    Library:Notify({Title="Teleport",Description="Đã tới island_"..n,Time=2})
end

local hnR = false
local hnC = {}

local function applyHN()
    pcall(function()
        local n = LP.Name
        local function sc(c)
            for _, o in ipairs(c:GetDescendants()) do
                if o:IsA("TextLabel") and (o.Text == n or o.Text == "@" .. n) then
                    if not hnC[o] then hnC[o] = {t=o.Text, v=o.Visible, tr=o.TextTransparency} end
                    if st.hname then o.Text = "" o.Visible = false o.TextTransparency = 1
                    else o.Text = hnC[o].t o.Visible = hnC[o].v o.TextTransparency = hnC[o].tr end
                end
            end
        end
        sc(workspace)
        for _, g in ipairs(PG:GetChildren()) do if g:IsA("ScreenGui") then sc(g) end end
    end)
end

local function startHN()
    if hnR then return end
    hnR = true
    task.spawn(function() while st.hname do applyHN() task.wait(0.3) end hnR = false end)
end

local function restoreHN()
    for o, d in pairs(hnC) do pcall(function() if o and o.Parent then o.Text = d.t o.Visible = d.v o.TextTransparency = d.tr end end) end
    hnC = {}
end

MG:AddToggle("Fish", {Text="Auto Fishing", Default=false, Callback=function(v) st.fish=v if v then startFish() else stopFish() end end})
MG:AddToggle("Skill", {Text="Auto Skill", Default=false, Callback=function(v) st.skill=v if v and st.fish then startSkill() end end})
MG:AddToggle("Bypass", {Text="Bypass Minigame", Default=false, Callback=function(v) st.bypass=v if v then startBypass() end end})

SG:AddToggle("Sell", {Text="Auto Sell", Default=false, Callback=function(v) st.sell=v if v then startSell() end end})
SG:AddSlider("SellInt", {Text="Thời gian (giây)", Default=300, Min=30, Max=3600, Rounding=0, Compact=false, Callback=function(v) sellInt=v end})
SG:AddButton("SellNow", {Text="SELL NOW", Func=function() task.spawn(doSell) end})

TG:AddDropdown("Island", {Text="Chọn đảo", Values=ISLANDS, Default=1, Multi=false, Callback=function(v) island=v end})
TG:AddButton("Tele", {Text="TELEPORT", Func=function() teleIsland(island) end})

PG2:AddToggle("Speed", {Text="Speed (40)", Default=false, Callback=function(v) st.speed=v if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = v and 40 or 16 end end})
PG2:AddToggle("HName", {Text="Hide Name", Default=false, Callback=function(v) st.hname=v if v then startHN() else restoreHN() end end})
PG2:AddButton("Kill", {Text="Kill Menu (Unload)", Func=function()
    st.fish=false st.bypass=false st.skill=false st.sell=false st.speed=false st.hname=false
    removePlat()
    if skillT then task.cancel(skillT); skillT=nil end
    restoreHN()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed=16 LP.Character.Humanoid.JumpPower=50
    end
    Library:Unload()
end})

LP.CharacterAdded:Connect(function(c)
    c:WaitForChild("Humanoid")
    task.wait(0.5)
    if st.speed then c.Humanoid.WalkSpeed=40 end
    if st.fish then startFish() end
end)

Library:Notify({Title="FM-DNHUB",Description="Đã load thành công!",Time=5})
