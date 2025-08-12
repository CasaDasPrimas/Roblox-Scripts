if _G.primas then return warn('already loaded.') end
_G.primas = true

repeat task.wait() until game:IsLoaded()

cloneref = cloneref or function(...) return ... end

local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local UserInputService = cloneref(game:GetService('UserInputService'))
local HttpService = cloneref(game:GetService('HttpService'))
local VirtualUser = cloneref(game:GetService('VirtualUser'))
local RunService = cloneref(game:GetService('RunService'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Players = cloneref(game:GetService('Players'))
local Debris = cloneref(game:GetService('Debris'))
local Stats = cloneref(game:GetService('Stats'))

local LocalPlayer = Players.LocalPlayer

_G.config = {
    parry_arrucacy_division = nil,
    cooldown_protection = nil,
    accuracy_multiplier = nil,
    random_accuracy = nil,
    curve_backwards = '',
    spam_threshold = nil,
    curve_keybind = nil,
    anti_phantom = nil,
    animation_fix = nil,
    field_of_view = nil,
    manual_notify = nil,
    curve_notify = nil,
    curve_method = '',
    skin_changer = nil,
    fly_keybind = nil,
    manual_spam = nil,
    ability_esp = nil,
    curve_random = '',
    auto_parry = nil,
    auto_claim = nil,
    ball_stats = nil,
    curve_slow = '',
    no_render = nil,
    fly_speed = nil,
    curve_none = '',
    auto_spam = nil,
    spam_type = '',
    curve_dot = '',
    ping_fix = nil,
    fly_key = '',
    no_slow = nil,
    names = '',
    fov = nil,
}

if not isfolder('Primas/cfg') then
    makefolder('Primas/cfg')
end

local cfg_path = 'Primas/cfg/blade_ball.json'

local function save_cfg()
    writefile(cfg_path, HttpService:JSONEncode(_G.config))
end

local function load_cfg()
    if isfile(cfg_path) then
        _G.config = HttpService:JSONDecode(readfile(cfg_path))
    end
end

load_cfg()

task.spawn(function()
    repeat
        save_cfg() task.wait(1)
    until not _G.primas
end)

local Fluent = loadstring(game:HttpGet('https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/release.lua'))()

local Window = Fluent:CreateWindow({
    Title = 'Casa das Primas',
    SubTitle = '',
    TabWidth = 115,
    Size = UDim2.fromOffset(440, 315),
    Acrylic = false,
    Theme = 'Grape',
    MinimizeKey = Enum.KeyCode.LeftControl
})

local blatant_tab = Window:AddTab({ Title = 'Blatant', Icon = 'skull' })
local player_tab = Window:AddTab({ Title = 'Player', Icon = 'user' })
local visual_tab = Window:AddTab({ Title = 'Visual', Icon = 'eye' })
local misc_tab = Window:AddTab({ Title = 'Misc', Icon = 'align-justify' })

local Connection = {}

local AutoParry = {}

AutoParry.ball = {
    properties = {
        aerodynamic_time = tick(),
        last_warping = tick(),
        lerp_radians = 0,
        curving = tick(),
    }
}

local grab_animation = nil

local Remotes = {}
local parry_remote = nil

local function linear_predict(a, b, time_volume)
    return a + (b - a) * time_volume
end

task.spawn(function()
    LocalPlayer.Idled:connect(function()
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0),workspace.CurrentCamera.CFrame)
            task.wait()
            VirtualUser:Button2Up(Vector2.new(0, 0),workspace.CurrentCamera.CFrame)
        end)
    end)
end)

task.spawn(function()
    for _, Value in getgc() do
        if type(Value) == "function" and islclosure(Value) then
            if debug.getupvalues(Value) then

            local Protos = debug.getprotos(Value)
            local Upvalues = debug.getupvalues(Value)
            local Constants = debug.getconstants(Value)

                if #Protos == 4 and #Upvalues == 24 and #Constants == 104 then   
                Remotes[debug.getupvalue(Value, 16)] = debug.getconstant(Value, 62)
                parry_remote = debug.getupvalue(Value, 17)

                Remotes[debug.getupvalue(Value, 18)] = debug.getconstant(Value, 64)
                Remotes[debug.getupvalue(Value, 19)] = debug.getconstant(Value, 65)
                    break
                end
            end
        end
    end
end)

local remote = parry_remote

function AutoParry.get_ball()
    for _, ball in workspace.Balls:GetChildren() do
        if ball:GetAttribute('realBall') then
            return ball
        end
    end
end

function AutoParry.get_balls()
    local balls = {}

    for _, ball in workspace.Balls:GetChildren() do
        if ball:GetAttribute('realBall') then
            table.insert(balls, ball)
        end
    end

    return balls
end

local closest_player = nil

function AutoParry.closest_player()
    local max_distance = math.huge
    local found_player = nil

    for _, player in workspace.Alive:GetChildren() do
        if tostring(player) ~= tostring(LocalPlayer) then
            if player.PrimaryPart then
                local Distance = LocalPlayer:DistanceFromCharacter(player.PrimaryPart.Position)
                if Distance < max_distance then
                    max_distance = Distance
                    found_player = player
                end
            end
        end
    end


    closest_player = found_player
    return found_player
end

function AutoParry.grab_animation()
    local animation = ReplicatedStorage.Shared.SwordAPI.Collection.Default:FindFirstChild('GrabParry')

    if not animation then
        return
    end

    local currently_sword = LocalPlayer.Character:GetAttribute('CurrentlyEquippedSword')

    if not currently_sword then
        return
    end

    local sword_data = ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(currently_sword)

    if not sword_data or not sword_data['AnimationType'] then
        return
    end

    for _, object in ReplicatedStorage.Shared.SwordAPI.Collection:GetChildren() do
        if object.Name == sword_data['AnimationType'] then
            if object:FindFirstChild('GrabParry') or object:FindFirstChild('Grab') then
                local sword_animation_type = 'GrabParry'

                if object:FindFirstChild('Grab') then
                    sword_animation_type = 'Grab'
                end

                animation = object[sword_animation_type]
            end
        end
    end

    grab_animation = LocalPlayer.Character.Humanoid.Animator:LoadAnimation(animation)
    grab_animation:Play()
