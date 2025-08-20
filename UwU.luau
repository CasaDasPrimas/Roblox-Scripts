repeat task.wait() until game:IsLoaded()

if UwU then
    return warn('UwU Already Executed nigg')
end

getgenv().UwU = true

--// Serviços
cloneref = cloneref or function(...) return ... end

local VirtualInputManager = cloneref(game:GetService('VirtualInputManager'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local UserInputService = cloneref(game:GetService('UserInputService'))
local TweenService = cloneref(game:GetService('TweenService'))
local HttpService = cloneref(game:GetService('HttpService'))
local TextService = cloneref(game:GetService('TextService'))
local RunService = cloneref(game:GetService('RunService'))
local Stats = cloneref(game:GetService('Stats').Network)
local Lighting = cloneref(game:GetService('Lighting'))
local Players = cloneref(game:GetService('Players'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Debris = cloneref(game:GetService('Debris'))
local LocalPlayer = Players.LocalPlayer

-- Variables
local IsMobile = table.find({
        Enum.Platform.IOS,
        Enum.Platform.Android
    }, UserInputService:GetPlatform())
local CurrentCamera =  workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
warn('antes')
--// Library
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/CasaDasPrimas/Roblox-Scripts/refs/heads/main/Library.luau'))()
local Window = Library:CreateWindow()
warn('depois')
local AP = Window:CreateTab('Auto Parry', 'rbxassetid://76499042599127')
local Spam = Window:CreateTab('Spam', 'rbxassetid://10709781460')
local PL = Window:CreateTab('Player', 'rbxassetid://126017907477623')
local Visual = Window:CreateTab('Visuals', 'rbxassetid://10723346959')
local World = Window:CreateTab('World', 'rbxassetid://10734897102')
local Misc = Window:CreateTab('Misc', 'rbxassetid://132243429647479')
local GUI = Window:CreateTab('GUI', 'rbxassetid://10734887784')
local EXC = Window:CreateTab('Exclusive', 'rbxassetid://10734966248')

--// Game-Variables
local variables = {
    Triggerbot_Parried = false,
    Tornado_Time = tick(),
    Last_Warping = tick(),
    FirstParry = false,
    Curving = tick(),
    Lerp_Radians = 0,
    GrabParry = nil,
    AnimFix = false,
    Parried = false,
    Velocity = {},
    LastParry = 0,
    Parries = 0,

    Modules = {
        SwordModel = '',
        SwordAnim = '',
        SwordFX = ''
    },

    Numbers = {
        ParryThreshold = 2.5,
        Multiplier = 1.1,
    }
}

local Connections = {}

local Modules = variables.Modules
local Numbers = variables.Numbers

local PF
local SC

local ParrySucess
local ClientSucess
getgenv().CurrentCurve = 'Camera'

local Remotes = {}
local Remote

task.spawn(function()
    for _,x in getgc()do
        if type(x)=='function'and islclosure(x)then
            if debug.getupvalues(x)then

                local y=debug.getprotos(x)
                local z=debug.getupvalues(x)
                local A=debug.getconstants(x)

                if#y==4 and#z==24 and#A>=102 then
                    Remotes[debug.getupvalue(x,16)]=debug.getconstant(x,62)
                    Remote=debug.getupvalue(x,17)

                    Remotes[debug.getupvalue(x,18)]=debug.getconstant(x,64)
                    Remotes[debug.getupvalue(x,19)]=debug.getconstant(x,65)
                    break
                end
            end
        end
    end
end)

if ReplicatedStorage:FindFirstChild('Controllers') then
    for _, obj in ipairs(ReplicatedStorage.Controllers:GetChildren()) do
        if obj.Name:match('^SwordsController%s*$') then
            SC = obj
        end
    end
end

if LocalPlayer.PlayerGui:FindFirstChild('Hotbar') and LocalPlayer.PlayerGui.Hotbar:FindFirstChild('Block') then
    for _, v in next, getconnections(LocalPlayer.PlayerGui.Hotbar.Block.Activated) do
        if SC and getfenv(v.Function).script == SC then
            PF = v.Function
            break
        end
    end
end
warn('remote')
local SwordModule = require(ReplicatedStorage:WaitForChild('Shared'):WaitForChild('ReplicatedInstances'):WaitForChild('Swords'))
local SwordControl

task.spawn(function()
    while task.wait() and not SwordControl do
        for _, v in getconnections(ReplicatedStorage.Remotes.FireSwordInfo.OnClientEvent) do
            local upvalues = getupvalues(v.Function)

            if #upvalues == 1 and type(upvalues[1]) == 'table' then
                SwordControl = upvalues[1]
                break
            end
        end
    end
end)

function SlashName(name)
    local Slash = SwordModule:GetSword(name)
    return (Slash and Slash.name) or 'SlashEffect'
end

function SetSword()
    setupvalue(rawget(SwordModule, 'EquipSwordTo'), 2, false)
    SwordModule:EquipSwordTo(LocalPlayer.Character, Modules.SwordModel)
    SwordControl:SetSword(Modules.SwordAnim)
end

function UpdateSword()
    SlashName(Modules.SwordFX)
    SetSword()
end

function Linear_Interpolation(a, b, time)
    return a + (b - a) * time
end

function Get_Balls()
    local Balls = {}

    for _, Ball in workspace.Balls:GetChildren() do
        if Ball:GetAttribute('realBall') then
            Ball.CanCollide = false
            table.insert(Balls, Ball)
        end
    end

    return Balls
end

function Get_Ball()
    for _, Ball in workspace.Balls:GetChildren() do
        if Ball:GetAttribute('realBall') then
            Ball.CanCollide = false
            return Ball
        end
    end
end

function Closest_Player()
    local Max_Distance = math.huge
    local Closest

    for _, player in workspace.Alive:GetChildren() do
        if player.Name ~= LocalPlayer.Name then
            if player.PrimaryPart then
                local Distance = LocalPlayer:DistanceFromCharacter(player.PrimaryPart.Position)

                if Distance < Max_Distance then
                    Closest = player
                end
            end
        end
    end

    return Closest
end

function Effect(obj)
    return obj.Offset.Y < 0.4
end

function Effect2(obj)
    return obj.Offset.Y == 0.5
end

function CooldownProtect()
    local BlockGui = LocalPlayer.PlayerGui.Hotbar.Block.UIGradient

    if Effect(BlockGui) then
        ReplicatedStorage.Remotes.AbilityButtonPress:Fire()
        return true
    end

    return false
end

function AutoAbility()
    local AbilityGui = LocalPlayer.PlayerGui.Hotbar.Ability.UIGradient
    local Abilities = {
        ['Raging Deflection'] = true,
        ['Rapture'] = true,
        ['Calming'] = true,
        ['Aerodynamic Slash'] = true,
        ['Fracture'] = true,
        ['Death Slash'] = true
    }

    if Effect2(AbilityGui) then
        for _, v in LocalPlayer.Character.Abilities:GetChildren() do
            if Abilities[v.Name] and v.Enabled then
                variables.Parried = true
                ReplicatedStorage.Remotes.AbilityButtonPress:Fire()
                task.wait(2.432)
                ReplicatedStorage.Remotes:WaitForChild('DeathSlashShootActivation'):FireServer(true)

                return true
            end
        end
    end

    return false
end

function GrabAnimation()
    local SwordAPI = ReplicatedStorage.Shared.SwordAPI.Collection
    local ParryAnim = SwordAPI.Default:FindFirstChild('GrabParry')

    if not ParryAnim then
        return
    end

    local Current_Sword = LocalPlayer.Character:GetAttribute('CurrentlyEquippedSword')

    if not Current_Sword then
        return
    end

    local Sword_Data = ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(Current_Sword)

    if not Sword_Data or not Sword_Data['AnimationType'] then
        return
    end

    for _, obj in SwordAPI:GetChildren() do
        if obj.Name == Sword_Data['AnimationType'] then
            if obj:FindFirstChild('GrabParry') or obj:FindFirstChild('Grab') then
                local SwordAnim = 'GrabParry'

                if obj:FindFirstChild('Grab') then
                    SwordAnim = 'Grab'
                end

                ParryAnim = obj[SwordAnim]
            end
        end
    end

    if variables.GrabParry and variables.GrabParry.IsPlaying then
        variables.GrabParry:Stop()
    end

    variables.GrabParry = LocalPlayer.Character.Humanoid:LoadAnimation(ParryAnim)
    variables.GrabParry.Priority = Enum.AnimationPriority.Action4
    variables.GrabParry:Play()
end

function GetProperties()
    local Closest = Closest_Player()

    if not Closest then
        return false
    end

    local Velocity = Closest.PrimaryPart.Velocity
    local Direction = (LocalPlayer.Character.PrimaryPart.Position - Closest.PrimaryPart.Position).Unit
    local Distance = (LocalPlayer.Character.PrimaryPart.Position - Closest.PrimaryPart.Position).Magnitude

    return {
        Velocity = Velocity,
        Direction = Direction,
        Distance = Distance
    }
end

function GetClosestPlayerToCursor()
    if getgenv().TargetAim and getgenv().TargetPlayer then
        return nil
    end

    local Closest
    local _Dot = -math.huge

    local Mouse_Location = UserInputService:GetMouseLocation()
    local Ray = CurrentCamera:ScreenPointToRay(Mouse_Location.X, Mouse_Location.Y)
    local Point = CFrame.lookAt(Ray.Origin, Ray.Origin + Ray.Direction)

    for _, player in workspace.Alive:GetChildren() do
        if player.Name ~= LocalPlayer.Name then
            local To_Player = (player.HumanoidRootPart.Position - CurrentCamera.CFrame.Position).Unit
            local Dot = Point.LookVector:Dot(To_Player)

            if Dot > _Dot then
                Closest = player
            end
        end
    end

    return Closest
end

function GetCurve()
    local World = {}
    local Pos

    local LastInput = UserInputService:GetLastInputType()
    local MouseLocation = UserInputService:GetMouseLocation()

    if LastInput == Enum.UserInputType.MouseButton1 or (Enum.UserInputType.MouseButton2 or LastInput == Enum.UserInputType.Keyboard) then
        Pos = {MouseLocation.X, MouseLocation.Y}
    else
        Pos = {CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2}
    end

    if IsMobile then
        Pos = {CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2}
    end

    for _, Point in workspace.Alive:GetChildren() do
        World[Point.Name] = CurrentCamera:WorldToScreenPoint(Point.PrimaryPart.Position)
    end

    local Root = LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
    local Part

    if getgenv().TargetAim and getgenv().TargetPlayer then
        local TargetPlayer = Players:FindFirstChild(getgenv().TargetPlayer)

        if TargetPlayer and TargetPlayer.Character then
            Part = TargetPlayer.Character.HumanoidRootPart
        end
    end

    if not Part then
        local Closest = GetClosestPlayerToCursor()

        if Closest and Closest:FindFirstChild('HumanoidRootPar') then
            Part = Closest.HumanoidRootPart
        end
    end

    local TargetPos = Part and Part.Position or (Root.Position + CurrentCamera.CFrame.LookVector * 100)

    if getgenv().CurrentCurve == 'Dot' then
        return {0, CFrame.new(Root.Position, TargetPos), World, Pos}
    elseif getgenv().CurrentCurve == 'Accelerated' then
        return {0, CFrame.new(Root.Position, TargetPos + Vector3.new(0, 5, 0)), World, Pos}
    elseif getgenv().CurrentCurve == 'Slow' then
        return {0, CFrame.new(Root.Position, TargetPos + Vector3.new(0, -9e18, 0)), World, Pos}
    elseif getgenv().CurrentCurve == 'High' then
        return {0, CFrame.new(Root.Position, TargetPos + Vector3(0, 9e18, 0)), World, Pos}
    elseif getgenv().CurrentCurve == 'Random' then
        return {0, CFrame.new(Root.Position, Vector3.new(math.random(-1e3, 1e3), math.random(-350, 1e3), math.random(-1e3, 1e3))), World, Pos}
    elseif getgenv().CurrentCurve == 'Backwards' then
        return {0, CFrame.new(CurrentCamera.CFrame.Position, Root.Position + (Root.Position - TargetPos).Unit * 1e4 + Vector3.new(0, 1e3, 0)), World, Pos}
    else
        return {0, CurrentCamera.CFrame, World, Pos}
    end
end

function Parry()
    local Curve = GetCurve()

    variables.Parried = true

    for obj, args in Remotes do
        obj:FireServer(args,Remote,unpack(Curve))
    end

    if getgenv().AnimFix then
        GrabAnimation()
    end

    if variables.Parries > 7 then
        return false
    end

    variables.Parries += 1

    task.delay(0.5,function()
        if variables.Parries > 0 then
            variables.Parries -= 1
        end
    end)
end

function Is_Curving()
    local Ball = Get_Ball()

    if not Ball then
        return false
    end

    local Zoomies = Ball:FindFirstChild('zoomies')

    if not Zoomies then
        return false
    end

    local Ping = Stats.ServerStatsItem['Data Ping']:GetValue()
    local Velocity = Zoomies.VectorVelocity
    local Ball_Unit = Velocity.Unit

    local Pos = LocalPlayer.Character.PrimaryPart.Position
    local BallPos = Ball.Position
    local Direction = (Pos - BallPos).Unit
    local Dot = Direction:Dot(Ball_Unit)
    local Speed = Velocity.Magnitude

    local Speed_Threshold = math.min(Speed / 100 / 40)
    --local Angle_Threshold = 40 * math.max(Dot, 0)
    local Distance = (Pos - BallPos).Magnitude
    local Reach = Distance / Speed - (Ping / 1000)

    local Ball_Threshold = 15 - math.min(Distance / 1000, 15) + Speed_Threshold

    local EnemyProp = GetProperties()

    if EnemyProp then
        local BaseDistance = 70
        local MaxDistance = 445
        local EnemyDynamic = math.min(BaseDistance + (Speed * .15), MaxDistance)
        local BallDynamic = math.min(30 + (Speed * 0.05), 200)

        if EnemyProp.Distance <= EnemyDynamic and Speed > 40 and Distance <= BallDynamic then
            return false
        end
    end

    if Distance <= 25 then
        return false
    end

    table.insert(variables.Velocity, Velocity)

    if #variables.Velocity > 4 then
        table.remove(variables.Velocity, 1)
    end

    if Ball:FindFirstChild('AeroDynamicSlashVFX') then
        Debris:AddItem(Ball.AeroDynamicSlashVFX, 0)
        variables.Tornado_Time = tick()
    end

    if workspace.Runtime:FindFirstChild('Tornado') then
        if (tick() - variables.Tornado_Time) < ((workspace.Runtime.Tornado:GetAttribute('TornadoTime') or 1) + 0.314159) then
            return true
        end
    end

    local Enough = Speed > 160

    if Enough and Reach > Ping / 10 then
        if Speed < 300 then
            Ball_Threshold = math.max(Ball_Threshold - 15, 15)
        elseif Speed > 300 and Speed < 600 then
            Ball_Threshold = math.max(Ball_Threshold - 16, 16)
        elseif Speed > 600 and Speed < 1000 then
            Ball_Threshold = math.max(Ball_Threshold - 17, 17)
        elseif Speed > 1000 and Speed < 1500 then
            Ball_Threshold = math.max(Ball_Threshold - 19, 19)
        elseif Speed > 1500 then
            Ball_Threshold = math.max(Ball_Threshold - 20, 20)
        end
    end

    if Speed < 300 then
        if (tick() - variables.Curving) < (Reach / 1.2) then
            return true
        end
    elseif Speed >= 300 and Speed < 450 then
        if (tick() - variables.Curving) < (Reach / 1.21) then
            return true
        end
    elseif Speed > 450 and Speed < 600 then
        if (tick() - variables.Curving) < (Reach / 1.335) then
            return true
        end
    elseif Speed > 600 then
        if (tick() - variables.Curving) < (Reach / 1.5) then
            return true
        end
    end

    local Dot_Threshold = (0.5 - Ping / 1000)
    local Difference = (Ball_Unit - Velocity.Unit)
    local Similarity = Direction:Dot(Difference.Unit)
    local Dot_Difference = Dot - Similarity

    if Dot_Difference < Dot_Threshold then
        return true
    end

    local Campled_Dot = math.clamp(Dot, -1, 1)
    local Radians = math.deg(math.asin(Campled_Dot))

    variables.Lerp_Radians = Linear_Interpolation(variables.Lerp_Radians, Radians, 0.8)

    if Speed < 300 then
        if variables.Lerp_Radians < 0.02 then
            variables.Last_Warping = tick()
        end

        if (tick() - variables.Last_Warping) < (Reach / 1.19) then
            return true
        end
    else
        if variables.Lerp_Radians < 0.018 then
            variables.Last_Warping = tick()
        end

        if (tick() - variables.Last_Warping) < (Reach / 1.5) then
            return true
        end
    end

    if #variables.Velocity == 4 then
        local Direction_Difference = (Ball_Unit - variables.Velocity[1].Unit).Unit
        local Intended_Dot = Direction:Dot(Direction_Difference)
        local Dot_Intended = Dot - Intended_Dot

        local Direction_Difference2 = (Ball_Unit - variables.Velocity[2].Unit).Unit
        local Intended_Dot2 = Direction:Dot(Direction_Difference2)
        local Dot_Intended2 = Dot - Intended_Dot2

        if Dot_Intended < Dot_Threshold or Dot_Intended2 < Dot_Threshold then
            return true
        end
    end

    local CurveDetected = false
    local AngleThreshold = 85
    local Horizontal = Vector3.new(Pos.X - BallPos.X, 0, Pos.Z - BallPos.Z)

    if Horizontal.Magnitude > 0 then
        Horizontal = Horizontal.Unit
    end

    local Away = -Horizontal

    local BallHorizontal = Vector3.new(Ball_Unit.X, 0, Ball_Unit.Z)

    if BallHorizontal.Magnitude > 0 then
        BallHorizontal = BallHorizontal.Unit
        local Angle = math.deg(math.acos(math.clamp(Away:Dot(BallHorizontal), -1, 1)))

        if Angle < AngleThreshold then
            CurveDetected = true
        end
    end

    return (Dot < Dot_Threshold) or CurveDetected
end

function AutoSpam(self)
    local Ball = Get_Ball()

    local Player = Closest_Player()

    if not Ball then
        return false
    end

    if not Player or not Player.PrimaryPart then
        return false
    end

    local Spam_Accuracy = 0

    local Velocity = Ball.AssemblyLinearVelocity
    local Speed = Velocity.Magnitude

    local Direction = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Unit
    local Dot = Direction:Dot(Velocity.Unit)

    local Target = Player.PrimaryPart.Position
    local Distance = LocalPlayer:DistanceFromCharacter(Target)

    local Spam_Distance = self.Ping + math.min(Speed / 6, 95)

    if self.EntityProps.Distance > Spam_Distance then
        return Spam_Accuracy
    end

    if self.BallProps.Distance > Spam_Distance then
        return Spam_Accuracy
    end

    if Distance > Spam_Distance then
        return Spam_Accuracy
    end

    local MaxSpeed = 5 - math.min(Speed / 5, 5)
    local MaxDot = math.clamp(Dot, -1, 0) * MaxSpeed

    Spam_Accuracy = Spam_Distance - MaxDot

    return Spam_Accuracy
end

workspace.Runtime.ChildAdded:Connect(function(obj)
    if getgenv().PhantomV2Detection and not Connections['PhatomV2'] then
        if obj.Name == 'maxTransmission' or obj.Name == 'transmissionpart' then
            local Weld = obj:FindFirstChildWhichIsA('WeldConstraint')

            if Weld then
                local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                if Character and Weld.Part1 == Character.HumanoidRootPart then
                    Ball = Get_Ball()
                    Weld:Destroy()

                    if Ball then
                        Connections['PhatomV2'] = RunService.Heartbeat:Connect(function()
                            local HightAtributte = Ball:GetAttribute('highlighted')

                            if HightAtributte then
                                Character.Humanoid.WalkSpeed = 36
                                local Root = Character:FindFirstChild('HumanoidRootPart')

                                if Root then
                                    local Pos = Root.Position
                                    local BallPos = Ball.Position
                                    local Distance = (BallPos - Pos).Unit

                                    Character.Humanoid:Move(Distance, false)
                                end
                            elseif not HightAtributte then
                                Connections['PhatomV2']:Disconnect()
                                Connections['PhatomV2'] = nil

                                Character.Humanoid.WalkSpeed = 36
                                Character.Humanoid:Move(Vector3.new(0, 0, 0), false)

                                Ball = nil
                            end
                        end)

                        task.delay(3, function()
                            if Connections['PhatomV2'] then
                                Connections['PhatomV2']:Disconnect()
                                Connections['PhatomV2'] = nil

                                Character.Humanoid:Move(Vector3.new(0, 0, 0), false)
                                Character.Humanoid.WalkSpeed = 36
                                Ball = nil
                            end
                        end)
                    end
                end
            end
        end
    end
end)

workspace.Balls.ChildAdded:Connect(function(obj)
    obj.ChildAdded:Connect(function(arg)
        if getgenv().SlashOfFury and arg.Name == 'ComboCounter' then
            local Label = arg:FindFirstChildOfClass('TextLabel')

            if Label then
                repeat
                    local Slashes_Counter = tonumber(Label.Text)

                    if Slashes_Counter and Slashes_Counter < 32 then
                        Parry()
                    end

                    task.wait()

                until not Label.Parent or not Label
            end
        end
    end)
end)

task.spawn(function()
    while task.wait() do
        if not Parry then
            for _, v in getconnections(ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent) do
                if v.Function and getinfo(v.Function).Name == 'parrySucessAll' then
                    ParrySucess = v
                    Parry = v.Function
                    v.Disable()
                end
            end
        end

        if not ClientSucess then
            for _, v in getconnections(ReplicatedStorage.Remotes.ParrySuccessClient.Event) do
                if v.Function and getinfo(v.Function).name == 'parrySuccessAll' then
                    ClientSucess = v
                    v:Disable()
                end
            end
        end
    end
end)

local NinjaDash = ReplicatedStorage['Packages']['_Index']['sleitnick_net@0.1.0']['net']['RE/NinjaDash']

local call
call = hookmetamethod(game, '__namecall', function(self, ...)
    if self == NinjaDash and getnamecallmethod() == 'FireServer' then
        variables.Parried = true

        task.delay(0.5155, function()
            variables.Parried = false
        end)
    end

    return call(self, ...)
end)

--// Buttons
local APModule = AP:CreateModule({
    Title = 'Auto Parry',
    Flag = 'Auto_Parry',
    Description = 'Automatically parries ball',
    Section = 'left',
    Callback = function(value: boolean)
        if getgenv().AutoParryNotify then
            if value then
                Library:CreateNotify({
                    Title = "Auto Parry Notification",
                    Text = "Auto Parry has been turned ON",
                    Duration = 3
                })
            else
                Library.CreateNotify({
                    Title = "Auto Parry Notification",
                    Text = "Auto Parry has been turned OFF",
                    Duration = 3
                })
            end
        end

        if value then
            Connections['Auto Parry'] = RunService.PreSimulation:Connect(function()
                local _Ball = Get_Ball()
                local Balls = Get_Balls()

                for _, Ball in Balls do
                    if getgenv().TriggerBot then
                        return
                    end

                    if not Ball then
                        return
                    end

                    local Zoomies = Ball:FindFirstChild('zoomies')

                    if not Zoomies then
                        return
                    end

                    Ball:GetAttributeChangedSignal('target'):Once(function()
                        variables.Parried = false
                    end)

                    if variables.Parried then
                        return
                    end

                    local Ball_Target = Ball:GetAttribute('target')
                    local Target = _Ball:GetAttribute('target')

                    local Velocity = Zoomies.VectorVelocity
                    local Distance = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Magnitude

                    local Ping = Stats.ServerStatsItem['Data Ping']:GetValue() / 10
                    local Ping_Threshold = math.clamp(Ping / 10, 5, 17)

                    local Speed = Velocity.Magnitude
                    local SpeedDiff = math.min(math.max(Speed - 9.5, 0), 650)
                    local SpeedDivisor = 2.4 + SpeedDiff * 0.002
                    local Multiplier = Numbers.Multiplier

                    local speed_divisor = SpeedDivisor * Multiplier
                    local Parry_Accuracy = Ping_Threshold + math.max(Speed / speed_divisor, 9.5)

                    local Curved = Is_Curving()

                    if Ball:FindFirstChild('AeroDynamicSlashVFX') then
                        Debris:AddItem(Ball.AeroDynamicSlashVFX, 0)
                        variables.Tornado_Time = tick()
                    end

                    if workspace.Runtime:FindFirstChild('Tornado') then
                        if (tick() - variables.Tornado_Time) < (workspace.Runtime.Tornado:GetAttribute("TornadoTime") or 1) + 0.314159 then
                            return
                        end
                    end

                    if Target == LocalPlayer.Name and Curved then
                        return
                    end

                    if Ball:FindFirstChild("ComboCounter") then
                        return
                    end

                    local Singularity = LocalPlayer.Character.PrimaryPart:FindFirstChild('SingularityCape')

                    if Singularity then
                        return
                    end

                    if Ball_Target == LocalPlayer.Name and Distance <= Parry_Accuracy then
                        if getgenv().AutoAbility and AutoAbility() then
                            return
                        end
                    end

                    if Ball_Target == LocalPlayer.Name and Distance <= Parry_Accuracy then
                        if getgenv().CooldownProtection and CooldownProtect() then
                            return
                        end

                        if getgenv().AutoParryKeypress then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
                        else
                            Parry()
                        end

                        variables.Parried = true
                    end

                    local Last_Parrys = tick()

                    repeat
                        RunService.PreSimulation:Wait()
                    until (tick() - Last_Parrys) >= 1 or not variables.Parried
                    variables.Parried = false
                end
            end)
        else
            if Connections['Auto Parry'] then
                Connections['Auto Parry']:Disconnect()
                Connections['Auto Parry'] = nil
            end
        end
    end
})

APModule:CreateCheckBox({
    Title = 'Notify',
    Flag = 'Auto Parry Notify',
    Callback = function(value: boolean)
        getgenv().AutoParryNotify = value
    end
})

local CurveModule = APModule:CreateDropdown({
    Title = 'Curves',
    Flag = 'Curves Type',
    Options = {"Camera", "Random", "Dot", "Backwards", "Slow", "Accelerated", "High"},
    MultiDropdown = false,
    Max = 8,
    Callback = function(value: string)
        getgenv().CurrentCurve = value
    end
})

APModule:CreateSlider({
    Title = 'Parry Accuracy',
    Flag = 'Accuracy',
    Min = 1,
    Max = 100,
    Default = 1,
    Round = false,
    Callback = function(value: number)
        Numbers.Multiplier = 0.555 + (value - 1) * (0.35 / -99) -- original 99
    end
})

APModule:CreateDivider({})

APModule:CreateCheckBox({
    Title = 'Cooldown Protection',
    Flag = 'CooldownProtection',
    Callback = function(value: boolean)
        getgenv().CooldownProtection = value
    end
})

APModule:CreateCheckBox({
    Title = 'Auto Ability',
    Flag = 'AutoAbility',
    Callback = function(value: boolean)
        getgenv().AutoAbility = value
    end
})

--anti phantom

APModule:CreateDivider({})

APModule:CreateCheckBox({
    Title = 'Animation Fix',
    Flag = 'Fix',
    Callback = function(value: boolean)
        getgenv().AnimFix = value
    end
})

APModule:CreateCheckBox({
    Title = 'Keypress',
    Flag = 'APKeypress',
    Callback = function(value: boolean)
        getgenv().AutoParryKeypress = value
    end
})

if not IsMobile then
    local HotKeyModule = AP:CreateModule ({
        Title = 'Auto Curve HotKey',
        Description = '',
        Flag = 'HotKey',
        Section = 'right',
        Callback = function(value: boolean)
            getgenv().HotKey = value
        end
    })

    HotKeyModule:CreateCheckBox({
        Title = 'Notify',
        Flag = 'HotKeyNotify',
        Callback = function(value: boolean)
            getgenv().HotKeyNotify = value
        end
    })

    UserInputService.InputBegan:Connect(function(input, process)
        if process or not getgenv().HotKey then
            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard then
            local Keys = {
                [Enum.KeyCode.One] = "Camera",
                [Enum.KeyCode.Two] = "Random",
                [Enum.KeyCode.Three] = "Dot",
                [Enum.KeyCode.Four] = "Backwards",
                [Enum.KeyCode.Five] = "Slow",
                [Enum.KeyCode.Six] = "Accelerated",
                [Enum.KeyCode.Seven] = "High"
            }

            if Keys[input.KeyCode] then
                getgenv().CurrentCurve = Keys[input.KeyCode]
                CurveModule:Update(Keys[input.KeyCode])
            end

            if getgenv().HotKeyNotify then
                Library:CreateNotify({
                    Title = "Curve Changed",
                    Text = "New Curve: " .. Keys[input.KeyCode],
                    Duration = 3
                })
            end
        end
    end)
end


Window:load()

