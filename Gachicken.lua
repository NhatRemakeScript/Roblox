local Players=game:GetService("Players")
local Player=Players.LocalPlayer
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local RS=game:GetService("ReplicatedStorage")
local VU=game:GetService("VirtualUser")
local SG=Instance.new("ScreenGui")
SG.Name="Menu"
SG.Parent=Player:WaitForChild("PlayerGui")

local rainbow=false
local rainbowHue=0

local function C(o,r)local c=Instance.new("UICorner")c.CornerRadius=UDim.new(0,r)c.Parent=o end
local function S(o,c,t)local s=Instance.new("UIStroke")s.Color=c s.Thickness=t s.Parent=o end

local MF=Instance.new("Frame")
MF.Size=UDim2.new(0,380,0,320)
MF.Position=UDim2.new(0.5,-190,0.5,-160)
MF.BackgroundColor3=Color3.fromRGB(20,20,25)
MF.Visible=false
MF.Parent=SG
C(MF,12)
local mainStroke=S(MF,Color3.fromRGB(255,0,0),1.5)

local function rainbowLoop()
    while true do
        rainbowHue=(rainbowHue+0.01)%1
        local col=Color3.fromHSV(rainbowHue,1,1)
        mainStroke.Color=col
        wait(0.05)
    end
end
spawn(rainbowLoop)

local TB=Instance.new("Frame")
TB.Size=UDim2.new(1,0,0,35)
TB.BackgroundColor3=Color3.fromRGB(30,30,38)
TB.Parent=MF
C(TB,12)
local TT=Instance.new("TextLabel")
TT.Size=UDim2.new(1,-60,1,0)
TT.Position=UDim2.new(0,15,0,0)
TT.BackgroundTransparency=1
TT.Text="⚡ Auto Farm"
TT.TextColor3=Color3.fromRGB(255,255,255)
TT.TextSize=16
TT.Font=Enum.Font.GothamBold
TT.TextXAlignment=Enum.TextXAlignment.Left
TT.TextYAlignment=Enum.TextYAlignment.Center
TT.Parent=TB
local CB=Instance.new("TextButton")
CB.Size=UDim2.new(0,25,0,25)
CB.Position=UDim2.new(1,-35,0.5,-12.5)
CB.BackgroundColor3=Color3.fromRGB(50,50,60)
CB.Text="−"
CB.TextColor3=Color3.fromRGB(255,255,255)
CB.TextSize=18
CB.Font=Enum.Font.GothamBold
CB.Parent=TB
C(CB,25)
local TC=Instance.new("Frame")
TC.Size=UDim2.new(1,0,0,30)
TC.Position=UDim2.new(0,0,0,35)
TC.BackgroundTransparency=1
TC.Parent=MF
local TMain=Instance.new("TextButton")
TMain.Size=UDim2.new(0,100,0,25)
TMain.Position=UDim2.new(0.5,-110,0.5,-12.5)
TMain.BackgroundColor3=Color3.fromRGB(60,60,80)
TMain.Text="Main"
TMain.TextColor3=Color3.fromRGB(255,255,255)
TMain.TextSize=13
TMain.Font=Enum.Font.GothamMedium
TMain.Parent=TC
C(TMain,6)
local TMisc=Instance.new("TextButton")
TMisc.Size=UDim2.new(0,100,0,25)
TMisc.Position=UDim2.new(0.5,10,0.5,-12.5)
TMisc.BackgroundColor3=Color3.fromRGB(40,40,48)
TMisc.Text="Stats"
TMisc.TextColor3=Color3.fromRGB(200,200,200)
TMisc.TextSize=13
TMisc.Font=Enum.Font.GothamMedium
TMisc.Parent=TC
C(TMisc,6)

local CP=Instance.new("ScrollingFrame")
CP.Size=UDim2.new(1,-10,1,-75)
CP.Position=UDim2.new(0,5,0,70)
CP.BackgroundTransparency=1
CP.BorderSizePixel=0
CP.ScrollBarThickness=4
CP.ScrollBarImageColor3=Color3.fromRGB(0,200,255)
CP.CanvasSize=UDim2.new(0,0,0,0)
CP.Parent=MF
local CL=Instance.new("UIListLayout")
CL.FillDirection=Enum.FillDirection.Vertical
CL.Padding=UDim.new(0,8)
CL.SortOrder=Enum.SortOrder.LayoutOrder
CL.Parent=CP