end

local is_mobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

function AutoParry.perfom_parry()
    AutoParry.closest_player()

    local World = {}
    local mouse_position = nil

    local camera = workspace.CurrentCamera

    local LastInputType = UserInputService:GetLastInputType()
    local MouseLocation = UserInputService:GetMouseLocation()

    if LastInputType == Enum.UserInputType.MouseButton1 or (Enum.UserInputType.MouseButton2 or LastInputType == Enum.UserInputType.Keyboard) then
        mouse_position = {MouseLocation.X, MouseLocation.Y}
    else
        mouse_position = {camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2}
    end

    if is_mobile then
        mouse_position = {camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2}
    end

    for _, pointer in workspace.Alive:GetChildren() do
        World[tostring(pointer)] = camera:WorldToScreenPoint(pointer.PrimaryPart.Position)
    end

    local curve_method = _G.config.curve_method

    if curve_method == 'Camera' then
        return {0, camera.CFrame, World, mouse_position}
    end

    if curve_method == 'Dot' then
        local Aimed_Player = nil
        local Closest_Distance = math.huge
        local Mouse_Vector = Vector2.new(mouse_position[1], mouse_position[2])

        for _, v in workspace.Alive:GetChildren() do
            if v ~= LocalPlayer.Character then
                local worldPos = v.PrimaryPart.Position
                local screenPos, isOnScreen = camera:WorldToScreenPoint(worldPos)

                if isOnScreen then
                    local playerScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (Mouse_Vector - playerScreenPos).Magnitude

                    if distance < Closest_Distance then
                        Closest_Distance = distance
                        Aimed_Player = v
                    end
                end
            end
        end

        if Aimed_Player then
            return {0, CFrame.new(LocalPlayer.Character.PrimaryPart.Position, Aimed_Player.PrimaryPart.Position), World, mouse_position}
        else
            return {0, CFrame.new(LocalPlayer.Character.PrimaryPart.Position, closest_player.PrimaryPart.Position), World, mouse_position}
        end
    end

    if curve_method == 'Slow' then
        local characterPos = LocalPlayer.Character.PrimaryPart.Position
        local lookDirectionDown = Vector3.new(0, -1, 0)
        local targetCFrame = CFrame.new(characterPos, characterPos + lookDirectionDown)
        return {0, targetCFrame, World, mouse_position}
    end

    if curve_method == 'Backwards' then
        local Backwards_Direction = camera.CFrame.LookVector * -10000
        Backwards_Direction = Vector3.new(Backwards_Direction.X, 0, Backwards_Direction.Z)
        return {0, CFrame.new(camera.CFrame.Position, camera.CFrame.Position + Backwards_Direction), World, mouse_position}
    end

    if curve_method == 'Random' then
        return {0, CFrame.new(LocalPlayer.Character.PrimaryPart.Position, Vector3.new(math.random(-1000, 1000), math.random(-350, 1000), math.random(-1000, 1000))), World, mouse_position}
    end

    return curve_method
end

local parried = false
local parries =  0

function AutoParry.parry()
    local perfom_parry = AutoParry.perfom_parry()

    for object, args in Remotes do
        object:FireServer(args, remote, unpack(perfom_parry))
    end

    if parries > 7 then
        return false
    end

    parries += 1

    task.delay(0.51, function()
        if parries > 0 then
            parries -= 1
        end
    end)
end

function AutoParry.ball_curved()
    local ball_properties = AutoParry.ball.properties

    local Ball = AutoParry.get_ball()

    if not Ball then
        return false
    end

    local Zoomies = Ball:FindFirstChild('zoomies')

    if not Zoomies then
        return false
    end

    local Velocity = Zoomies.VectorVelocity
    local Ball_Direction = Velocity.Unit

    local Direction = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Unit
    local Dot = Direction:Dot(Ball_Direction)

    local Speed = Velocity.Magnitude
    local Speed_Threshold = math.min(Speed / 100, 40)

    local Direction_Difference = (Ball_Direction - Velocity).Unit
    local Direction_Similarity = Direction:Dot(Direction_Difference)

    local Dot_Difference = Dot - Direction_Similarity
    local Distance = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Magnitude

    local Pings = Stats.Network.ServerStatsItem['Data Ping']:GetValue()

    local Dot_Threshold = 0.5 - (Pings / 1000)
    local Reach_Time = Distance / Speed - (Pings / 1000)

    local Ball_Distance_Threshold = 15 - math.min(Distance / 1000, 15) + Speed_Threshold

    local Clamped_Dot = math.clamp(Dot, -1, 1)
    local Radians = math.rad(math.asin(Clamped_Dot))

    ball_properties.lerp_radians = linear_predict(ball_properties.lerp_radians, Radians, 0.8)

    if Speed > 100 and Reach_Time > Pings / 10 then
        Ball_Distance_Threshold = math.max(Ball_Distance_Threshold - 15, 15)
    end

    if Distance < Ball_Distance_Threshold then
        return false
    end

    if Dot_Difference < Dot_Threshold then
        return true
    end

    if ball_properties.lerp_radians < 0.018 then
        ball_properties.last_warping = tick()
    end

    if (tick() - ball_properties.last_warping) < (Reach_Time / 1.5) then
        return true
    end

    if (tick() - ball_properties.curving) < (Reach_Time / 1.5) then
        return true
    end

    return Dot < Dot_Threshold
