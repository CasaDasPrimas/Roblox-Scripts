--// Connections
type ConnectionsType = {
    [string]: RBXScriptConnection?,

    disconnect: (self: ConnectionsType, key: string) -> (),
    disconnect_all: (self: ConnectionsType) -> ()
}

--// Util
type UtilType = {
    map: (self: UtilType, value: number, minIn: number, maxIn: number, minOut: number, maxOut: number) -> number,
    viewport: (self: UtilType, location: Vector2, distance: number) -> Vector3,
    get_offset: (self: UtilType) -> number
}

--// Blur
type AcrylicBlurType = {
    new: (obj: GuiObject) -> AcrylicBlurType,

    create_folder: (self: AcrylicBlurType) -> (),
    create_depth_of_fields: (self: AcrylicBlurType) -> (),
    create_frame: (self: AcrylicBlurType) -> (),
    create_root: (self: AcrylicBlurType) -> (),

    setup: (self: AcrylicBlurType) -> (),
    render: (self: AcrylicBlurType, distance: number) -> (),

    check_quality_level: (self: AcrylicBlurType) -> (),
    change_visiblity: (self: AcrylicBlurType, state: boolean) -> ()
}

--// Main Type
type ConfigType = {
    save: (self: ConfigType, file_name: string, config: any) -> (),
    load: (self: ConfigType, file_name: string, defaultConfig: any) -> any
}

--// Library INIT def toma no cu beto
type LibraryType = {
    _config: any,
    _is_mobile: boolean?,

    _choosing_keybind: boolean,
    _device: string?,

    _ui_open: boolean,
    _ui_scale: number,
    _ui_loaded: boolean,
    _ui: ScreenGui?,

    _dragging: boolean,
    _drag_start: Vector3?,
    _container_position: UDim2?,

    CreateWindow: (self: LibraryType) -> LibraryType,
    get_screen_scale: (self: LibraryType) -> (),
    get_device: (self: LibraryType) -> (),

    removed: (self: LibraryType, action: () -> ()) -> (),
    flag_type: (self: LibraryType, flag: string, flag_type: string) -> boolean,
    remove_table_value: (self: LibraryType, tbl: {any}, value: any) -> (),

    CreateUi: (self: LibraryType) -> (),
    CreateNotify: (self: LibraryType, settings: any) -> (),
    change_visiblity: (self: LibraryType, state: boolean) -> (),

    load: (self: LibraryType) -> (),
    update_tabs: (self: LibraryType, tab: TextButton) -> (),

    update_sections: (self: LibraryType, left: ScrollingFrame, right: ScrollingFrame) -> (),
    CreateTab: (self: LibraryType, title: string, icon: string) -> any
}

--// Services
cloneref = cloneref or function(...) return ... end

local UserInputService: UserInputService = cloneref(game:GetService('UserInputService'))
local ContentProvider: ContentProvider = cloneref(game:GetService('ContentProvider'))
local TweenService: TweenService = cloneref(game:GetService('TweenService'))
local HttpService: HttpService = cloneref(game:GetService('HttpService'))
local TextService: TextService = cloneref(game:GetService('TextService'))
local RunService: RunService = cloneref(game:GetService('RunService'))
local Lighting: Lighting = cloneref(game:GetService('Lighting'))
local Players: Players = cloneref(game:GetService('Players'))
local CoreGui: CoreGui = cloneref(game:GetService('CoreGui'))
local Debris: Debris = cloneref(game:GetService('Debris'))

--// Variables
local CurrentCamera: Camera = workspace.CurrentCamera
local LocalPlayer: Player = Players.LocalPlayer
local Mouse: Mouse = LocalPlayer:GetMouse()

--// Languages
local SelectedLanguage: { [string]: string } = {
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

local function StringToTable(str: string): {string}
    local result: {string} = {}

    for v in string.gmatch(str, '([^,]+)') do
        table.insert(result, v:match('^%s*(.-)%s*$'))
    end

    return result
end

local function TableToString(tbl: {string}): string
    return table.concat(tbl, ', ')
end

if not isfolder('OwO') then
    makefolder("OwO")
end

local Connections: ConnectionsType = setmetatable({
    disconnect = function(self: ConnectionsType, key: string)
        local connection = self[key]

        if connection then
            connection:Disconnect()
            self[key] = nil
        end
    end,

    disconnect_all = function(self: ConnectionsType)
        for key, connection in pairs(self) do
            if typeof(connection) == 'RBXScriptConnection' then
                connection:Disconnect()
                self[key] = nil
            end
        end
    end
}, {} :: ConnectionsType)

local Util: UtilType = setmetatable({
    map = function(self: UtilType, value: number, minIn: number, maxIn: number, minOut: number, maxOut: number): number
        return (value - minIn) * (maxOut - minOut) / (maxIn - minIn) + minOut
    end,

    viewport = function(self: UtilType, location: Vector2, distance: number): Vector3
        local ray: Ray = CurrentCamera:ScreenPointToRay(location.X, location.Y)
        return ray.Origin + ray.Direction * distance
    end,

    get_offset = function(self: UtilType): number
        local viewportSizeY: number = CurrentCamera.ViewportSize.Y
        return self:map(viewportSizeY, 0, 2560, 8, 56)
    end
}, {} :: UtilType)

local AcrylicBlur: AcrylicBlurType = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(obj: GuiObject): AcrylicBlurType
    local self: AcrylicBlurType = setmetatable({
        _object = obj,
        _folder = nil :: Folder?,
        _frame = nil :: Frame?,
        _root = nil :: Part?
    }, AcrylicBlur)

    self:setup()
    return self
end

function AcrylicBlur:create_folder()
    local old: Instance? = CurrentCamera:FindFirstChild('AcrylicBlur')

    if old then
        Debris:AddItem(old, 0)
    end

    local folder: Folder = Instance.new('Folder')
    folder.Name = 'AcrylicBlur'
    folder.Parent = CurrentCamera

    self._folder = folder
end

function AcrylicBlur:create_depth_of_fields()
    local depthOfField: DepthOfFieldEffect = Lighting:FindFirstChild('AcrylicBlur') or Instance.new('DepthOfFieldEffect')
    depthOfField.FarIntensity = 0
    depthOfField.FocusDistance = 0.05
    depthOfField.InFocusRadius = 0.1
    depthOfField.NearIntensity = 1
    depthOfField.Name = 'AcrylicBlur'
    depthOfField.Parent = Lighting

    for _, obj: Instance in Lighting:GetChildren() do
        if not obj:IsA('DepthOfFieldEffect') or obj == depthOfField then
            continue
        end
        Connections[obj.Name] = obj:GetPropertyChangedSignal('FarIntensity'):Connect(function()
            obj.FarIntensity = 0
        end)

        obj.FarIntensity = 0
    end
end

function AcrylicBlur:create_frame()
    local frame: Frame = Instance.new('Frame')
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1
    frame.Parent = self._object
    self._frame = frame
end

function AcrylicBlur:create_root()
    local part: Part = Instance.new('Part')
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
    part.Parent = self._folder

    local mesh: SpecialMesh = Instance.new('SpecialMesh')
    mesh.MeshType = Enum.MeshType.Brick
    mesh.Offset = Vector3.new(0, 0, -0.000001)
    mesh.Parent = part

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
    local positions: {top_left: Vector2, top_right: Vector2, bottom_right: Vector2} = {
        top_left = Vector2.new(),
        top_right = Vector2.new(),
        bottom_right = Vector2.new(),
    }

    local function update_positions(size: Vector2, position: Vector2)
        positions.top_left = position
        positions.top_right = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end

    local function update()
        local top_left3D: Vector3 = Util:viewport(positions.top_left, distance)
        local top_right3D: Vector3 = Util:viewport(positions.top_right, distance)
        local bottom_right3D: Vector3 = Util:viewport(positions.bottom_right, distance)

        local width: number = (top_right3D - top_left3D).Magnitude
        local height: number = (top_right3D - bottom_right3D).Magnitude

        if self._root then
            self._root.CFrame = CFrame.fromMatrix((top_left3D + bottom_right3D) / 2, CurrentCamera.CFrame.XVector, CurrentCamera.CFrame.YVector, CurrentCamera.CFrame.ZVector)
            self._root.Mesh.Scale = Vector3.new(width, height, 0)
        end
    end

    local function on_change()
        local offset: number = Util:get_offset()
        local size: Vector2 = self._frame.AbsoluteSize - Vector2.new(offset, offset)
        local position: Vector2 = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)

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
    local gameSettings: GameSettings = UserSettings():GetService("UserGameSettings")
    local qualityLevel: number = gameSettings.SavedQualityLevel.Value

    if qualityLevel < 8 then
        self:change_visiblity(false)
    end

    Connections['quality_level'] = gameSettings:GetPropertyChangedSignal('SavedQualityLevel'):Connect(function()
        qualityLevel = gameSettings.SavedQualityLevel.Value
        self:change_visiblity(qualityLevel >= 8)
    end)
