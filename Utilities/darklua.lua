if _G.primas then return warn'already loaded.'end
_G.primas=true

repeat task.wait()until game:IsLoaded()

cloneref = cloneref or function(...) return ... end

local a=cloneref(game:GetService'ReplicatedStorage')
local b=cloneref(game:GetService'UserInputService')
local c=cloneref(game:GetService'HttpService')
local d=cloneref(game:GetService'VirtualUser')
local e=cloneref(game:GetService'RunService')
local f=cloneref(game:GetService'Players')
local g=cloneref(game:GetService'Debris')
local h=cloneref(game:GetService'Stats')

local i=f.LocalPlayer

_G.config={
parry_arrucacy_division=nil,
accuracy=nil,
cooldown_protection = nil,
spam_threshold=nil,
curve_keybind=nil,
animation_fix=nil,
manual_notify=nil,
curve_notify=nil,
curve_method='',
skin_changer=nil,
manual_spam=nil,
ability_esp=nil,
auto_parry=nil,
ball_debug=nil,
no_render=nil,
auto_spam=nil,
ping_fix=nil,
no_slow=nil,
names='',
}

if not isfolder'Primas/cfg'then
makefolder'Primas/cfg'
end

local j='Primas/cfg/blade_ball.json'

local function save_cfg()
writefile(j,c:JSONEncode(_G.config))
end

local function load_cfg()
if isfile(j)then
_G.config=c:JSONDecode(readfile(j))
end
end

load_cfg()

task.spawn(function()
repeat
save_cfg()task.wait(1)
until not _G.primas
end)

local k=loadstring(game:HttpGet'https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/release.lua')()

local l=k:CreateWindow{
Title='Casa das Primas',
SubTitle='',
TabWidth=100,
Size=UDim2.fromOffset(440,315),
Acrylic=false,
Theme='Grape',
MinimizeKey=Enum.KeyCode.LeftControl
}

local m=l:AddTab{Title='Blatant',Icon='skull'}
local n=l:AddTab{Title='Player',Icon='user'}
local o=l:AddTab{Title='Visual',Icon='eye'}
local p=l:AddTab{Title='Misc',Icon='align-justify'}
local cre=l:AddTab{Title='Credits',Icon='copyright'}

local q={}

local r={}

r.ball={
properties={
aerodynamic_time=tick(),
last_warping=tick(),
lerp_radians=0,
curving=tick(),
}
}

local s

local function linear_predict(v,w,x)
return v+(w-v)*x
end

task.spawn(function()
i.Idled:connect(function()
pcall(function()
d:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
task.wait()
d:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)
end)
end)

local u={}
local v

task.spawn(function()
for w,x in getgc()do
if type(x)=="function"and islclosure(x)then
if debug.getupvalues(x)then

local y=debug.getprotos(x)
local z=debug.getupvalues(x)
local A=debug.getconstants(x)

if#y==4 and#z==24 and#A>=102 then
u[debug.getupvalue(x,16)]=debug.getconstant(x,62)
v=debug.getupvalue(x,17)

u[debug.getupvalue(x,18)]=debug.getconstant(x,64)
u[debug.getupvalue(x,19)]=debug.getconstant(x,65)
break
end
end
end
end
end)

function r.get_ball()
for w,x in workspace.Balls:GetChildren()do
if x:GetAttribute'realBall'then
return x
end
end
end

function r.get_balls()
local w={}

for x,y in workspace.Balls:GetChildren()do
if y:GetAttribute'realBall'then
table.insert(w,y)
end
end

return w
end

local w

function r.closest_player()
local x=math.huge
local y

for z,A in workspace.Alive:GetChildren()do
if tostring(A)~=tostring(i)then
if A.PrimaryPart then
local B=i:DistanceFromCharacter(A.PrimaryPart.Position)
if B<x then
x=B
y=A
end
end
end
end


w=y
return y
end

local parry_cooldown = i.PlayerGui.Hotbar.Block.UIGradient

local function is_coooldown(uigradient)
    return uigradient.Offset.Y < 0.5
end

local function cooldown_protection()
    if is_coooldown(parry_cooldown) then
        a.Remotes.AbilityButtonPress:Fire()

        return true
    end

    return false
end

local x=b.TouchEnabled and not b.MouseEnabled

function r.perfom_parry()
r.closest_player()

local y={}
local z

local A=workspace.CurrentCamera