end

function AutoParry:get_ball_properties()
    local Ball = AutoParry.get_ball()

    local Ball_Velocity = Vector3.zero
    local Ball_Origin = Ball

    local Ball_Direction = (LocalPlayer.Character.PrimaryPart.Position - Ball_Origin.Position).Unit
    local Ball_Distance = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Magnitude
    local Ball_Dot = Ball_Direction:Dot(Ball_Velocity.Unit)

    return {Velocity = Ball_Velocity, Direction = Ball_Direction, Distance = Ball_Distance, Dot = Ball_Dot}
end

function AutoParry:players_properties()
    AutoParry.closest_player()

    if not closest_player then
        return false
    end

    local players_velocity = closest_player.PrimaryPart.Velocity
    local players_direction = (LocalPlayer.Character.PrimaryPart.Position - closest_player.PrimaryPart.Position).Unit
    local players_distance = (LocalPlayer.Character.PrimaryPart.Position - closest_player.PrimaryPart.Position).Magnitude

    return {velocity = players_velocity, direction = players_direction, distance = players_distance}
end

local spam_range = 0

function AutoParry.perfom_spam(self)
    local ball_properties = AutoParry.ball.properties

    local Ball = AutoParry.get_ball()

    local closest_player = AutoParry.closest_player()

    if not Ball then
        return false
    end

    if not closest_player or not closest_player.PrimaryPart then
        return false
    end

    local Velocity = Ball.AssemblyLinearVelocity
    local Speed = Velocity.Magnitude

    local Direction = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Unit
    local Dot = Direction:Dot(Velocity.Unit)

    local Target_Position = closest_player.PrimaryPart.Position
    local Target_Distance = LocalPlayer:DistanceFromCharacter(Target_Position)

    local Maximum_Spam_Distance = self.Ping + math.min(Speed / 6, 95)

    if self.Entity_Properties.distance > Maximum_Spam_Distance then
        return spam_range
    end

    if self.Ball_Properties.Distance > Maximum_Spam_Distance then
        return spam_range
    end

    if Target_Distance > Maximum_Spam_Distance then
        return spam_range
    end

    local Maximum_Speed = 5 - math.min(Speed / 5, 5)
    local Maximum_Dot = math.clamp(Dot, -1, 0) * Maximum_Speed

    spam_range = Maximum_Spam_Distance - Maximum_Dot

    return spam_range
end

local billboardLabels = {}

function qolPlayerNameVisibility()
        local function createBillboardGui(p)
        local character = p.Character

        while (not character) or (not character.Parent) do
            task.wait()
            character = p.Character
        end

        local head = character:WaitForChild("Head")

        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Adornee = head
        billboardGui.Size = UDim2.new(0, 200, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = head

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextSize = 9
        textLabel.TextWrapped = false
        textLabel.BackgroundTransparency = 1
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

            if _G.config.ability_esp then
                textLabel.Visible = true
                local abilityName = p:GetAttribute("EquippedAbility")
                if abilityName then
                    textLabel.Text = p.DisplayName .. " [" .. abilityName .. "]"
                else
                    textLabel.Text = p.DisplayName
                end
            else
                textLabel.Visible = false
            end
        end)
    end

    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer then
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

getgenv().swordModel = _G.config.names
getgenv().swordAnimations = _G.config.names
getgenv().swordFX = _G.config.names

if getgenv().updateSword and getgenv().skin_changer then
    getgenv().updateSword()
    return
end

local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local swordInstancesInstance = rs:WaitForChild("Shared",9e9):WaitForChild("ReplicatedInstances",9e9):WaitForChild("Swords",9e9)
local swordInstances = require(swordInstancesInstance)

local swordsController

while task.wait() and (not swordsController) do
    for i,v in getconnections(rs.Remotes.FireSwordInfo.OnClientEvent) do
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
    local slashName = swordInstances:GetSword(swordName)
    return (slashName and slashName.SlashName) or "SlashEffect"
end

function setSword()
    if not _G.config.skin_changer then return end
    
    setupvalue(rawget(swordInstances,"EquipSwordTo"),2,false)
    
    swordInstances:EquipSwordTo(plr.Character, getgenv().swordModel)
    swordsController:SetSword(getgenv().swordAnimations)
end

local playParryFunc
local parrySuccessAllConnection

while task.wait() and not parrySuccessAllConnection do
    for i,v in getconnections(rs.Remotes.ParrySuccessAll.OnClientEvent) do
        if v.Function and getinfo(v.Function).name == "parrySuccessAll" then
            parrySuccessAllConnection = v
            playParryFunc = v.Function
            v:Disable()
        end
    end
end

local parrySuccessClientConnection
while task.wait() and not parrySuccessClientConnection do
    for i,v in getconnections(rs.Remotes.ParrySuccessClient.Event) do
        if v.Function and getinfo(v.Function).name == "parrySuccessAll" then
            parrySuccessClientConnection = v
            v:Disable()
        end
    end
end

getgenv().slashName = getSlashName(getgenv().swordFX)

local lastOtherParryTimestamp = 0
local clashConnections = {}

rs.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(...)
    setthreadidentity(2)
    local args = {...}
    if tostring(args[4]) ~= plr.Name then
        lastOtherParryTimestamp = tick()
    elseif _G.config.skin_changer then
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

task.spawn(function()
    while task.wait() do
        if _G.config.skin_changer then
            local char = plr.Character or plr.CharacterAdded:Wait()
            if plr:GetAttribute("CurrentlyEquippedSword") ~= getgenv().swordModel then
                setSword()
            end
            if char and (not char:FindFirstChild(getgenv().swordModel)) then
                setSword()
            end
            for _,v in (char and char:GetChildren()) or {} do
                if v:IsA("Model") and v.Name ~= getgenv().swordModel then
                    v:Destroy()
                end
                task.wait()
            end
        end
    end
end)