local function CreateToggle(parent,text,def,cb)
local fr=Instance.new("Frame")
fr.Size=UDim2.new(1,0,0,35)
fr.BackgroundColor3=Color3.fromRGB(30,30,38)
fr.Parent=parent
C(fr,8)
S(fr,Color3.fromRGB(50,50,60),1)
local lb=Instance.new("TextLabel")
lb.Size=UDim2.new(1,-70,1,0)
lb.Position=UDim2.new(0,12,0,0)
lb.BackgroundTransparency=1
lb.Text=text
lb.TextColor3=Color3.fromRGB(220,220,220)
lb.TextSize=14
lb.Font=Enum.Font.GothamMedium
lb.TextXAlignment=Enum.TextXAlignment.Left
lb.TextYAlignment=Enum.TextYAlignment.Center
lb.Parent=fr
local sw=Instance.new("Frame")
sw.Size=UDim2.new(0,40,0,22)
sw.Position=UDim2.new(1,-52,0.5,-11)
sw.BackgroundColor3=def and Color3.fromRGB(255,215,0)or Color3.fromRGB(60,60,70)
sw.Parent=fr
C(sw,22)
local knob=Instance.new("Frame")
knob.Size=UDim2.new(0,18,0,18)
knob.Position=def and UDim2.new(0,19,0.5,-9)or UDim2.new(0,2,0.5,-9)
knob.AnchorPoint=Vector2.new(0.5,0.5)
knob.BackgroundColor3=Color3.fromRGB(255,255,255)
knob.Parent=sw
C(knob,4)
local state=def or false
local function setState(ns)
state=ns
local targetPos=state and UDim2.new(0,19,0.5,-9)or UDim2.new(0,2,0.5,-9)
local targetCol=state and Color3.fromRGB(255,215,0)or Color3.fromRGB(60,60,70)
local targetRot=state and 45 or 0
TS:Create(sw,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{BackgroundColor3=targetCol}):Play()
TS:Create(knob,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{Position=targetPos,Rotation=targetRot}):Play()
if cb then cb(state)end
end
local click=Instance.new("TextButton")
click.Size=UDim2.new(1,0,1,0)
click.BackgroundTransparency=1
click.Text=""
click.Parent=fr
click.MouseButton1Click:Connect(function()setState(not state)end)
return fr,setState
end

local mainTab=Instance.new("Frame")
mainTab.Name="MainTab"
mainTab.Size=UDim2.new(1,0,0,0)
mainTab.BackgroundTransparency=1
mainTab.AutomaticSize=Enum.AutomaticSize.Y
mainTab.Parent=CP
local mainLayout=Instance.new("UIListLayout")
mainLayout.FillDirection=Enum.FillDirection.Vertical
mainLayout.Padding=UDim.new(0,8)
mainLayout.SortOrder=Enum.SortOrder.LayoutOrder
mainLayout.Parent=mainTab
local miscTab=Instance.new("Frame")
miscTab.Name="MiscTab"
miscTab.Size=UDim2.new(1,0,0,0)
miscTab.BackgroundTransparency=1
miscTab.AutomaticSize=Enum.AutomaticSize.Y
miscTab.Visible=false
miscTab.Parent=CP
local miscLayout=Instance.new("UIListLayout")
miscLayout.FillDirection=Enum.FillDirection.Vertical
miscLayout.Padding=UDim.new(0,8)
miscLayout.SortOrder=Enum.SortOrder.LayoutOrder
miscLayout.Parent=miscTab

spawn(function()
    while wait(60) do
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end)

local function randDelay(min, max)
    return math.random(min*100, max*100) / 100
end

local reb=false
CreateToggle(mainTab,"👼 Auto Rebirth",false,function(s)
reb=s
spawn(function()
    while reb do
        pcall(function() RS.Remotes.Rebirth:InvokeServer() end)
        wait(randDelay(1.8, 2.5))
    end
end)
end)

local feeder=false
CreateToggle(mainTab,"🌾 Auto Feeder",false,function(s)
feeder=s
spawn(function()
    local a=1
    while feeder do
        pcall(function()
            RS.Remotes.BuyGenerator:InvokeServer(a)
            RS.Remotes.UpgradeGenerator:InvokeServer(a)
        end)
        a=(a==1)and 2 or 1
        wait(randDelay(1.8, 2.5))
    end
end)
end)

local ne=false
local currentTarget=nil
local isWalking=false
local function moveToPosition(targetPos)
    local char=Player.Character
    if not char then return false end
    local root=char:FindFirstChild("HumanoidRootPart")
    local humanoid=char:FindFirstChild("Humanoid")
    if not root or not humanoid then return false end
    local distance=(root.Position - targetPos).Magnitude
    if distance < 5 then
        humanoid:MoveTo(root.Position)
        return true
    end
    humanoid:MoveTo(targetPos)
    isWalking=true
    local startTime=tick()
    while isWalking and tick()-startTime<15 do
        local newDist=(root.Position - targetPos).Magnitude
        if newDist < 5 then
            isWalking=false
            return true
        end
        if humanoid.MoveDirection.Magnitude<0.5 and newDist>10 then
            break
        end
        wait(0.5)
    end
    isWalking=false
    return false
