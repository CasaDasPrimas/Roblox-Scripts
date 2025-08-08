local VirtualInputManager = cloneref(game:GetService('VirtualInputManager'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local UserInputService = cloneref(game:GetService('UserInputService'))
local HttpService = cloneref(game:GetService('HttpService'))
local RunService = cloneref(game:GetService('RunService'))
local Players = cloneref(game:GetService('Players'))
local Debris = cloneref(game:GetService('Debris'))
local Stats = cloneref(game:GetService('Stats'))

local LocalPlayer = Players.LocalPlayer

if not game:IsLoaded() then
    game.Loaded:Wait()
end

_G.config = {
    auto_parry = nil,
    auto_spam = nil,
    animation_fix = nil,
    curve_method = nil,
    curve_keybind = nil,
    curve_none = '',
    curve_random = '',
    curve_dot = '',
    curve_slow = '',
    curve_backwards = '',
    ability_esp = nil,
    skin_changer = nil,
    parry_arrucacy_division = nil,
    spam_threshold = nil,
    no_slow = nil,
    no_render = nil,
    ping_fix = nil,
    names = ''
}

if not isfolder('Casa Das Primas') then
    makefolder('Casa Das Primas')
end

local cfg_path = 'Casa Das Primas/blade_ball.json'

local function save_cfg()
    writefile(cfg_path, HttpService:JSONEncode(_G.config))
end

local function load_cfg()
    if isfile(cfg_path) then
        _G.config = HttpService:JSONDecode(readfile(cfg_path))
    end
end

load_cfg()

local Fluent = loadstring(game:HttpGet('https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/release.lua'))()

local Window = Fluent:CreateWindow({
    Title = 'Casa Das Primas 💃🏼',
    SubTitle = 'mani | beto',
    TabWidth = 115,
    Size = UDim2.fromOffset(440, 315),
    Acrylic = false,
    Theme = 'AMOLED',
    MinimizeKey = Enum.KeyCode.LeftControl
})

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

if not LPH_OBFUSCATED then
    function LPH_JIT(Function) return Function end
    function LPH_JIT_MAX(Function) return Function end
    function LPH_NO_VIRTUALIZE(Function) return Function end
end

local PropertyChangeOrder = {}

local HashOne
local HashTwo
local HashThree

LPH_NO_VIRTUALIZE(function()
    for _, Value in next, getgc() do
        if rawequal(typeof(Value), "function") and islclosure(Value) and getrenv().debug.info(Value, "s"):find("SwordsController") then
            if rawequal(getrenv().debug.info(Value, "l"), 276) then
                HashOne = getconstant(Value, 62)
                HashTwo = getconstant(Value, 64)
                HashThree = getconstant(Value, 65)
            end
        end
    end
end)()

LPH_NO_VIRTUALIZE(function()
    for _, Object in next, game:GetDescendants() do
        if Object:IsA("RemoteEvent") and string.find(Object.Name, "\n") then
            Object.Changed:Once(function()
                table.insert(PropertyChangeOrder, Object)
            end)
        end
    end
end)()

repeat
    task.wait()
until #PropertyChangeOrder == 3

local ShouldPlayerJump = PropertyChangeOrder[1]
local MainRemote = PropertyChangeOrder[2]
local GetOpponentPosition = PropertyChangeOrder[3]

for _, Value in pairs(getconnections(LocalPlayer.PlayerGui.Hotbar.Block.Activated)) do
    if Value and Value.Function and not iscclosure(Value.Function)  then
        for Index2,Value2 in pairs(getupvalues(Value.Function)) do
            if type(Value2) == "function" then
                parry_remote = getupvalue(getupvalue(Value2, 2), 17)
            end
        end
    end
end

local function parry(...)
    ShouldPlayerJump:FireServer(HashOne, parry_remote, ...)
    MainRemote:FireServer(HashTwo, parry_remote, ...)
    GetOpponentPosition:FireServer(HashThree, parry_remote, ...)
end

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

local first_parry = false

local parried = false
local parries =  0

function AutoParry.parry()
    local perfom_parry = AutoParry.perfom_parry()

    if not first_parry then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)

        first_parry = true
    else
        parry(perfom_parry[1], perfom_parry[2], perfom_parry[3], perfom_parry[4])
    end

    if parries > 7 then
        return false
    end

    parries += 1

    task.delay(0.5, function()
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
        textLabel.TextSize = 8
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


type functionInfo = {
    scriptName: string,
    name: string,
    line: number,
    upvalueCount: number,
    constantCount: number
}

local function getFunction(t:functionInfo)
    t = t or {}
    local functions = {}
    local function findMatches()
        setthreadidentity(6)
        for i,v in getgc() do
            if type(v) == "function" and islclosure(v) then
                local match = true
                local info = getinfo(v)
                if t.scriptName and (not tostring(getfenv(v).script):find(t.scriptName)) then
                    match = false
                end
                if t.name and info.name ~= t.name then
                    match = false
                end
                if t.line and info.currentline ~= t.line then
                    match = false
                end
                if t.upvalueCount and #getupvalues(v) ~= t.upvalueCount then
                    match = false
                end
                if t.constantCount and #getconstants(v) ~= t.constantsCount then
                    match = false
                end
                if match then
                    table.insert(functions,v)
                end
            end
        end
        setthreadidentity(8)
    end

    findMatches()

    if #functions == 0 then
        while task.wait(1) and #functions == 0 do
            findMatches()
        end
    end
    
    if #functions == 1 then
        return functions[1]
    end
end

type tableInfo = {
    highEntropyTableIndex: string,
}

getgenv().swordModel = _G.config.names
getgenv().swordAnimations = _G.config.names
getgenv().swordFX = _G.config.names

if getgenv().updateSword and getgenv().skin_changer then
    getgenv().updateSword()
    return
end

local function getTable(t:tableInfo)
    t = t or {}
    local tables = {}
    
    local function findMatches()
        for i,v in getgc(true) do
            if type(v) == "table" then
                local match = true
                if t.highEntropyTableIndex and (not rawget(v,t.highEntropyTableIndex)) then
                    match = false
                end
                if match then
                    table.insert(tables,v)
                end
            end
        end
    end

    findMatches()

    if #tables == 0 then
        while task.wait(1) and #tables == 0 do
            findMatches()
        end
    end

    if #tables == 1 then
        return tables[1]
    end
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
    while task.wait(1) do
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

local blatant_tab = Window:AddTab({ Title = 'Blatant', Icon = 'skull' })
local player_tab = Window:AddTab({ Title = 'Player', Icon = 'user' })
local misc_tab = Window:AddTab({ Title = 'Misc', Icon = 'align-justify' })

_G.config.curve_method = 'Camera'

local Last_Parry = 0

blatant_tab:AddToggle('Toggle', {
    Title = 'Auto Parry',
    Default = _G.config.auto_parry or false,
    Callback = function(state)
        _G.config.auto_parry = state
        save_cfg()

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

                    local cappedSpeedDiff = math.min(math.max(Speed - 5.5, 0), 900)
                    local speed_divisor_base = 3 + cappedSpeedDiff * 0.018

                    local effectiveMultiplier = 0.95 + (1 + _G.config.parry_arrucacy_division - 1) * (2 / 99)

                    local speed_divisor = speed_divisor_base * effectiveMultiplier
                    local Parry_Accuracy = Ping_Threshold + math.max(Speed / speed_divisor, 8)

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

                    if Ball_Target == tostring(LocalPlayer) and Distance <= Parry_Accuracy * _G.config.parry_arrucacy_division / 3.5 then
                        local Parry_Time = os.clock()

                        local Time_View = Parry_Time - (Last_Parry)

                        if Time_View > 0.5 then
                            AutoParry.grab_animation()
                        end

                        AutoParry.parry(_G.config.curve_method)

                        Last_Parry = Parry_Time
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
    Title = 'Parry Accuracy',
    Description = '',
    Default = _G.config.parry_arrucacy_division or 100,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Callback = function(state)
        task.spawn(function()
            _G.config.parry_arrucacy_division = 10 + (1 + tonumber(state) - 1) * (10 / 99)
            save_cfg()
        end)
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
    Default = _G.config.curve_method or 1,
    Callback = function(state)
        task.spawn(function()
            _G.config.curve_method = state
            save_cfg()
        end)
    end
})

blatant_tab:AddToggle('Toggle', {
    Title = 'Curve Keybind',
    Default =  _G.config.curve_keybind or false,
    Callback = function(state)
        spawn(function()
        _G.config.curve_keybind = state
        save_cfg()
        end)
    end
})

local curve_none = blatant_tab:AddKeybind('Keybind', {
    Title = 'Camera',
    Mode = 'Toggle',
    Default = _G.config.curve_none or 'One',
    Callback = function()
    spawn(function()
        if _G.config.curve_keybind then
            _G.config.curve_method = 'Camera'
            Fluent:Notify({
                Title = 'Curve Method',
                Content = 'Camera',
                Duration = 4
            })
        end
    end)
end
})

curve_none:OnChanged(function()
    _G.config.curve_none = curve_none.Value
    save_cfg()
end)

local curve_random = blatant_tab:AddKeybind('Keybind', {
    Title = 'Random',
    Mode = 'Toggle',
    Default = _G.config.curve_random or 'Two',
    Callback = function(state)
    spawn(function()
        if _G.config.curve_keybind then
            _G.config.curve_method = 'Random'
            Fluent:Notify({
                Title = 'Curve Method',
                Content = 'Random',
                Duration = 4
            })
        end
    end)
end
})

curve_random:OnChanged(function()
    _G.config.curve_random = curve_random.Value
    save_cfg()
end)

local curve_dot = blatant_tab:AddKeybind('Keybind', {
    Title = 'Dot',
    Mode = 'Toggle',
    Default = _G.config.curve_dot or 'Three',
    Callback = function(state)
    spawn(function()
        if _G.config.curve_keybind then
            _G.config.curve_method = 'Dot'
            Fluent:Notify({
                Title = 'Curve Method',
                Content = 'Dot',
                Duration = 4
            })
        end
    end)
end
})

curve_dot:OnChanged(function()
    _G.config.curve_dot = curve_dot.Value
    save_cfg()
end)

local curve_slow = blatant_tab:AddKeybind('Keybind', {
    Title = 'Slow',
    Mode = 'Toggle',
    Default =  _G.config.curve_slow or 'Four',
    Callback = function(state)
    spawn(function()
        if _G.config.curve_keybind then
            _G.config.curve_method = 'Slow'
            Fluent:Notify({
                Title = 'Curve Method',
                Content = 'Slow',
                Duration = 4
            })
        end
    end)
end
})

curve_slow:OnChanged(function()
    _G.config.curve_slow = curve_slow.Value
    save_cfg()
end)

local backwards = blatant_tab:AddKeybind('Keybind', {
    Title = 'Backwards',
    Mode = 'Toggle',
    Default =  _G.config.curve_backwards or 'Five',
    Callback = function(state)
    spawn(function()
        if _G.config.curve_keybind then
            _G.config.curve_method = 'Backwards'
            Fluent:Notify({
                Title = 'Curve Method',
                Content = 'Backwards',
                Duration = 4
            })
        end
    end)
end
})

backwards:OnChanged(function()
    _G.config.curve_backwards = backwards.Value
    save_cfg()
end)

blatant_tab:AddToggle('Toggle', {
    Title = 'Auto Spam',
    Default = false or _G.config.auto_spam,
    Callback = function(state)
        _G.config.auto_spam = state
        save_cfg()

        if state then
            Connection['auto_spam'] = RunService.PreSimulation:Connect(function()
                local ball_properties = AutoParry.ball.properties

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


    blatant_tab:AddToggle('Toggle', {
        Title = 'Animation Fix',
        Default = false or _G.config.animation_fix,
        Callback = function(state)
            _G.config.animation_fix = state
            save_cfg()

            if state then
                if not _G.config.auto_spam then
                    return
                end
                if _G.config.auto_spam then
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
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        end
                    end)
                end
            else
                if Connection['animation_fix'] then
                    Connection['animation_fix']:Disconnect()
                    Connection['animation_fix'] = nil
                end
            end
        end
    })

blatant_tab:AddSlider('Slider', {
    Title = 'Spam Accuracy',
    Description = '',
    Default = _G.config.spam_threshold or 3,
    Min = 1,
    Max = 3,
    Rounding = 1,
    Callback = function(state)
        task.spawn(function()
            _G.config.spam_threshold = tonumber(state)
            save_cfg()
        end)
    end
})

UserInputService.InputBegan:Connect(function(i,p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.E then
        _G.manual_spam = not _G.manual_spam
    end
end)

blatant_tab:AddKeybind('Keybind', {
    Title = 'Manual Spam',
    Mode = 'Toggle',
    Default = 'E',
    Callback = function(state)
        if state then
            Fluent:Notify({
                Title = 'Manual Spam',
                Content = 'ON',
                Duration = 4
            })
            Connection['manual_spam'] = RunService.PreSimulation:Connect(function()
                if _G.manual_spam then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    AutoParry.parry(_G.config.curve_method)
                end
            end)
        else
            Fluent:Notify({
                Title = 'Manual Spam',
                Content = 'OFF',
                Duration = 4
            })
            if Connection['manual_spam'] then
                Connection['manual_spam']:Disconnect()
                Connection['manual_spam'] = nil
            end
        end
    end,
})

player_tab:AddToggle('Toggle', {
    Title = 'No Slow',
    Default = false or _G.config.no_slow,
    Callback = function(state)
        _G.config.no_slow = state
        save_cfg()

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

	            if LocalPlayer.Character.Humanoid.WalkSpeed < 36 then
		            LocalPlayer.Character.Humanoid.WalkSpeed = 36
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

misc_tab:AddToggle('Toggle', {
    Title = 'Ability ESP',
    Default = false or _G.config.ability_esp,
    Callback = function(state)
        _G.config.ability_esp = state
        save_cfg()
        for _, label in pairs(billboardLabels) do
            label.Visible = state
        end
    end
})

misc_tab:AddToggle('Toggle', {
    Title = 'No Render',
    Default = _G.config.no_render or false,
    Callback = function(state)
        _G.config.no_render = state
        save_cfg()
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
    Title = 'Ping Fix',
    Default = _G.config.ping_fix or false,
    Callback = function(state)
        _G.config.ping_fix = state
        save_cfg()
        task.spawn(function()
            while _G.config.ping_fix do task.wait()
                if _G.manual_spam or Stats.Network.ServerStatsItem['Data Ping']:GetValue() > 270 then
                    setfpscap(60)
                else
                    setfpscap(240)
                end
            end
            setfpscap(240)
        end)
    end
})

local oldSword = nil

misc_tab:AddToggle('Toggle', {
    Title = 'Skin Changer',
    Default = false or _G.config.skin_changer,
    Callback = function(state)
        _G.config.skin_changer = state
        save_cfg()
        task.spawn(function()
            if state then
                oldSword = LocalPlayer.Character:GetAttribute('CurrentlyEquippedSword')
                getgenv().updateSword()
            else
                if oldSword then
                    setupvalue(rawget(swordInstances,"EquipSwordTo"),2,false)

                    swordInstances:EquipSwordTo(plr.Character, oldSword)
                    swordsController:SetSword(oldSword)
                end
            end
        end)
    end
})

misc_tab:AddInput('Input', {
    Title = 'Sword Name',
    Default = _G.config.names or LocalPlayer.Character:GetAttribute('CurrentlyEquippedSword').Name,
    Placeholder = 'Placeholder',
    Numeric = false,
    Finished = true,
    Callback = function(state)
        spawn(function()
            getgenv().swordModel = state
            getgenv().swordAnimations = state
            getgenv().swordFX = state
            _G.config.names = tostring(state)
            save_cfg()
            if _G.config.skin_changer then
                getgenv().updateSword()
            end
        end)
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

    if Connection['Target Change'] then
        Connection['Target Change']:Disconnect()
        Connection['Target Change'] = nil
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
    Title = 'Casa Das Primas',
    Content = 'Loaded.',
    Duration = 4
})