local B=b:GetLastInputType()
local C=b:GetMouseLocation()

if B==Enum.UserInputType.MouseButton1 or(Enum.UserInputType.MouseButton2 or B==Enum.UserInputType.Keyboard)then
z={C.X,C.Y}
else
z={A.ViewportSize.X/2,A.ViewportSize.Y/2}
end

if x then
z={A.ViewportSize.X/2,A.ViewportSize.Y/2}
end

for D,E in workspace.Alive:GetChildren()do
y[tostring(E)]=A:WorldToScreenPoint(E.PrimaryPart.Position)
end

local D=_G.config.curve_method

if D=='Camera'then
return{0,A.CFrame,y,z}
end

if D=='Dot'then
local E
local F=math.huge
local G=Vector2.new(z[1],z[2])

for H,I in workspace.Alive:GetChildren()do
if I~=i.Character then
local J=I.PrimaryPart.Position
local K,L=A:WorldToScreenPoint(J)

if L then
local M=Vector2.new(K.X,K.Y)
local N=(G-M).Magnitude

if N<F then
F=N
E=I
end
end
end
end

if E then
return{0,CFrame.new(i.Character.PrimaryPart.Position,E.PrimaryPart.Position),y,z}
else
return{0,CFrame.new(i.Character.PrimaryPart.Position,w.PrimaryPart.Position),y,z}
end
end

if D=='Slow'then
local E=i.Character.PrimaryPart.Position
local F=Vector3.new(0,-1,0)
local G=CFrame.new(E,E+F)
return{0,G,y,z}
end

if D=='Backwards'then
local E=A.CFrame.LookVector*-1E4
E=Vector3.new(E.X,0,E.Z)
return{0,CFrame.new(A.CFrame.Position,A.CFrame.Position+E),y,z}
end

if D=='Random'then
return{0,CFrame.new(i.Character.PrimaryPart.Position,Vector3.new(math.random(-1E3,1000),math.random(-350,1000),math.random(-1E3,1000))),y,z}
end

return D
end

local y=false
local z=0

function r.parry()
local A=r.perfom_parry()

y=true

for B,C in u do
B:FireServer(C,v,unpack(A))
end

if z>7 then
return false
end

z+=1

task.delay(0.5,function()
if z>0 then
z-=1
end
end)
end

function r.ball_curved()
local A=r.ball.properties

local B=r.get_ball()

if not B then
return false
end

local C=B:FindFirstChild'zoomies'

if not C then
return false
end

local D=C.VectorVelocity
local E=D.Unit

local F=(i.Character.PrimaryPart.Position-B.Position).Unit
local G=F:Dot(E)

local H=D.Magnitude
local I=math.min(H/100,40)

local J=(E-D).Unit
local K=F:Dot(J)

local L=G-K
local M=(i.Character.PrimaryPart.Position-B.Position).Magnitude

local N=h.Network.ServerStatsItem['Data Ping']:GetValue()

local O=0.5-(N/1000)
local P=M/H-(N/1000)

local Q=15-math.min(M/1000,15)+I

local R=math.clamp(G,-1,1)
local S=math.rad(math.asin(R))

A.lerp_radians=linear_predict(A.lerp_radians,S,0.8)

if H>100 and P>N/10 then
Q=math.max(Q-15,15)
end

if M<Q then
return false
end

if L<O then
return true
end

if A.lerp_radians<0.018 then
A.last_warping=tick()
end

if(tick()-A.last_warping)<(P/1.5)then
return true
end

if(tick()-A.curving)<(P/1.5)then
return true
end

return G<O
end

function r.get_ball_properties(A)
local B=r.get_ball()

local C=Vector3.zero
local D=B

local E=(i.Character.PrimaryPart.Position-D.Position).Unit
local F=(i.Character.PrimaryPart.Position-B.Position).Magnitude
local G=E:Dot(C.Unit)

return{Velocity=C,Direction=E,Distance=F,Dot=G}
end

function r.players_properties(A)
r.closest_player()

if not w then
return false
end

local B=w.PrimaryPart.Velocity
local C=(i.Character.PrimaryPart.Position-w.PrimaryPart.Position).Unit
local D=(i.Character.PrimaryPart.Position-w.PrimaryPart.Position).Magnitude

return{velocity=B,direction=C,distance=D}
end

local A=0

function r.perfom_spam(B)local C=
r.ball.properties

