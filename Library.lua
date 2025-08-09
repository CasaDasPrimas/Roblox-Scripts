repeat task.wait() until game:IsLoaded()

--// Services
cloneref = cloneref or function(a) return a end

local UserInputService = cloneref(game:GetService('UserInputService'))
local ContentProvider = cloneref(game:GetService('ContentProvider'))
local TweenService = cloneref(game:GetService('TweenService'))
local HttpService = cloneref(game:GetService('HttpService'))
local TextService = cloneref(game:GetService('TextService'))
local RunService = cloneref(game:GetService('RunService'))
local Lighting = cloneref(game:GetService('Lighting'))
local Players = cloneref(game:GetService('Players'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Debris = cloneref(game:GetService('Debris'))

--// Variables
local CurrentCamera =  workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Languages
getgenv().GG = {
    Language = {
        CheckboxEnabled = 'Enabled',
        CheckboxDisabled = 'Disabled',
        SliderValue = 'Value',
        DropdownSelect = 'Select',
        DropdownNone = 'None',
        DropdownSelected = 'Selected',
        ButtonClick = 'Click',
        TextboxEnter = 'Enter',
        ModuleEnabled = 'Enabled',
        ModuleDisabled = 'Disabled',
        TabGeneral = 'General',
        TabSettings = 'Settings',
        Loading = 'Loading...',
        Error = 'Error',
        Success = 'Success'
    }
}

local SelectedLanguage = GG.Language

function StringToTable(String)
    local r = {}

    for v in string.gmatch(String, '([^,]+)') do
        local TrV = v:match('^%s*(.-)%s*$')
        tablein(r, TrV)
    end

    return r
end

function TableToString(Table)
    return table.concat(Table, ', ')
end

if not isfolder('OwO') then
    makefolder("OwO")
end

--// Connections
local Connections = setmetatable({
    disconnect = function(self, String)
        if not self[String] then
            return
        end

        self[String]:Disconnect()
        self[String] = nil
    end,
    disconnect_all = function(self)
        for _, v in self do
            if typeof(v) == 'function' then
                continue
            end

            v:Disconnect()
        end
    end
}, Connections)

local Util = setmetatable({
    map = function(self: any, value: number, minimum: number, maximum: number, out_minimum: number, out_maximum: number)
        return (value - minimum) * (out_maximum - out_minimum) / (maximum - minimum) + out_minimum
    end,
    viewport = function(self: any, location: any, distance: number)
        local ray = CurrentCamera:ScreenPointToRay(location.X, location.Y)

        return ray.Origin + ray.Direction * distance
    end,
    get_offset = function(self: any)
        local viewport_size_Y = CurrentCamera.ViewportSize.Y

        return self:map(viewport_size_Y, 0, 2560, 8, 56)
    end
}, Util)

local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(obj: GuiObject)
    local self = setmetatable({
        _object = obj,
        _folder = nil,
        _frame = nil,
        _root = nil
    }, AcrylicBlur)

    self:setup()

    return self
end

function AcrylicBlur:create_folder()
    local old = CurrentCamera:FindFirstChild('AcrylicBlur')

    if old then
        Debris:AddItem(old, 0)
    end

    local folder = Instance.new('Folder', CurrentCamera)
    folder.Name = 'AcrylicBlur'

    self._folder = folder
end

function AcrylicBlur:create_depth_of_fields()
    local depth_of_fields = Lighting:FindFirstChild('AcrylicBlur') or Instance.new('DepthOfFieldEffect', Lighting)

    depth_of_fields.FarIntensity = 0
    depth_of_fields.FocusDistance = 0.05
    depth_of_fields.InFocusRadius = 0.1
    depth_of_fields.NearIntensity = 1
    depth_of_fields.Name = 'AcrylicBlur'

    for _, obj in Lighting:GetChildren() do
        if not obj:IsA('DepthOfFieldEffect') then
            continue
        end

        if obj == depth_of_fields then
            continue
        end

        Connections[obj] = obj:GetPropertyChangedSignal('FarIntensity'):Connect(function()
            obj.FarIntensity = 0
        end)

        obj.FarIntensity = 0
    end
end

function AcrylicBlur:create_frame()
    local frame = Instance.new('Frame', self._object)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1

    self._frame = frame
end

function AcrylicBlur:create_root()
    local part = Instance.new('Part', self._folder)
    part.Name = 'Root'
    part.Color = Color3.new(0, 0, 0)
    part.Material = Enum.Material.Glass
    part.Size = Vector3.new(1, 1, 0)
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Locked = true
    part.CastShadow = false
    part.Transparency = 0.98

    local Mesh = Instance.new('SpecialMesh', part)
    Mesh.MeshType = Enum.MeshType.Brick
    Mesh.Offset = Vector3.new(0, 0, -0.000001)

    self._root = part
end

function AcrylicBlur:setup()
    self:create_depth_of_fields()
    self:create_folder()
    self:create_root()
    self:create_frame()

    self:render(0.001)
    self:check_quality_level()
end

function AcrylicBlur:render(distance: number)
    local positions = {
        top_left = Vector2.new(),
        top_right = Vector2.new(),
        bottom_right = Vector2.new(),
    }

    local function update_positions(size: any, position: any)
        positions.top_left = position
        positions.top_right = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end

    local function update()
        local top_left = positions.top_left
        local top_right = positions.top_right
        local bottom_right = positions.bottom_right

        local top_left3D = Util:viewport(top_left, distance)
        local top_right3D = Util:viewport(top_right, distance)
        local bottom_right3D = Util:viewport(bottom_right, distance)

        local width = (top_right3D - top_left3D).Magnitude
        local height = (top_right3D - bottom_right3D).Magnitude

        if not self._root then
            return
        end

        self._root.CFrame = CFrame.fromMatrix((top_left3D + bottom_right3D) / 2, CurrentCamera.CFrame.XVector, CurrentCamera.CFrame.YVector, CurrentCamera.CFrame.ZVector)
        self._root.Mesh.Scale = Vector3.new(width, height, 0)
    end

    local function on_change()
        local offset = Util:get_offset()
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
        local position = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)

        update_positions(size, position)
        task.spawn(update)
    end

    Connections['cframe_update'] = CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(update)
    Connections['viewport_size_update'] = CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(update)
    Connections['field_of_view_update'] = CurrentCamera:GetPropertyChangedSignal('FieldOfView'):Connect(update)

    Connections['frame_absolute_position'] = self._frame:GetPropertyChangedSignal('AbsolutePosition'):Connect(on_change)
    Connections['frame_absolute_size'] = self._frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(on_change)

    task.spawn(update)
end

function AcrylicBlur:check_quality_level()
    local game_settings = UserSettings().GameSettings
    local quality_level = game_settings.SavedQualityLevel.Value

    if quality_level < 8 then
        self:change_visiblity(false)
    end

    Connections['quality_level'] = game_settings:GetPropertyChangedSignal('SavedQualityLevel'):Connect(function()
        game_settings = UserSettings().GameSettings
        quality_level = game_settings.SavedQualityLevel.Value

        self:change_visiblity(quality_level >= 8)
    end)
end


function AcrylicBlur:change_visiblity(state: boolean)
    self._root.Transparency = state and 0.98 or 1
end


local Config = setmetatable({
    save = function(self: any, file_name: any, config: any)
        local success_save, result = pcall(function()
            local flags = HttpService:JSONEncode(config)
            writefile('OwO/'..file_name..'.json', flags)
        end)

        if not success_save then
            warn('failed to save config', result)
        end
    end,
    load = function(self: any, file_name: any, config: any)
        local success_load, result = pcall(function()
            if not isfile('OwO/'..file_name..'.json') then
                return self:save(file_name, config)
            end

            local flags = readfile('OwO/'..file_name..'.json')

            if not flags then
                self:save(file_name, config)

                return
            end

            return HttpService:JSONDecode(flags)
        end)

        if not success_load then
            warn('failed to load config', result)
        end

        if not result then
            result = {
                _flags = {},
                _keybinds = {},
                _library = {}
            }
        end

        return result
    end
}, Config)

local Library = {
    _config = Config:load(game.GameId),

    _choosing_keybind = false,
    _device = nil,

    _ui_open = true,
    _ui_scale = 1,
    _ui_loaded = false,
    _ui = nil,

    _dragging = false,
    _drag_start = nil,
    _container_position = nil
}

Library.__index = Library

function Library:CreateWindow()
    local self = setmetatable({
        _loaded = false,
        _tab = 0,
    }, Library)

    self:CreateUi()

    return self
end

local NotifyContainer = Instance.new("Frame", CoreGui.RobloxGui:FindFirstChild("RobloxCoreGuis") or Instance.new("ScreenGui", CoreGui.RobloxGui))
NotifyContainer.Name = "RobloxCoreGuis"
NotifyContainer.Size = UDim2.new(0, 300, 0, 0)
NotifyContainer.Position = UDim2.new(0.8, 0, 0, 10)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.ClipsDescendants = false
NotifyContainer.AutomaticSize = Enum.AutomaticSize.Y

local UIListLayout = Instance.new("UIListLayout", NotifyContainer)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

function Library:CreateNotify(settings)
    local Notification = Instance.new("Frame", NotifyContainer)

    Notification.Size = UDim2.new(1, 0, 0, 60)
    Notification.BackgroundTransparency = 1
    Notification.BorderSizePixel = 0
    Notification.Name = "Notification"
    Notification.AutomaticSize = Enum.AutomaticSize.Y

    local UICorner = Instance.new("UICorner", Notification)
    UICorner.CornerRadius = UDim.new(0, 4)

    local InnerFrame = Instance.new("Frame", Notification)

    InnerFrame.Size = UDim2.new(1, 0, 0, 60)
    InnerFrame.Position = UDim2.new(0, 0, 0, 0)
    InnerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    InnerFrame.BackgroundTransparency = 0.3
    InnerFrame.BorderSizePixel = 0
    InnerFrame.Name = "InnerFrame"
    InnerFrame.AutomaticSize = Enum.AutomaticSize.Y

    local InnerUICorner = Instance.new("UICorner", InnerFrame)
    InnerUICorner.CornerRadius = UDim.new(0, 4)

    local Title = Instance.new("TextLabel", InnerFrame)

    Title.Text = settings.Title or "Notification Title"
    Title.TextColor3 = Color3.fromRGB(210, 210, 210)
    Title.Font = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextSize = 14
    Title.Size = UDim2.new(1, -10, 0, 20)
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.TextWrapped = true
    Title.AutomaticSize = Enum.AutomaticSize.Y

    local Body = Instance.new("TextLabel", InnerFrame)

    Body.Text = settings.Text or "This is the body of the notification."
    Body.TextColor3 = Color3.fromRGB(180, 180, 180)
    Body.Font = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Body.TextSize = 12
    Body.Size = UDim2.new(1, -10, 0, 30)
    Body.Position = UDim2.new(0, 5, 0, 25)
    Body.BackgroundTransparency = 1
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.TextYAlignment = Enum.TextYAlignment.Top
    Body.TextWrapped = true
    Body.AutomaticSize = Enum.AutomaticSize.Y

    task.spawn(function()
        task.wait(0.1)
        local Height = Title.TextBounds.Y + Body.TextBounds.Y + 10
        InnerFrame.Size = UDim2.new(1, 0, 0, Height)
    end)

    task.spawn(function()
        local tweenIn = TweenService:Create(InnerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 10 + NotifyContainer.Size.Y.Offset)
        })
        tweenIn:Play()

        local duration = settings.Duration or 5
        task.wait(duration)

        local tweenOut = TweenService:Create(InnerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 310, 0, 10 + NotifyContainer.Size.Y.Offset)
        })
        tweenOut:Play()

        tweenOut.Completed:Connect(function()
            Notification:Destroy()
        end)
    end)
