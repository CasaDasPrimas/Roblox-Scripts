repeat task.wait() until game:IsLoaded()

if _G.FTF then
    return warn('[Casa Das Primas]: Already Executed.')
end
_G.FTF = true

--// 📦 Serviços
cloneref = cloneref or function(...) return ... end

local Chat = cloneref(game:GetService('TextChatService'))
local Vim = cloneref(game:GetService('VirtualInputManager'))
local Mkt = cloneref(game:GetService('MarketplaceService'))
local Re = cloneref(game:GetService('ReplicatedStorage'))
local Uis = cloneref(game:GetService('UserInputService'))
local Action = cloneref(game:GetService('ContextActionService'))
local Http = cloneref(game:GetService('HttpService'))
local Rs = cloneref(game:GetService('RunService'))
local Starter = cloneref(game:GetService('StarterGui'))
local Lighting = cloneref(game:GetService('Lighting'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Pl = cloneref(game:GetService('Players'))
local Lp = Pl.LocalPlayer
local PlayerGui = Lp:WaitForChild('PlayerGui')

--// 🌍 Verificação de Mapa
local Maps = {
    [132745842491660] = 'Pro Server',
    [100448435050950] = 'Treino FTF',
    [74436060734791] = 'Treino2 FTF',
    [17539432357]  = 'Área de Teste',
    [125624013879756]  = 'VC Server',
    [1738581510]    = 'Trading Post',
    [893973440]       = 'Mapa Normal'
}

if not Maps[game.PlaceId] then
    return Lp:Kick('Thats not a FTF Map nigga.')
elseif not gethui() then
    return Lp:Kick('Low sUNC? \n Trash Executor.')
end

--// 🧠 Variáveis do Jogo
local SavedStats = Lp:WaitForChild('SavedPlayerStatsModule')
local TempStats = Lp:WaitForChild('TempPlayerStatsModule')
local ActionBox = PlayerGui.ScreenGui:FindFirstChild('ActionBox')
local GameActive = Re:WaitForChild('IsGameActive')
local Remote = Re:WaitForChild('RemoteEvent')
local Animations = Re:WaitForChild('Animations')
local Atmosphere = Lighting.Atmosphere
local TotalDistance = math.huge

--// 🎮 Variáveis do Cliente
local ActionFrame = PlayerGui:WaitForChild('ContextActionGui'):WaitForChild('ContextButtonFrame')
local Character = Lp.Character or Lp.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild('Humanoid')
local CrawlAnim = Humanoid:LoadAnimation(Animations:WaitForChild('AnimCrawl'))
local IsMobile = Uis.TouchEnabled and not Uis.KeyboardEnabled
local Font = Enum.Font.Fantasy
local ScriptWhitelist = {}
local Gui = gethui()

--// 🗂️ Interface no CoreGui
local Folder = CoreGui:FindFirstChild('Casa Das Primas') or Instance.new('Folder')
Folder.Name = '[Casa Das Primas]'
Folder.Parent = CoreGui

local Assets = Folder:FindFirstChild('Assets') or Instance.new('Folder')
Assets.Name = 'Assets'
Assets.Parent = Folder

--//📦 Tables e Multi-Tables
_G.config = {
    interact_aura = nil,
    enable_crawl = nil,
    tie_distance = nil,
    hit_distance = nil,
    void_protect = nil,
    anti_chatspy = nil,
    esp_dropdown = {},
    freeze_aura = nil,
    touch_fling = nil,
    auto_escape = nil,
    fling_power = nil,
    anti_error = nil,
    fullbright = nil,
    anti_fling = nil,
    save_aura = nil,
    auto_save = nil,
    auto_tie = nil,
    anti_afk = nil,
    hit_aura = nil,
    esp_plrs = nil,
    backpack = nil,
    facefuck = nil,
    no_stun = nil,
    headsit = nil,
    buttons = {},
    b_mod = nil,
    c_mod = nil,
    nofog = nil,
    fling = nil,
    focus = nil,
    exit = nil,
    view = nil,
    bang = nil,
    suck = nil,
    size = nil,
    uwu = nil,
    pod = nil,
    pc = nil,
    y = nil,
    x = nil
}

local Initial = {
    fullbrightTable = {},
    fogTable = {},
    Connects = {},
    Parents = {},
    properties = {
    lpValue = 0,
    root = nil,
    OldVelocity = nil
    }
}

--load config
task.spawn(function()
    if not isfolder('Casa Das Primas') then
        makefolder('Casa Das Primas')
    else
        local path = 'Casa Das Primas/Flee The Facility.json'

        if isfile(path) then
            _G.config = Http:JSONDecode(readfile(path))
            repeat writefile(path, Http:JSONEncode(_G.config)) task.wait(1) until not _G.FTF
        end
    end
end)


-- functions
function brightness()
    local other = Re.GetValue('CurrentMap')
    local airport = workspace:FindFirstChild('Airport by deadlybones28')

    Lighting.Brightness = 2
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)

    if other ~= airport then
        Lighting.ClockTime = 14
    end
end

function fog()
    Atmosphere.Density = 0
    Atmosphere.Offset = 0
end

function GetRoot(char)
    return char:FindFirstChild('HumanoidRootPart')
end

function GetTorso(char)
    return char:FindFirstChild('Torso')
end


function RandomChar()
    local length = math.random(1, 5)
    local array = {}
    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
end

function reset()
    if Initial and Initial.Connects then
        for _, con in pairs(Initial.Connects) do
            if con and typeof(con) == 'Instance' and con.Disconnect then
                con:Disconnect()
            end
        end
        Initial.Connects = {}
    end

    if Folder and Folder.Parent then
        Folder:Destroy()
        Folder = nil
    end
end

task.spawn(function()
    local vip = workspace:FindFirstChild('VipBoard')
    for v, obj in ipairs(vip:GetDescendants()) do
        if obj:IsA('ClickDetector') then
            obj.Parent = Assets
        end
    end
end)

local largura, altura = 500, 350

if not IsMobile then
    largura, altura = 600, 460
else
    local screengui = Instance.new('ScreenGui')
    local button = Instance.new('ImageButton')
    local frame1 = Instance.new('Frame')
    local frame2 = Instance.new('Frame')
    local UICorner = Instance.new('UICorner')

    screengui.Name = 'HubButton'
    screengui.Parent = Folder

    frame1.BackgroundTransparency = 1
    frame1.Size = UDim2.new(0, 46, 0, 48)
    frame1.Position = UDim2.new(0, 16, 0, 10)
    frame1.Parent = screengui

    frame2.BackgroundTransparency = 1
    frame2.Size = UDim2.new(0, 46, 0, 48)
    frame2.Parent = frame1

    button.Parent = frame2
    button.BackgroundTransparency = 1
    button.Position = UDim2.new(0, 0, 0.5, -34)
    button.Size = UDim2.new(0, 46, 0, 46)
    button.Draggable = true
    button.Image = 'rbxassetid://18540832673'
    button.MouseButton1Click:Connect(function()
        Vim:SendKeyEvent(true, 'Insert', false, game)
        Vim:SendKeyEvent(false, 'Insert', false, game)
    end)

    UICorner.Parent = button
    UICorner.CornerRadius = UDim.new(1, 0)
end

local Fluent = loadstring(game:HttpGet('https://raw.githubusercontent.com/DevBeto-Cyber/Workspace/refs/heads/main/Library.txt', true))()

local Window = Fluent:CreateWindow(
    {
        Title = 'Casa Das Primas - by Beto   |              ',
        SubTitle = Mkt:GetProductInfo(game.PlaceId).Name,
        TabWidth = 100,
        Size = UDim2.fromOffset(largura, altura),
        Acrylic = false,
        Theme = 'Darker',
        MinimizeKey = Enum.KeyCode.Insert
    }
)

local Tabs = {
    Status = Window:AddTab({Title = 'Game Status', Icon = 'database'}),
    Main = Window:AddTab({Title = 'Main', Icon = 'book'}),
    Esp = Window:AddTab({Title = 'Esp', Icon = 'eye'}),
    Players = Window:AddTab({Title = 'Players', Icon = 'users'}),
    Scripts = Window:AddTab({Title = 'Scripts', Icon = 'align-justify'}),
    Settings = Window:AddTab({Title = 'Settings', Icon = 'settings'})
}

task.spawn(function()
    for _, obj in Gui:GetChildren() do
        if obj.Name == 'Library' then
            obj.Parent = Folder
        end
    end
end)

local stats = Tabs.Status:AddSection('Hello! ' .. Lp.DisplayName)
local tempo = 'Calculando...'
local paragraph = stats:AddParagraph(
    {
    Title = 'Run time:',tempo,
    Content = ''
    }
)

task.spawn(function()
    repeat
        local totalS = math.floor(workspace.DistributedGameTime)
        local h = math.floor(totalS / 3600)
        local m = math.floor((totalS % 3600) / 60)
        local s = totalS % 60

        if h > 0 then
            tempo = string.format('%d Hour(s), %d Minute(s), %d Second(s)', h, m, s)
        elseif m > 0 then
            tempo = string.format('%d Minute(s), %d Second(s)', m, s)
        else
            tempo = string.format('%d Second(s)', s)
        end
        paragraph:SetTitle('Run time: ' .. tempo)
        task.wait(1)
    until not _G.FTF
end)

local Detector = stats:AddParagraph(
    {
        Title = 'Calculando...',
        Content = ''
    }
)

local lastState = GameActive.Value
local beastchances = ''

Initial.Connects['beastloop'] = GameActive:GetPropertyChangedSignal('Value'):Connect(function()
    if lastState == true and GameActive.Value == false then
        Initial.properties.lpValue += 1
    end
    lastState = GameActive.Value
end)

function NextBeast()
    local highpoint = 0
    local beast

    for _, plrs in pairs(Pl:GetPlayers()) do
        if plrs:FindFirstChild('SavedPlayerStatsModule') then
            local saved = plrs:FindFirstChild('SavedPlayerStatsModule').GetValue('BeastChance')

            if plrs == Lp and saved == 0 then
                Initial.properties.lpValue = 0
            end

            if saved > highpoint then
                highpoint = saved
                beast = plrs
            elseif saved == highpoint then
                if plrs == Lp and Initial.properties.lpValue >= 4 then
                    beast = Lp
                end
            end
        end
    end

    if beast then
        if beast == Lp then
            beastchances = 'Is You'
        elseif beast ~= Lp then
            beastchances = beast.Name
        end
    else
        beastchances = 'Unknown'
    end

    Detector:SetTitle('The Next Beast is: ' .. beastchances)
end
NextBeast()

Initial.Connects['NextBeast'] = SavedStats.BeastChance:GetPropertyChangedSignal('Value'):Connect(function()
    NextBeast()
end)

local IsBeastNow = TempStats.GetValue('IsBeast')

Initial.Connects['GetBeast'] = TempStats.IsBeast:GetPropertyChangedSignal('Value'):Connect(function()
    local val = TempStats.GetValue('IsBeast')
    IsBeastNow = val == true
end)

-- main sec
local Main = Tabs.Main:AddSection('')

Main:AddButton(
    {
        Title = 'Shiftlock',
        Description = 'Use LeftControl to active',
        Callback = function()
            local ScreenGui = Instance.new('ScreenGui')
            local Button = Instance.new('ImageButton')
            local Cursor = Instance.new('ImageLabel')
            local States = {
                Off = 'rbxasset://textures/ui/mouseLock_off@2x.png',
                On = 'rbxasset://textures/ui/mouseLock_on@2x.png',
                Lock = 'rbxasset://textures/MouseLockedCursor.png'
            }

            local MaxLength = 900000
            local DisabledOffset = CFrame.new(-1.7, 0, 0)
            local EnabledOffset = CFrame.new(1.7, 0, 0)

            ScreenGui.ResetOnSpawn = false
            ScreenGui.Name = 'Shiftlock'
            ScreenGui.Parent = Folder

            Button.Visible = false

            Cursor.SizeConstraint = Enum.SizeConstraint.RelativeXX
            Cursor.Position = UDim2.new(0.5, 0, 0.5, 0)
            Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
            Cursor.Size = UDim2.new(0.03, 0, 0.03, 0)
            Cursor.BackgroundTransparency = 1
            Cursor.Image = States.Lock
            Cursor.Parent = ScreenGui
            Cursor.Visible = false
            Cursor.Name = 'Cursor'

            local shiftlockEnabled = false

            local function toggleShiftlock()
                shiftlockEnabled = not shiftlockEnabled

                task.spawn(function()
                    while shiftlockEnabled do
                        Rs.RenderStepped:Wait()
                        pcall(function()
                            if Character and Character:FindFirstChild('Humanoid') and workspace.CurrentCamera and not TempStats.Ragdoll.Value and not TempStats.Captured.Value then
                                if IsMobile then
                                    Button.Image = States.On
                                end
                                Character.Humanoid.AutoRotate = false
                                Cursor.Visible = true

                                GetRoot(Character).CFrame = CFrame.new(
                                    GetRoot(Character).Position,
                                    Vector3.new(
                                        workspace.CurrentCamera.CFrame.LookVector.X * MaxLength,
                                        GetRoot(Character).Position.Y,
                                        workspace.CurrentCamera.CFrame.LookVector.Z * MaxLength
                                    )
                                )

                                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * EnabledOffset
                                workspace.CurrentCamera.Focus = CFrame.fromMatrix(
                                    workspace.CurrentCamera.Focus.Position,
                                    workspace.CurrentCamera.CFrame.RightVector,
                                    workspace.CurrentCamera.CFrame.UpVector
                                ) * EnabledOffset
                            else
                                Cursor.Visible = false
                                if Character and Character:FindFirstChild('Humanoid') then
                                    Character.Humanoid.AutoRotate = true
                                end
                                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * DisabledOffset
                            end
                        end)
                        if not shiftlockEnabled or not _G.FTF then break end
                    end

                    if IsMobile then
                        Button.Image = States.Off
                    end
                    Cursor.Visible = false
                    if Character and Character:FindFirstChild('Humanoid') then
                        Character.Humanoid.AutoRotate = true
                    end
                    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * DisabledOffset
                end)
            end

            if IsMobile then
                Button.Size = UDim2.new(0.0636147112, 0, 0.0661305636, 0)
                Button.SizeConstraint = Enum.SizeConstraint.RelativeXX
                Button.Position = UDim2.new(0.8, 0, 0.35, 0)
                Button.BackgroundTransparency = 1
                Button.Visible = true
                Button.Parent = ScreenGui
                Button.Image = States.Off

                Button.MouseButton1Click:Connect(toggleShiftlock)
            else
                Uis.InputBegan:Connect(function(input, gameProcessed)
                    if input.KeyCode == Enum.KeyCode.LeftControl and not gameProcessed then
                        toggleShiftlock()
                    end
                end)
            end
        end
    }
)


Main:AddToggle('',
    {
        Title = 'Anti Error',
        Default = _G.config.anti_error or false,
        Callback = function(val)
            _G.config.anti_error = val

            task.spawn(function()
                while val do
                    local currentAnim = TempStats.GetValue('CurrentAnimation')
                    if currentAnim == 'Typing' then
                        Remote:FireServer('SetPlayerMinigameResult', true)

                        if not val or not _G.FTF then break end
                        task.wait()
                    end
                end
            end)
        end
    }
)

Main:AddToggle('',
    {
        Title = 'Touch Fling',
        Default = _G.config.touch_fling or false,
        Callback = function(val)
            _G.config.touch_fling = val

            task.spawn(function()
                while val do
                    Rs.Heartbeat:Wait()
                    pcall(function()
                        Initial.properties.root = GetRoot(Character)

                        if Initial.properties.root then
                            Initial.properties.OldVelocity = Initial.properties.root.Velocity
                            Initial.properties.root.Velocity = (Initial.properties.OldVelocity * _G.config.fling_power * 100) + Vector3.new(0, _G.config.fling_power * 100, 0)
                            Rs.RenderStepped:Wait()
                            Initial.properties.root.Velocity = Initial.properties.OldVelocity
                            Rs.Stepped:Wait()
                            Initial.properties.root.Velocity = Initial.properties.OldVelocity + Vector3.new(0, 0.1, 0)
                        end
                    end)
                    if not val or not _G.FTF then break end
                end

                pcall(function()
                    Initial.properties.root = GetRoot(Character)

                    if Initial.properties.root and Initial.properties.OldVelocity then
                        Initial.properties.root.Velocity = Initial.properties.OldVelocity
                    end
                end)
            end)
        end
    }
)

Main:AddToggle('',
    {
        Title = 'Full Brightness',
        Default = _G.config.fullbright or false,
        Callback = function(val)
            _G.config.fullbright = val

            if val then
                if Initial.Connects['fullbright'] then
                    Initial.Connects['fullbright']:Disconnect()
                    Initial.Connects['fullbright'] = nil
                end

                for k, v in pairs({Brightness=Lighting.Brightness,GlobalShadows=Lighting.GlobalShadows,OutdoorAmbient=Lighting.OutdoorAmbient,ClockTime=Lighting.ClockTime}) do
                    Initial.fullbrightTable[k] = v
                end

                brightness()

                Initial.Connects['fullbright'] = Lighting:GetPropertyChangedSignal('GlobalShadows'):Connect(function()
                    if Lighting.GlobalShadows then
                    table.clear(Initial.fullbrightTable)
                        for k, v in pairs({Brightness=Lighting.Brightness,GlobalShadows=Lighting.GlobalShadows,OutdoorAmbient=Lighting.OutdoorAmbient,ClockTime=Lighting.ClockTime}) do
                            Initial.fullbrightTable[k] = v
                        end
                        brightness()
                    end
                end)
            else
                if Initial.Connects['fullbright'] then
                    Initial.Connects['fullbright']:Disconnect()
                    Initial.Connects['fullbright'] = nil
                end

                for k, v in pairs(Initial.fullbrightTable) do
                    Lighting[k] = v
                end
                table.clear(Initial.fullbrightTable)
            end
        end
    }
)

Main:AddToggle('',
    {
        Title = 'No Fog',
        Default = _G.config.nofog or false,
        Callback = function(val)
            _G.config.nofog = val

            if val then
                if Initial.Connects['nofog'] then
                    Initial.Connects['nofog']:Disconnect()
                    Initial.Connects['nofog'] = nil
                end

                for k, v in pairs({Density=Atmosphere.Density,Offset=Atmosphere.Offset}) do
                    Initial.fogTable[k] = v
                end

                fog()

                Initial.Connects['nofog'] = Atmosphere:GetPropertyChangedSignal('Density'):Connect(function()
                    if Atmosphere.Density ~= 0 and workspace.CurrentCamera.CameraSubject == Character.Humanoid then
                        table.clear(Initial.fogTable)
                        for k, v in pairs({Density=Atmosphere.Density, Offset=Atmosphere.Offset}) do
                            Initial.fogTable[k] = v
                        end
                        fog()
                    end
                end)
            else
                if Initial.Connects['nofog'] then
                    Initial.Connects['nofog']:Disconnect()
                    Initial.Connects['nofog'] = nil
                end

                for k, v in pairs(Initial.fogTable) do
                    Atmosphere[k] = v
                end
                table.clear(Initial.fogTable)
            end
        end
    }
)

Main:AddToggle('',
    {
        Title = 'Interact Aura',
        Default = _G.config.interact_aura or false,
        Callback = function(val)
            _G.config.interact_aura = val

            task.spawn(function()
                while val do
                    if ActionBox.Visible and ActionBox.Text ~= 'Free' then
                        Remote:FireServer('Input', 'Action', true)
                    end

                    if not val or not _G.FTF then break end
                    task.wait()
                end
            end)
        end
    }
)

Main:AddToggle('',
    {
        Title = 'Save Aura',
        Default = _G.config.save_aura or false,
        Callback = function(val)
            _G.config.save_aura = val

            task.spawn(function()
                while val do
                    if ActionBox.Text == 'Free' then
                        Remote:FireServer('Input', 'Action', true)
                    end

                    if not val or not _G.FTF then break end
                    task.wait()
                end
            end)
        end
    }
)

Main:AddButton(
    {
        Title = 'Teleport to Pc',
        Description = 'Teleports to nearest pc',
        Callback = function()
            local CPc

            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name:match('^ComputerTrigger') and v.Parent:FindFirstChild('Screen') and v:FindFirstChild('ActionSign') then
                    local s, a = v.Parent.Screen, v.ActionSign

                    if s.Color ~= Color3.fromRGB(40, 127, 71) and a.Value == 20 and (GetRoot(Character).Position - v.Position).Magnitude < TotalDistance then
                        CPc = v
                    end
                end
            end

            if CPc then
                GetRoot(Character).CFrame = CFrame.new(CPc.Position)
            else
                Fluent:Notify({
                    Title = '[Casa Das Primas]',
                    Content = 'dindt find anything',
                    Duration = 3
                })
            end
        end
    }
)


Main:AddButton(
    {
        Title = 'Manual Escape',
        Description = '',
        Callback = function()
            local CExit

            for _, v in ipairs(workspace:GetDescendants()) do
                local a = v:FindFirstChild('ExitArea')

                if v.Name == 'ExitDoor' and a and (GetRoot(Character).Position - a.Position).Magnitude < TotalDistance then
                    CExit = v:FindFirstChild('ExitDoorTrigger') or a
                end
            end

            if CExit then
                GetRoot(Character).CFrame = CFrame.new(CExit.Position)
            else
                Fluent:Notify({
                    Title = '[Casa Das Primas]',
                    Content = 'didnt find anything',
                    Duration = 3
                })
            end
        end
    }
)

Main:AddButton(
    {
        Title = 'Return to Spawn',
        Description = '',
        Callback = function()
            if GetRoot(Character) then
                GetRoot(Character).CFrame = CFrame.new(103.5, 7.999999523162842, -417)
            end
        end
    }
)

local beast_sec = Tabs.Main:AddSection('Beast Section')

task.spawn(function()
    local dome = Instance.new('Part')

    dome.Name = 'dome'
    dome.Shape = Enum.PartType.Ball
    dome.Material = Enum.Material.ForceField
    dome.CanCollide = false
    dome.Anchored = true
    dome.CastShadow = false
    dome.Parent = workspace

    Rs.RenderStepped:Connect(function()
        if not _G.config.auto_tie then
            dome.Transparency = 1
            return
        else
            dome.Transparency = 0.8
            dome.Position = GetRoot(Character).Position

            local baseSize = _G.config.tie_distance
            dome.Size = Vector3.new(baseSize, baseSize, baseSize)
            dome.Color = Color3.fromRGB(255, 255, 255)
        end
    end)
end)

beast_sec:AddToggle('',
    {
        Title = 'Auto Tie',
        Default = _G.config.auto_tie or false,
        Callback = function(val)
            _G.config.auto_tie = val

            task.spawn(function()
                Fluent:Notify({
                    Title = 'Casa Das Primas',
                    Content = 'button val: ' .. tostring(_G.config.auto_tie),
                    Duration = 1
                })
            end)
        end
    }
)

-- esp sec

-- players sec

-- scripts sec
local my = Tabs.Scripts:AddSection('My Scripts')
local others = Tabs.Scripts:AddSection('Others Scripts')

--[[
event sec
]]
local global_sec = Tabs.Settings:AddSection('Sliders')

global_sec:AddSlider('',
    {
        Title = 'Fling Power',
        Description = '',
        Default = _G.config.fling_power or 1,
        Min = 1,
        Max = 100,
        Rounding = 1,
        Callback = function(val)
            _G.config.fling_power = tonumber(val)
        end
    }
)

global_sec:AddSlider('',
    {
        Title = 'Tie Distance',
        Description = '',
        Default = _G.config.tie_distance or 5,
        Min = 1,
        Max = 15,
        Rounding = 1,
        Callback = function(val)
            _G.config.tie_distance = tonumber(val)
        end
    }
)

local buttons_sec = Tabs.Settings:AddSection('Buttons')

buttons_sec:AddToggle('',
    {
        Title = 'Crawl Modifier',
        Default = _G.config.c_mod or false,
        CallBack = function(val)
            _G.config.c_mod = val

            if val then
                local button = Action:GetButton('Crawl')

                if button then
                    Initial.properties['btn'] = button:Clone()
                    Initial.properties['btn'].Parent = Assets
                end

                local state = false

                local function CrawlFunction(_, arg)
                    if arg == Enum.UserInputState.Begin then
                        Humanoid.HipHeight = -2
                        Humanoid.WalkSpeed = 8
                        CrawlAnim:Play(0.100000001, 1, 0)
                        Remote:FireServer('Input', 'Crawl', true)
                        Initial.Connects['Adjust'] = Humanoid.Running:Connect(function(arg)
                            if arg > 0.5 then
                                CrawlAnim:AdjustSpeed(2)
                            else
                                CrawlAnim:AdjustSpeed(0)
                            end
                        end)
                    elseif arg == Enum.UserInputState.End then
                        Humanoid.HipHeight = 0
                        Humanoid.WalkSpeed = 16
                        CrawlAnim:Stop()
                        Remote:FireServer('Input', 'Crawl', false)
                        Initial.Connects['Adjust']:Disconnect()
                        Initial.Connects['Adjust'] = nil
                    end
                end

                local function SetAct()
                    if button then
                        Action:BindAction('Crawl', CrawlFunction, true, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL2)
                        Action:SetTitle('Crawl', 'C')
                        Action:SetPosition('Crawl', button.Position)
                        task.wait(1)
                        state = false
                    end
                end

                SetAct()

                Initial.Connects['chill_add'] = ActionFrame.ChildAdded:Connect(function()
                    if state then return end

                    button = Action:GetButton('Crawl')

                    if button then
                        state = true
                        SetAct()
                    end
                end)

                Initial.Connects['RGetVal'] = TempStats.Ragdoll:GetPropertyChangedSignal('Value'):Connect(function()
                    if TempStats.Ragdoll.Value then
                        Humanoid.HipHeight = 0
                        Humanoid.WalkSpeed = 16
                        CrawlAnim:Stop()
                        Remote:FireServer('Input', 'Crawl', false)
                        Initial.Connects['Adjust']:Disconnect()
                        Initial.Connects['Adjust'] = nil
                    end
                end)
            else
                if Initial.Connects['chill_add'] and Initial.Connects['RGetVal'] then
                    Initial.Connects['chill_add']:Disconnect()
                    Initial.Connects['RGetVal']:Disconnect()
                    Initial.Connects['chill_add'] = nil
                    Initial.Connects['RGetVal'] = nil
                end

                if Initial.Connects['Adjust'] then
                    Initial.Connects['Adjust']:Disconnect()
                    Initial.Connects['Adjust'] = nil
                end

                if Initial.properties['btn'] then
                    local btnpath = ActionFrame:FindFirstChild('ContextActionButton')
                    Initial.properties['btn'].Parent = btnpath
                    btnpath:Destroy()
                end
            end
        end
    })

-- misc sec

Tabs.Settings:AddButton(
    {
        Title = 'Destroy Library',
        Description = 'Destroy The Library',
        Callback = function()
            reset()
        end
    }
)

if IsMobile then
    Tabs.Settings:AddButton(
        {
            Title = 'Destroy Executor',
            Description = 'Destroy your Executor',
            Callback = function()
            end
        }
    )
end

Window:SelectTab(1)

Fluent:Notify({
    Title = '[Casa Das Primas]',
    Content = 'Game Loaded: ' .. Mkt:GetProductInfo(game.PlaceId).Name,
    Duration = 3.3
})

--[[
local args = {
    [1] = 'Input'
}

game:GetService('Players').LocalPlayer.Character.BeastPowers.PowersEvent:FireServer(unpack(args))


local args = {
    [1] = 'HammerClick',
    [2] = true
}

game:GetService('Players').LocalPlayer.Character.Hammer.HammerEvent:FireServer(unpack(args))
]]

--[[
    workspace.grazi_blox55.Hammer.HammerEvent
workspace.grazi_blox55.BeastPowers.PowerProgressPercent
workspace.grazi_blox55.BeastPowers.CurrentPower
workspace['Homestead by MrWindy']:GetChildren()[38].ExitArea
961932719
]]