local D=r.get_ball()

local E=r.closest_player()

if not D then
return false
end

if not E or not E.PrimaryPart then
return false
end

local F=D.AssemblyLinearVelocity
local G=F.Magnitude

local H=(i.Character.PrimaryPart.Position-D.Position).Unit
local I=H:Dot(F.Unit)

local J=E.PrimaryPart.Position
local K=i:DistanceFromCharacter(J)

local L=B.Ping+math.min(G/6,95)

if B.Entity_Properties.distance>L then
return A
end

if B.Ball_Properties.Distance>L then
return A
end

if K>L then
return A
end

local M=5-math.min(G/5,5)
local N=math.clamp(I,-1,0)*M

A=L-N

return A
end

local B={}

function qolPlayerNameVisibility()
local function createBillboardGui(C)
local D=C.Character

while(not D)or(not D.Parent)do
task.wait()
D=C.Character
end

local E=D:WaitForChild"Head"

local F=Instance.new"BillboardGui"
F.Adornee=E
F.Size=UDim2.new(0,200,0,50)
F.StudsOffset=Vector3.new(0,3,0)
F.AlwaysOnTop=true
F.Parent=E

local G=Instance.new"TextLabel"
G.Size=UDim2.new(1,0,1,0)
G.TextColor3=Color3.fromRGB(255,255,255)
G.TextSize=10
G.TextWrapped=false
G.BackgroundTransparency=1
G.TextXAlignment=Enum.TextXAlignment.Center
G.TextYAlignment=Enum.TextYAlignment.Center
G.Parent=F

B[C]=G

local H=D:FindFirstChild"Humanoid"
if H then
H.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
end

local I
I=e.Heartbeat:Connect(function()
if not(D and D.Parent)then
I:Disconnect()
F:Destroy()
B[C]=nil
return
end

if _G.config.ability_esp then
G.Visible=true
local J=C:GetAttribute"EquippedAbility"
if J then
G.Text=C.DisplayName.." ["..J.."]"
else
G.Text=C.DisplayName
end
else
G.Visible=false
end
end)
end

for C,D in f:GetPlayers()do
if D~=i then
D.CharacterAdded:Connect(function()
createBillboardGui(D)
end)
createBillboardGui(D)
end
end

f.PlayerAdded:Connect(function(C)
C.CharacterAdded:Connect(function()
createBillboardGui(C)
end)
end)
end

qolPlayerNameVisibility()

getgenv().swordModel=_G.config.names
getgenv().swordAnimations=_G.config.names
getgenv().swordFX=_G.config.names

if getgenv().updateSword and getgenv().skin_changer then
getgenv().updateSword()
return
end

local C=game:GetService"Players"
local D=C.LocalPlayer
local E=game:GetService"ReplicatedStorage"
local F=E:WaitForChild("Shared",9e9):WaitForChild("ReplicatedInstances",9e9):WaitForChild("Swords",9e9)
local G=require(F)

local H

while task.wait()and(not H)do
for I,J in getconnections(E.Remotes.FireSwordInfo.OnClientEvent)do
if J.Function and islclosure(J.Function)then
local K=getupvalues(J.Function)
if#K==1 and type(K[1])=="table"then
H=K[1]
break
end
end
end
end

function getSlashName(I)
local J=G:GetSword(I)
return(J and J.SlashName)or"SlashEffect"
end

function setSword()
if not _G.config.skin_changer then return end

setupvalue(rawget(G,"EquipSwordTo"),2,false)

G:EquipSwordTo(D.Character,getgenv().swordModel)
H:SetSword(getgenv().swordAnimations)
end

local I
local J

while task.wait()and not J do
for K,L in getconnections(E.Remotes.ParrySuccessAll.OnClientEvent)do
if L.Function and getinfo(L.Function).name=="parrySuccessAll"then
J=L
I=L.Function
L:Disable()
end
end
end

local K
while task.wait()and not K do
for L,M in getconnections(E.Remotes.ParrySuccessClient.Event)do
if M.Function and getinfo(M.Function).name=="parrySuccessAll"then
K=M
M:Disable()
end
end
end

getgenv().slashName=getSlashName(getgenv().swordFX)

local L=0
local M={}

E.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(...)
setthreadidentity(2)
local N={...}
if tostring(N[4])~=D.Name then
L=tick()
elseif _G.config.skin_changer then
N[1]=getgenv().slashName
N[3]=getgenv().swordFX
end
return I(unpack(N))
end)