local parry_cooldown = LocalPlayer.PlayerGui.Hotbar.Block.UIGradient

local function is_coooldown(uigradient)
    return uigradient.Offset.Y < 0.5
end

local function is_coooldown_phantom(uigradient)
    return uigradient.Offset.Y < 0.2
end

local function cooldown_protection()
    if is_coooldown(parry_cooldown) then
        ReplicatedStorage.Remotes.AbilityButtonPress:Fire()

        return true
    end

    return false
end

local function cooldown_protection_phantom()
    if is_coooldown_phantom(parry_cooldown) then
        ReplicatedStorage.Remotes.AbilityButtonPress:Fire()

        return true
    end

    return false
end

local function anti_phantom()
    workspace.Runtime.ChildAdded:Connect(function(child)
        if child.Name == 'maxTransmission' or child.Name == 'transmissionpart' then
            return true
        end
    end)
end

_G.config.curve_method = 'Camera'

local Last_Parry = 0

blatant_tab:AddToggle('Toggle', {
    Title = 'Auto Parry',
    Default = _G.config.auto_parry or false,
    Callback = function(state)
        _G.config.auto_parry = state

        if state then
            Connection['auto_parry'] = RunService.PreSimulation:Connect(function()
                local ball_properties = AutoParry.ball.properties

                local ball = AutoParry.get_ball()
                local balls = AutoParry.get_balls()

                for _, ball_instance in balls do

                    if not ball_instance then
                        return
                    end

                    local Zoomies = ball_instance:FindFirstChild('zoomies')

                    if not Zoomies then
                        return
                    end

                    ball_instance:GetAttributeChangedSignal('target'):Once(function()
                        parried = false
                    end)

                    if parried then
                        return
                    end

                    local Ball_Target = ball_instance:GetAttribute('target')
                    local One_Target = ball:GetAttribute('target')

                    local Velocity = Zoomies.VectorVelocity

                    local Distance = (LocalPlayer.Character.PrimaryPart.Position - ball_instance.Position).Magnitude

                    local Ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue() / 10

                    local Ping_Threshold = math.clamp(Ping / 10, 5, 17)

                    local Speed = Velocity.Magnitude

                    local cappedSpeedDiff = math.min(math.max(Speed - 9.5, 0), 650)
                    local speed_divisor_base = 2.4 + cappedSpeedDiff * 0.002

                    local effectiveMultiplier = _G.config.parry_arrucacy_division

                    if _G.config.random_accuracy then
                        if Speed < 200 then
                            effectiveMultiplier = (math.random(10, 90) - 1) * (0.55 / 99)
                        else
                            effectiveMultiplier = (math.random(1, 50) - 1) * (0.7 / 99)
                        end
                    end

                    local speed_divisor = speed_divisor_base * effectiveMultiplier
                    local Parry_Accuracy = Ping_Threshold + math.max(Speed / speed_divisor, 9.5)

                    local Curved = AutoParry.ball_curved()

                    if ball_instance:FindFirstChild('AeroDynamicSlashVFX') then
                        Debris:AddItem(ball_instance.AeroDynamicSlashVFX, 0)
                        ball_properties.aerodynamic_time = tick()
                    end

                    if workspace.Runtime:FindFirstChild('Tornado') then
                        if (tick() - ball_properties.aerodynamic_time) < (workspace.Runtime.Tornado:GetAttribute("TornadoTime") or 1) + 0.314159 then
                            return
                        end
                    end

                    if One_Target == tostring(LocalPlayer) and Curved then
                        return
                    end

                    if Ball_Target == tostring(LocalPlayer) and Distance <= Parry_Accuracy and effectiveMultiplier * _G.config.accuracy_multiplier then
                        if not _G.config.auto_spam or not _G.manual_spam then
                            if _G.config.cooldown_protection and cooldown_protection() then
                                return
                            end
                        end

                        local Parry_Time = tick()

                        local Time_View = Parry_Time - (Last_Parry)

                        if Time_View > 0.5 then
                            AutoParry.grab_animation()
                        end

                        if _G.config.anti_phantom and anti_phantom() then
                            task.delay(0.3, function()
                                AutoParry.parry(_G.config.curve_method)
                            end)
                        end

                        if _G.config.anti_phantom and anti_phantom() and _G.config.cooldown_protection and cooldown_protection_phantom() then
                            return
                        end

                        AutoParry.parry(_G.config.curve_method)
                        parried = true
                    end

                    local Last_Parrys = tick()

                    repeat
                        RunService.PreSimulation:Wait()
                    until (tick() - Last_Parrys) >= 1 or not parried
                    parried = false
                end
            end)
        else
            if Connection['auto_parry'] then
                Connection['auto_parry']:Disconnect()
                Connection['auto_parry'] = nil
            end
        end
    end
})

blatant_tab:AddSlider('Slider', {
    Title = 'Accuracy',
    Description = '',
    Default = _G.config.parry_arrucacy_division or 100,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Callback = function(state)
         _G.config.parry_arrucacy_division = 0.8 + (state - 1) * (1.45 / 99)
    end
})

blatant_tab:AddSlider('Slider', {
    Title = 'Accuracy Multiplier',
    Description = '',
    Default = _G.config.accuracy_multiplier or 0.4,
    Min = 0.1,
    Max = 1,
    Rounding = 1,
    Callback = function(state)
         _G.config.accuracy_multiplier = tonumber(state)
    end
})

blatant_tab:AddToggle('Toggle', {
    Title = 'Random Accuracy',
    Default = _G.config.random_accuracy or false,
    Callback = function(state)
        _G.config.random_accuracy = state
    end
})

