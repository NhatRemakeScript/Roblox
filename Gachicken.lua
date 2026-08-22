local Players=game:GetService("Players")
local Player=Players.LocalPlayer
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local RS=game:GetService("ReplicatedStorage")
local VU=game:GetService("VirtualUser")
local SG=Instance.new("ScreenGui")
SG.Name="Menu"
SG.Parent=Player:WaitForChild("PlayerGui")
local function C(o,r)local c=Instance.new("UICorner")c.CornerRadius=UDim.new(0,r)c.Parent=o end
local function S(o,c,t)local s=Instance.new("UIStroke")s.Color=c s.Thickness=t s.Parent=o end
local MF=Instance.new("Frame")
MF.Size=UDim2.new(0,380,0,320)
MF.Position=UDim2.new(0.5,-190,0.5,-160)
MF.BackgroundColor3=Color3.fromRGB(20,20,25)
MF.Visible=false
MF.Parent=SG
C(MF,12)
S(MF,Color3.fromRGB(0,200,255),1.5)
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
TMisc.Text="Misc"
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
sw.BackgroundColor3=def and Color3.fromRGB(0,200,255)or Color3.fromRGB(60,60,70)
sw.Parent=fr
C(sw,22)
local knob=Instance.new("Frame")
knob.Size=UDim2.new(0,16,0,16)
knob.Position=def and UDim2.new(0,21,0.5,-8)or UDim2.new(0,3,0.5,-8)
knob.BackgroundColor3=Color3.fromRGB(255,255,255)
knob.Parent=sw
C(knob,16)
local state=def or false
local function setState(ns)
state=ns
local tp=state and UDim2.new(0,21,0.5,-8)or UDim2.new(0,3,0.5,-8)
local tc=state and Color3.fromRGB(0,200,255)or Color3.fromRGB(60,60,70)
TS:Create(sw,TweenInfo.new(0.2),{BackgroundColor3=tc}):Play()
TS:Create(knob,TweenInfo.new(0.2),{Position=tp}):Play()
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

-- ANTI AFK
spawn(function()
    while wait(60) do
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end)

-- Toggle cũ
local reb=false
CreateToggle(mainTab,"🔄 Auto Rebirth",false,function(s)
reb=s
spawn(function()while reb do pcall(function()RS.Remotes.Rebirth:InvokeServer()end)wait(1)end end)
end)
local bf=false
CreateToggle(mainTab,"🌾 Auto Buy Feeder",false,function(s)
bf=s
spawn(function()local a=1 while bf do pcall(function()RS.Remotes.BuyGenerator:InvokeServer(a)end)a=(a==1)and 2 or 1 wait(3)end end)
end)
local ug=false
CreateToggle(mainTab,"⚒️ Auto Upgraded",false,function(s)
ug=s
spawn(function()local a=1 while ug do pcall(function()RS.Remotes.UpgradeGenerator:InvokeServer(a)end)a=(a==1)and 2 or 1 wait(2)end end)
end)
local ne=false
CreateToggle(mainTab,"🥚 Auto NestEgg",false,function(s)
ne=s
spawn(function()while ne do pcall(function()
local ch=Player.Character if not ch then wait(1)return end
local rp=ch:FindFirstChild("HumanoidRootPart")if not rp then wait(1)return end
local egg=nil
for _,v in pairs(workspace:GetDescendants())do
if v:IsA("Model")and v.Name:find("NestEgg")then
local ow=v:FindFirstChild("Owner")or v:FindFirstChild("OwnerName")
if ow and ow.Value==Player.Name then egg=v break end
end
end
if egg then
local pos=egg:FindFirstChild("HumanoidRootPart")or egg:FindFirstChild("PrimaryPart")or egg:FindFirstChildWhichIsA("BasePart")
if pos then rp.CFrame=CFrame.new(pos.Position+Vector3.new(0,2,0))end
end
end)wait(2)end end)
end)

-- Biến toàn cục để tạm dừng tower start
local pauseTowerStart = false

-- Auto Tower Start (gửi mỗi 30 giây, nhưng tạm dừng nếu pauseTowerStart = true)
local autoTowerStart=false
CreateToggle(mainTab,"🗼 Auto Tower Start (30s)",false,function(s)
autoTowerStart=s
if s then
spawn(function()
while autoTowerStart do
if not pauseTowerStart then
pcall(function()RS.Remotes.TowerStart:InvokeServer()end)
else
-- Nếu đang tạm dừng, thì không gửi, nhưng vẫn chờ 30s
end
wait(30)
end
end)
end
end)

-- Auto Tower Ready (chỉ gửi khi thấy "REBIRTH READY!")
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
local autoTowerReady=false
CreateToggle(mainTab,"⏳ Auto Tower Ready (Rebirth Ready)",false,function(s)
autoTowerReady=s
if s then
spawn(function()
local lastReady=false
while autoTowerReady do
local currentReady=findRebirthReady()
if currentReady and not lastReady then
-- Tạm dừng tower start trong 10 giây
pauseTowerStart = true
pcall(function()RS.Remotes.TowerSurrender:InvokeServer()end)
wait(10)
pauseTowerStart = false
wait(3) -- chờ thêm 3 giây để ổn định
end
lastReady=currentReady
wait(0.5)
end
end)
end
end)

-- Misc Tab: Leaderstats
local sl=Instance.new("TextLabel")
sl.Size=UDim2.new(1,-10,0,150)
sl.Position=UDim2.new(0,5,0,5)
sl.BackgroundTransparency=1
sl.Text="Loading..."
sl.TextColor3=Color3.fromRGB(220,220,220)
sl.TextSize=14
sl.Font=Enum.Font.GothamMedium
sl.TextWrapped=true
sl.TextXAlignment=Enum.TextXAlignment.Left
sl.TextYAlignment=Enum.TextYAlignment.Top
sl.Parent=miscTab
local function upStats()
local ls=Player:FindFirstChild("leaderstats")
if not ls then sl.Text="No leaderstats"return end
local t=""
for _,s in ipairs(ls:GetChildren())do t=t..s.Name..": "..tostring(s.Value).."\n"end
sl.Text=t
end
spawn(function()while true do upStats()wait(1)end end)

-- Canvas và Tab Switching
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
TMisc.MouseButton1Click:Connect(function()switchTab("Misc")end)
local function onToggleAdded()task.wait(0.05)calcCanvas()end
mainTab.ChildAdded:Connect(onToggleAdded)
miscTab.ChildAdded:Connect(onToggleAdded)
switchTab("Main")

-- Bubble và kéo thả
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