end

function Library:get_screen_scale()
    local ViewportSize = CurrentCamera.ViewportSize.X

    self._ui_scale = ViewportSize / 1400
end

function Library:get_device()
    local device = 'Unknown'

    if not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
        device = 'PC'
    elseif UserInputService.TouchEnabled then
        device = 'Mobile'
    elseif UserInputService.GamepadEnabled then
        device = 'Console'
    end

    self._device = device
end

function Library:removed(action: any)
    self._ui.AncestryChanged:Once(action)
end

function Library:flag_type(flag: any, flag_type: any)
    if not Library._config._flags[flag] then
        return
    end

    return typeof(Library._config._flags[flag]) == flag_type
end

function Library:remove_table_value(__table: any, table_value: string)
    for i, v in __table do
        if v ~= table_value then
            continue
        end

        table.remove(__table, i)
    end
end

function Library:CreateUi()
    local OwO = Instance.new('ScreenGui', CoreGui)
    OwO.ResetOnSpawn = false
    OwO.Name = 'OwO'
    OwO.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Container = Instance.new('Frame', OwO)
    Container.ClipsDescendants = true
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.Name = 'Container'
    Container.BackgroundTransparency = 0
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0, 0, 0, 0)
    Container.Active = true
    Container.BorderSizePixel = 0

    local Gradient = Instance.new("UIGradient", Container)
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 5, 15)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(40, 15, 30)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(70, 25, 50)),
        ColorSequenceKeypoint.new(0.70, Color3.fromRGB(100, 40, 75)),
        ColorSequenceKeypoint.new(0.85, Color3.fromRGB(130, 60, 100)),
        ColorSequenceKeypoint.new(0.95, Color3.fromRGB(160, 80, 125)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(190, 100, 150))
    })

    Gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 0.05),
        NumberSequenceKeypoint.new(0.50, 0.1),
        NumberSequenceKeypoint.new(1.0, 0.15)
    })
    Gradient.Rotation = -45

    local UICorner = Instance.new('UICorner', Container)
    UICorner.CornerRadius = UDim.new(0, 10)

    local UIStroke = Instance.new('UIStroke', Container)
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Transparency = 0.5
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Handler = Instance.new('Frame', Container)
    Handler.BackgroundTransparency = 1
    Handler.Name = 'Handler'
    Handler.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Handler.Size = UDim2.new(0, 698, 0, 479)
    Handler.BorderSizePixel = 0
    Handler.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    local Tabs = Instance.new('ScrollingFrame', Handler)
    Tabs.ScrollBarImageTransparency = 1
    Tabs.ScrollBarThickness = 0
    Tabs.Name = 'Tabs'
    Tabs.Size = UDim2.new(0, 129, 0, 401)
    Tabs.Selectable = false
    Tabs.AutomaticCanvasSize = Enum.AutomaticSize.XY
    Tabs.BackgroundTransparency = 1
    Tabs.Position = UDim2.new(0.026097271591424942, 0, 0.1111111119389534, 0)
    Tabs.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Tabs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Tabs.BorderSizePixel = 0
    Tabs.CanvasSize = UDim2.new(0, 0, 0.5, 0)

    local UIListLayout = Instance.new('UIListLayout', Tabs)
    UIListLayout.Padding = UDim.new(0, 4)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local ScriptName = Instance.new('TextLabel', Handler)
    ScriptName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    ScriptName.TextColor3 = Color3.fromRGB(255, 254, 255)
    ScriptName.TextTransparency = 0.20000000298023224
    ScriptName.Text = 'UwU.dll' --// Titulo do Script
    ScriptName.Name = 'ScriptName'
    ScriptName.Size = UDim2.new(0, 31, 0, 13)
    ScriptName.AnchorPoint = Vector2.new(0, 0.5)
    ScriptName.Position = UDim2.new(0.0560000017285347, 0, 0.054999999701976776, 0)
    ScriptName.BackgroundTransparency = 1
    ScriptName.TextXAlignment = Enum.TextXAlignment.Left
    ScriptName.BorderSizePixel = 0
    ScriptName.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScriptName.TextSize = 13
    ScriptName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    local UIGradient = Instance.new('UIGradient', ScriptName)
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 155, 155)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }

    local Pin = Instance.new('Frame', Handler)
    Pin.Name = 'Pin'
    Pin.Position = UDim2.new(0.026000000536441803, 0, 0.13600000739097595, 0)
    Pin.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Pin.Size = UDim2.new(0, 2, 0, 16)
    Pin.BorderSizePixel = 0
    Pin.BackgroundColor3 = Color3.fromRGB(255, 254, 255)

    local UICorner2 = Instance.new('UICorner', Pin)
    UICorner2.CornerRadius = UDim.new(1, 0)

    local Icon = Instance.new('ImageLabel', Handler)
    Icon.ScaleType = Enum.ScaleType.Fit
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.Image = ''
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0.01300000037252903, 0, 0.054999999701976776, 0)
    Icon.Name = 'Icon'
    Icon.Size = UDim2.new(0, 35, 0, 35)

    local IDs = {
        "137613206534423",
        "85001297263526",
        "77720936213212",
        "71849504203751",
        "139291859864999",
        "110957981641303",
        "135054168844778",
        "103066533154874"
    }

    local Frame = 1
    local lastTime = os.clock()

    RunService.Heartbeat:Connect(function()
        local Time = os.clock()

        if Time - lastTime >= 0.1 then
            Icon.Image = "rbxassetid://" .. IDs[Frame]
            Frame = Frame + 1

            if Frame > #IDs then
                Frame = 1
            end
            lastTime = Time
        end
        RunService.RenderStepped:Wait()
    end)

    local Divider = Instance.new('Frame', Handler)
    Divider.Name = 'Divider'
    Divider.BackgroundTransparency = 0.5
    Divider.Position = UDim2.new(0.23499999940395355, 0, 0, 0)
    Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Divider.Size = UDim2.new(0, 1, 0, 479)
    Divider.BorderSizePixel = 0
    Divider.BackgroundColor3 =Color3.fromRGB(255, 254, 255)

    local Sections = Instance.new('Folder', Handler)
    Sections.Name = 'Sections'

    local Minimize = Instance.new('TextButton', Handler)
    Minimize.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Minimize.TextColor3 = Color3.fromRGB(0, 0, 0)
    Minimize.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Minimize.Text = ''
    Minimize.AutoButtonColor = false
    Minimize.Name = 'Minimize'
    Minimize.BackgroundTransparency = 1
    Minimize.Position = UDim2.new(0.020057305693626404, 0, 0.02922755666077137, 0)
    Minimize.Size = UDim2.new(0, 24, 0, 24)
    Minimize.BorderSizePixel = 0
    Minimize.TextSize = 14
    Minimize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    local UIScale = Instance.new('UIScale', Container)

    self._ui = OwO

    local function on_drag(input: InputObject, _)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging = true
            self._drag_start = input.Position
            self._container_position = Container.Position

            Connections['container_input_ended'] = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                Connections:disconnect('container_input_ended')
                self._dragging = false
            end)
        end
    end

    local function update_drag(input: any)
        local delta = input.Position - self._drag_start
        local position = UDim2.new(self._container_position.X.Scale, self._container_position.X.Offset + delta.X, self._container_position.Y.Scale, self._container_position.Y.Offset + delta.Y)

        TweenService:Create(Container, TweenInfo.new(0.2), {
            Position = position
        }):Play()
    end

    local function drag(input: InputObject, _)
        if not self._dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            update_drag(input)
        end
    end

    Connections['container_input_began'] = Container.InputBegan:Connect(on_drag)
    Connections['input_changed'] = UserInputService.InputChanged:Connect(drag)

    self:removed(function()
        self._ui = nil
        Connections:disconnect_all()
    end)

    function self:Update1Run(a)
        if a == "nil" then
            Container.BackgroundTransparency = 0.05000000074505806
        else
            pcall(function()
                Container.BackgroundTransparency = tonumber(a)
            end)
        end
    end

    function self:UIVisiblity()
        OwO.Enabled = not OwO.Enabled
    end

    getgenv().LibraryVisible = false

    local function SetTransparency(state: boolean)
        local Folder = CurrentCamera:FindFirstChild("AcrylicBlur")

        if Folder then
            local root = Folder:FindFirstChild("Root")

            if root then
                root.Transparency = state and 0.98 or 1
            end
        end
    end

    function self:change_visiblity(state: boolean)
        if state then
            TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(698, 479)
            }):Play()

            if getgenv().LibraryVisible then
                getgenv().Visible = true
                SetTransparency(true)
                Container.Visible = true
                Container.Active = true
                Connections['container_input_began'] = Container.InputBegan:Connect(on_drag)
                Connections['input_changed'] = UserInputService.InputChanged:Connect(drag)
            end
        else
            local tween = TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(104.5, 52)
            })

            tween:Play()

            if getgenv().LibraryVisible then
                tween.Completed:Connect(function()
                    if Container.Size == UDim2.fromOffset(104.5, 52) then
                        Container.Visible = false
                        Container.Active = false
                        Connections:disconnect('container_input_began')
                        Connections:disconnect('input_changed')
                        SetTransparency(false)
                        getgenv().Visible = false
                    end
                end)
            end
        end
    end

    function self:load()
        local content = {}

        for _, obj in OwO:GetDescendants() do
            if not obj:IsA('ImageLabel') then
                continue
            end

            table.insert(content, obj)
        end

        ContentProvider:PreloadAsync(content)
        self:get_device()

        if self._device == 'Mobile' or self._device == 'Unknown' then
            self:get_screen_scale()
            UIScale.Scale = self._ui_scale

            Connections['ui_scale'] = CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
                self:get_screen_scale()
                UIScale.Scale = self._ui_scale
            end)
        end

        TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(698, 479)
        }):Play()

        AcrylicBlur.new(Container)
        self._ui_loaded = true
    end

    function self:update_tabs(tab: TextButton)
        for _, obj in Tabs:GetChildren() do
            if obj.Name ~= 'Tab' then
                continue
            end

            if obj == tab then
                if obj.BackgroundTransparency ~= 0.5 then
                    local offset = obj.LayoutOrder * (0.113 / 1.3)

                    TweenService:Create(Pin, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Position = UDim2.fromScale(0.026, 0.135 + offset)
                    }):Play()

                    TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.5
                    }):Play()

                    TweenService:Create(obj.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        TextTransparency = 0.2,
                        TextColor3 = Color3.fromRGB(255, 254, 255)
                    }):Play()

                    TweenService:Create(obj.TextLabel.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Offset = Vector2.new(1, 0)
                    }):Play()

                    TweenService:Create(obj.Icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        ImageTransparency = 0.2,
                        ImageColor3 = Color3.fromRGB(255, 254, 255)
                    }):Play()
                end

                continue
            end

            if obj.BackgroundTransparency ~= 1 then
                TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                }):Play()

                TweenService:Create(obj.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    TextTransparency = 0.7,
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()

                TweenService:Create(obj.TextLabel.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Offset = Vector2.new(0, 0)
                }):Play()

                TweenService:Create(obj.Icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    ImageTransparency = 0.8,
                    ImageColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()
            end
        end
    end

    function self:update_sections(left_section: ScrollingFrame, right_section: ScrollingFrame)
        for _, obj in Sections:GetChildren() do
            if obj == left_section or obj == right_section then
                obj.Visible = true

                continue
            end

            obj.Visible = false
        end
    end

    function self:CreateTab(title: string, icon: string)
        local TabManager = {}

        local params = Instance.new('GetTextBoundsParams')
        params.Text = title
        params.Font = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        params.Size = 13
        params.Width = 10000

        local FontSize = TextService:GetTextBoundsAsync(params)
        local FirstTab = not Tabs:FindFirstChild('Tab')

        local Tab = Instance.new('TextButton', Tabs)
        Tab.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        Tab.TextColor3 = Color3.fromRGB(0, 0, 0)
        Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tab.Text = ''
        Tab.AutoButtonColor = false
        Tab.BackgroundTransparency = 1
        Tab.Name = 'Tab'
        Tab.Size = UDim2.new(0, 129, 0, 38)
        Tab.BorderSizePixel = 0
        Tab.TextSize = 14
        Tab.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
        Tab.LayoutOrder = self._tab

        local UICorner3 = Instance.new('UICorner', Tab)
        UICorner3.CornerRadius = UDim.new(0, 5)

        local TextLabel = Instance.new('TextLabel', Tab)
        TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextTransparency = 0.7
        TextLabel.Text = title
        TextLabel.Size = UDim2.new(0, FontSize.X, 0, 16)
        TextLabel.AnchorPoint = Vector2.new(0, 0.5)
        TextLabel.Position = UDim2.new(0.2400001734495163, 0, 0.5, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BorderSizePixel = 0
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.TextSize = 13
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

        local UIGradient2 = Instance.new('UIGradient', TextLabel)
            UIGradient2.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.7, Color3.fromRGB(155, 155, 155)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 58, 58))
            }

        local Icon2 = Instance.new('ImageLabel', Tab)
        Icon2.ScaleType = Enum.ScaleType.Fit
        Icon2.ImageTransparency = 0.800000011920929
        Icon2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Icon2.AnchorPoint = Vector2.new(0, 0.5)
        Icon2.BackgroundTransparency = 1
        Icon2.Position = UDim2.new(0.10000000149011612, 0, 0.5, 0)
        Icon2.Name = 'Icon'
        Icon2.Image = icon
        Icon2.Size = UDim2.new(0, 12, 0, 12)
        Icon2.BorderSizePixel = 0
        Icon2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

        local LeftSection = Instance.new('ScrollingFrame', Sections)
        LeftSection.Name = 'LeftSection'
        LeftSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        LeftSection.ScrollBarThickness = 0
        LeftSection.Size = UDim2.new(0, 243, 0, 445)
        LeftSection.Selectable = false
        LeftSection.AnchorPoint = Vector2.new(0, 0.5)
        LeftSection.ScrollBarImageTransparency = 1
        LeftSection.BackgroundTransparency = 1
        LeftSection.Position = UDim2.new(0.2594326436519623, 0, 0.5, 0)
        LeftSection.BorderColor3 = Color3.fromRGB(0, 0, 0)
        LeftSection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        LeftSection.BorderSizePixel = 0
        LeftSection.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        LeftSection.Visible = false

        local UIListLayout2 = Instance.new('UIListLayout', LeftSection)
        UIListLayout2.Padding = UDim.new(0, 11)
        UIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder

        local UIPadding = Instance.new('UIPadding', LeftSection)
        UIPadding.PaddingTop = UDim.new(0, 1)

        local RightSection = Instance.new('ScrollingFrame', Sections)
        RightSection.Name = 'RightSection'
        RightSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        RightSection.ScrollBarThickness = 0
        RightSection.Size = UDim2.new(0, 243, 0, 445)
        RightSection.Selectable = false
        RightSection.AnchorPoint = Vector2.new(0, 0.5)
        RightSection.ScrollBarImageTransparency = 1
        RightSection.BackgroundTransparency = 1
        RightSection.Position = UDim2.new(0.6290000081062317, 0, 0.5, 0)
        RightSection.BorderColor3 = Color3.fromRGB(0, 0, 0)
        RightSection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        RightSection.BorderSizePixel = 0
        RightSection.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        RightSection.Visible = false

        local UIListLayout3 = Instance.new('UIListLayout', RightSection)
        UIListLayout3.Padding = UDim.new(0, 11)
        UIListLayout3.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder

        local UIPadding2 = Instance.new('UIPadding', RightSection)
        UIPadding2.PaddingTop = UDim.new(0, 1)

        self._tab += 1

        if FirstTab then
            self:update_tabs(Tab, LeftSection, RightSection)
            self:update_sections(LeftSection, RightSection)
        end

        Tab.MouseButton1Click:Connect(function()
            self:update_tabs(Tab, LeftSection, RightSection)
            self:update_sections(LeftSection, RightSection)
        end)

        function TabManager:CreateModule(settings: any)
            local LayoutOrderModule = 0

            local ModuleManager = {
                _state = false,
                _size = 0,
                _multiplier = 0
            }

            if settings.Section == 'right' then
                settings.Section = RightSection
            else
                settings.Section = LeftSection
            end

            local Module = Instance.new('Frame', settings.Section)
            Module.ClipsDescendants = true
            Module.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Module.BackgroundTransparency = 0.5
            Module.Position = UDim2.new(0.004115226212888956, 0, 0, 0)
            Module.Name = 'Module'
            Module.Size = UDim2.new(0, 241, 0, 93)
            Module.BorderSizePixel = 0
            Module.BackgroundColor3 = Color3.fromRGB(22, 28, 38)

            local UIListLayout4 = Instance.new('UIListLayout', Module)
            UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder

            local UICorner4 = Instance.new('UICorner', Module)
            UICorner4.CornerRadius = UDim.new(0, 5)

            local UIStroke2 = Instance.new('UIStroke', Module)
            UIStroke2.Color = Color3.fromRGB(255, 254, 255)
            UIStroke2.Transparency = 0.5
            UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local Header = Instance.new('TextButton', Module)
            Header.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            Header.TextColor3 = Color3.fromRGB(0, 0, 0)
            Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Header.Text = ''
            Header.AutoButtonColor = false
            Header.BackgroundTransparency = 1
            Header.Name = 'Header'
            Header.Size = UDim2.new(0, 241, 0, 93)
            Header.BorderSizePixel = 0
            Header.TextSize = 14
            Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

            local Icon3 = Instance.new('ImageLabel', Header)
            Icon3.ImageColor3 = Color3.fromRGB(255, 181, 255)
            Icon3.ScaleType = Enum.ScaleType.Fit
            Icon3.ImageTransparency = 0.699999988079071
            Icon3.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Icon3.AnchorPoint = Vector2.new(0, 0.5)
            Icon3.Image = 'rbxassetid://79095934438045'
            Icon3.BackgroundTransparency = 1
            Icon3.Position = UDim2.new(0.07100000232458115, 0, 0.8199999928474426, 0)
            Icon3.Name = 'Icon'
            Icon3.Size = UDim2.new(0, 15, 0, 15)
            Icon3.BorderSizePixel = 0
            Icon3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

            local ModuleName = Instance.new('TextLabel', Header)
            ModuleName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            ModuleName.TextColor3 = Color3.fromRGB(255, 254, 255)
            ModuleName.TextTransparency = 0.20000000298023224

            if not settings.Rich then
                ModuleName.Text = settings.Title or "Title"
            else
                ModuleName.RichText = true
                ModuleName.Text = settings.RichText or "<font color='rgb(255,0,0)'>OwO</font> user"
            end

            ModuleName.Name = 'ModuleName'
            ModuleName.Size = UDim2.new(0, 205, 0, 13)
            ModuleName.AnchorPoint = Vector2.new(0, 0.5)
            ModuleName.Position = UDim2.new(0.0729999989271164, 0, 0.23999999463558197, 0)
            ModuleName.BackgroundTransparency = 1
            ModuleName.TextXAlignment = Enum.TextXAlignment.Left
            ModuleName.BorderSizePixel = 0
            ModuleName.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ModuleName.TextSize = 13
            ModuleName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

            local Description = Instance.new('TextLabel', Header)
            Description.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            Description.TextColor3 = Color3.fromRGB(200, 200, 200)
            Description.TextTransparency = 0.699999988079071
            Description.Text = settings.Description
            Description.Name = 'Description'
            Description.Size = UDim2.new(0, 205, 0, 13)
            Description.AnchorPoint = Vector2.new(0, 0.5)
            Description.Position = UDim2.new(0.0729999989271164, 0, 0.41999998688697815, 0)
            Description.BackgroundTransparency = 1
            Description.TextXAlignment = Enum.TextXAlignment.Left
            Description.BorderSizePixel = 0
            Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Description.TextSize = 10
            Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

            local Toggle = Instance.new('Frame', Header)
            Toggle.Name = 'Toggle'
            Toggle.BackgroundTransparency = 0.699999988079071
            Toggle.Position = UDim2.new(0.8199999928474426, 0, 0.7570000290870667, 0)
            Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Toggle.Size = UDim2.new(0, 25, 0, 12)
            Toggle.BorderSizePixel = 0
            Toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

            local UICorner5 = Instance.new('UICorner', Toggle)
            UICorner5.CornerRadius = UDim.new(1, 0)

            local Circle = Instance.new('Frame', Toggle)
            Circle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Circle.AnchorPoint = Vector2.new(0, 0.5)
            Circle.BackgroundTransparency = 0.20000000298023224
            Circle.Position = UDim2.new(0, 0, 0.5, 0)
            Circle.Name = 'Circle'
            Circle.Size = UDim2.new(0, 12, 0, 12)
            Circle.BorderSizePixel = 0
            Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)

            local UICorner6 = Instance.new('UICorner', Circle)
            UICorner6.CornerRadius = UDim.new(1, 0)

            local Keybind = Instance.new('Frame', Header)

            Keybind.Name = 'Keybind'
            Keybind.BackgroundTransparency = 0.699999988079071
            Keybind.Position = UDim2.new(0.15000000596046448, 0, 0.7350000143051147, 0)
            Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Keybind.Size = UDim2.new(0, 33, 0, 15)
            Keybind.BorderSizePixel = 0
            Keybind.BackgroundColor3 = Color3.fromRGB(128, 128, 128)

            local UICorner7 = Instance.new('UICorner', Keybind)
            UICorner7.CornerRadius = UDim.new(0, 3)

            local TextLabel2 = Instance.new('TextLabel', Keybind)

            TextLabel2.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            TextLabel2.TextColor3 = Color3.fromRGB(209, 222, 255)
            TextLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel2.Text = 'None'
            TextLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel2.Size = UDim2.new(0, 25, 0, 13)
            TextLabel2.BackgroundTransparency = 1
            TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
            TextLabel2.BorderSizePixel = 0
            TextLabel2.TextSize = 10
            TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

            local Divider2 = Instance.new('Frame', Header)
            Divider2.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Divider2.AnchorPoint = Vector2.new(0.5, 0)
            Divider2.BackgroundTransparency = 0.5
            Divider2.Position = UDim2.new(0.5, 0, 0.6200000047683716, 0)
            Divider2.Name = 'Divider'
            Divider2.Size = UDim2.new(0, 241, 0, 1)
            Divider2.BorderSizePixel = 0
            Divider2.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

            local Divider3 = Instance.new('Frame', Header)
            Divider3.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Divider3.AnchorPoint = Vector2.new(0.5, 0)
            Divider3.BackgroundTransparency = 0.5
            Divider3.Position = UDim2.new(0.5, 0, 1, 0)
            Divider3.Name = 'Divider'
            Divider3.Size = UDim2.new(0, 241, 0, 1)
            Divider3.BorderSizePixel = 0
            Divider3.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

            local Options = Instance.new('Frame', Module)
            Options.Name = 'Options'
            Options.BackgroundTransparency = 1
            Options.Position = UDim2.new(0, 0, 1, 0)
            Options.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Options.Size = UDim2.new(0, 241, 0, 8)
            Options.BorderSizePixel = 0
            Options.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

            local UIPadding5 = Instance.new('UIPadding', Options)
            UIPadding5.PaddingTop = UDim.new(0, 8)

            local UIListLayout5 = Instance.new('UIListLayout', Options)
            UIListLayout5.Padding = UDim.new(0, 5)
            UIListLayout5.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout5.SortOrder = Enum.SortOrder.LayoutOrder

            function ModuleManager:change_state(state: boolean)
                self._state = state

                if self._state then
                    TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2.fromOffset(241, 93 + self._size + self._multiplier)
                    }):Play()

                    TweenService:Create(Toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(255, 254, 255)
                    }):Play()

                    TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(255, 254, 255),
                        Position = UDim2.fromScale(0.53, 0.5)
                    }):Play()
                else
                    TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2.fromOffset(241, 93)
                    }):Play()

                    TweenService:Create(Toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    }):Play()

                    TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                        Position = UDim2.fromScale(0, 0.5)
                    }):Play()
                end

                Library._config._flags[settings.Flag] = self._state
                Config:save(game.GameId, Library._config)

                settings.Callback(self._state)
            end

            function ModuleManager:connect_keybind()
                if not Library._config._keybinds[settings.Flag] then
                    return
                end

                Connections[settings.Flag ..'_keybind'] = UserInputService.InputBegan:Connect(function(input, process)
                    if process then
                        return
                    end

                    if tostring(input.KeyCode) ~= Library._config._keybinds[settings.Flag] then
                        return
                    end

                    self:change_state(not self._state)
                end)
            end

            function ModuleManager:scale_keybind(empty: boolean)
                if Library._config._keybinds[settings.Flag] and not empty then
                    local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.Flag]), 'Enum.KeyCode.', '')

                    local params2 = Instance.new('GetTextBoundsParams')
                    params2.Text = keybind_string
                    params2.Font = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Bold)
                    params2.Size = 10
                    params2.Width = 10000

                    local FontSize2 = TextService:GetTextBoundsAsync(params2)

                    Keybind.Size = UDim2.fromOffset(FontSize2.X + 6, 15)
                    TextLabel.Size = UDim2.fromOffset(FontSize2.X, 13)
                else
                    Keybind.Size = UDim2.fromOffset(31, 15)
                    TextLabel.Size = UDim2.fromOffset(25, 13)
                end
            end

            if Library:flag_type(settings.Flag, 'boolean') then
                ModuleManager._state = true
                settings.Callback(ModuleManager._state)

                Toggle.BackgroundColor3 = Color3.fromRGB(255, 254, 255)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 254, 255)
                Circle.Position = UDim2.fromScale(0.53, 0.5)
            end

            if Library._config._keybinds[settings.Flag] then
                local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.Flag]), 'Enum.KeyCode.', '')
                TextLabel.Text = keybind_string

                ModuleManager:connect_keybind()
                ModuleManager:scale_keybind()
            end

            Connections[settings.Flag..'_input_began'] = Header.InputBegan:Connect(function(input: InputObject)
                if Library._choosing_keybind then
                    return
                end

                if input.UserInputType ~= Enum.UserInputType.MouseButton3 then
                    return
                end

                Library._choosing_keybind = true

                Connections['keybind_choose_start'] = UserInputService.InputBegan:Connect(function(input: InputObject, process)
                    if process then
                        return
                    end

                    if input == Enum.UserInputState or input == Enum.UserInputType then
                        return
                    end

                    if input.KeyCode == Enum.KeyCode.Unknown then
                        return
                    end

                    if input.KeyCode == Enum.KeyCode.Backspace then
                        ModuleManager:scale_keybind(true)

                        Library._config._keybinds[settings.Flag] = nil
                        Config:save(game.GameId, Library._config)

                        TextLabel.Text = 'None'

                        if Connections[settings.Flag..'_keybind'] then
                            Connections[settings.Flag..'_keybind']:Disconnect()
                            Connections[settings.Flag..'_keybind'] = nil
                        end

                        Connections['keybind_choose_start']:Disconnect()
                        Connections['keybind_choose_start'] = nil

                        Library._choosing_keybind = false

                        return
                    end

                    Connections['keybind_choose_start']:Disconnect()
                    Connections['keybind_choose_start'] = nil

                    Library._config._keybinds[settings.Flag] = tostring(input.KeyCode)
                    Config:save(game.GameId, Library._config)

                    if Connections[settings.Flag..'_keybind'] then
                        Connections[settings.Flag..'_keybind']:Disconnect()
                        Connections[settings.Flag..'_keybind'] = nil
                    end

                    ModuleManager:connect_keybind()
                    ModuleManager:scale_keybind()

                    Library._choosing_keybind = false

                    local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.Flag]), 'Enum.KeyCode.', '')
                    TextLabel.Text = keybind_string
                end)
            end)

            Header.MouseButton1Click:Connect(function()
                ModuleManager:change_state(not ModuleManager._state)
            end)

            function ModuleManager:CreateParagraph(settings: any)
                LayoutOrderModule += 1

                local ParagraphManager = {}

                if self._size == 0 then
                    self._size = 11
                end

                self._size += settings.Scale or 65

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local Paragraph = Instance.new('Frame', Options)
                Paragraph.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
                Paragraph.BackgroundTransparency = 0.1
                Paragraph.Size = UDim2.new(0, 207, 0, 30)
                Paragraph.BorderSizePixel = 0
                Paragraph.Name = "Paragraph"
                Paragraph.AutomaticSize = Enum.AutomaticSize.Y
                Paragraph.LayoutOrder = LayoutOrderModule

                local UICorner8 = Instance.new('UICorner', Paragraph)
                UICorner8.CornerRadius = UDim.new(0, 4)

                local Title = Instance.new('TextLabel', Paragraph)
                Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Title.TextColor3 = Color3.fromRGB(210, 210, 210)
                Title.Text = settings.Title or "Title"
                Title.Size = UDim2.new(1, -10, 0, 20)
                Title.Position = UDim2.new(0, 5, 0, 5)
                Title.BackgroundTransparency = 1
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.TextYAlignment = Enum.TextYAlignment.Center
                Title.TextSize = 12
                Title.AutomaticSize = Enum.AutomaticSize.XY

                local Body = Instance.new('TextLabel', Paragraph)
                Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Body.TextColor3 = Color3.fromRGB(180, 180, 180)

                if not settings.Rich then
                    Body.Text = settings.Text or "Skibidi"
                else
                    Body.RichText = true
                    Body.Text = settings.RichText or "<font color='rgb(255,0,0)'>OwO</font> user"
                end

                Body.Size = UDim2.new(1, -10, 0, 20)
                Body.Position = UDim2.new(0, 5, 0, 30)
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = 11
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.XY
                Body.Parent = Paragraph

                Paragraph.MouseEnter:Connect(function()
                    TweenService:Create(Paragraph, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(42, 50, 66)
                    }):Play()
                end)

                Paragraph.MouseLeave:Connect(function()
                    TweenService:Create(Paragraph, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(32, 38, 51)
                    }):Play()
                end)

                return ParagraphManager
            end

            function ModuleManager:CreateText(settings: any)
                LayoutOrderModule += 1

                local TextManager = {}

                if self._size == 0 then
                    self._size = 11
                end

                self._size += settings.Scale or 50

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local TextFrame = Instance.new('Frame', Options)

                TextFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TextFrame.BackgroundTransparency = 0.1
                TextFrame.Size = UDim2.new(0, 207, 0, settings.Height)
                TextFrame.BorderSizePixel = 0
                TextFrame.Name = "Text"
                TextFrame.AutomaticSize = Enum.AutomaticSize.Y
                TextFrame.LayoutOrder = LayoutOrderModule

                local UICorner7 = Instance.new('UICorner', TextFrame)
                UICorner7.CornerRadius = UDim.new(0, 4)

                local Body = Instance.new('TextLabel', TextFrame)

                Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Body.TextColor3 = Color3.fromRGB(180, 180, 180)

                if not settings.Rich then
                    Body.Text = settings.Text or "Skibidi"
                else
                    Body.RichText = true
                    Body.Text = settings.RichText or "<font color='rgb(255,0,0)'>OwO</font> user"
                end

                Body.Size = UDim2.new(1, -10, 1, 0)
                Body.Position = UDim2.new(0, 5, 0, 5)
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = 10
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.XY

                TextFrame.MouseEnter:Connect(function()
                    TweenService:Create(TextFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(42, 50, 66)
                    }):Play()
                end)

                TextFrame.MouseLeave:Connect(function()
                    TweenService:Create(TextFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(32, 38, 51)
                    }):Play()
                end)

                function TextManager:Set(new_settings)
                    if not new_settings.Rich then
                        Body.Text = new_settings.Text or "Skibidi"
                    else
                        Body.RichText = true
                        Body.Text = new_settings.RichText or "<font color='rgb(255,0,0)'>OwO</font> user"
                    end
                end

                return TextManager
            end

            function ModuleManager:CreateTextBox(settings: any)
                LayoutOrderModule += 1

                local TextboxManager = {
                    _text = ""
                }

                if self._size == 0 then
                    self._size = 11
                end

                self._size += 32

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local Label = Instance.new('TextLabel', Options)
                Label.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.TextTransparency = 0.2
                Label.Text = settings.Title or "Enter text"
                Label.Size = UDim2.new(0, 207, 0, 13)
                Label.AnchorPoint = Vector2.new(0, 0)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BorderSizePixel = 0
                Label.TextSize = 10
                Label.LayoutOrder = LayoutOrderModule

                local TextBox = Instance.new('TextBox', Options)
                TextBox.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                TextBox.PlaceholderText = settings.PlaceHolder or "Enter text..."
                TextBox.Text = Library._config._flags[settings.Flag] or ""
                TextBox.Name = 'TextBox'
                TextBox.Size = UDim2.new(0, 207, 0, 15)
                TextBox.BorderSizePixel = 0
                TextBox.TextSize = 10
                TextBox.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
                TextBox.BackgroundTransparency = 0.9
                TextBox.ClearTextOnFocus = false
                TextBox.LayoutOrder = LayoutOrderModule

                local UICorner8 = Instance.new('UICorner', TextBox)
                UICorner8.CornerRadius = UDim.new(0, 4)

                function TextboxManager:update_text(text)
                    self._text = text
                    Library._config._flags[settings.Flag] = self._text
                    Config:save(game.GameId, Library._config)
                    settings.Callback(self._text)
                end

                if Library:flag_type(settings.Flag, 'string') then
                    TextboxManager:update_text(Library._config._flags[settings.Flag])
                end

                TextBox.FocusLost:Connect(function()
                    TextboxManager:update_text(TextBox.Text)
                end)

                return TextboxManager
            end

            function ModuleManager:CreateCheckBox(settings: any)
                LayoutOrderModule += 1

                local CheckboxManager = {
                    _state = false
                }

                if self._size == 0 then
                    self._size = 11
                end

                self._size += 20

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local Checkbox = Instance.new("TextButton", Options)
                Checkbox.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Checkbox.TextColor3 = Color3.fromRGB(0, 0, 0)
                Checkbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Checkbox.Text = ""
                Checkbox.AutoButtonColor = false
                Checkbox.BackgroundTransparency = 1
                Checkbox.Name = "Checkbox"
                Checkbox.Size = UDim2.new(0, 207, 0, 15)
                Checkbox.BorderSizePixel = 0
                Checkbox.TextSize = 14
                Checkbox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                Checkbox.LayoutOrder = LayoutOrderModule

                local TitleLabel = Instance.new("TextLabel", Checkbox)
                TitleLabel.Name = "TitleLabel"

                if SelectedLanguage == "th" then
                    TitleLabel.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TitleLabel.TextSize = 13
                else
                    TitleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TitleLabel.TextSize = 11
                end

                TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                TitleLabel.TextTransparency = 0.2
                TitleLabel.Text = settings.Title or "Skibidi"
                TitleLabel.Size = UDim2.new(0, 142, 0, 13)
                TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
                TitleLabel.Position = UDim2.new(0, 0, 0.5, 0)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

                local KeybindBox = Instance.new("Frame", Checkbox)
                KeybindBox.Name = "KeybindBox"
                KeybindBox.Size = UDim2.fromOffset(14, 14)
                KeybindBox.Position = UDim2.new(1, -35, 0.5, 0)
                KeybindBox.AnchorPoint = Vector2.new(0, 0.5)
                KeybindBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                KeybindBox.BorderSizePixel = 0

                local KeybindCorner = Instance.new("UICorner", KeybindBox)
                KeybindCorner.CornerRadius = UDim.new(0, 4)

                local KeybindLabel = Instance.new("TextLabel", KeybindBox)
                KeybindLabel.Name = "KeybindLabel"
                KeybindLabel.Size = UDim2.new(1, 0, 1, 0)
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
                KeybindLabel.TextScaled = false
                KeybindLabel.TextSize = 10
                KeybindLabel.Font = Enum.Font.SourceSans
                KeybindLabel.Text = Library._config._keybinds[settings.Flag] and string.gsub(tostring(Library._config._keybinds[settings.Flag]), "Enum.KeyCode.", "") 
                    or "..."

                local Box = Instance.new("Frame", Checkbox)
                Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Box.AnchorPoint = Vector2.new(1, 0.5)
                Box.BackgroundTransparency = 0.9
                Box.Position = UDim2.new(1, 0, 0.5, 0)
                Box.Name = "Box"
                Box.Size = UDim2.new(0, 15, 0, 15)
                Box.BorderSizePixel = 0
                Box.BackgroundColor3 = Color3.fromRGB(152, 152, 152)

                local BoxCorner = Instance.new("UICorner", Box)
                BoxCorner.CornerRadius = UDim.new(0, 4)

                local Fill = Instance.new("Frame", Box)
                Fill.AnchorPoint = Vector2.new(0.5, 0.5)
                Fill.BackgroundTransparency = 0.2
                Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
                Fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Fill.Name = "Fill"
                Fill.BorderSizePixel = 0
                Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                local FillCorner = Instance.new("UICorner", Fill)
                FillCorner.CornerRadius = UDim.new(0, 3)

                function CheckboxManager:change_state(state: any)
                    self._state = state

                    if self._state then
                        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.7
                        }):Play()

                        TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(9, 9)
                        }):Play()
                    else
                        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.9
                        }):Play()

                        TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(0, 0)
                        }):Play()
                    end
                    Library._config._flags[settings.Flag] = self._state
                    Config:save(game.GameId, Library._config)
                    settings.Callback(self._state)
                end

                if Library:flag_type(settings.Flag, "boolean") then
                    CheckboxManager:change_state(Library._config._flags[settings.Flag])
                end

                Checkbox.MouseButton1Click:Connect(function()
                    CheckboxManager:change_state(not CheckboxManager._state)
                end)

                Checkbox.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then
                        return
                    end

                    if input.UserInputType ~= Enum.UserInputType.MouseButton3 then
                        return
                    end

                    if Library._choosing_keybind then
                        return
                    end

                    Library._choosing_keybind = true

                    Connections['choose'] = UserInputService.InputBegan:Connect(function(keyInput, processed)
                        if processed then
                            return
                        end

                        if keyInput.UserInputType ~= Enum.UserInputType.Keyboard then
                            return
                        end

                        if keyInput.KeyCode == Enum.KeyCode.Unknown then
                            return
                        end

                        if keyInput.KeyCode == Enum.KeyCode.Backspace then
                            ModuleManager:scale_keybind(true)
                            Library._config._keybinds[settings.Flag] = nil
                            Config:save(game.GameId, Library._config)
                            KeybindLabel.Text = "..."

                            if Connections[settings.Flag .. "_keybind"] then
                                Connections[settings.Flag .. "_keybind"]:Disconnect()
                                Connections[settings.Flag .. "_keybind"] = nil
                            end

                            Connections:disconnect('choose')
                            Library._choosing_keybind = false
                            return
                        end

                        Connections:disconnect('choose')
                        Library._config._keybinds[settings.Flag] = tostring(keyInput.KeyCode)
                        Config:save(game.GameId, Library._config)

                        if Connections[settings.Flag .. "_keybind"] then
                            Connections[settings.Flag .. "_keybind"]:Disconnect()
                            Connections[settings.Flag .. "_keybind"] = nil
                        end

                        ModuleManager:connect_keybind()
                        ModuleManager:scale_keybind()
                        Library._choosing_keybind = false

                        local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.Flag]), "Enum.KeyCode.", "")
                        KeybindLabel.Text = keybind_string
                    end)
                end)

                local keyPressConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then
                        return
                    end

                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local storedKey = Library._config._keybinds[settings.Flag]

                        if storedKey and tostring(input.KeyCode) == storedKey then
                            CheckboxManager:change_state(not CheckboxManager._state)
                        end
                    end
                end)
                Connections[settings.Flag .. "_keypress"] = keyPressConnection

                return CheckboxManager
            end

            function ModuleManager:CreateDivider(settings: any)
                LayoutOrderModule += 1

                if self._size == 0 then
                    self._size = 11
                end

                self._size += 27

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                local dividerHeight = 1
                local dividerWidth = 207

                local OuterFrame = Instance.new('Frame', Options)
                OuterFrame.Size = UDim2.new(0, dividerWidth, 0, 20)
                OuterFrame.BackgroundTransparency = 1
                OuterFrame.Name = 'OuterFrame'
                OuterFrame.LayoutOrder = LayoutOrderModule

                if settings and settings.ShotTopic then
                    local TextLabel3 = Instance.new('TextLabel', OuterFrame)

                    TextLabel3.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabel3.TextColor3 = Color3.fromRGB(255, 255, 255)
                    TextLabel3.TextTransparency = 0
                    TextLabel3.Text = settings.Title
                    TextLabel3.Size = UDim2.new(0, 153, 0, 13)
                    TextLabel3.Position = UDim2.new(0.5, 0, 0.501, 0)
                    TextLabel3.BackgroundTransparency = 1
                    TextLabel3.TextXAlignment = Enum.TextXAlignment.Center
                    TextLabel3.BorderSizePixel = 0
                    TextLabel3.AnchorPoint = Vector2.new(0.5,0.5)
                    TextLabel3.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    TextLabel3.TextSize = 11
                    TextLabel3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    TextLabel3.ZIndex = 3
                    TextLabel3.TextStrokeTransparency = 0
                end

                if not settings or settings and not settings.DisableLine then
                    local Divider4 = Instance.new('Frame', OuterFrame)

                    Divider4.Size = UDim2.new(1, 0, 0, dividerHeight)
                    Divider4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Divider4.BorderSizePixel = 0
                    Divider4.Name = 'Divider'
                    Divider4.ZIndex = 2
                    Divider4.Position = UDim2.new(0, 0, 0.5, -dividerHeight / 2)

                    local Gradient2 = Instance.new('UIGradient', Divider)

                    Gradient2.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255, 0))
                    })
                    Gradient2.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.5, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                    Gradient2.Rotation = 0

                    local UICorner9 = Instance.new('UICorner', Divider)
                    UICorner9.CornerRadius = UDim.new(0, 2)
                end

                return true
            end

            function ModuleManager:CreateSlider(settings: any)
                LayoutOrderModule += 1

                local SliderManager = {}

                if self._size == 0 then
                    self._size = 11
                end

                self._size += 27

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local Slider = Instance.new('TextButton', Options)
                Slider.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Slider.TextSize = 14
                Slider.TextColor3 = Color3.fromRGB(0, 0, 0)
                Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Slider.Text = ''
                Slider.AutoButtonColor = false
                Slider.BackgroundTransparency = 1
                Slider.Name = 'Slider'
                Slider.Size = UDim2.new(0, 207, 0, 22)
                Slider.BorderSizePixel = 0
                Slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                Slider.LayoutOrder = LayoutOrderModule

                local TextLabel = Instance.new('TextLabel', Slider)
                if SelectedLanguage == "th" then
                    TextLabel.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabel.TextSize = 13
                else
                    TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabel.TextSize = 11
                end

                TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextLabel.TextTransparency = 0.20000000298023224
                TextLabel.Text = settings.Title
                TextLabel.Size = UDim2.new(0, 153, 0, 13)
                TextLabel.Position = UDim2.new(0, 0, 0.05000000074505806, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.BorderSizePixel = 0
                TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                local Drag = Instance.new('Frame', Slider)
                Drag.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Drag.AnchorPoint = Vector2.new(0.5, 1)
                Drag.BackgroundTransparency = 0.8999999761581421
                Drag.Position = UDim2.new(0.5, 0, 0.949999988079071, 0)
                Drag.Name = 'Drag'
                Drag.Size = UDim2.new(0, 207, 0, 4)
                Drag.BorderSizePixel = 0
                Drag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                local UICorner10 = Instance.new('UICorner', Drag)
                UICorner10.CornerRadius = UDim.new(1, 0)

                local Fill = Instance.new('Frame', Drag)
                Fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Fill.AnchorPoint = Vector2.new(0, 0.5)
                Fill.BackgroundTransparency = 0.5
                Fill.Position = UDim2.new(0, 0, 0.5, 0)
                Fill.Name = 'Fill'
                Fill.Size = UDim2.new(0, 103, 0, 4)
                Fill.BorderSizePixel = 0
                Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                local UICorner11 = Instance.new('UICorner', Fill)
                UICorner11.CornerRadius = UDim.new(0, 3)

                local UIGradient = Instance.new('UIGradient', Fill)
                UIGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(79, 79, 79))
                }

                local Circle2 = Instance.new('Frame', Fill)

                Circle2.AnchorPoint = Vector2.new(1, 0.5)
                Circle2.Name = 'Circle'
                Circle2.Position = UDim2.new(1, 0, 0.5, 0)
                Circle2.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Circle2.Size = UDim2.new(0, 6, 0, 6)
                Circle2.BorderSizePixel = 0
                Circle2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                local UICorner12 = Instance.new('UICorner', Circle)
                UICorner12.CornerRadius = UDim.new(1, 0)

                local Label = Instance.new('TextLabel', Slider)
                Label.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.TextTransparency = 0.20000000298023224
                Label.Text = '50'
                Label.Name = 'Value'
                Label.Size = UDim2.new(0, 42, 0, 13)
                Label.AnchorPoint = Vector2.new(1, 0)
                Label.Position = UDim2.new(1, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.TextXAlignment = Enum.TextXAlignment.Right
                Label.BorderSizePixel = 0
                Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Label.TextSize = 10
                Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                function SliderManager:set_percentage(percentage: number)
                    local rounded = 0

                    if settings.Round then
                        rounded = math.floor(percentage)
                    else
                        rounded = math.floor(percentage * 10) / 10
                    end

                    percentage = (percentage - settings.Min) / (settings.Max - settings.Min)

                    local slider_size = math.clamp(percentage, 0.02, 1) * Drag.Size.X.Offset
                    local number_threshold = math.clamp(rounded, settings.Min, settings.Max)

                    Library._config._flags[settings.Flag] = number_threshold
                    Label.Text = number_threshold

                    TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2.fromOffset(slider_size, Drag.Size.Y.Offset)
                    }):Play()

                    settings.Callback(number_threshold)
                end

                function SliderManager:update()
                    local mouse_position = (Mouse.X - Drag.AbsolutePosition.X) / Drag.Size.X.Offset
                    local percentage = settings.Min + (settings.Max - settings.Min) * mouse_position

                    self:set_percentage(percentage)
                end

                function SliderManager:input()
                    SliderManager:update()

                    Connections['slider_drag_'..settings.Flag] = Mouse.Move:Connect(function()
                        SliderManager:update()
                    end)

                    Connections['slider_input_'..settings.Flag] = UserInputService.InputEnded:Connect(function(input, process)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                            return
                        end

                        Connections:disconnect('slider_drag_'..settings.Flag)
                        Connections:disconnect('slider_input_'..settings.Flag)

                        if not settings.ignoresaved then
                            Config:save(game.GameId, Library._config)
                        end
                    end)
                end


                if Library:flag_type(settings.Flag, 'number') then
                    if not settings.ignoresaved then
                        SliderManager:set_percentage(Library._config._flags[settings.Flag])
                    else
                        SliderManager:set_percentage(settings.Default)
                    end
                else
                    SliderManager:set_percentage(settings.Default)
                end

                Slider.MouseButton1Down:Connect(function()
                    SliderManager:input()
                end)

                return SliderManager
            end

            function ModuleManager:CreateDropdown(settings: any)

                if not settings.Order then
                    LayoutOrderModule += 1
                end

                local DropdownManager = {
                    _state = false,
                    _size = 0
                }

                if not settings.Order then
                    if self._size == 0 then
                        self._size = 11
                    end

                    self._size += 44
                end

                if not settings.Order then
                    if ModuleManager._state then
                        Module.Size = UDim2.fromOffset(241, 93 + self._size)
                    end
                    Options.Size = UDim2.fromOffset(241, self._size)
                end

                local Dropdown = Instance.new('TextButton', Options)
                Dropdown.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Dropdown.TextColor3 = Color3.fromRGB(0, 0, 0)
                Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Dropdown.Text = ''
                Dropdown.AutoButtonColor = false
                Dropdown.BackgroundTransparency = 1
                Dropdown.Name = 'Dropdown'
                Dropdown.Size = UDim2.new(0, 207, 0, 39)
                Dropdown.BorderSizePixel = 0
                Dropdown.TextSize = 14
                Dropdown.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

                if not settings.Order then
                    Dropdown.LayoutOrder = LayoutOrderModule
                else
                    Dropdown.LayoutOrder = settings.OrderValue
                end

                if not Library._config._flags[settings.Flag] then
                    Library._config._flags[settings.Flag] = {}
                end

                local TextLabel3 = Instance.new('TextLabel', Dropdown)

                if SelectedLanguage == "th" then
                    TextLabel3.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabel3.TextSize = 13
                else
                    TextLabel3.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabel3.TextSize = 11
                end

                TextLabel3.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextLabel3.TextTransparency = 0.20000000298023224
                TextLabel3.Text = settings.Title
                TextLabel3.Size = UDim2.new(0, 207, 0, 13)
                TextLabel3.BackgroundTransparency = 1
                TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel3.BorderSizePixel = 0
                TextLabel3.BorderColor3 = Color3.fromRGB(0, 0, 0)
                TextLabel3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                local Box = Instance.new('Frame', TextLabel3)
                Box.ClipsDescendants = true
                Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Box.AnchorPoint = Vector2.new(0.5, 0)
                Box.BackgroundTransparency = 0.8999999761581421
                Box.Position = UDim2.new(0.5, 0, 1.2000000476837158, 0)
                Box.Name = 'Box'
                Box.Size = UDim2.new(0, 207, 0, 22)
                Box.BorderSizePixel = 0
                Box.BackgroundColor3 = Color3.fromRGB(152, 181, 255)

                local UICorner13 = Instance.new('UICorner', Box)
                UICorner13.CornerRadius = UDim.new(0, 4)

                local Header2 = Instance.new('Frame', Box)
                Header2.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Header2.AnchorPoint = Vector2.new(0.5, 0)
                Header2.BackgroundTransparency = 1
                Header2.Position = UDim2.new(0.5, 0, 0, 0)
                Header2.Name = 'Header'
                Header2.Size = UDim2.new(0, 207, 0, 22)
                Header2.BorderSizePixel = 0
                Header2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                local CurrentOption = Instance.new('TextLabel', Header2)
                CurrentOption.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                CurrentOption.TextColor3 = Color3.fromRGB(255, 255, 255)
                CurrentOption.TextTransparency = 0.20000000298023224
                CurrentOption.Name = 'CurrentOption'
                CurrentOption.Size = UDim2.new(0, 161, 0, 13)
                CurrentOption.AnchorPoint = Vector2.new(0, 0.5)
                CurrentOption.Position = UDim2.new(0.04999988153576851, 0, 0.5, 0)
                CurrentOption.BackgroundTransparency = 1
                CurrentOption.TextXAlignment = Enum.TextXAlignment.Left
                CurrentOption.BorderSizePixel = 0
                CurrentOption.BorderColor3 = Color3.fromRGB(0, 0, 0)
                CurrentOption.TextSize = 10
                CurrentOption.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                local UIGradient3 = Instance.new('UIGradient', CurrentOption)
                UIGradient3.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(0.704, 0),
                    NumberSequenceKeypoint.new(0.872, 0.36250001192092896),
                    NumberSequenceKeypoint.new(1, 1)
                }

                local Arrow = Instance.new('ImageLabel', Header)
                Arrow.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Arrow.AnchorPoint = Vector2.new(0, 0.5)
                Arrow.Image = 'rbxassetid://84232453189324'
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(0.9100000262260437, 0, 0.5, 0)
                Arrow.Name = 'Arrow'
                Arrow.Size = UDim2.new(0, 8, 0, 8)
                Arrow.BorderSizePixel = 0
                Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                local Options2 = Instance.new('ScrollingFrame', Box)
                Options2.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
                Options2.Active = true
                Options2.ScrollBarImageTransparency = 1
                Options2.AutomaticCanvasSize = Enum.AutomaticSize.XY
                Options2.ScrollBarThickness = 0
                Options2.Name = 'Options'
                Options2.Size = UDim2.new(0, 207, 0, 0)
                Options2.BackgroundTransparency = 1
                Options2.Position = UDim2.new(0, 0, 1, 0)
                Options2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Options2.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Options2.BorderSizePixel = 0
                Options2.CanvasSize = UDim2.new(0, 0, 0.5, 0)

                local UIListLayout6 = Instance.new('UIListLayout', Options2)
                UIListLayout6.SortOrder = Enum.SortOrder.LayoutOrder

                local UIPadding15 = Instance.new('UIPadding', Box)
                UIPadding15.PaddingTop = UDim.new(0, -1)
                UIPadding15.PaddingLeft = UDim.new(0, 10)

                local UIListLayout7 = Instance.new('UIListLayout', Box)
                UIListLayout7.SortOrder = Enum.SortOrder.LayoutOrder

                function DropdownManager:set_options(new: table)
                    for _, obj in ipairs(Options2:GetChildren()) do
                        if obj.Name == "Option" then
                            obj:Destroy()
                        end
                    end

                    for _, option in ipairs(new) do
                        local btn = Instance.new("TextButton")
                        btn.Name = "Option"
                        btn.Text = tostring(option)
                        btn.Size = UDim2.new(1, 0, 0, 18)
                        btn.BackgroundTransparency = 1
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        btn.TextSize = 12
                        btn.Font = Enum.Font.SourceSans
                        btn.Parent = Options

                        btn.MouseButton1Click:Connect(function()
                            self:update(option)
                        end)
                    end

                    settings.Options = new

                    local current = Library._config._flags[settings.Flag]

                    if typeof(current) == "string" and table.find(new, current) then
                        CurrentOption.Text = current
                    else
                        CurrentOption.Text = SelectedLanguage.DropdownSelect or "Select"
                        Library._config._flags[settings.Flag] = nil
                    end
                end

                function DropdownManager:update(option: string)
                    if settings.MultiDropdown then
                        if not Library._config._flags[settings.Flag] then
                            Library._config._flags[settings.Flag] = {}
                        end

                        local CurrentTarget

                        if #Library._config._flags[settings.Flag] > 0 then
                            CurrentTarget = TableToString(Library._config._flags[settings.Flag])
                        end

                        local selected = {}

                        if CurrentTarget then
                            for v in string.gmatch(CurrentTarget, "([^,]+)") do
                                local trimmedV = v:match("^%s*(.-)%s*$")

                                if trimmedV ~= "Label" then
                                    table.insert(selected, trimmedV)
                                end
                            end
                        else
                            for v in string.gmatch(CurrentOption.Text, "([^,]+)") do
                                local trimmedV = v:match("^%s*(.-)%s*$")

                                if trimmedV ~= "Label" then
                                    table.insert(selected, trimmedV)
                                end
                            end
                        end

                        local CurrentTextGet = StringToTable(CurrentOption.Text)

                        _option = "nil"

                        if typeof(option) ~= 'string' then
                            _option = option.Name
                        else
                            _option = option
                        end

                        for i, v in pairs(CurrentTextGet) do
                            if v == _option then
                                table.remove(CurrentTextGet, i)
                                break
                            end
                        end

                        CurrentOption.Text = table.concat(selected, ", ")

                        local OptionsChild = {}

                        for _, obj in Options2:GetChildren() do
                            if obj.Name == "Option" then
                                table.insert(OptionsChild, obj.Text)
                                if table.find(selected, obj.Text) then
                                    obj.TextTransparency = 0.2
                                else
                                    obj.TextTransparency = 0.6
                                end
                            end
                        end

                        CurrentTarget = StringToTable(CurrentOption.Text)

                        for _, v in CurrentTarget do
                            if not table.find(OptionsChild, v) and table.find(selected, v) then
                                table.remove(selected, _)
                            end
                        end

                        CurrentOption.Text = table.concat(selected, ", ")

                        Library._config._flags[settings.Flag] = StringToTable(CurrentOption.Text)
                    else
                        CurrentOption.Text = (typeof(option) == "string" and option) or option.Name

                        for _, obj in Options2:GetChildren() do
                            if obj.Name == "Option" then
                                if obj.Text == CurrentOption.Text then
                                    obj.TextTransparency = 0.2
                                else
                                    obj.TextTransparency = 0.6
                                end
                            end
                        end
                        Library._config._flags[settings.Flag] = option
                    end
                    Config:save(game.GameId, Library._config)
                    settings.Callback(option)
                end

                local CurrentDropSizeState = 0

                function DropdownManager:unfold_settings()
                    self._state = not self._state

                    if self._state then
                        ModuleManager._multiplier += self._size

                        CurrentDropSizeState = self._size

                        TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(241, 93 + ModuleManager._size + ModuleManager._multiplier)
                        }):Play()

                        TweenService:Create(Module.Options, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(241, ModuleManager._size + ModuleManager._multiplier)
                        }):Play()

                        TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(207, 39 + self._size)
                        }):Play()

                        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(207, 22 + self._size)
                        }):Play()

                        TweenService:Create(Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Rotation = 180
                        }):Play()
                    else
                        ModuleManager._multiplier -= self._size

                        CurrentDropSizeState = 0

                        TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(241, 93 + ModuleManager._size + ModuleManager._multiplier)
                        }):Play()

                        TweenService:Create(Module.Options, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(241, ModuleManager._size + ModuleManager._multiplier)
                        }):Play()

                        TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(207, 39)
                        }):Play()

                        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(207, 22)
                        }):Play()

                        TweenService:Create(Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Rotation = 0
                        }):Play()
                    end
                end

                if #settings.Options > 0 then
                    DropdownManager._size = 3

                    for i, v in settings.Options do
                        local Option = Instance.new('TextButton', Options2)
                        Option.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                        Option.Active = false
                        Option.TextTransparency = 0.6000000238418579
                        Option.AnchorPoint = Vector2.new(0, 0.5)
                        Option.TextSize = 10
                        Option.Size = UDim2.new(0, 186, 0, 16)
                        Option.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Option.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        Option.Text = (typeof(v) == "string" and v) or v.Name
                        Option.AutoButtonColor = false
                        Option.Name = 'Option'
                        Option.BackgroundTransparency = 1
                        Option.TextXAlignment = Enum.TextXAlignment.Left
                        Option.Selectable = false
                        Option.Position = UDim2.new(0.04999988153576851, 0, 0.34210526943206787, 0)
                        Option.BorderSizePixel = 0
                        Option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                        local UIGradient4 = Instance.new('UIGradient', Option)
                        UIGradient4.Transparency = NumberSequence.new{
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.704, 0),
                            NumberSequenceKeypoint.new(0.872, 0.36250001192092896),
                            NumberSequenceKeypoint.new(1, 1)
                        }

                        Option.MouseButton1Click:Connect(function()
                            if not Library._config._flags[settings.Flag] then
                                Library._config._flags[settings.Flag] = {}
                            end

                            if settings.MultiDropdown then
                                if table.find(Library._config._flags[settings.Flag], v) then
                                    Library:remove_table_value(Library._config._flags[settings.Flag], v)
                                else
                                    table.insert(Library._config._flags[settings.Flag], v)
                                end
                            end

                            DropdownManager:update(v)
                        end)

                        if i > settings.Max then
                            return
                        end

                        DropdownManager._size += 16
                        Options.Size = UDim2.fromOffset(207, DropdownManager._size)
                    end
                end

                function DropdownManager:New(value)
                    Dropdown:Destroy(true)
                    value.OrderValue = Dropdown.LayoutOrder
                    ModuleManager._multiplier += CurrentDropSizeState
                    return ModuleManager:CreateDropdown(value)
                end

                if Library:flag_type(settings.Flag, 'string') then
                    DropdownManager:update(Library._config._flags[settings.Flag])
                else
                    DropdownManager:update(settings.Options[1])
                end

                Dropdown.MouseButton1Click:Connect(function()
                    DropdownManager:unfold_settings()
                end)

                return DropdownManager
            end

            function ModuleManager:create_feature(settings: any)

                local checked = false

                LayoutOrderModule += 1

                if self._size == 0 then
                    self._size = 11
                end

                self._size += 20

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local FeatureContainer = Instance.new("Frame", Options)
                FeatureContainer.Size = UDim2.new(0, 207, 0, 16)
                FeatureContainer.BackgroundTransparency = 1
                FeatureContainer.LayoutOrder = LayoutOrderModule

                local UIListLayout6 = Instance.new("UIListLayout", FeatureContainer)
                UIListLayout6.FillDirection = Enum.FillDirection.Horizontal
                UIListLayout6.SortOrder = Enum.SortOrder.LayoutOrder

                local FeatureButton = Instance.new("TextButton", FeatureContainer)
                FeatureButton.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                FeatureButton.TextSize = 11
                FeatureButton.Size = UDim2.new(1, -35, 0, 16)
                FeatureButton.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
                FeatureButton.TextColor3 = Color3.fromRGB(210, 210, 210)
                FeatureButton.Text = "    " .. settings.Title or "    " .. "Feature"
                FeatureButton.AutoButtonColor = false
                FeatureButton.TextXAlignment = Enum.TextXAlignment.Left
                FeatureButton.TextTransparency = 0.2

                local RightContainer = Instance.new("Frame", FeatureContainer)
                RightContainer.Size = UDim2.new(0, 45, 0, 16)
                RightContainer.BackgroundTransparency = 1

                local RightLayout = Instance.new("UIListLayout", RightContainer)
                RightLayout.Padding = UDim.new(0.1, 0)
                RightLayout.FillDirection = Enum.FillDirection.Horizontal
                RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                RightLayout.SortOrder = Enum.SortOrder.LayoutOrder

                local KeybindBox = Instance.new("TextLabel", RightContainer)
                KeybindBox.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                KeybindBox.Size = UDim2.new(0, 15, 0, 15)
                KeybindBox.BackgroundColor3 = Color3.fromRGB(181, 181, 181)
                KeybindBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                KeybindBox.TextSize = 11
                KeybindBox.BackgroundTransparency = 1
                KeybindBox.LayoutOrder = 2

                local KeybindButton = Instance.new("TextButton", KeybindBox)
                KeybindButton.Size = UDim2.new(1, 0, 1, 0)
                KeybindButton.BackgroundTransparency = 1
                KeybindButton.TextTransparency = 1

                local CheckboxCorner = Instance.new("UICorner", KeybindBox)
                CheckboxCorner.CornerRadius = UDim.new(0, 3)

                local UIStroke3 = Instance.new("UIStroke", KeybindBox)
                UIStroke.Color3 = Color3.fromRGB(255, 255, 255)
                UIStroke3.Thickness = 1
                UIStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                if not Library._config._flags then
                    Library._config._flags = {}
                end

                if not Library._config._flags[settings.Flag] then
                    Library._config._flags[settings.Flag] = {
                        checked = false,
                        BIND = settings.Default or "Unknown"
                    }
                end

                checked = Library._config._flags[settings.Flag].checked
                KeybindBox.Text = Library._config._flags[settings.Flag].BIND

                if KeybindBox.Text == "Unknown" then
                    KeybindBox.Text = "..."
                end

                local UseF_Var = nil

                if not settings.DisableCheck then
                    local Checkbox = Instance.new("TextButton", RightContainer)
                    Checkbox.Size = UDim2.new(0, 15, 0, 15)
                    Checkbox.BackgroundColor3 = checked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(182, 182, 182)
                    Checkbox.Text = ""
                    Checkbox.LayoutOrder = 1

                    local UIStroke5 = Instance.new("UIStroke", Checkbox)
                    UIStroke5.Color = Color3.fromRGB(255, 255, 255)
                    UIStroke5.Thickness = 1
                    UIStroke5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                    local CheckboxCorner2 = Instance.new("UICorner", Checkbox)
                    CheckboxCorner2.CornerRadius = UDim.new(0, 3)

                    local function toggleState()
                        checked = not checked

                        Checkbox.BackgroundColor3 = checked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(182, 182, 182)
                        Library._config._flags[settings.Flag].checked = checked
                        Config:save(game.GameId, Library._config)

                        if settings.Callback then
                            settings.Callback(checked)
                        end
                    end

                    UseF_Var = toggleState

                    Checkbox.MouseButton1Click:Connect(toggleState)
                else
                    UseF_Var = function()
                        settings.Button_Callback()
                    end
                end

                KeybindButton.MouseButton1Click:Connect(function()
                    KeybindBox.Text = "..."

                    local inputConnection
                    inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then
                            return
                        end

                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            local newKey = input.KeyCode.Name
                            Library._config._flags[settings.Flag].BIND = newKey

                            if newKey ~= "Unknown" then
                                KeybindBox.Text = newKey
                            end

                            Config:save(game.GameId, Library._config)
                            inputConnection:Disconnect()
                        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                            Library._config._flags[settings.Flag].BIND = "Unknown"
                            KeybindBox.Text = "..."
                            Config:save(game.GameId, Library._config)
                            inputConnection:Disconnect()
                        end
                    end)
                    Connections["keybind_input_" .. settings.Flag] = inputConnection
                end)

                local keyPressConnection
                keyPressConnection = UserInputService.InputBegan:Connect(function(input: InputObject, process)
                    if process then
                        return
                    end

                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode.Name == Library._config._flags[settings.Flag].BIND then
                            UseF_Var()
                        end
                    end
                end)
                Connections["keybind_press_" .. settings.Flag] = keyPressConnection

                FeatureButton.MouseButton1Click:Connect(function()
                    if settings.Button_Callback then
                        settings.Button_Callback()
                    end
                end)

                if not settings.DisableCheck then
                    settings.Callback(checked)
                end

                return FeatureContainer
            end

            return ModuleManager
        end

        return TabManager
    end

    Connections['library_visiblity'] = UserInputService.InputBegan:Connect(function(input: InputObject, _: boolean)

        if UserInputService:GetFocusedTextBox() then
            return
        end

        if input.KeyCode ~= Enum.KeyCode.LeftControl then
            return
        end

        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    self._ui.Container.Handler.Minimize.MouseButton1Click:Connect(function()
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    return self
end

return Library