end
CreateToggle(mainTab,"🥚 Collect Egg",false,function(s)
ne=s
if s then
spawn(function()
    while ne do
        pcall(function()
            local char=Player.Character
            if not char then wait(1) return end
            local root=char:FindFirstChild("HumanoidRootPart")
            local humanoid=char:FindFirstChild("Humanoid")
            if not root or not humanoid then wait(1) return end
            local egg=nil
            for _,v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name:find("NestEgg") then
                    local ow=v:FindFirstChild("owner") or v:FindFirstChild("Owner") or v:FindFirstChild("OwnerName")
                    if ow and ow.Value==Player.Name then
                        egg=v
                        break
                    end
                end
            end
            if egg then
                local pos=egg:FindFirstChild("HumanoidRootPart") or egg:FindFirstChild("PrimaryPart") or egg:FindFirstChildWhichIsA("BasePart")
                if pos then
                    local targetPos=pos.Position+Vector3.new(0,2,0)
                    local distance=(root.Position-targetPos).Magnitude
                    if distance>5 then
                        moveToPosition(targetPos)
                    end
                end
            end
        end)
        wait(randDelay(2.5, 3.5))
    end
end)
end
end)

local autoTower=false
local pauseTowerStart=false
CreateToggle(mainTab,"🗼 Auto Tower",false,function(s)
autoTower=s
if s then
spawn(function()
    while autoTower do
        if not pauseTowerStart then
            pcall(function() RS.Remotes.TowerStart:InvokeServer() end)
        end
        wait(randDelay(27.5, 29.7))
    end
end)
end
end)

local function findRebirthReady()
    for _, gui in ipairs(Player:WaitForChild("PlayerGui"):GetDescendants())do
        if gui:IsA("TextLabel")or gui:IsA("TextButton")then
            if gui.Text and gui.Text:upper():find("REBIRTH READY!")then
                return true
            end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants())do
        if obj:IsA("BillboardGui")or obj:IsA("SurfaceGui")then
            for _, child in ipairs(obj:GetDescendants())do
                if(child:IsA("TextLabel")or child:IsA("TextButton"))and child.Text then
                    if child.Text:upper():find("REBIRTH READY!")then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local towerReady=false
CreateToggle(mainTab,"⚡ Tower Ready",false,function(s)
towerReady=s
if s then
spawn(function()
    while towerReady do
        local currentReady=findRebirthReady()
        if currentReady then
            pauseTowerStart=true
            pcall(function() RS.Remotes.TowerSurrender:InvokeServer() end)
            wait(10)
            pauseTowerStart=false
            wait(3)
        end
        wait(0.8)
    end
end)
end
end)

local statsFrame=Instance.new("Frame")
statsFrame.Size=UDim2.new(1,-10,0,120)
statsFrame.Position=UDim2.new(0,5,0,5)
statsFrame.BackgroundColor3=Color3.fromRGB(30,30,38)
statsFrame.Parent=miscTab
C(statsFrame,8)
S(statsFrame,Color3.fromRGB(50,50,60),1)

local statsLabel=Instance.new("TextLabel")
statsLabel.Size=UDim2.new(1,-10,1,-10)
statsLabel.Position=UDim2.new(0,5,0,5)
statsLabel.BackgroundTransparency=1
statsLabel.Text="Loading..."
statsLabel.TextColor3=Color3.fromRGB(220,220,220)
statsLabel.TextSize=13
statsLabel.Font=Enum.Font.GothamMedium
statsLabel.TextWrapped=true
statsLabel.TextXAlignment=Enum.TextXAlignment.Left
statsLabel.TextYAlignment=Enum.TextYAlignment.Top
statsLabel.Parent=statsFrame

local function updateStats()
    local ls=Player:FindFirstChild("leaderstats")
    if not ls then
        statsLabel.Text="No leaderstats"
        return
    end
    local corn=ls:FindFirstChild("Corn") or ls:FindFirstChild("Corn Farm")
    local tower=ls:FindFirstChild("Tower")
    local money=ls:FindFirstChild("Money") or ls:FindFirstChild("Cash")
    local text=""
    if corn then text=text.."🌽 Corn Farm: "..corn.Value.."/s\n" end
    if tower then text=text.."🗼 Current Tower: "..tower.Value.."\n" end
    if money then text=text.."💰 Money: "..money.Value.."\n" end
    if text=="" then
        for _,s in ipairs(ls:GetChildren())do
            text=text..s.Name..": "..tostring(s.Value).."\n"
        end
    end
    statsLabel.Text=text