end

function AcrylicBlur:change_visiblity(state: boolean)
    if self._root then
        self._root.Transparency = state and 0.98 or 1
    end
end

local Config: ConfigType = setmetatable({
    save = function(self: ConfigType, file_name: string, config: any)
        local success, result = pcall(function()
            writefile('OwO/' .. file_name .. '.json', HttpService:JSONEncode(config))
        end)

        if not success then
            warn('Failed to save config:', result)
        end
    end,
    load = function(self: ConfigType, file_name: string, defaultConfig: any): any
        local success, result = pcall(function()
            if not isfile('OwO/' .. file_name .. '.json') then
                return self:save(file_name, defaultConfig)
            end

            local flags: string? = readfile('OwO/' .. file_name .. '.json')

            if not flags then
                self:save(file_name, defaultConfig)

                return defaultConfig
            end

            return HttpService:JSONDecode(flags)
        end)

        if not success then
            warn('Failed to load config:', result)

            return defaultConfig
        end

        return result or defaultConfig
    end
}, {} :: ConfigType)

local Library: LibraryType = {
    _config = Config:load(tostring(game.GameId), {
        _flags = {},
        _keybinds = {},
        _library = {}
    }),

    _is_mobile = table.find({
        Enum.Platform.IOS,
        Enum.Platform.Android
    }, UserInputService:GetPlatform()),

    _choosing_keybind = false,
    _ui_open = true,
    _ui_scale = 1,

    _ui_loaded = false,
    _dragging = false
}

Library.__index = Library

function Library:CreateWindow(): LibraryType
    local self: LibraryType = setmetatable({
        _loaded = false,
        _tab = 0
    }, Library)

    self:CreateUi()
    return self
end

local NotifyContainer: Frame = Instance.new("Frame")
NotifyContainer.Name = "NotifyContainer"
NotifyContainer.Size = UDim2.new(0, 300, 0, 0)
NotifyContainer.Position = UDim2.new(0.8, 0, 0, 10)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.AutomaticSize = Enum.AutomaticSize.Y
NotifyContainer.Parent = CoreGui:FindFirstChild("RobloxGui") or Instance.new("ScreenGui", CoreGui)

local UIListLayout: UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = NotifyContainer

function Library:CreateNotify(settings: {Title: string?, Text: string?, Duration: number?})
    local Notification: Frame = Instance.new("Frame")
    Notification.Size = UDim2.new(1, 0, 0, 60)
    Notification.BackgroundTransparency = 1
    Notification.AutomaticSize = Enum.AutomaticSize.Y
    Notification.Parent = NotifyContainer

    local UICorner: UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Notification

    local InnerFrame: Frame = Instance.new("Frame")
    InnerFrame.Size = UDim2.new(1, 0, 0, 60)
    InnerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    InnerFrame.BackgroundTransparency = 0.3
    InnerFrame.AutomaticSize = Enum.AutomaticSize.Y
    InnerFrame.Parent = Notification

    local InnerUICorner: UICorner = Instance.new("UICorner")
    InnerUICorner.CornerRadius = UDim.new(0, 4)
    InnerUICorner.Parent = InnerFrame

    local Title: TextLabel = Instance.new("TextLabel")
    Title.Text = settings.Title or "Notification Title"
    Title.TextColor3 = Color3.fromRGB(210, 210, 210)
    Title.Font = Enum.Font.GothamSemibold
    Title.TextSize = 14
    Title.Size = UDim2.new(1, -10, 0, 20)
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextWrapped = true
    Title.AutomaticSize = Enum.AutomaticSize.Y
    Title.Parent = InnerFrame

    local Body: TextLabel = Instance.new("TextLabel")
    Body.Text = settings.Text or "This is the body of the notification."
    Body.TextColor3 = Color3.fromRGB(180, 180, 180)
    Body.Font = Enum.Font.GothamSemibold
    Body.TextSize = 12
    Body.Size = UDim2.new(1, -10, 0, 30)
    Body.Position = UDim2.new(0, 5, 0, 25)
    Body.BackgroundTransparency = 1
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.TextYAlignment = Enum.TextYAlignment.Top
    Body.TextWrapped = true
    Body.AutomaticSize = Enum.AutomaticSize.Y
    Body.Parent = InnerFrame

    task.spawn(function()
        task.wait(0.1)
        local height = Title.TextBounds.Y + Body.TextBounds.Y + 10
        InnerFrame.Size = UDim2.new(1, 0, 0, height)
    end)

    task.spawn(function()
        TweenService:Create(InnerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 10 + NotifyContainer.Size.Y.Offset)
        }):Play()

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
    local viewportSizeX: number = CurrentCamera.ViewportSize.X

    self._ui_scale = viewportSizeX / 1400
end

function Library:get_device()
    self._device = self._is_mobile and 'Mobile' or 'PC'
end

function Library:removed(action: () -> ())
    if self._ui then
        self._ui.AncestryChanged:Once(action)
    end
end

function Library:flag_type(flag: string, flag_type: string): boolean
    local value = self._config._flags[flag]

    return value ~= nil and typeof(value) == flag_type
end

function Library:remove_table_value(tbl: {any}, value: any)
    for i, v in ipairs(tbl) do
        if v == value then
            table.remove(tbl, i)
            break
        end
    end
end