table.insert(M,getconnections(E.Remotes.ParrySuccessAll.OnClientEvent)[1])

getgenv().updateSword=function()
getgenv().slashName=getSlashName(getgenv().swordFX)
setSword()
end

task.spawn(function()
while task.wait()do
if _G.config.skin_changer then
local N=D.Character or D.CharacterAdded:Wait()
if D:GetAttribute"CurrentlyEquippedSword"~=getgenv().swordModel then
setSword()
end
if N and(not N:FindFirstChild(getgenv().swordModel))then
setSword()
end
for O,P in(N and N:GetChildren())or{}do
if P:IsA"Model"and P.Name~=getgenv().swordModel then
P:Destroy()
end
task.wait()
end
end
end
end)

_G.config.curve_method='Camera'

local Grab_Parry = nil

function grab()
    local character = i.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not humanoid or not animator then return end

    local Current_Sword = character:GetAttribute("CurrentlyEquippedSword")
    if not Current_Sword then return end

    local SwordAPI = game:GetService("ReplicatedStorage").Shared.SwordAPI.Collection
    local Parry_Animation = SwordAPI.Default:FindFirstChild("GrabParry")
    if not Parry_Animation then return end

    local Sword_Data = game:GetService("ReplicatedStorage").Shared.ReplicatedInstances.Swords.GetSword:Invoke(Current_Sword)
    if not Sword_Data or not Sword_Data["AnimationType"] then return end

    for _, object in pairs(SwordAPI:GetChildren()) do
        if object.Name == Sword_Data["AnimationType"] then
            if object:FindFirstChild("GrabParry") or object:FindFirstChild("Grab") then
                local sword_animation_type = "GrabParry"
                if object:FindFirstChild("Grab") then
                    sword_animation_type = "Grab"
                end
                Parry_Animation = object[sword_animation_type]
            end
        end
    end

    if Grab_Parry and Grab_Parry.IsPlaying then
        Grab_Parry:Stop()
    end

    Grab_Parry = animator:LoadAnimation(Parry_Animation)
    Grab_Parry.Priority = Enum.AnimationPriority.Action4
    Grab_Parry:Play()
end

game:GetService("ReplicatedStorage").Remotes.ParrySuccess.OnClientEvent:Connect(function()
    if i.Character.Parent ~= workspace.Alive then return end
    if Grab_Parry then
        Grab_Parry:Stop()
    end
end)

local triggerActive = false
local hasClicked = false

local function createDraggableLabel()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TriggerbotStatusGui"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 30)
    frame.Position = UDim2.new(1, -160, 1, -50)
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.BackgroundTransparency = 1
    frame.Active = true
    frame.Parent = screenGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 0, 0)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 27
    label.Parent = frame

    local dragging = false
    local dragStartPosition
    local frameStartPosition

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPosition = input.Position
            frameStartPosition = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStartPosition
            frame.Position = frameStartPosition + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)

    return label
end

local label = createDraggableLabel()

local function updateLabel()
    if triggerActive then
        label.Text = "triggerbot: ON"
        label.TextColor3 = Color3.new(0, 1, 0)
    else
        label.Text = "triggerbot: OFF"
        label.TextColor3 = Color3.new(1, 0, 0)
    end
end

updateLabel()

b.InputBegan:Connect(function(connection, gameProcessed)
    if gameProcessed then return end
    if connection.KeyCode == Enum.KeyCode.C then
        triggerActive = not triggerActive
        updateLabel()
        if triggerActive then
            hasClicked = false
            task.spawn(function()
                while triggerActive do
                    local ball = r.get_ball()
                    if ball and ball:GetAttribute('target') == i.Name then
                        if not hasClicked then
                            grab()
                            local ball = r.get_ball()
                            if ball and ball:GetAttribute('target') == i.Name then
                                r.parry(_G.config.curve_method)
                                hasClicked = true
                            end
                        end
                    else
                        hasClicked = false
                    end
                    task.wait()
                end
            end)
        end
    end
end)

local O=0

local al=0.7