blatant_tab:AddToggle('Toggle', {
    Title = 'Cooldown Protection',
    Default = _G.config.cooldown_protection or false,
    Callback = function(state)
        _G.config.cooldown_protection = state
    end
})

blatant_tab:AddToggle('Toggle', {
    Title = 'Anti Phantom',
    Default = _G.config.anti_phantom or false,
    Callback = function(state)
        _G.config.anti_phantom = state
    end
})

blatant_tab:AddDropdown('Dropdown', {
    Title = 'Curve Method',
    Values = {
        'Camera',
        'Random',
        'Dot',
        'Slow',
        'Backwards'
    },
    Multi = false,
    Default = _G.config.curve_method or 'Camera',
    Callback = function(state)
        task.spawn(function()
            _G.config.curve_method = state
        end)
    end
})

blatant_tab:AddToggle('Toggle', {
    Title = 'Curve Keybind',
    Default =  _G.config.curve_keybind or false,
    Callback = function(state)
        spawn(function()
            _G.config.curve_keybind = state
        end)
    end
})

blatant_tab:AddToggle('Toggle', {
    Title = 'Curve Notify',
    Default =  _G.config.curve_notify or false,
    Callback = function(state)
        _G.config.curve_notify = state
    end
})

local cam = blatant_tab:AddKeybind('Keybind', {
    Title = 'Camera',
    Mode = 'Toggle',
    Default = _G.config.curve_none or 'One',
    Callback = function()
    spawn(function()
        if _G.config.curve_keybind then
            _G.config.curve_method = 'Camera'
            if _G.config.curve_notify then
                Fluent:Notify({
                    Title = 'Curve Method',
                    Content = 'Camera',
                    Duration = 3
                })
            end
        end
    end)
end
})

cam:OnChanged(function(new)
    _G.config.curve_none = new
end)

local randola = blatant_tab:AddKeybind('Keybind', {
    Title = 'Random',
    Mode = 'Toggle',
    Default = _G.config.curve_random or 'Two',
    Callback = function()
    spawn(function()
        if _G.config.curve_keybind then
            _G.config.curve_method = 'Random'
            if _G.config.curve_notify then
                Fluent:Notify({
                    Title = 'Curve Method',
                    Content = 'Random',
                    Duration = 3
                })
            end
        end
    end)
end
})

randola:OnChanged(function(new)
    _G.config.curve_random = new
end)

local dotado = blatant_tab:AddKeybind('Keybind', {
    Title = 'Dot',
    Mode = 'Toggle',
    Default = _G.config.curve_dot or 'Three',
    Callback = function()
    spawn(function()
        if _G.config.curve_keybind then
            _G.config.curve_method = 'Dot'
            if _G.config.curve_notify then
                Fluent:Notify({
                    Title = 'Curve Method',
                    Content = 'Dot',
                    Duration = 3
                })
            end
        end
    end)
end
})

dotado:OnChanged(function(new)
    _G.config.curve_dot = new
end)

local back = blatant_tab:AddKeybind('Keybind', {
    Title = 'Backwards',
    Mode = 'Toggle',
    Default =  _G.config.curve_backwards or 'Four',
    Callback = function()
    spawn(function()
        if _G.config.curve_keybind then
            _G.config.curve_method = 'Backwards'
            if _G.config.curve_notify then
                Fluent:Notify({
                    Title = 'Curve Method',
                    Content = 'Backwards',
                    Duration = 3
                })
            end
        end
    end)
end
})

back:OnChanged(function(new)
    _G.config.curve_backwards = new
end)

local slowed = blatant_tab:AddKeybind('Keybind', {
    Title = 'Slow',
    Mode = 'Toggle',
    Default =  _G.config.curve_slow or 'Five',
    Callback = function()
    spawn(function()
        if _G.config.curve_keybind then
            _G.config.curve_method = 'Slow'
            if _G.config.curve_notify then
                Fluent:Notify({
                    Title = 'Curve Method',
                    Content = 'Slow',
                    Duration = 3
                })
            end
        end
    end)
end
})

slowed:OnChanged(function(new)
    _G.config.curve_slow = new
end)

blatant_tab:AddToggle('Toggle', {
    Title = 'Auto Spam',
    Default = _G.config.auto_spam or false,
    Callback = function(state)
        _G.config.auto_spam = state

        if state then
            Connection['auto_spam'] = RunService.PreSimulation:Connect(function()
                if _G.manual_spam then
                    return
                end

                local Ball = AutoParry.get_ball()

                if not Ball then
                    return
                end

                local Zoomies = Ball:FindFirstChild('zoomies')

                if not Zoomies then
                    return
                end

                AutoParry.closest_player()

                local Ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue()

                local Ping_Threshold = math.clamp(Ping / 10, 1, 16)

                local Ball_Target = Ball:GetAttribute('target')

                local Ball_Properties = AutoParry:get_ball_properties()
                local Entity_Properties = AutoParry:players_properties()

                local spam_range = AutoParry.perfom_spam({
                    Ball_Properties = Ball_Properties,
                    Entity_Properties = Entity_Properties,
                    Ping = Ping_Threshold
                })

                local Target_Position = closest_player.PrimaryPart.Position
                local Target_Distance = LocalPlayer:DistanceFromCharacter(Target_Position)

                local Direction = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Unit
                local Ball_Direction = Zoomies.VectorVelocity.Unit

                local Dot = Direction:Dot(Ball_Direction)

                local Distance = LocalPlayer:DistanceFromCharacter(Ball.Position)

                if not Ball_Target then
                    return
                end

                if Target_Distance > spam_range or Distance > spam_range then
                    return
                end

                local Pulsed = LocalPlayer.Character:GetAttribute('Pulsed')

                if Pulsed then
                    return
                end

                if Ball_Target == tostring(LocalPlayer) and Target_Distance > 30 and Distance > 30 then
                    return
                end

                local threshold = _G.config.spam_threshold

                if Distance <= spam_range and parries > threshold then
                    AutoParry.parry(_G.config.curve_method)
                end
            end)
        else
            if Connection['auto_spam'] then
                Connection['auto_spam']:Disconnect()
                Connection['auto_spam'] = nil
            end
        end
    end
})