function Library:CreateUi()
    local OwO: ScreenGui = Instance.new('ScreenGui')
    OwO.ResetOnSpawn = false
    OwO.Name = 'OwO'
    OwO.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    OwO.Parent = CoreGui

    local Container: Frame = Instance.new('Frame')
    Container.ClipsDescendants = true
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.Name = 'Container'
    Container.BackgroundTransparency = 0
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0, 0, 0, 0)
    Container.Active = true
    Container.Parent = OwO

    local Gradient: UIGradient = Instance.new("UIGradient")

    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 5, 15)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(40, 15, 30)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(70, 25, 50)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(100, 40, 75)),
        ColorSequenceKeypoint.new(0.85, Color3.fromRGB(130, 60, 100)),
        ColorSequenceKeypoint.new(0.95, Color3.fromRGB(160, 80, 125)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 100, 150))
    })
    Gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 0.15)
    })
    Gradient.Rotation = -45
    Gradient.Parent = Container

    local UICorner: UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Container

    local UIStroke: UIStroke = Instance.new('UIStroke')
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Transparency = 0.5
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = Container

    local Handler: Frame = Instance.new('Frame')
    Handler.BackgroundTransparency = 1
    Handler.Name = 'Handler'
    Handler.Size = UDim2.new(0, 698, 0, 479)
    Handler.Parent = Container

    local Tabs: ScrollingFrame = Instance.new('ScrollingFrame')
    Tabs.ScrollBarImageTransparency = 1
    Tabs.ScrollBarThickness = 0
    Tabs.Name = 'Tabs'
    Tabs.Size = UDim2.new(0, 129, 0, 401)
    Tabs.AutomaticCanvasSize = Enum.AutomaticSize.XY
    Tabs.BackgroundTransparency = 1
    Tabs.Position = UDim2.new(0.026, 0, 0.111, 0)
    Tabs.CanvasSize = UDim2.new(0, 0, 0.5, 0)
    Tabs.Parent = Handler

    local UIListLayout: UIListLayout = Instance.new('UIListLayout')
    UIListLayout.Padding = UDim.new(0, 4)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Tabs

    local ScriptName: TextLabel = Instance.new('TextLabel')
    ScriptName.Font = Enum.Font.GothamSemibold
    ScriptName.TextColor3 = Color3.fromRGB(255, 254, 255)
    ScriptName.TextTransparency = 0.2
    ScriptName.Text = 'UwU.dll'
    ScriptName.Name = 'ScriptName'
    ScriptName.Size = UDim2.new(0, 31, 0, 13)
    ScriptName.AnchorPoint = Vector2.new(0, 0.5)
    ScriptName.Position = UDim2.new(0.056, 0, 0.055, 0)
    ScriptName.BackgroundTransparency = 1
    ScriptName.TextXAlignment = Enum.TextXAlignment.Left
    ScriptName.TextSize = 13
    ScriptName.Parent = Handler

    local UIGradient: UIGradient = Instance.new('UIGradient')
    UIGradient.Color = ColorSequence.new(Color3.fromRGB(155, 155, 155), Color3.fromRGB(255, 255, 255))
    UIGradient.Parent = ScriptName

    local Pin: Frame = Instance.new('Frame')
    Pin.Name = 'Pin'
    Pin.Position = UDim2.new(0.026, 0, 0.136, 0)
    Pin.Size = UDim2.new(0, 2, 0, 16)
    Pin.BackgroundColor3 = Color3.fromRGB(255, 254, 255)
    Pin.Parent = Handler

    local UICorner: UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = Pin

    local Icon: ImageLabel = Instance.new('ImageLabel')
    Icon.ScaleType = Enum.ScaleType.Fit
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.Image = ''
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0.013, 0, 0.055, 0)
    Icon.Name = 'Icon'
    Icon.Size = UDim2.new(0, 35, 0, 35)
    Icon.Parent = Handler

    local IDs: {string} = {
        "137613206534423",
        "85001297263526",
        "77720936213212",
        "71849504203751",
        "139291859864999",
        "110957981641303",
        "135054168844778",
        "103066533154874"
    }

    local frameIndex: number = 1
    local lastTime: number = os.clock()

    RunService.Heartbeat:Connect(function()
        local timeNow: number = os.clock()

        if timeNow - lastTime >= 0.1 then
            Icon.Image = "rbxassetid://" .. IDs[frameIndex]
            frameIndex = frameIndex % #IDs + 1
            lastTime = timeNow
        end
    end)

    local Divider: Frame = Instance.new('Frame')
    Divider.Name = 'Divider'
    Divider.BackgroundTransparency = 0.5
    Divider.Position = UDim2.new(0.235, 0, 0, 0)
    Divider.Size = UDim2.new(0, 1, 0, 479)
    Divider.BackgroundColor3 = Color3.fromRGB(255, 254, 255)
    Divider.Parent = Handler

    local Sections: Folder = Instance.new('Folder')
    Sections.Name = 'Sections'
    Sections.Parent = Handler

    local Minimize: TextButton = Instance.new('TextButton')
    Minimize.Font = Enum.Font.SourceSans
    Minimize.TextColor3 = Color3.fromRGB(0, 0, 0)
    Minimize.Text = ''
    Minimize.AutoButtonColor = false
    Minimize.Name = 'Minimize'
    Minimize.BackgroundTransparency = 1
    Minimize.Position = UDim2.new(0.02, 0, 0.029, 0)
    Minimize.Size = UDim2.new(0, 24, 0, 24)
    Minimize.TextSize = 14
    Minimize.Parent = Handler

    local UIScale: UIScale = Instance.new('UIScale')
    UIScale.Parent = Container

    self._ui = OwO

    local function on_drag(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging = true
            self._drag_start = input.Position
            self._container_position = Container.Position

            Connections['container_input_ended'] = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Connections:disconnect('container_input_ended')
                    self._dragging = false
                end
            end)
        end
    end

    local function update_drag(input: InputObject)
        local delta: Vector3 = input.Position - self._drag_start
        local position: UDim2 = UDim2.new(self._container_position.X.Scale, self._container_position.X.Offset + delta.X, self._container_position.Y.Scale, self._container_position.Y.Offset + delta.Y)

        TweenService:Create(Container, TweenInfo.new(0.2), { Position = position }):Play()
    end

    local function drag(input: InputObject)
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

    function self:Update1Run(transparency: string?)
        if transparency == "nil" then
            Container.BackgroundTransparency = 0.05
        else
            Container.BackgroundTransparency = tonumber(transparency) or 0
        end
    end

    function self:UIVisiblity()
        if self._ui then
            self._ui.Enabled = not self._ui.Enabled
        end
    end

    local function SetTransparency(state: boolean)
        local folder: Folder? = CurrentCamera:FindFirstChild("AcrylicBlur")

        if folder then
            local root: Part? = folder:FindFirstChild("Root")

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

            Connections['container_input_began'] = Container.InputBegan:Connect(on_drag)
            Connections['input_changed'] = UserInputService.InputChanged:Connect(drag)
            SetTransparency(true)
        else
            TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(104.5, 52)
            }):Play()

            Connections:disconnect('container_input_began')
            Connections:disconnect('input_changed')
            SetTransparency(false)
        end
    end

    function self:load()
        local content: {Instance} = {}

        for _, obj: Instance in OwO:GetDescendants() do
            if obj:IsA('ImageLabel') then
                table.insert(content, obj)
            end
        end

        ContentProvider:PreloadAsync(content)
        self:get_device()

        if self._device == 'Mobile' then
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
        for _, obj: Instance in Tabs:GetChildren() do
            if obj.Name ~= 'Tab' then
                continue
            end

            local isSelected = obj == tab

            TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = isSelected and 0.5 or 1
            }):Play()

            local textLabel: TextLabel = obj:FindFirstChildOfClass("TextLabel")

            if textLabel then
                TweenService:Create(textLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    TextTransparency = isSelected and 0.2 or 0.7,
                    TextColor3 = isSelected and Color3.fromRGB(255, 254, 255) or Color3.fromRGB(255, 255, 255)
                }):Play()

                local gradient: UIGradient = textLabel:FindFirstChildOfClass("UIGradient")

                if gradient then
                    TweenService:Create(gradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Offset = isSelected and Vector2.new(1, 0) or Vector2.new(0, 0)
                    }):Play()
                end
            end

            local icon: ImageLabel = obj:FindFirstChild("Icon")

            if icon then
                TweenService:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    ImageTransparency = isSelected and 0.2 or 0.8,
                    ImageColor3 = isSelected and Color3.fromRGB(255, 254, 255) or Color3.fromRGB(255, 255, 255)
                }):Play()
            end

            if isSelected then
                local offset: number = obj.LayoutOrder * (0.113 / 1.3)

                TweenService:Create(Pin, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = UDim2.fromScale(0.026, 0.135 + offset)
                }):Play()
            end
        end
    end

    function self:update_sections(leftSection: ScrollingFrame, rightSection: ScrollingFrame)
        for _, obj: Instance in Sections:GetChildren() do
            obj.Visible = obj == leftSection or obj == rightSection
        end
    end

    function self:CreateTab(title: string, icon: string)
        local TabManager = {
            _tab = self._tab
        }

        local params = Instance.new('TextBoundsParams')
        params.Text = title
        params.Font = Enum.Font.GothamSemibold
        params.Size = 13
        params.Width = 10000

        local fontSize: Vector2 = TextService:GetTextBoundsAsync(params)
        local isFirstTab: boolean = not Tabs:FindFirstChild('Tab')

        local Tab: TextButton = Instance.new('TextButton')
        Tab.Font = Enum.Font.SourceSans
        Tab.TextColor3 = Color3.fromRGB(0, 0, 0)
        Tab.Text = ''
        Tab.AutoButtonColor = false
        Tab.BackgroundTransparency = 1
        Tab.Name = 'Tab'
        Tab.Size = UDim2.new(0, 129, 0, 38)
        Tab.TextSize = 14
        Tab.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
        Tab.LayoutOrder = self._tab
        Tab.Parent = Tabs

        local UICorner: UICorner = Instance.new('UICorner')
        UICorner.CornerRadius = UDim.new(0, 5)
        UICorner.Parent = Tab

        local TextLabel: TextLabel = Instance.new('TextLabel')
        TextLabel.Font = Enum.Font.GothamSemibold
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextTransparency = 0.7
        TextLabel.Text = title
        TextLabel.Size = UDim2.new(0, fontSize.X, 0, 16)
        TextLabel.AnchorPoint = Vector2.new(0, 0.5)
        TextLabel.Position = UDim2.new(0.24, 0, 0.5, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.TextSize = 13
        TextLabel.Parent = Tab

        local UIGradient: UIGradient = Instance.new('UIGradient')
        UIGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(58, 58, 58))
        UIGradient.Parent = TextLabel

        local Icon: ImageLabel = Instance.new('ImageLabel')
        Icon.ScaleType = Enum.ScaleType.Fit
        Icon.ImageTransparency = 0.8
        Icon.AnchorPoint = Vector2.new(0, 0.5)
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(0.1, 0, 0.5, 0)
        Icon.Name = 'Icon'
        Icon.Image = icon
        Icon.Size = UDim2.new(0, 12, 0, 12)
        Icon.Parent = Tab

        local LeftSection: ScrollingFrame = Instance.new('ScrollingFrame')
        LeftSection.Name = 'LeftSection'
        LeftSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        LeftSection.ScrollBarThickness = 0
        LeftSection.Size = UDim2.new(0, 243, 0, 445)
        LeftSection.AnchorPoint = Vector2.new(0, 0.5)
        LeftSection.ScrollBarImageTransparency = 1
        LeftSection.BackgroundTransparency = 1
        LeftSection.Position = UDim2.new(0.259, 0, 0.5, 0)
        LeftSection.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        LeftSection.Visible = false
        LeftSection.Parent = Sections

        local UIListLayout: UIListLayout = Instance.new('UIListLayout')
        UIListLayout.Padding = UDim.new(0, 11)
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = LeftSection

        local UIPadding: UIPadding = Instance.new('UIPadding')
        UIPadding.PaddingTop = UDim.new(0, 1)
        UIPadding.Parent = LeftSection

        local RightSection: ScrollingFrame = Instance.new('ScrollingFrame')
        RightSection.Name = 'RightSection'
        RightSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        RightSection.ScrollBarThickness = 0
        RightSection.Size = UDim2.new(0, 243, 0, 445)
        RightSection.AnchorPoint = Vector2.new(0, 0.5)
        RightSection.ScrollBarImageTransparency = 1
        RightSection.BackgroundTransparency = 1
        RightSection.Position = UDim2.new(0.629, 0, 0.5, 0)
        RightSection.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        RightSection.Visible = false
        RightSection.Parent = Sections

        local UIListLayout: UIListLayout = Instance.new('UIListLayout')
        UIListLayout.Padding = UDim.new(0, 11)
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = RightSection

        local UIPadding: UIPadding = Instance.new('UIPadding')
        UIPadding.PaddingTop = UDim.new(0, 1)
        UIPadding.Parent = RightSection

        self._tab = self._tab + 1

        if isFirstTab then
            self:update_tabs(Tab)
            self:update_sections(LeftSection, RightSection)
        end

        Tab.MouseButton1Click:Connect(function()
            self:update_tabs(Tab)
            self:update_sections(LeftSection, RightSection)
        end)

        function TabManager:CreateModule(settings: any)
            local layoutOrder: number = 0
            local ModuleManager = {
                _state = false,
                _size = 0,
                _multiplier = 0
            }

            local section: ScrollingFrame = settings.Section == 'right' and RightSection or LeftSection

            local Module: Frame = Instance.new('Frame')
            Module.ClipsDescendants = true
            Module.BackgroundTransparency = 0.5
            Module.Name = 'Module'
            Module.Size = UDim2.new(0, 241, 0, 93)
            Module.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
            Module.Parent = section

            local UIListLayout: UIListLayout = Instance.new('UIListLayout')
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Parent = Module

            local UICorner: UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(0, 5)
            UICorner.Parent = Module

            local UIStroke: UIStroke = Instance.new('UIStroke')
            UIStroke.Color = Color3.fromRGB(255, 254, 255)
            UIStroke.Transparency = 0.5
            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            UIStroke.Parent = Module

            local Header: TextButton = Instance.new('TextButton')
            Header.Font = Enum.Font.SourceSans
            Header.TextColor3 = Color3.fromRGB(0, 0, 0)
            Header.Text = ''
            Header.AutoButtonColor = false
            Header.BackgroundTransparency = 1
            Header.Name = 'Header'
            Header.Size = UDim2.new(0, 241, 0, 93)
            Header.TextSize = 14
            Header.Parent = Module

            local Icon: ImageLabel = Instance.new('ImageLabel')
            Icon.ScaleType = Enum.ScaleType.Fit
            Icon.ImageTransparency = 0.7
            Icon.AnchorPoint = Vector2.new(0, 0.5)
            Icon.Image = 'rbxassetid://79095934438045'
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(0.071, 0, 0.82, 0)
            Icon.Name = 'Icon'
            Icon.Size = UDim2.new(0, 15, 0, 15)
            Icon.Parent = Header

            local ModuleName: TextLabel = Instance.new('TextLabel')
            ModuleName.Font = Enum.Font.GothamSemibold
            ModuleName.TextColor3 = Color3.fromRGB(255, 254, 255)
            ModuleName.TextTransparency = 0.2
            ModuleName.Text = settings.Title or "Title"
            ModuleName.Name = 'ModuleName'
            ModuleName.Size = UDim2.new(0, 205, 0, 13)
            ModuleName.AnchorPoint = Vector2.new(0, 0.5)
            ModuleName.Position = UDim2.new(0.073, 0, 0.24, 0)
            ModuleName.BackgroundTransparency = 1
            ModuleName.TextXAlignment = Enum.TextXAlignment.Left
            ModuleName.TextSize = 13
            ModuleName.Parent = Header

            if settings.Rich then
                ModuleName.RichText = true
                ModuleName.Text = settings.RichText or "<font color='rgb(255,0,0)'>OwO</font> user"
            end

            local Description: TextLabel = Instance.new('TextLabel')
            Description.Font = Enum.Font.GothamSemibold
            Description.TextColor3 = Color3.fromRGB(200, 200, 200)
            Description.TextTransparency = 0.7
            Description.Text = settings.Description or ""
            Description.Name = 'Description'
            Description.Size = UDim2.new(0, 205, 0, 13)
            Description.AnchorPoint = Vector2.new(0, 0.5)
            Description.Position = UDim2.new(0.073, 0, 0.42, 0)
            Description.BackgroundTransparency = 1
            Description.TextXAlignment = Enum.TextXAlignment.Left
            Description.TextSize = 10
            Description.Parent = Header

            local Toggle: Frame = Instance.new('Frame')
            Toggle.Name = 'Toggle'
            Toggle.BackgroundTransparency = 0.7
            Toggle.Position = UDim2.new(0.82, 0, 0.757, 0)
            Toggle.Size = UDim2.new(0, 25, 0, 12)
            Toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Toggle.Parent = Header

            local UICorner: UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = Toggle

            local Circle: Frame = Instance.new('Frame')
            Circle.AnchorPoint = Vector2.new(0, 0.5)
            Circle.BackgroundTransparency = 0.2
            Circle.Position = UDim2.new(0, 0, 0.5, 0)
            Circle.Name = 'Circle'
            Circle.Size = UDim2.new(0, 12, 0, 12)
            Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            Circle.Parent = Toggle

            local UICorner: UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = Circle

            local Keybind: Frame = Instance.new('Frame')
            Keybind.Name = 'Keybind'
            Keybind.BackgroundTransparency = 0.7
            Keybind.Position = UDim2.new(0.15, 0, 0.735, 0)
            Keybind.Size = UDim2.new(0, 33, 0, 15)
            Keybind.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
            Keybind.Parent = Header

            local UICorner: UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(0, 3)
            UICorner.Parent = Keybind

            local TextLabel: TextLabel = Instance.new('TextLabel')
            TextLabel.Font = Enum.Font.GothamSemibold
            TextLabel.TextColor3 = Color3.fromRGB(209, 222, 255)
            TextLabel.Text = 'None'
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.Size = UDim2.new(0, 25, 0, 13)
            TextLabel.BackgroundTransparency = 1
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            TextLabel.TextSize = 10
            TextLabel.Parent = Keybind

            local Divider: Frame = Instance.new('Frame')
            Divider.AnchorPoint = Vector2.new(0.5, 0)
            Divider.BackgroundTransparency = 0.5
            Divider.Position = UDim2.new(0.5, 0, 0.62, 0)
            Divider.Name = 'Divider'
            Divider.Size = UDim2.new(0, 241, 0, 1)
            Divider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Divider.Parent = Header

            local Divider: Frame = Instance.new('Frame')
            Divider.AnchorPoint = Vector2.new(0.5, 0)
            Divider.BackgroundTransparency = 0.5
            Divider.Position = UDim2.new(0.5, 0, 1, 0)
            Divider.Name = 'Divider'
            Divider.Size = UDim2.new(0, 241, 0, 1)
            Divider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Divider.Parent = Header

            local Options: Frame = Instance.new('Frame')
            Options.Name = 'Options'
            Options.BackgroundTransparency = 1
            Options.Position = UDim2.new(0, 0, 1, 0)
            Options.Size = UDim2.new(0, 241, 0, 8)
            Options.Parent = Module

            local UIPadding: UIPadding = Instance.new('UIPadding')
            UIPadding.PaddingTop = UDim.new(0, 8)
            UIPadding.Parent = Options

            local UIListLayout: UIListLayout = Instance.new('UIListLayout')
            UIListLayout.Padding = UDim.new(0, 5)
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Parent = Options

            function ModuleManager:change_state(state: boolean)
                self._state = state

                local targetSize: UDim2 = state and UDim2.fromOffset(241, 93 + self._size + self._multiplier) or UDim2.fromOffset(241, 93)

                TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = targetSize
                }):Play()

                local toggleColor: Color3 = state and Color3.fromRGB(255, 254, 255) or Color3.fromRGB(0, 0, 0)

                TweenService:Create(Toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundColor3 = toggleColor
                }):Play()

                local circleColor: Color3 = state and Color3.fromRGB(255, 254, 255) or Color3.fromRGB(200, 200, 200)
                local circlePosition: UDim2 = state and UDim2.fromScale(0.53, 0.5) or UDim2.fromScale(0, 0.5)

                TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundColor3 = circleColor,
                    Position = circlePosition
                }):Play()

                Library._config._flags[settings.Flag] = self._state

                Config:save(tostring(game.GameId), Library._config)
                settings.Callback(self._state)
            end

            function ModuleManager:connect_keybind()
                if not Library._config._keybinds[settings.Flag] then
                    return
                end

                Connections[settings.Flag .. '_keybind'] = UserInputService.InputBegan:Connect(function(input: InputObject, process: boolean)
                    if process or tostring(input.KeyCode) ~= Library._config._keybinds[settings.Flag] then
                        return
                    end

                    self:change_state(not self._state)
                end)
            end

            function ModuleManager:scale_keybind(empty: boolean)
                if Library._config._keybinds[settings.Flag] and not empty then
                    local keyStr: string = string.gsub(Library._config._keybinds[settings.Flag], 'Enum.KeyCode.', '')

                    local params: TextBoundsParams = Instance.new('GetTextBoundsParams')
                    params.Text = keyStr
                    params.Font = Enum.Font.MontserratBold
                    params.Size = 10
                    params.Width = 10000

                    local fontSize: Vector2 = TextService:GetTextBoundsAsync(params)
                    Keybind.Size = UDim2.fromOffset(fontSize.X + 6, 15)
                    TextLabel.Size = UDim2.fromOffset(fontSize.X, 13)
                else
                    Keybind.Size = UDim2.fromOffset(31, 15)
                    TextLabel.Size = UDim2.fromOffset(25, 13)
                end
            end

            if Library:flag_type(settings.Flag, 'boolean') then
                ModuleManager:change_state(Library._config._flags[settings.Flag])
            end

            if Library._config._keybinds[settings.Flag] then
                local keyStr: string = string.gsub(Library._config._keybinds[settings.Flag], 'Enum.KeyCode.', '')

                TextLabel.Text = keyStr
                ModuleManager:connect_keybind()
                ModuleManager:scale_keybind(false)
            end

            Connections[settings.Flag .. '_input_began'] = Header.InputBegan:Connect(function(input: InputObject)
                if Library._choosing_keybind or input.UserInputType ~= Enum.UserInputType.MouseButton3 then
                    return
                end

                Library._choosing_keybind = true

                Connections['keybind_choose_start'] = UserInputService.InputBegan:Connect(function(keyInput: InputObject, process: boolean)
                    if process or keyInput.KeyCode == Enum.KeyCode.Unknown then
                        return
                    end

                    if keyInput.KeyCode == Enum.KeyCode.Backspace then
                        ModuleManager:scale_keybind(true)
                        Library._config._keybinds[settings.Flag] = nil

                        Config:save(tostring(game.GameId), Library._config)
                        TextLabel.Text = 'None'
                        Connections:disconnect(settings.Flag .. '_keybind')

                        Connections:disconnect('keybind_choose_start')
                        Library._choosing_keybind = false

                        return
                    end

                    Connections:disconnect('keybind_choose_start')
                    Library._config._keybinds[settings.Flag] = tostring(keyInput.KeyCode)

                    Config:save(tostring(game.GameId), Library._config)
                    Connections:disconnect(settings.Flag .. '_keybind')
                    ModuleManager:connect_keybind()

                    ModuleManager:scale_keybind(false)
                    Library._choosing_keybind = false

                    local keyStr: string = string.gsub(Library._config._keybinds[settings.Flag], 'Enum.KeyCode.', '')
                    TextLabel.Text = keyStr
                end)
            end)

            Header.MouseButton1Click:Connect(function()
                ModuleManager:change_state(not ModuleManager._state)
            end)

            function ModuleManager:CreateParagraph(settings: any)
                layoutOrder = layoutOrder + 1

                self._size = self._size + (settings.Scale or 65)

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end
                Options.Size = UDim2.fromOffset(241, self._size)

                local Paragraph: Frame = Instance.new('Frame')
                Paragraph.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
                Paragraph.BackgroundTransparency = 0.1
                Paragraph.Size = UDim2.new(0, 207, 0, 30)
                Paragraph.Name = "Paragraph"
                Paragraph.AutomaticSize = Enum.AutomaticSize.Y
                Paragraph.LayoutOrder = layoutOrder
                Paragraph.Parent = Options

                local UICorner: UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Paragraph

                local Title: TextLabel = Instance.new('TextLabel')
                Title.Font = Enum.Font.GothamSemibold
                Title.TextColor3 = Color3.fromRGB(210, 210, 210)
                Title.Text = settings.Title or "Title"
                Title.Size = UDim2.new(1, -10, 0, 20)
                Title.Position = UDim2.new(0, 5, 0, 5)
                Title.BackgroundTransparency = 1
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.TextYAlignment = Enum.TextYAlignment.Center
                Title.TextSize = 12
                Title.AutomaticSize = Enum.AutomaticSize.XY
                Title.Parent = Paragraph

                local Body: TextLabel = Instance.new('TextLabel')
                Body.Font = Enum.Font.Gotham
                Body.TextColor3 = Color3.fromRGB(180, 180, 180)
                Body.Text = settings.Text or "Skibidi"
                Body.Size = UDim2.new(1, -10, 0, 20)
                Body.Position = UDim2.new(0, 5, 0, 30)
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = 11
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.XY
                Body.Parent = Paragraph

                if settings.Rich then
                    Body.RichText = true
                    Body.Text = settings.RichText or "<font color='rgb(255,0,0)'>OwO</font> user"
                end

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

                return {}
            end

            function ModuleManager:CreateText(settings: any)
                layoutOrder = layoutOrder + 1

                self._size = self._size + (settings.Scale or 50)

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end
                Options.Size = UDim2.fromOffset(241, self._size)

                local TextFrame: Frame = Instance.new('Frame')
                TextFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TextFrame.BackgroundTransparency = 0.1
                TextFrame.Size = UDim2.new(0, 207, 0, settings.Height or 50)
                TextFrame.Name = "Text"
                TextFrame.AutomaticSize = Enum.AutomaticSize.Y
                TextFrame.LayoutOrder = layoutOrder
                TextFrame.Parent = Options

                local UICorner: UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = TextFrame

                local Body: TextLabel = Instance.new('TextLabel')
                Body.Font = Enum.Font.Gotham
                Body.TextColor3 = Color3.fromRGB(180, 180, 180)
                Body.Text = settings.Text or "Skibidi"
                Body.Size = UDim2.new(1, -10, 1, 0)
                Body.Position = UDim2.new(0, 5, 0, 5)
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = 10
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.XY
                Body.Parent = TextFrame

                if settings.Rich then
                    Body.RichText = true
                    Body.Text = settings.RichText or "<font color='rgb(255,0,0)'>OwO</font> user"
                end

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

                return {
                    Set = function(newSettings: any)
                        Body.Text = newSettings.Text or "Skibidi"
                        if newSettings.Rich then
                            Body.RichText = true
                            Body.Text = newSettings.RichText or "<font color='rgb(255,0,0)'>OwO</font> user"
                        end
                    end
                }
            end

            function ModuleManager:CreateTextBox(settings: any)
                layoutOrder = layoutOrder + 1

                self._size = self._size + 32

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local Label: TextLabel = Instance.new('TextLabel')
                Label.Font = Enum.Font.GothamSemibold
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.TextTransparency = 0.2
                Label.Text = settings.Title or "Enter text"
                Label.Size = UDim2.new(0, 207, 0, 13)
                Label.BackgroundTransparency = 1
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextSize = 10
                Label.LayoutOrder = layoutOrder
                Label.Parent = Options

                local TextBox: TextBox = Instance.new('TextBox')
                TextBox.Font = Enum.Font.SourceSans
                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextBox.PlaceholderText = settings.PlaceHolder or "Enter text..."
                TextBox.Text = Library._config._flags[settings.Flag] or ""
                TextBox.Name = 'TextBox'
                TextBox.Size = UDim2.new(0, 207, 0, 15)
                TextBox.TextSize = 10
                TextBox.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
                TextBox.BackgroundTransparency = 0.9
                TextBox.ClearTextOnFocus = false
                TextBox.LayoutOrder = layoutOrder
                TextBox.Parent = Options

                local UICorner: UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = TextBox

                local TextboxManager = {
                    _text = TextBox.Text
                }

                function TextboxManager:update_text(text: string)
                    self._text = text

                    Library._config._flags[settings.Flag] = self._text
                    Config:save(tostring(game.GameId), Library._config)
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
                layoutOrder = layoutOrder + 1

                self._size = self._size + 20

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end
                Options.Size = UDim2.fromOffset(241, self._size)

                local Checkbox: TextButton = Instance.new("TextButton")
                Checkbox.Font = Enum.Font.SourceSans
                Checkbox.TextColor3 = Color3.fromRGB(0, 0, 0)
                Checkbox.Text = ""
                Checkbox.AutoButtonColor = false
                Checkbox.BackgroundTransparency = 1
                Checkbox.Name = "Checkbox"
                Checkbox.Size = UDim2.new(0, 207, 0, 15)
                Checkbox.TextSize = 14
                Checkbox.LayoutOrder = layoutOrder
                Checkbox.Parent = Options

                local TitleLabel: TextLabel = Instance.new("TextLabel")
                TitleLabel.Name = "TitleLabel"
                TitleLabel.Font = Enum.Font.GothamSemibold
                TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                TitleLabel.TextTransparency = 0.2
                TitleLabel.Text = settings.Title or "Skibidi"
                TitleLabel.Size = UDim2.new(0, 142, 0, 13)
                TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
                TitleLabel.Position = UDim2.new(0, 0, 0.5, 0)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.Parent = Checkbox

                local KeybindBox: Frame = Instance.new("Frame")
                KeybindBox.Name = "KeybindBox"
                KeybindBox.Size = UDim2.fromOffset(14, 14)
                KeybindBox.Position = UDim2.new(1, -35, 0.5, 0)
                KeybindBox.AnchorPoint = Vector2.new(0, 0.5)
                KeybindBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                KeybindBox.Parent = Checkbox

                local KeybindCorner: UICorner = Instance.new("UICorner")
                KeybindCorner.CornerRadius = UDim.new(0, 4)
                KeybindCorner.Parent = KeybindBox

                local KeybindLabel: TextLabel = Instance.new("TextLabel")
                KeybindLabel.Name = "KeybindLabel"
                KeybindLabel.Size = UDim2.new(1, 0, 1, 0)
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
                KeybindLabel.TextSize = 10
                KeybindLabel.Font = Enum.Font.SourceSans
                KeybindLabel.Text = Library._config._keybinds[settings.Flag] and string.gsub(Library._config._keybinds[settings.Flag], "Enum.KeyCode.", "") or "..."
                KeybindLabel.Parent = KeybindBox

                local Box: Frame = Instance.new("Frame")
                Box.AnchorPoint = Vector2.new(1, 0.5)
                Box.BackgroundTransparency = 0.9
                Box.Position = UDim2.new(1, 0, 0.5, 0)
                Box.Name = "Box"
                Box.Size = UDim2.new(0, 15, 0, 15)
                Box.BackgroundColor3 = Color3.fromRGB(152, 152, 152)
                Box.Parent = Checkbox

                local BoxCorner: UICorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 4)
                BoxCorner.Parent = Box

                local Fill: Frame = Instance.new("Frame")
                Fill.AnchorPoint = Vector2.new(0.5, 0.5)
                Fill.BackgroundTransparency = 0.2
                Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
                Fill.Name = "Fill"
                Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Fill.Parent = Box

                local FillCorner: UICorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 3)
                FillCorner.Parent = Fill

                local CheckboxManager = {
                    _state = false
                }

                function CheckboxManager:change_state(state: boolean)
                    self._state = state

                    local boxTransparency: number = state and 0.7 or 0.9
                    TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = boxTransparency
                    }):Play()

                    local fillSize: UDim2 = state and UDim2.fromOffset(9, 9) or UDim2.fromOffset(0, 0)
                    TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = fillSize
                    }):Play()

                    Library._config._flags[settings.Flag] = self._state

                    Config:save(tostring(game.GameId), Library._config)
                    settings.Callback(self._state)
                end

                if Library:flag_type(settings.Flag, "boolean") then
                    CheckboxManager:change_state(Library._config._flags[settings.Flag])
                end

                Checkbox.MouseButton1Click:Connect(function()
                    CheckboxManager:change_state(not CheckboxManager._state)
                end)

                Checkbox.InputBegan:Connect(function(input: InputObject)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton3 or Library._choosing_keybind then
                        return
                    end
                    Library._choosing_keybind = true

                    Connections['choose'] = UserInputService.InputBegan:Connect(function(keyInput: InputObject, processed: boolean)
                        if processed or keyInput.UserInputType ~= Enum.UserInputType.Keyboard or keyInput.KeyCode == Enum.KeyCode.Unknown then
                            return
                        end

                        if keyInput.KeyCode == Enum.KeyCode.Backspace then
                            Library._config._keybinds[settings.Flag] = nil
                            Config:save(tostring(game.GameId), Library._config)

                            KeybindLabel.Text = "..."
                            Connections:disconnect(settings.Flag .. "_keybind")
                            Connections:disconnect('choose')

                            Library._choosing_keybind = false
                            return
                        end

                        Connections:disconnect('choose')
                        Library._config._keybinds[settings.Flag] = tostring(keyInput.KeyCode)
                        Config:save(tostring(game.GameId), Library._config)

                        Connections:disconnect(settings.Flag .. "_keybind")
                        Library._choosing_keybind = false

                        local keyStr: string = string.gsub(Library._config._keybinds[settings.Flag], "Enum.KeyCode.", "")
                        KeybindLabel.Text = keyStr
                    end)
                end)

                local keyPressConnection = UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
                    if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
                        return
                    end

                    if tostring(input.KeyCode) == Library._config._keybinds[settings.Flag] then
                        CheckboxManager:change_state(not CheckboxManager._state)
                    end
                end)

                Connections[settings.Flag .. "_keypress"] = keyPressConnection

                return CheckboxManager
            end

            function ModuleManager:CreateDivider(settings: any)
                layoutOrder = layoutOrder + 1

                self._size = self._size + 27

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                local OuterFrame: Frame = Instance.new('Frame')
                OuterFrame.Size = UDim2.new(0, 207, 0, 20)
                OuterFrame.BackgroundTransparency = 1
                OuterFrame.Name = 'OuterFrame'
                OuterFrame.LayoutOrder = layoutOrder
                OuterFrame.Parent = Options

                if settings and settings.ShotTopic then
                    local TextLabel: TextLabel = Instance.new('TextLabel')
                    TextLabel.Font = Enum.Font.GothamSemibold
                    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    TextLabel.Text = settings.Title or ""
                    TextLabel.Size = UDim2.new(0, 153, 0, 13)
                    TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.TextXAlignment = Enum.TextXAlignment.Center
                    TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                    TextLabel.TextSize = 11
                    TextLabel.ZIndex = 3
                    TextLabel.TextStrokeTransparency = 0
                    TextLabel.Parent = OuterFrame
                end

                if not settings or not settings.DisableLine then
                    local Divider: Frame = Instance.new('Frame')
                    Divider.Size = UDim2.new(1, 0, 0, 1)
                    Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Divider.Name = 'Divider'
                    Divider.ZIndex = 2
                    Divider.Position = UDim2.new(0, 0, 0.5, -0.5)
                    Divider.Parent = OuterFrame

                    local Gradient: UIGradient = Instance.new('UIGradient')
                    Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255))
                    Gradient.Transparency = NumberSequence.new(1, 0, 1)
                    Gradient.Rotation = 0
                    Gradient.Parent = Divider

                    local UICorner: UICorner = Instance.new('UICorner')
                    UICorner.CornerRadius = UDim.new(0, 2)
                    UICorner.Parent = Divider
                end

                return true
            end

            function ModuleManager:CreateSlider(settings: any)
                layoutOrder = layoutOrder + 1

                self._size = self._size + 27

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local Slider: TextButton = Instance.new('TextButton')
                Slider.Font = Enum.Font.SourceSans
                Slider.TextColor3 = Color3.fromRGB(0, 0, 0)
                Slider.Text = ''
                Slider.AutoButtonColor = false
                Slider.BackgroundTransparency = 1
                Slider.Name = 'Slider'
                Slider.Size = UDim2.new(0, 207, 0, 22)
                Slider.TextSize = 14
                Slider.LayoutOrder = layoutOrder
                Slider.Parent = Options

                local TextLabel: TextLabel = Instance.new('TextLabel')
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextLabel.TextTransparency = 0.2
                TextLabel.Text = settings.Title or ""
                TextLabel.Size = UDim2.new(0, 153, 0, 13)
                TextLabel.Position = UDim2.new(0, 0, 0.05, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.TextSize = 11
                TextLabel.Parent = Slider

                local Drag: Frame = Instance.new('Frame')
                Drag.AnchorPoint = Vector2.new(0.5, 1)
                Drag.BackgroundTransparency = 0.9
                Drag.Position = UDim2.new(0.5, 0, 0.95, 0)
                Drag.Name = 'Drag'
                Drag.Size = UDim2.new(0, 207, 0, 4)
                Drag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Drag.Parent = Slider

                local UICorner: UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(1, 0)
                UICorner.Parent = Drag

                local Fill: Frame = Instance.new('Frame')
                Fill.AnchorPoint = Vector2.new(0, 0.5)
                Fill.BackgroundTransparency = 0.5
                Fill.Position = UDim2.new(0, 0, 0.5, 0)
                Fill.Name = 'Fill'
                Fill.Size = UDim2.new(0, 103, 0, 4)
                Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Fill.Parent = Drag

                local UICorner: UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 3)
                UICorner.Parent = Fill

                local UIGradient: UIGradient = Instance.new('UIGradient')
                UIGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(79, 79, 79))
                UIGradient.Parent = Fill

                local Circle: Frame = Instance.new('Frame')
                Circle.AnchorPoint = Vector2.new(1, 0.5)
                Circle.Name = 'Circle'
                Circle.Position = UDim2.new(1, 0, 0.5, 0)
                Circle.Size = UDim2.new(0, 6, 0, 6)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Circle.Parent = Fill

                local UICorner: UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(1, 0)
                UICorner.Parent = Circle

                local ValueLabel: TextLabel = Instance.new('TextLabel')
                ValueLabel.Font = Enum.Font.GothamSemibold
                ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                ValueLabel.TextTransparency = 0.2
                ValueLabel.Text = '50'
                ValueLabel.Name = 'Value'
                ValueLabel.Size = UDim2.new(0, 42, 0, 13)
                ValueLabel.AnchorPoint = Vector2.new(1, 0)
                ValueLabel.Position = UDim2.new(1, 0, 0, 0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.TextSize = 10
                ValueLabel.Parent = Slider

                local SliderManager = {}

                function SliderManager:set_percentage(percentage: number)
                    local rounded: number = settings.Round and math.floor(percentage) or math.floor(percentage * 10) / 10
                    percentage = (rounded - settings.Min) / (settings.Max - settings.Min)

                    local sliderSize: number = math.clamp(percentage, 0.02, 1) * Drag.Size.X.Offset
                    local numberThreshold: number = math.clamp(rounded, settings.Min, settings.Max)

                    Library._config._flags[settings.Flag] = numberThreshold
                    ValueLabel.Text = tostring(numberThreshold)

                    TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2.fromOffset(sliderSize, Drag.Size.Y.Offset)
                    }):Play()

                    settings.Callback(numberThreshold)
                end

                function SliderManager:update()
                    local mousePos: number = (Mouse.X - Drag.AbsolutePosition.X) / Drag.Size.X.Offset
                    local percentage: number = settings.Min + (settings.Max - settings.Min) * mousePos

                    self:set_percentage(percentage)
                end

                function SliderManager:input()
                    self:update()

                    Connections['slider_drag_' .. settings.Flag] = Mouse.Move:Connect(function()
                        self:update()
                    end)

                    Connections['slider_input_' .. settings.Flag] = UserInputService.InputEnded:Connect(function(input: InputObject)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            Connections:disconnect('slider_drag_' .. settings.Flag)
                            Connections:disconnect('slider_input_' .. settings.Flag)
                            Config:save(tostring(game.GameId), Library._config)
                        end
                    end)
                end

                if Library:flag_type(settings.Flag, 'number') then
                    self:set_percentage(Library._config._flags[settings.Flag])
                else
                    self:set_percentage(settings.Default or settings.Min)
                end

                Slider.MouseButton1Down:Connect(function()
                    SliderManager:input()
                end)

                return SliderManager
            end

            function ModuleManager:CreateDropdown(settings: any)
                layoutOrder = layoutOrder + 1

                local DropdownManager = {
                    _state = false,
                    _size = 0
                }

                self._size = self._size + 44

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local Dropdown: TextButton = Instance.new('TextButton')
                Dropdown.Font = Enum.Font.SourceSans
                Dropdown.TextColor3 = Color3.fromRGB(0, 0, 0)
                Dropdown.Text = ''
                Dropdown.AutoButtonColor = false
                Dropdown.BackgroundTransparency = 1
                Dropdown.Name = 'Dropdown'
                Dropdown.Size = UDim2.new(0, 207, 0, 39)
                Dropdown.TextSize = 14
                Dropdown.LayoutOrder = layoutOrder
                Dropdown.Parent = Options

                local TextLabel: TextLabel = Instance.new('TextLabel')
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextLabel.TextTransparency = 0.2
                TextLabel.Text = settings.Title or ""
                TextLabel.Size = UDim2.new(0, 207, 0, 13)
                TextLabel.BackgroundTransparency = 1
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.TextSize = 11
                TextLabel.Parent = Dropdown

                local Box: Frame = Instance.new('Frame')
                Box.ClipsDescendants = true
                Box.AnchorPoint = Vector2.new(0.5, 0)
                Box.BackgroundTransparency = 0.9
                Box.Position = UDim2.new(0.5, 0, 1.2, 0)
                Box.Name = 'Box'
                Box.Size = UDim2.new(0, 207, 0, 22)
                Box.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
                Box.Parent = TextLabel

                local UICorner: UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Box

                local Header: Frame = Instance.new('Frame')
                Header.AnchorPoint = Vector2.new(0.5, 0)
                Header.BackgroundTransparency = 1
                Header.Position = UDim2.new(0.5, 0, 0, 0)
                Header.Name = 'Header'
                Header.Size = UDim2.new(0, 207, 0, 22)
                Header.Parent = Box

                local CurrentOption: TextLabel = Instance.new('TextLabel')
                CurrentOption.Font = Enum.Font.GothamSemibold
                CurrentOption.TextColor3 = Color3.fromRGB(255, 255, 255)
                CurrentOption.TextTransparency = 0.2
                CurrentOption.Name = 'CurrentOption'
                CurrentOption.Size = UDim2.new(0, 161, 0, 13)
                CurrentOption.AnchorPoint = Vector2.new(0, 0.5)
                CurrentOption.Position = UDim2.new(0.05, 0, 0.5, 0)
                CurrentOption.BackgroundTransparency = 1
                CurrentOption.TextXAlignment = Enum.TextXAlignment.Left
                CurrentOption.TextSize = 10
                CurrentOption.Parent = Header

                local UIGradient: UIGradient = Instance.new('UIGradient')
                UIGradient.Transparency = NumberSequence.new(0, 0, 0.3625, 1)
                UIGradient.Parent = CurrentOption

                local Arrow: ImageLabel = Instance.new('ImageLabel')
                Arrow.AnchorPoint = Vector2.new(0, 0.5)
                Arrow.Image = 'rbxassetid://84232453189324'
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(0.91, 0, 0.5, 0)
                Arrow.Name = 'Arrow'
                Arrow.Size = UDim2.new(0, 8, 0, 8)
                Arrow.Parent = Header

                local OptionsScroll: ScrollingFrame = Instance.new('ScrollingFrame')
                OptionsScroll.Active = true
                OptionsScroll.ScrollBarImageTransparency = 1
                OptionsScroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
                OptionsScroll.ScrollBarThickness = 0
                OptionsScroll.Name = 'Options'
                OptionsScroll.Size = UDim2.new(0, 207, 0, 0)
                OptionsScroll.BackgroundTransparency = 1
                OptionsScroll.Position = UDim2.new(0, 0, 1, 0)
                OptionsScroll.CanvasSize = UDim2.new(0, 0, 0.5, 0)
                OptionsScroll.Parent = Box

                local UIListLayout: UIListLayout = Instance.new('UIListLayout')
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Parent = OptionsScroll

                local UIPadding: UIPadding = Instance.new('UIPadding')
                UIPadding.PaddingTop = UDim.new(0, -1)
                UIPadding.PaddingLeft = UDim.new(0, 10)
                UIPadding.Parent = Box

                local UIListLayout: UIListLayout = Instance.new('UIListLayout')
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Parent = Box

                function DropdownManager:set_options(newOptions: {string})
                    for _, obj: Instance in OptionsScroll:GetChildren() do
                        if obj.Name == "Option" then
                            obj:Destroy()
                        end
                    end

                    for _, option in newOptions do
                        local btn: TextButton = Instance.new("TextButton")
                        btn.Name = "Option"
                        btn.Text = option
                        btn.Size = UDim2.new(1, 0, 0, 18)
                        btn.BackgroundTransparency = 1
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        btn.TextSize = 12
                        btn.Font = Enum.Font.SourceSans
                        btn.Parent = OptionsScroll

                        btn.MouseButton1Click:Connect(function()
                            self:update(option)
                        end)
                    end

                    settings.Options = newOptions

                    local current: string? = Library._config._flags[settings.Flag]

                    if current and table.find(newOptions, current) then
                        CurrentOption.Text = current
                    else
                        CurrentOption.Text = SelectedLanguage.DropdownSelect or "Select"
                        Library._config._flags[settings.Flag] = nil
                    end
                end

                function DropdownManager:update(option: string)
                    if settings.MultiDropdown then
                        local selected: {string} = Library._config._flags[settings.Flag] or {}

                        if table.find(selected, option) then
                            Library:remove_table_value(selected, option)
                        else
                            table.insert(selected, option)
                        end

                        Library._config._flags[settings.Flag] = selected
                        CurrentOption.Text = TableToString(selected)
                    else
                        Library._config._flags[settings.Flag] = option
                        CurrentOption.Text = option
                    end

                    Config:save(tostring(game.GameId), Library._config)
                    settings.Callback(option)
                end

                local currentDropSize: number = 0

                function DropdownManager:unfold_settings()
                    self._state = not self._state

                    if self._state then
                        ModuleManager._multiplier = ModuleManager._multiplier + self._size
                        currentDropSize = self._size

                        TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(241, 93 + ModuleManager._size + ModuleManager._multiplier)
                        }):Play()

                        TweenService:Create(Options, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
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
                        ModuleManager._multiplier = ModuleManager._multiplier - self._size
                        currentDropSize = 0
                        TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(241, 93 + ModuleManager._size + ModuleManager._multiplier)
                        }):Play()

                        TweenService:Create(Options, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
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

                    for _, v in settings.Options do
                        local Option: TextButton = Instance.new('TextButton')
                        Option.Font = Enum.Font.GothamSemibold
                        Option.Active = false
                        Option.TextTransparency = 0.6
                        Option.AnchorPoint = Vector2.new(0, 0.5)
                        Option.TextSize = 10
                        Option.Size = UDim2.new(0, 186, 0, 16)
                        Option.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Option.Text = v
                        Option.AutoButtonColor = false
                        Option.Name = 'Option'
                        Option.BackgroundTransparency = 1
                        Option.TextXAlignment = Enum.TextXAlignment.Left
                        Option.Selectable = false
                        Option.Position = UDim2.new(0.05, 0, 0.342, 0)
                        Option.Parent = OptionsScroll

                        local UIGradient: UIGradient = Instance.new('UIGradient')
                        UIGradient.Transparency = NumberSequence.new(0, 0, 0.3625, 1)
                        UIGradient.Parent = Option

                        Option.MouseButton1Click:Connect(function()
                            DropdownManager:update(v)
                        end)

                        DropdownManager._size = DropdownManager._size + 16
                    end
                end

                function DropdownManager:New(value: any)
                    Dropdown:Destroy()
                    value.OrderValue = Dropdown.LayoutOrder
                    ModuleManager._multiplier = ModuleManager._multiplier + currentDropSize

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
                layoutOrder = layoutOrder + 1

                self._size = self._size + 20

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local FeatureContainer: Frame = Instance.new("Frame")
                FeatureContainer.Size = UDim2.new(0, 207, 0, 16)
                FeatureContainer.BackgroundTransparency = 1
                FeatureContainer.LayoutOrder = layoutOrder
                FeatureContainer.Parent = Options

                local UIListLayout: UIListLayout = Instance.new("UIListLayout")
                UIListLayout.FillDirection = Enum.FillDirection.Horizontal
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Parent = FeatureContainer

                local FeatureButton: TextButton = Instance.new("TextButton")
                FeatureButton.Font = Enum.Font.GothamSemibold
                FeatureButton.TextSize = 11
                FeatureButton.Size = UDim2.new(1, -35, 0, 16)
                FeatureButton.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
                FeatureButton.TextColor3 = Color3.fromRGB(210, 210, 210)
                FeatureButton.Text = "    " .. (settings.Title or "Feature")
                FeatureButton.AutoButtonColor = false
                FeatureButton.TextXAlignment = Enum.TextXAlignment.Left
                FeatureButton.TextTransparency = 0.2
                FeatureButton.Parent = FeatureContainer

                local RightContainer: Frame = Instance.new("Frame")
                RightContainer.Size = UDim2.new(0, 45, 0, 16)
                RightContainer.BackgroundTransparency = 1
                RightContainer.Parent = FeatureContainer

                local RightLayout: UIListLayout = Instance.new("UIListLayout")
                RightLayout.Padding = UDim.new(0.1, 0)
                RightLayout.FillDirection = Enum.FillDirection.Horizontal
                RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
                RightLayout.Parent = RightContainer

                local KeybindBox: TextLabel = Instance.new("TextLabel")
                KeybindBox.Font = Enum.Font.GothamSemibold
                KeybindBox.Size = UDim2.new(0, 15, 0, 15)
                KeybindBox.BackgroundColor3 = Color3.fromRGB(181, 181, 181)
                KeybindBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                KeybindBox.TextSize = 11
                KeybindBox.BackgroundTransparency = 1
                KeybindBox.LayoutOrder = 2
                KeybindBox.Parent = RightContainer

                local KeybindButton: TextButton = Instance.new("TextButton")
                KeybindButton.Size = UDim2.new(1, 0, 1, 0)
                KeybindButton.BackgroundTransparency = 1
                KeybindButton.TextTransparency = 1
                KeybindButton.Parent = KeybindBox

                local CheckboxCorner: UICorner = Instance.new("UICorner")
                CheckboxCorner.CornerRadius = UDim.new(0, 3)
                CheckboxCorner.Parent = KeybindBox

                local UIStroke: UIStroke = Instance.new("UIStroke")
                UIStroke.Color = Color3.fromRGB(255, 255, 255)
                UIStroke.Thickness = 1
                UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke.Parent = KeybindBox

                if not Library._config._flags[settings.Flag] then
                    Library._config._flags[settings.Flag] = {
                        checked = false,
                        BIND = settings.Default or "Unknown"
                    }
                end

                local checked: boolean = Library._config._flags[settings.Flag].checked
                KeybindBox.Text = Library._config._flags[settings.Flag].BIND == "Unknown" and "..." or Library._config._flags[settings.Flag].BIND

                local toggled: () -> ()

                if not settings.DisableCheck then
                    local Checkbox: TextButton = Instance.new("TextButton")
                    Checkbox.Size = UDim2.new(0, 15, 0, 15)
                    Checkbox.BackgroundColor3 = checked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(182, 182, 182)
                    Checkbox.Text = ""
                    Checkbox.LayoutOrder = 1
                    Checkbox.Parent = RightContainer

                    local UIStroke: UIStroke = Instance.new("UIStroke")
                    UIStroke.Color = Color3.fromRGB(255, 255, 255)
                    UIStroke.Thickness = 1
                    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    UIStroke.Parent = Checkbox

                    local CheckboxCorner: UICorner = Instance.new("UICorner")
                    CheckboxCorner.CornerRadius = UDim.new(0, 3)
                    CheckboxCorner.Parent = Checkbox

                    toggled = function()
                        checked = not checked
                        Checkbox.BackgroundColor3 = checked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(182, 182, 182)
                        Library._config._flags[settings.Flag].checked = checked
                        Config:save(tostring(game.GameId), Library._config)
                        settings.Callback(checked)
                    end

                    Checkbox.MouseButton1Click:Connect(toggled)
                else
                    toggled = function()
                        settings.Button_Callback()
                    end
                end

                KeybindButton.MouseButton1Click:Connect(function()
                    KeybindBox.Text = "..."

                    local inputConn = UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
                        if processed then
                            return
                        end

                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            local newKey: string = input.KeyCode.Name
                            Library._config._flags[settings.Flag].BIND = newKey
                            KeybindBox.Text = newKey ~= "Unknown" and newKey or "..."
                            Config:save(tostring(game.GameId), Library._config)
                            inputConn:Disconnect()
                        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                            Library._config._flags[settings.Flag].BIND = "Unknown"
                            KeybindBox.Text = "..."
                            Config:save(tostring(game.GameId), Library._config)
                            inputConn:Disconnect()
                        end
                    end)
                    Connections["keybind_input_" .. settings.Flag] = inputConn
                end)

                Connections["keybind_press_" .. settings.Flag] = UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
                    if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
                        return
                    end
                    if input.KeyCode.Name == Library._config._flags[settings.Flag].BIND then
                        toggled()
                    end
                end)

                FeatureButton.MouseButton1Click:Connect(settings.Button_Callback or function() end)

                if not settings.DisableCheck then
                    settings.Callback(checked)
                end

                return FeatureContainer
            end

            return ModuleManager
        end

        return TabManager
    end

    Connections['library_visiblity'] = UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
        if processed or UserInputService:GetFocusedTextBox() or input.KeyCode ~= Enum.KeyCode.LeftControl then
            return
        end

        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    Minimize.MouseButton1Click:Connect(function()
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    return self
end

return Library