end
spawn(function()while true do updateStats()wait(1)end end)

local function calcCanvas()
local h=0
for _,ch in ipairs(CP:GetChildren())do
if ch:IsA("Frame")and ch.Visible then h=h+ch.AbsoluteSize.Y+8 end
end
CP.CanvasSize=UDim2.new(0,0,0,math.max(h,0))
end
local function switchTab(tn)
if tn=="Main"then
mainTab.Visible=true
miscTab.Visible=false
TMain.BackgroundColor3=Color3.fromRGB(60,60,80)
TMain.TextColor3=Color3.fromRGB(255,255,255)
TMisc.BackgroundColor3=Color3.fromRGB(40,40,48)
TMisc.TextColor3=Color3.fromRGB(200,200,200)
else
mainTab.Visible=false
miscTab.Visible=true
TMisc.BackgroundColor3=Color3.fromRGB(60,60,80)
TMisc.TextColor3=Color3.fromRGB(255,255,255)
TMain.BackgroundColor3=Color3.fromRGB(40,40,48)
TMain.TextColor3=Color3.fromRGB(200,200,200)
end
CP.CanvasPosition=Vector2.new(0,0)
task.wait(0.05)
calcCanvas()
end
TMain.MouseButton1Click:Connect(function()switchTab("Main")end)
TMisc.MouseButton1Click:Connect(function()switchTab("Stats")end)
local function onToggleAdded()task.wait(0.05)calcCanvas()end
mainTab.ChildAdded:Connect(onToggleAdded)
miscTab.ChildAdded:Connect(onToggleAdded)
switchTab("Main")

local bubble=Instance.new("ImageButton")
bubble.Size=UDim2.new(0,50,0,50)
bubble.Position=UDim2.new(0,15,0.5,-25)
bubble.BackgroundColor3=Color3.fromRGB(20,20,25)
bubble.Image="rbxassetid://1316385681"
bubble.ImageColor3=Color3.fromRGB(0,200,255)
bubble.ImageTransparency=0.3
bubble.Parent=SG
C(bubble,50)
S(bubble,Color3.fromRGB(0,200,255),2)
local bl=Instance.new("TextLabel")
bl.Size=UDim2.new(1,0,1,0)
bl.BackgroundTransparency=1
bl.Text="⚡"
bl.TextColor3=Color3.fromRGB(255,255,255)
bl.TextSize=20
bl.Font=Enum.Font.GothamBold
bl.TextScaled=true
bl.Parent=bubble
local open=false
bubble.MouseButton1Click:Connect(function()open=not open MF.Visible=open end)
local drag={active=false,offset=Vector2.new(0,0)}
TB.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 then
drag.active=true
drag.offset=Vector2.new(i.Position.X-MF.AbsolutePosition.X,i.Position.Y-MF.AbsolutePosition.Y)
end
end)
UIS.InputChanged:Connect(function(i)
if drag.active and i.UserInputType==Enum.UserInputType.MouseMovement then
local nx=math.clamp(i.Position.X-drag.offset.X,0,SG.AbsoluteSize.X-MF.AbsoluteSize.X)
local ny=math.clamp(i.Position.Y-drag.offset.Y,0,SG.AbsoluteSize.Y-MF.AbsoluteSize.Y)
MF.Position=UDim2.new(0,nx,0,ny)
end
end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 then drag.active=false end
end)
local bdrag={active=false,offset=Vector2.new(0,0)}
bubble.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 then
bdrag.active=true
bdrag.offset=Vector2.new(i.Position.X-bubble.AbsolutePosition.X,i.Position.Y-bubble.AbsolutePosition.Y)
end
end)
UIS.InputChanged:Connect(function(i)
if bdrag.active and i.UserInputType==Enum.UserInputType.MouseMovement then
local nx=math.clamp(i.Position.X-bdrag.offset.X,0,SG.AbsoluteSize.X-bubble.AbsoluteSize.X)
local ny=math.clamp(i.Position.Y-bdrag.offset.Y,0,SG.AbsoluteSize.Y-bubble.AbsoluteSize.Y)
bubble.Position=UDim2.new(0,nx,0,ny)
end
end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 then bdrag.active=false end
end)
local min=false
CB.MouseButton1Click:Connect(function()
min=not min
if min then
CP.Visible=false
TC.Visible=false
MF.Size=UDim2.new(0,380,0,35)
CB.Text="+"
else
CP.Visible=true
TC.Visible=true
MF.Size=UDim2.new(0,380,0,320)
CB.Text="−"
task.wait(0.05)
calcCanvas()
end
end)