local PF
local SC = nil

if ReplicatedStorage:FindFirstChild("Controllers") then
    for _, child in ipairs(ReplicatedStorage.Controllers:GetChildren()) do
        if child.Name:match("^SwordsController%s*$") then
            SC = child
        end
    end
end

if LocalPlayer.PlayerGui:FindFirstChild("Hotbar") and LocalPlayer.PlayerGui.Hotbar:FindFirstChild("Block") then
    for _, v in next, getconnections(LocalPlayer.PlayerGui.Hotbar.Block.Activated) do
        if SC and getfenv(v.Function).script == SC then
            PF = v.Function
            break
        end
    end
end

blatant_tab:AddToggle('Toggle', {
    Title = 'Animation Fix',
    Default = _G.config.animation_fix or false,
    Callback = function(state)
        _G.config.animation_fix = state

        if state then
            Connection['animation_fix'] = RunService.PreSimulation:Connect(function()

                local Ball = AutoParry.get_ball()

                if not Ball then
                    return
                end

                local Zoomies = Ball:FindFirstChild('zoomies')

                if not Zoomies then
                    return
                end

                AutoParry.closest_player()

                local Ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue()

                local Ping_Threshold = math.clamp(Ping / 10, 1, 16)

                local Ball_Target = Ball:GetAttribute('target')

                local Ball_Properties = AutoParry:get_ball_properties()
                local Entity_Properties = AutoParry:players_properties()

                local spam_range = AutoParry.perfom_spam({
                    Ball_Properties = Ball_Properties,
                    Entity_Properties = Entity_Properties,
                    Ping = Ping_Threshold
                })

                local Target_Position = closest_player.PrimaryPart.Position
                local Target_Distance = LocalPlayer:DistanceFromCharacter(Target_Position)

                local Direction = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Unit
                local Ball_Direction = Zoomies.VectorVelocity.Unit

                local Dot = Direction:Dot(Ball_Direction)

                local Distance = LocalPlayer:DistanceFromCharacter(Ball.Position)

                if not Ball_Target then
                    return
                end

                if Target_Distance > spam_range or Distance > spam_range then
                    return
                end

                local Pulsed = LocalPlayer.Character:GetAttribute('Pulsed')

                if Pulsed then
                    return
                end

                if Ball_Target == tostring(LocalPlayer) and Target_Distance > 30 and Distance > 30 then
                    return
                end

                local threshold = _G.config.spam_threshold

                if Distance <= spam_range and parries > threshold then
                    PF()
                end
            end)
        else
            if Connection['animation_fix'] then
                Connection['animation_fix']:Disconnect()
                Connection['animation_fix'] = nil
            end
        end
    end
})

blatant_tab:AddSlider('Slider', {
    Title = 'Accuracy',
    Description = '',
    Default = _G.config.spam_threshold or 3,
    Min = 1,
    Max = 3,
    Rounding = 1,
    Callback = function(state)
        task.spawn(function()
            _G.config.spam_threshold = tonumber(state)
        end)
    end
})

local sp_type = blatant_tab:AddDropdown('', {
    Title = 'Manual Mode',
    Values = {
        'Legit',
        'Blatant'
    },
    Multi = false,
    Default = _G.config.spam_type or 'Legit',
    Callback = function(state)
        task.spawn(function()
            _G.config.spam_type = state
        end)
    end
})