m:AddToggle('Toggle',{
Title='Auto Parry',
Default=_G.config.auto_parry or false,
Callback=function(P)
_G.config.auto_parry=P

if P then
q.auto_parry=e.PreSimulation:Connect(function()
if triggerActive then
    return
end
local Q=r.ball.properties

local R=r.get_ball()
local S=r.get_balls()

for T,U in S do

if not U then
return
end

local V=U:FindFirstChild'zoomies'

if not V then
return
end

U:GetAttributeChangedSignal'target':Once(function()
y=false
end)

if y then
return
end

local W=U:GetAttribute'target'
local X=R:GetAttribute'target'

local Y=V.VectorVelocity

local Z=(i.Character.PrimaryPart.Position-U.Position).Magnitude

local _=h.Network.ServerStatsItem['Data Ping']:GetValue()/10

local aa=math.clamp(_/10,5,17)

local ab=Y.Magnitude

local ac=math.min(math.max(ab-9.5,0),650)
local ad=2.4+ac*0.002

local mul=al

local af=ad*al
local ag=aa+math.max(ab/af,9.5)

local ah=r.ball_curved()

if U:FindFirstChild'AeroDynamicSlashVFX'then
g:AddItem(U.AeroDynamicSlashVFX,0)
Q.aerodynamic_time=tick()
end

if workspace.Runtime:FindFirstChild'Tornado'then
if(tick()-Q.aerodynamic_time)<(workspace.Runtime.Tornado:GetAttribute"TornadoTime"or 1)+0.314159 then
return
end
end

if X==tostring(i)and ah then
return
end

if W==tostring(i)and Z<=ag and mul*0.8 and not triggerActive then
if not _G.config.auto_spam or not _G.manual_spam then
    if _G.config.cooldown_protection and cooldown_protection() then
        return
    end
end

grab()

r.parry(_G.config.curve_method)
y=true
end

local ai=tick()

repeat
e.PreSimulation:Wait()
until(tick()-ai)>=1 or not y
y=false
end
end)
else
if q.auto_parry then
q.auto_parry:Disconnect()
q.auto_parry=nil
end
end
end
})

m:AddToggle('', {
    Title = 'Cooldown Protection',
    Default = _G.config.cooldown_protection or false,
    Callback = function(state)
        _G.config.cooldown_protection = state
    end
})

a.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(Q,R)
if R.Parent and R.Parent~=i.Character then
if R.Parent.Parent~=workspace.Alive then
return
end
end

r.closest_player()

local S=r.get_ball()

if not S then
return
end

local T=(i.Character.PrimaryPart.Position-w.PrimaryPart.Position).Magnitude
local U=(i.Character.PrimaryPart.Position-S.Position).Magnitude
local V=(i.Character.PrimaryPart.Position-S.Position).Unit
local W=V:Dot(S.AssemblyLinearVelocity.Unit)

local X=r.ball_curved()

if T<15 and U<15 and W>-0.25 then
if X then
r.parry(_G.config.curve_method)
end
end

if not s then
return
end

s:Stop()
end)

a.Remotes.ParrySuccess.OnClientEvent:Connect(function()
if i.Character.Parent~=workspace.Alive then
return
end

if not s then
return
end

s:Stop()
end)

workspace.Balls.ChildAdded:Connect(function()
y=false
end)

workspace.Balls.ChildRemoved:Connect(function(Q)
z=0
y=false

if q.target_change then
q.target_change:Disconnect()
q.target_change=nil
end
end)

a.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(Q,R)
local S=i.Character.PrimaryPart
local T=r.get_ball()

if not T then
return
end

local U=T:FindFirstChild'zoomies'

if not U then
return
end

local V=U.VectorVelocity.Magnitude

local W=(i.Character.PrimaryPart.Position-T.Position).Magnitude
local X=U.VectorVelocity

local Y=X.Unit

local Z=(i.Character.PrimaryPart.Position-T.Position).Unit
Z:Dot(Y)

local _=h.Network.ServerStatsItem['Data Ping']:GetValue()


local al=math.min(V/100,40)
local am=W/V-(_/1000)

local an=V>100
local ao=15-math.min(W/1000,15)+al

if an and am>_/10 then
ao=math.max(ao-15,15)
end

if R~=S and W>ao then
r.ball.properties.curving=tick()
end
end)

m:AddSlider('Slider',{
Title='Accuracy',
Description='',
Default=_G.config.accuracy or 100,
Min=1,
Max=100,
Rounding=1,
Callback=function(aa)
al=0.5 + (aa-1)*(1.55 / 99)
_G.config.accuracy=tonumber(aa)
end
})