UserInputService.InputBegan:Connect(function(i,p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.E then
        _G.manual_spam = not _G.manual_spam
    end
end)

local manual = blatant_tab:AddKeybind('Keybind', {
    Title = 'Manual Spam',
    Mode = 'Toggle',
    Default = _G.config.manual_spam or 'E',
    Callback = function(state)
        if state then
            Connection['manual_spam'] = RunService.PreSimulation:Connect(function()
                if _G.manual_spam then
                    if sp_type.Value == 'Legit' then
                        PF()
                    end

                    AutoParry.parry(_G.config.curve_method)
                end
            end)
            if _G.config.manual_notify then
                Fluent:Notify({
                    Title = 'Manual Spam',
                    Content = 'ON',
                    Duration = 4
                })
            end
        else
            if Connection['manual_spam'] then
                Connection['manual_spam']:Disconnect()
                Connection['manual_spam'] = nil
            end
            if _G.config.manual_notify then
                Fluent:Notify({
                    Title = 'Manual Spam',
                    Content = 'OFF',
                    Duration = 4
                })
            end
        end
    end
})

manual:OnChanged(function(new)
    _G.config.manual_spam = new
end)

blatant_tab:AddToggle('Toggle', {
    Title = 'Manual Notify',
    Default = _G.config.manual_notify or false,
    Callback = function(state)
        _G.config.manual_notify = state
    end
})

player_tab:AddToggle('Toggle', {
    Title = 'No Slow',
    Default = false or _G.config.no_slow,
    Callback = function(state)
        _G.config.no_slow = state

        if state then
            Connection['no_slow'] = RunService.PostSimulation:Connect(function()
	            if not LocalPlayer.Character then
		            return
	            end

	            if not workspace.Alive:FindFirstChild(LocalPlayer.Name) then
		            return
	            end

	            if not LocalPlayer.Character:FindFirstChild('Humanoid') then
		            return
	            end

	            if LocalPlayer.Character.Humanoid.WalkSpeed < 36 or LocalPlayer.Character.Humanoid.PlatformStand then
		            LocalPlayer.Character.Humanoid.WalkSpeed = 36
	            end

                if not _G.fly_state then
                    LocalPlayer.Character.Humanoid.PlatformStand = false
                end
            end)
        else
            if Connection['no_slow'] then
                Connection['no_slow']:Disconnect()
                Connection['no_slow'] = nil
            end
        end
    end
})


player_tab:AddToggle('Toggle', {
    Title = 'Fly',
    Default = _G.config.fly or false,
    Callback = function(state)
        _G.config.fly_key = state
    end
})

player_tab:AddToggle('Toggle', {
    Title = 'Fly Keybind',
    Default = _G.config.fly_keybind or false,
    Callback = function(state)
        _G.config.fly_keybind = state
    end
})

local fly = player_tab:AddKeybind('Keybind', {
    Title = 'Fly Key',
    Mode = 'Toggle',
    Default = _G.config.fly_key or 'V',
    Callback = function(state)
        _G.fly_state = state
        
        if state and  _G.config.fly_key and _G.config.fly_keybind then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")

                
            getgenv().OriginalStateType = humanoid:GetState()
                
            getgenv().RagdollHandler = humanoid.StateChanged:Connect(function(oldState, newState)
                if _G.fly_state then
                    if newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll then
                        task.defer(function()
                            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                            humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end)
                    end
                end
            end)
                
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 90000
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.Parent = hrp
                
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Parent = hrp
                
            humanoid.PlatformStand = true

            getgenv().ResetterConnection = RunService.Heartbeat:Connect(function()
                if not _G.fly_state then return end
                    
                if bodyGyro and bodyGyro.Parent then
                    bodyGyro.P = 90000
                    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                end
                    
                if bodyVelocity and bodyVelocity.Parent then
                    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                end
                    
                humanoid.PlatformStand = true
                    
                if not bodyGyro.Parent or not bodyVelocity.Parent then
                    if bodyGyro then bodyGyro:Destroy() end
                    if bodyVelocity then
                        bodyVelocity:Destroy() end
                        
                    bodyGyro = Instance.new("BodyGyro")
                    bodyGyro.P = 90000
                    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bodyGyro.Parent = hrp
                        
                    bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bodyVelocity.Parent = hrp
                end
            end)
                
            getgenv().FlyConnection = RunService.RenderStepped:Connect(function()
                if not _G.fly_state then return end
                local camCF = workspace.CurrentCamera.CFrame
                local moveDir = Vector3.new(0, 0, 0)
                    
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDir = moveDir + camCF.LookVector
                end
                
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - camCF.LookVector
                end
                
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - camCF.RightVector
                end
                
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + camCF.RightVector
                end
                
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                    moveDir = moveDir + Vector3.new(0, 1, 0)
                end
                
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                    moveDir = moveDir - Vector3.new(0, 1, 0)
                end
                    
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit
                end
                
                bodyVelocity.Velocity = moveDir * (_G.config.fly_speed or 50)
                bodyGyro.CFrame = camCF
            end)
        else
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")
            
            humanoid.PlatformStand = false
            if getgenv().FlyConnection then
                getgenv().FlyConnection:Disconnect()
                getgenv().FlyConnection = nil
            end
                
            if getgenv().RagdollHandler then
                getgenv().RagdollHandler:Disconnect()
                getgenv().RagdollHandler = nil
            end
                
            if getgenv().ResetterConnection then
                getgenv().ResetterConnection:Disconnect()
                getgenv().ResetterConnection = nil
            end
                
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChild("Humanoid")
                    
                if humanoid then
                    humanoid.PlatformStand = true
                    if getgenv().OriginalStateType then
                        humanoid:ChangeState(getgenv().OriginalStateType)
                    end
                end
                    
                if hrp then
                    for _, v in ipairs(hrp:GetChildren()) do
                        if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
                            v:Destroy()
                        end
                    end
                end
            end
        end
    end
})

fly:OnChanged(function(new)
    _G.config.fly_key = new
end)

player_tab:AddSlider('Slider', {
    Title = 'Fly Speed',
    Description = '',
    Default = _G.config.fly_speed or 50,
    Min = 1,
    Max = 200,
    Rounding = 1,
    Callback = function(state)
        task.spawn(function()
            _G.config.fly_speed = tonumber(state)
        end)
    end
})

visual_tab:AddToggle('Toggle', {
    Title = 'Ability ESP',
    Default = _G.config.ability_esp or false,
    Callback = function(state)
        _G.config.ability_esp = state
        for _, label in pairs(billboardLabels) do
            label.Visible = state
        end
    end
})

local old_sword = nil

visual_tab:AddToggle('Toggle', {
    Title = 'Skin Changer',
    Default = _G.config.skin_changer or false,
    Callback = function(state)
        _G.config.skin_changer = state

        task.spawn(function()
            if state then
                old_sword = LocalPlayer.Character:GetAttribute('CurrentlyEquippedSword')
                getgenv().updateSword()
            else
                if old_sword then
                    setupvalue(rawget(swordInstances,"EquipSwordTo"),2,false)
                    swordInstances:EquipSwordTo(plr.Character, old_sword)
                    swordsController:SetSword(old_sword)
                end
            end
        end)
    end
})

visual_tab:AddInput('Input', {
    Title = 'Sword Name',
    Default = _G.config.names or LocalPlayer.Character:GetAttribute('CurrentlyEquippedSword').Name,
    Placeholder = 'Placeholder',
    Numeric = false,
    Finished = true,
    Callback = function(state)
        task.spawn(function()
            getgenv().swordModel = state
            getgenv().swordAnimations = state
            getgenv().swordFX = state
            _G.config.names = tostring(state)
            if _G.config.skin_changer then
                getgenv().updateSword()
            end
        end)
    end
})

misc_tab:AddToggle('', {
  Title = 'Auto Claim Rewards',
  Default = _G.config.auto_claim or false,
  Callback = function(state)
    _G.config.auto_claim = state

      if state then
        local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.1.0"):WaitForChild("net")

        task.spawn(function()
          net["RF/RedeemQuestsType"]:InvokeServer("Battlepass", "Weekly")
          net["RF/RedeemQuestsType"]:InvokeServer("Battlepass", "Daily")
          net["RF/ClaimAllDailyMissions"]:InvokeServer("Daily")
          net["RF/ClaimAllWeeklyMissions"]:InvokeServer("Weekly")
          net["RF/ClaimAllClanBPQuests"]:InvokeServer()

          local joinTimestamp = tonumber(plr:GetAttribute("JoinedTimestamp")) + 10
            for i = 1, 6 do
              while workspace:GetServerTimeNow() < joinTimestamp + (i * 300) + 1 do
                task.wait(1)
                if not _G.config.auto_claim then 
                  return 
                end
              end
              net["RF/ClaimPlaytimeReward"]:InvokeServer(i)
            end
        end)
      end
    end
})

misc_tab:AddToggle('Toggle', {
    Title = 'Ping Fix',
    Default = _G.config.ping_fix or false,
    Callback = function(state)
        _G.config.ping_fix = state
        task.spawn(function()
            while _G.config.ping_fix do task.wait()
                if _G.manual_spam or Stats.Network.ServerStatsItem['Data Ping']:GetValue() > 270 then
                    setfpscap(60)
                else
                    if is_mobile then
                        setfpscap(60)
                    else
                        setfpscap(240)
                    end
                end
            end
            if is_mobile then
                setfpscap(60)
            else
                setfpscap(240)
            end
        end)
    end
})

misc_tab:AddToggle('Toggle', {
    Title = 'No Render',
    Default = _G.config.no_render or false,
    Callback = function(state)
        _G.config.no_render = state
        task.spawn(function()
            if state then
                Connection['no_render'] = workspace.Runtime.ChildAdded:Connect(function(child)

                LocalPlayer.PlayerScripts.EffectScripts.ClientFX.Enabled = false
                if child.Name == 'Tornado' then
                    return
                end
                Debris:AddItem(child, 0)
                end)
            else
                LocalPlayer.PlayerScripts.EffectScripts.ClientFX.Enabled = true
                if Connection['no_render'] then
                    Connection['no_render']:Disconnect()
                    Connection['no_render'] = nil
                end
            end
        end)
    end
})

misc_tab:AddToggle('Toggle', {
    Title = 'FOV',
    Default = _G.config.fov or false,
    Callback = function(state)
        _G.config.fov = state
    end
})

misc_tab:AddSlider('Slider', {
    Title = 'FOV',
    Description = '',
    Default = _G.config.field_of_view or 70,
    Min = 70,
    Max = 120,
    Rounding = 1,
    Callback = function(state)
         _G.config.field_of_view = state

         while _G.config.fov do task.wait()
            workspace.CurrentCamera.FieldOfView = state
         end

         if not _G.config.fov then
            workspace.CurrentCamera.FieldOfView = 70
         end
    end
})

ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(_, root)
    if root.Parent and root.Parent ~= LocalPlayer.Character then
        if root.Parent.Parent ~= workspace.Alive then
            return
        end
    end

    AutoParry.closest_player()

    local Ball = AutoParry.get_ball()

    if not Ball then
        return
    end

    local Target_Distance = (LocalPlayer.Character.PrimaryPart.Position - closest_player.PrimaryPart.Position).Magnitude
    local Distance = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Magnitude
    local Direction = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Unit
    local Dot = Direction:Dot(Ball.AssemblyLinearVelocity.Unit)

    local Curve_Detected = AutoParry.ball_curved()

    if Target_Distance < 15 and Distance < 15 and Dot > -0.25 then
        if Curve_Detected then
            AutoParry.parry(_G.config.curve_method)
        end
    end

    if not grab_animation then
        return
    end

    grab_animation:Stop()
end)

ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
    if LocalPlayer.Character.Parent ~= workspace.Alive then
        return
    end

    if not grab_animation then
        return
    end

    grab_animation:Stop()