local aa=m:AddDropdown('Dropdown',{
Title='Curve Mode',
Values={
'Camera',
'Random',
'Dot',
'Backwards',
'Slow',
},
Multi=false,
Default=_G.config.curve_method or'Camera',
Callback=function(aa)
task.spawn(function()
_G.config.curve_method=aa
end)
end
})

local ab={
[Enum.KeyCode.One]="Camera",
[Enum.KeyCode.Two]="Random",
[Enum.KeyCode.Three]="Dot",
[Enum.KeyCode.Four]="Backwards",
[Enum.KeyCode.Five]="Slow",
}

local ac

b.InputBegan:Connect(function(ad, gameProcessed)
if gameProcessed then return end
if not _G.config.curve_keybind then
return
end

local ae=ab[ad.KeyCode]

if not ae then
return
end

if _G.config.curve_method==ae then
if _G.config.curve_notify then
k:Notify{
Title='Curve Method',
Content='Already setted: '..ae,
Duration=3
}
end

return
end

_G.config.curve_method=ae
aa:SetValue(ae)
ac=ae

if _G.config.curve_notify then
k:Notify{
Title='Curve Method',
Content=ae,
Duration=3
}
end
end)

m:AddToggle('Toggle',{
Title='Hotkey Curve',
Default=_G.config.curve_keybind or false,
Callback=function(ad)
task.spawn(function()
_G.config.curve_keybind=ad
end)
end
})

m:AddToggle('Toggle',{
Title='Curve Notify',
Default=_G.config.curve_notify or false,
Callback=function(ad)
task.spawn(function()
_G.config.curve_notify=ad
end)
end
})

m:AddToggle('Toggle',{
Title='Auto Spam',
Default=_G.config.auto_spam or false,
Callback=function(af)
_G.config.auto_spam=af

if af then
q.auto_spam=e.PreSimulation:Connect(function()
if _G.manual_spam then
return
end

local ag=r.get_ball()

if not ag then
return
end

local ah=ag:FindFirstChild'zoomies'

if not ah then
return
end

r.closest_player()

local ai=h.Network.ServerStatsItem['Data Ping']:GetValue()

local aj=math.clamp(ai/10,1,16)

local P=ag:GetAttribute'target'

local Q=r:get_ball_properties()
local R=r:players_properties()

local S=r.perfom_spam{
Ball_Properties=Q,
Entity_Properties=R,
Ping=aj
}

local T=w.PrimaryPart.Position
local U=i:DistanceFromCharacter(T)

local V=(i.Character.PrimaryPart.Position-ag.Position).Unit
local W=ah.VectorVelocity.Unit

V:Dot(W)

local X=i:DistanceFromCharacter(ag.Position)

if not P then
return
end

if U>S or X>S then
return
end

local Y=i.Character:GetAttribute'Pulsed'

if Y then
return
end

if P==tostring(i)and U>30 and X>30 then
return
end

local Z=_G.config.spam_threshold

if X<=S and z>Z then
r.parry(_G.config.curve_method)
end
end)
else
if q.auto_spam then
q.auto_spam:Disconnect()
q.auto_spam=nil
end
end
end
})

local af
local ag = nil

if a:FindFirstChild"Controllers"then
for ah,ai in ipairs(a.Controllers:GetChildren())do
if ai.Name:match"^SwordsController%s*$"then
ag=ai
end
end
end

if i.PlayerGui:FindFirstChild"Hotbar"and i.PlayerGui.Hotbar:FindFirstChild"Block"then
for ah,ai in next,getconnections(i.PlayerGui.Hotbar.Block.Activated)do
if ag and getfenv(ai.Function).script==ag then
af=ai.Function
break
end
end
end

m:AddToggle('Toggle',{
Title='Animation Fix',
Default=_G.config.animation_fix or false,
Callback=function(ah)
_G.config.animation_fix=ah

if ah then
q.animation_fix=e.PreSimulation:Connect(function()

local ai=r.get_ball()

if not ai then
return
end

local aj=ai:FindFirstChild'zoomies'

if not aj then
return
end

r.closest_player()

local P=h.Network.ServerStatsItem['Data Ping']:GetValue()

local Q=math.clamp(P/10,1,16)

local R=ai:GetAttribute'target'

local S=r:get_ball_properties()
local T=r:players_properties()

local U=r.perfom_spam{
Ball_Properties=S,
Entity_Properties=T,
Ping=Q
}

local V=w.PrimaryPart.Position
local W=i:DistanceFromCharacter(V)

local X=(i.Character.PrimaryPart.Position-ai.Position).Unit
local Y=aj.VectorVelocity.Unit

X:Dot(Y)

local Z=i:DistanceFromCharacter(ai.Position)

if not R then
return
end

if W>U or Z>U then
return
end

local _=i.Character:GetAttribute'Pulsed'

if _ then
return
end

if R==tostring(i)and W>30 and Z>30 then
return
end

local ak=_G.config.spam_threshold

if Z<=U and z>ak then
af()
end
end)
else
if q.animation_fix then
q.animation_fix:Disconnect()
q.animation_fix=nil
end
end
end
})

m:AddSlider('Slider',{
Title='Threshold',
Description='',
Default=_G.config.spam_threshold or 3,
Min=1,
Max=3,
Rounding=1,
Callback=function(ah)
task.spawn(function()
_G.config.spam_threshold=tonumber(ah)
end)
end
})

b.InputBegan:Connect(function(ai,aj)
if aj then return end
if ai.KeyCode==Enum.KeyCode.E then
_G.manual_spam=not _G.manual_spam
end
end)

local ai=m:AddKeybind('Keybind',{
Title='Manual Spam',
Mode='Toggle',
Default=_G.config.manual_spam or'E',
Callback=function(ai)
if ai then
q.manual_spam=e.PreSimulation:Connect(function()
if _G.manual_spam then
r.parry(_G.config.curve_method)
end
end)
if _G.config.manual_notify then
k:Notify{
Title='Manual Spam',
Content='ON',
Duration=4
}
end
else
if q.manual_spam then
q.manual_spam:Disconnect()
q.manual_spam=nil
end
if _G.config.manual_notify then
k:Notify{
Title='Manual Spam',
Content='OFF',
Duration=4
}
end
end
end
})

ai:OnChanged(function(aj)
_G.config.manual_spam=aj
end)

m:AddToggle('Toggle',{
Title='Manual Notify',
Default=_G.config.manual_notify or false,
Callback=function(aj)
_G.config.manual_notify=aj
end
})

n:AddToggle('Toggle',{
Title='No Slow',
Default=_G.config.no_slow,
Callback=function(aj)
_G.config.no_slow=aj

if aj then
q.no_slow=e.PostSimulation:Connect(function()
if not i.Character then
return
end

if not workspace.Alive:FindFirstChild(i.Name)then
return
end

if not i.Character:FindFirstChild'Humanoid'then
return
end

if i.Character.Humanoid.WalkSpeed<36 or i.Character.Humanoid.PlatformStand then
i.Character.Humanoid.WalkSpeed=36
end
end)
else
if q.no_slow then
q.no_slow:Disconnect()
q.no_slow=nil
end
end
end
})

o:AddToggle('Toggle',{
Title='Ability ESP',
Default=_G.config.ability_esp or false,
Callback=function(P)
_G.config.ability_esp=P
for Q,R in pairs(B)do
R.Visible=P
end
end
})

o:AddToggle('Toggle',{
Title='FOV',
Default=_G.config.field_of_view or false,
Callback=function(ah)
_G.config.field_of_view=ah
local ai=workspace.CurrentCamera

if ah then
_G.config.fov_distance=_G.config.fov_distance or 70
ai.FieldOfView=_G.config.fov_distance

if not _G.fov_loop then
_G.fov_loop=e.RenderStepped:Connect(function()
if _G.config.field_of_view then
ai.FieldOfView=_G.config.fov_distance
end
end)
end
else
ai.FieldOfView=70
if _G.fov_loop then
_G.fov_loop:Disconnect()
_G.fov_loop=nil
end
end
end
})

o:AddSlider('Slider',{
Title='FOV Distance',
Description='',
Default=_G.config.fov_distance or 70,
Min=70,
Max=120,
Rounding=1,
Callback=function(ah)
_G.config.fov_distance=ah
if _G.config.field_of_view then
workspace.CurrentCamera.FieldOfView=ah
end
end
})

local P