end)

workspace.Balls.ChildAdded:Connect(function()
    parried = false
end)

workspace.Balls.ChildRemoved:Connect(function(Value)
    parries = 0
    parried = false

    if Connection['target_change'] then
        Connection['target_change']:Disconnect()
        Connection['target_change'] = nil
    end
end)

ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(a, b)
    local Primary_Part = LocalPlayer.Character.PrimaryPart
    local Ball = AutoParry.get_ball()

    if not Ball then
        return
    end

    local Zoomies = Ball:FindFirstChild('zoomies')

    if not Zoomies then
        return
    end

    local Speed = Zoomies.VectorVelocity.Magnitude

    local Distance = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Magnitude
    local Velocity = Zoomies.VectorVelocity

    local Ball_Direction = Velocity.Unit

    local Direction = (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Unit
    local Dot = Direction:Dot(Ball_Direction)

    local Pings = Stats.Network.ServerStatsItem['Data Ping']:GetValue()


    local Speed_Threshold = math.min(Speed / 100, 40)
    local Reach_Time = Distance / Speed - (Pings / 1000)

    local Enough_Speed = Speed > 100
    local Ball_Distance_Threshold = 15 - math.min(Distance / 1000, 15) + Speed_Threshold

    if Enough_Speed and Reach_Time > Pings / 10 then
        Ball_Distance_Threshold = math.max(Ball_Distance_Threshold - 15, 15)
    end

    if b ~= Primary_Part and Distance > Ball_Distance_Threshold then
        AutoParry.ball.properties.curving = tick()
    end
end)

Window:SelectTab(1)

Fluent:Notify({
    Title = 'Casa das Primas 💃',
    Content = 'Loaded!!',
    Duration = 3
})