o:AddToggle('Toggle',{
Title='Skin Changer',
Default=_G.config.skin_changer or false,
Callback=function(Q)
_G.config.skin_changer=Q

task.spawn(function()
if Q then
P=i.Character:GetAttribute'CurrentlyEquippedSword'
getgenv().updateSword()
else
if P then
setupvalue(rawget(G,"EquipSwordTo"),2,false)
G:EquipSwordTo(D.Character,P)
H:SetSword(P)
end
end
end)
end
})

o:AddInput('Input',{
Title='Sword Name',
Default=_G.config.names or i.Character:GetAttribute'CurrentlyEquippedSword'.Name,
Placeholder='Placeholder',
Numeric=false,
Finished=true,
Callback=function(Q)
task.spawn(function()
getgenv().swordModel=Q
getgenv().swordAnimations=Q
getgenv().swordFX=Q
_G.config.names=tostring(Q)
if _G.config.skin_changer then
getgenv().updateSword()
end
end)
end
})

p:AddToggle('Toggle',{
Title='Ping Fix',
Default=_G.config.ping_fix or false,
Callback=function(Q)
_G.config.ping_fix=Q
task.spawn(function()
while _G.config.ping_fix do task.wait()
if _G.manual_spam or h.Network.ServerStatsItem['Data Ping']:GetValue()>270 then
setfpscap(60)
else
if x then
setfpscap(60)
else
setfpscap(240)
end
end
end
if x then
setfpscap(60)
else
setfpscap(240)
end
end)
end
})

local af
p:AddToggle('Toggle',{
Title='Ball Stats',
Default=_G.config.ball_debug or false,
Callback=function(ag)
_G.config.ball_debug=ag

if ag then
af=Instance.new("ScreenGui",i:WaitForChild"PlayerGui")
local ah=Instance.new("TextLabel",af)
local ai=Instance.new("TextLabel",af)

local aj={}

af.ResetOnSpawn=false

ah.Name="BallStatsLabel"
ah.Size=UDim2.new(0.2,0,0.05,0)
ah.Position=UDim2.new(0.7,0,0.1,0)
ah.TextScaled=false
ah.TextSize=26
ah.BackgroundTransparency=1
ah.TextColor3=Color3.new(1,1,1)
ah.Font=Enum.Font.Fantasy
ah.ZIndex=2

ai.Name="PeakStatsLabel"
ai.Size=UDim2.new(0.2,0,0.05,0)
ai.Position=UDim2.new(0.7,0,0.135,0)
ai.TextScaled=false
ai.TextSize=26
ai.BackgroundTransparency=1
ai.TextColor3=Color3.new(1,1,1)
ai.Font=ah.Font
ai.ZIndex=2

r.ball_stats=e.Heartbeat:Connect(function()
local P=r.get_balls()or{}

if#P==0 then
ah.Text="Waiting..."
ai.Text='Max Speed: 0'
return
end

for Q,R in aj do
local S=false
for T,U in P do
if U==Q then
S=true
end
end
if not S then
aj[Q]=nil
end
end

for Q,R in P do
local S=R:FindFirstChild"zoomies"
if S then
local T=S.VectorVelocity.Magnitude
aj[R]=aj[R]or 0
if T>aj[R]then
aj[R]=T
end

local U=("Ball Speed: %.2f"):format(T)
ah.Text=U

local V=("Max Speed: %.2f"):format(aj[R])
ai.Text=V
break
end
end
end)
else
if r.ball_stats then
r.ball_stats:Disconnect()
r.ball_stats=nil
end

if af then
af:Destroy()
af=nil
end
end
end
})

p:AddToggle('Toggle',{
Title='No Render',
Default=_G.config.no_render or false,
Callback=function(ag)
_G.config.no_render=ag
task.spawn(function()
if ag then
r.no_render=workspace.Runtime.ChildAdded:Connect(function(ah)
i.PlayerScripts.EffectScripts.ClientFX.Enabled=false
if ah.Name=='Tornado'then
return
end
g:AddItem(ah,0)
end)
else
i.PlayerScripts.EffectScripts.ClientFX.Enabled=true
if r.no_render then
r.no_render:Disconnect()
r.no_render=nil
end
end
end)
end
})

cre:AddButton({
Title='Discord Server',
Callback=function()
setclipboard('https://discord.gg/kC9uQtWE6p')
end
})

cre:AddButton({
Title='Developed by Mani & Beto',
Description='Brazilian developers',
Callback=function()
end
})

l:SelectTab(1)

k:Notify{
Title='Casa das Primas',
Content='Loaded.',
Duration=3
}