repeat task.wait() until game:IsLoaded()

if _G.HttpSpy then
    return warn('[HttpSpy]: Already Executed!')
end

_G.HttpSpy = true

--//Services
cloneref = cloneref or function(...) return ... end

local TweenService: TweenService = cloneref(game:GetService('TweenService'))
local HttpService: HttpService = cloneref(game:GetService('HttpService'))
local Players: Players = cloneref(game:GetService('Players'))

--// Variables
local LocalPlayer: LocalPlayer = Players.LocalPlayer
local LayoutOrder, state = 0, true

--// save_config
local config = {
	state = true
}

--[[
local path = 'Casa Das Primas/HttpSpy.json'

if not isfolder('Casa Das Primas') then
	makefolder('Casa Das Primas')
end

if isfile(path) then 
	config = HttpService:JSONDecode(readfile(path))
end

local function save()
	writefile(path, HttpService:JSONEncode(config))
end
]]
--// Instances:
local ScreenGui: ScreenGui = Instance.new('ScreenGui', LocalPlayer.PlayerGui)
ScreenGui.Name = 'HttpSpy'
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local Container: Frame = Instance.new('Frame', ScreenGui)
Container.Name = 'Container'
Container.BackgroundColor3 = Color3.fromRGB(52, 58, 64)
Container.ClipsDescendants = true
Container.Position = UDim2.fromScale(0.3, 0.12)
Container.Size = UDim2.fromOffset(0, 0)

TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
	Size = UDim2.fromOffset(530, 350)
}):Play()

local UICorner: UICorner = Instance.new('UICorner', Container)
UICorner.CornerRadius = UDim.new(0, 10)

local UIGradient: UIGradient = Instance.new('UIGradient', Container)
UIGradient.Offset = Vector2.new(0.2, 0)
UIGradient.Rotation = -45
UIGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 15)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(35, 35, 40)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(72, 72, 72)),
	ColorSequenceKeypoint.new(0.7, Color3.fromRGB(92, 92, 100)),
	ColorSequenceKeypoint.new(0.85, Color3.fromRGB(100, 100, 120)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}

UIGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0, 0.05),
    NumberSequenceKeypoint.new(0.5, 0.1),
    NumberSequenceKeypoint.new(1, 0.15)
}

local Handler: Frame = Instance.new('Frame', Container)
Handler.Name = 'Handler'
Handler.BackgroundTransparency = 1
Handler.Size = UDim2.fromOffset(530, 350)

local Title: TextLabel = Instance.new('TextLabel', Handler)
Title.Name = 'Title'
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromScale(0.019, 0.029)
Title.Size = UDim2.new(0.291, -52, 0.094, 0)
Title.Font = Enum.Font.SourceSansSemibold
Title.Text = 'HttpSpy'
Title.TextColor3 = Color3.fromRGB(200, 200, 200)
Title.TextScaled = true
Title.TextSize = 20
Title.TextWrapped = true

local Options: ScrollingFrame = Instance.new('ScrollingFrame', Handler)
Options.Name = 'Options'
Options.BackgroundTransparency = 1
Options.Position = UDim2.fromScale(0.017, 0.291)
Options.Size = UDim2.fromOffset(248, 225)
Options.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
Options.ScrollBarThickness = 5
Options.ScrollBarImageTransparency = 0.1
Options.ScrollingDirection = 'Y'

local UIListLayout: UIListLayout = Instance.new('UIListLayout', Options)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

local Search: TextBox = Instance.new('TextBox', Handler)
Search.Name = 'Search'
Search.BackgroundTransparency = 1
Search.Position = UDim2.fromScale(0.094, 0.18)
Search.Size = UDim2.fromOffset(207, 30)
Search.Font = Enum.Font.SourceSansSemibold
Search.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)
Search.PlaceholderText = 'Search'
Search.Text = ''
Search.TextColor3 = Color3.fromRGB(200, 200, 200)
Search.TextSize = 20
Search.TextWrapped = true
Search.TextXAlignment = Enum.TextXAlignment.Left

local Frame: Frame = Instance.new('Frame', Search)
Frame.BackgroundTransparency = 1
Frame.Position = UDim2.fromScale(-0.193, 0)
Frame.Size = UDim2.fromOffset(245, 30)

local UICorner_2: UICorner = Instance.new('UICorner', Frame)
UICorner_2.CornerRadius = UDim.new(0, 5)

local UIStroke: UIStroke = Instance.new('UIStroke', Frame)
UIStroke.Color = Color3.fromRGB(170, 170, 170)
UIStroke.ApplyStrokeMode = 'Border'
UIStroke.Thickness = 1
UIStroke.Transparency = 0.5

local Lupa: ImageLabel = Instance.new('ImageLabel', Frame)
Lupa.Name = 'Lupa'
Lupa.BackgroundTransparency = 1
Lupa.Position = UDim2.fromScale(0.041, 0.15)
Lupa.Size = UDim2.fromOffset(25, 21)
Lupa.Image = 'rbxassetid://10734943674'

local Dividers: Folder = Instance.new('Folder', Handler)
Dividers.Name = 'Dividers'

local Divider: Frame = Instance.new('Frame', Dividers)
Divider.Name = 'Divider'
Divider.BackgroundColor3 = Color3.fromRGB(92, 100, 121)
Divider.Position = UDim2.fromScale(0.5, 0.18)
Divider.Size = UDim2.fromOffset(1, 275)

local Divider_2: Frame = Instance.new('Frame', Dividers)
Divider_2.Name = 'Divider'
Divider_2.BackgroundColor3 = Color3.fromRGB(92, 100, 121)
Divider_2.Position = UDim2.fromScale(0, 0.15)
Divider_2.Size = UDim2.fromOffset(530, 1)

local Divider_3: Frame = Instance.new('Frame', Dividers)
Divider_3.Name = 'Divider'
Divider_3.BackgroundColor3 = Color3.fromRGB(92, 100, 121)
Divider_3.Position = UDim2.fromScale(0.52, 0.28)
Divider_3.Size = UDim2.fromOffset(239, 1)

local Divider_4: Frame = Instance.new('Frame', Dividers)
Divider_4.Name = 'Divider'
Divider_4.BackgroundColor3 = Color3.fromRGB(92, 100, 121)
Divider_4.Position = UDim2.fromScale(0.519, 0.47)
Divider_4.Size = UDim2.fromOffset(239, 1)

local Delete: ImageButton = Instance.new('ImageButton', Handler)
Delete.Name = 'Delete'
Delete.BackgroundTransparency = 1
Delete.Position = UDim2.fromScale(0.971, 0.031)
Delete.Size = UDim2.fromOffset(-30, 30)
Delete.Image = 'rbxassetid://10747384394'
Delete.ImageColor3 = Color3.fromRGB(200, 200, 200)

local Minimizer: ImageButton = Instance.new('ImageButton', Handler)
Minimizer.Name = 'Minimizer'
Minimizer.BackgroundTransparency = 1
Minimizer.Position = UDim2.fromScale(0.85, 0.034)
Minimizer.Size = UDim2.fromOffset(30, 30)
Minimizer.Image = 'rbxassetid://10734896206'
Minimizer.ImageColor3 = Color3.fromRGB(200, 200, 200)

local RecentUrl: TextLabel = Instance.new('TextLabel', Handler)
RecentUrl.Name = 'RecentUrl'
RecentUrl.BackgroundTransparency = 1
RecentUrl.Position = UDim2.fromScale(0.519, 0.3)
RecentUrl.Size = UDim2.fromOffset(72, 22)
RecentUrl.Font = Enum.Font.SourceSansSemibold
RecentUrl.Text = 'Url:'
RecentUrl.TextColor3 = Color3.fromRGB(200, 200, 200)
RecentUrl.TextScaled = true
RecentUrl.TextSize = 20
RecentUrl.TextWrapped = true
RecentUrl.TextXAlignment = Enum.TextXAlignment.Left

local TextLabel: TextLabel = Instance.new('TextLabel', RecentUrl)
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.fromScale(0.43, 0)
TextLabel.Size = UDim2.fromOffset(200, 22)
TextLabel.Font = Enum.Font.SourceSansSemibold
TextLabel.Text = 'https://roblox.com'
TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TextLabel.TextScaled = true
TextLabel.TextSize = 20
TextLabel.TextWrapped = true
TextLabel.TextXAlignment = Enum.TextXAlignment.Left

local Status: TextLabel = Instance.new('TextLabel', Handler)
Status.Name = 'Status'
Status.BackgroundTransparency = 1
Status.Position = UDim2.fromScale(0.519, 0.38)
Status.Size = UDim2.fromOffset(72, 22)
Status.Font = Enum.Font.SourceSansSemibold
Status.Text = 'Status:'
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextScaled = true
Status.TextSize = 20
Status.TextWrapped = true
Status.TextXAlignment = Enum.TextXAlignment.Left

local TextLabel_2: TextLabel = Instance.new('TextLabel', Status)
TextLabel_2.BackgroundTransparency = 1
TextLabel_2.Position = UDim2.fromScale(0.764, 0)
TextLabel_2.Size = UDim2.fromOffset(72, 25)
TextLabel_2.Font = Enum.Font.SourceSansSemibold
TextLabel_2.Text = config.state and 'On' or 'Off'
TextLabel_2.TextColor3 = config.state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
TextLabel_2.TextScaled = true
TextLabel_2.TextSize = 20
TextLabel_2.TextWrapped = true
TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left

local Stop: TextButton = Instance.new('TextButton', Handler)
Stop.Name = 'Stop'
Stop.BackgroundColor3 = Color3.fromRGB(95, 103, 125)
Stop.BackgroundTransparency = 0.5
Stop.Position = UDim2.fromScale(0.519, 0.173)
Stop.Size = UDim2.fromOffset(113, 30)
Stop.Font = Enum.Font.SourceSansSemibold
Stop.Text =  config.state and 'Stop' or 'Active'
Stop.TextColor3 = Color3.fromRGB(200, 200, 200)
Stop.TextScaled = true
Stop.TextSize = 20
Stop.TextWrapped = true

local UICorner_3: UICorner = Instance.new('UICorner', Stop)
UICorner_3.CornerRadius = UDim.new(0, 3)

local Clear: TextButton = Instance.new('TextButton', Handler)
Clear.Name = 'Clear'
Clear.BackgroundColor3 = Color3.fromRGB(95, 103, 125)
Clear.BackgroundTransparency = 0.5
Clear.Position = UDim2.fromScale(0.757, 0.173)
Clear.Size = UDim2.fromOffset(113, 30)
Clear.Font = Enum.Font.SourceSansSemibold
Clear.Text = 'Clear'
Clear.TextColor3 = Color3.fromRGB(200, 200, 200)
Clear.TextScaled = true
Clear.TextSize = 20
Clear.TextWrapped = true

local UICorner_4: UICorner = Instance.new('UICorner', Clear)
UICorner_4.CornerRadius = UDim.new(0, 5)

local Client: TextLabel = Instance.new('TextLabel', Handler)
Client.Name = 'Client'
Client.BackgroundTransparency = 1
Client.Position = UDim2.fromScale(0.519, 0.5)
Client.Size = UDim2.fromOffset(84, 29)
Client.Font = Enum.Font.SourceSansSemibold
Client.Text = 'Client'
Client.TextColor3 = Color3.fromRGB(200, 200, 200)
Client.TextScaled = true
Client.TextSize = 20
Client.TextWrapped = true
Client.TextXAlignment = Enum.TextXAlignment.Left

local _LocalPlayer: TextLabel = Instance.new('TextLabel', Client)
_LocalPlayer.Name = 'LocalPlayer'
_LocalPlayer.BackgroundTransparency = 1
_LocalPlayer.Position = UDim2.fromScale(0.06, 1)
_LocalPlayer.Size = UDim2.fromOffset(90, 23)
_LocalPlayer.Font = Enum.Font.SourceSansSemibold
_LocalPlayer.Text = 'LocalPlayer:'
_LocalPlayer.TextColor3 = Color3.fromRGB(200, 200, 200)
_LocalPlayer.TextScaled = true
_LocalPlayer.TextSize = 20
_LocalPlayer.TextWrapped = true
_LocalPlayer.TextXAlignment = Enum.TextXAlignment.Left

local TextLabel_3: TextLabel = Instance.new('TextLabel', _LocalPlayer)
TextLabel_3.BackgroundTransparency = 1
TextLabel_3.Position = UDim2.fromScale(1.02, 0.1)
TextLabel_3.Size = UDim2.fromOffset(146, 22)
TextLabel_3.Font = Enum.Font.SourceSansSemibold
TextLabel_3.Text = `{LocalPlayer.DisplayName} ({LocalPlayer.Name})`
TextLabel_3.TextColor3 = Color3.fromRGB(200, 200, 200)
TextLabel_3.TextScaled = true
TextLabel_3.TextSize = 20
TextLabel_3.TextWrapped = true
TextLabel_3.TextXAlignment = Enum.TextXAlignment.Left

local Uptime: TextLabel = Instance.new('TextLabel', Client)
Uptime.Name = 'Uptime'
Uptime.BackgroundTransparency = 1
Uptime.Position = UDim2.fromScale(0.06, 2.069)
Uptime.Size = UDim2.fromOffset(90, 23)
Uptime.Font = Enum.Font.SourceSansSemibold
Uptime.Text = 'Uptime:'
Uptime.TextColor3 = Color3.fromRGB(200, 200, 200)
Uptime.TextScaled = true
Uptime.TextSize = 20
Uptime.TextWrapped = true
Uptime.TextXAlignment = Enum.TextXAlignment.Left

local TextLabel_4: TextLabel = Instance.new('TextLabel', Uptime)
TextLabel_4.BackgroundTransparency = 1
TextLabel_4.Position = UDim2.fromScale(0.744, 0)
TextLabel_4.Size = UDim2.fromOffset(175, 23)
TextLabel_4.Font = Enum.Font.SourceSansSemibold
TextLabel_4.Text = '0'
TextLabel_4.TextColor3 = Color3.fromRGB(200, 200, 200)
TextLabel_4.TextScaled = true
TextLabel_4.TextSize = 20
TextLabel_4.TextWrapped = true
TextLabel_4.TextXAlignment = Enum.TextXAlignment.Left

--// Connections:
Stop.MouseButton1Click:Connect(function()
	config.state = not config.state
	Stop.Text =  config.state and 'Stop' or 'Active'
	TextLabel_2.Text = config.state and 'On' or 'Off'
	TextLabel_2.TextColor3 = config.state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
	--save()
end)

Clear.MouseButton1Click:Connect(function()
	for _, v in Options:GetChildren() do
		if v:IsA('TextButton') then
			v:Destroy()
		end
	end

	LayoutOrder = 0
end)

Minimizer.MouseButton1Click:Connect(function()
	TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(530, (state and 52 or 350))
	}):Play()

	Minimizer.Image = state and 'rbxassetid://10734965702' or 'rbxassetid://10734896206'

	state = not state
end)

Delete.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
	_G.HttpSpy = false
end)

do
	local time = tick()

	repeat task.wait(1)
		local ts = math.floor(tick() - time)
		local h = math.floor(ts / 3600)
		local m = math.floor((ts % 3600) / 60)
		local s = ts % 60
		local t

		if h > 0 then
			t = string.format("%d Hour(s), %d Minute(s), %d Second(s)", h, m, s)
		elseif m > 0 then
			t = string.format("%d Minute(s), %d Second(s)", m, s)
		else
			t = string.format("%d Second(s)", s)
		end

		TextLabel_4.Text = t
	until not _G.HttpSpy
end

--// Function:
local function AddText(method: string, url: string)
	local TextButton = Instance.new('TextButton', Options)
	local Method = Instance.new('TextLabel', TextButton)
	local UICorner = Instance.new('UICorner', TextButton)
	local URL = Instance.new('TextLabel', TextButton)

	LayoutOrder += 1

	TextButton.BackgroundTransparency = 0.92
	TextButton.Position = UDim2.new(0.00403225794, 0, 1.35633684e-07, 0)
	TextButton.Size = UDim2.new(0, 240, 0, 30)
	TextButton.Font = Enum.Font.SourceSansSemibold
	TextButton.Text = ''
	TextButton.TextColor3 = Color3.fromRGB(200, 200, 200)
	TextButton.TextSize = 20
	TextButton.TextWrapped = true
	TextButton.TextXAlignment = Enum.TextXAlignment.Right
	TextButton.LayoutOrder = LayoutOrder - 1

	Method.Name = 'Method'
	Method.BackgroundTransparency = 1
	Method.Position = UDim2.new(0, 0, 0, 5)
	Method.Size = UDim2.new(0, 45, 0, 20)
	Method.Font = Enum.Font.SourceSansSemibold
	Method.Text = `{method}:`
	Method.TextColor3 = Color3.fromRGB(200, 200, 200)
	Method.TextScaled = true
	Method.TextSize = 20
	Method.TextWrapped = true
	Method.TextXAlignment = Enum.TextXAlignment.Right

	UICorner.CornerRadius = UDim.new(0, 4)

	URL.Name = 'URL'
	URL.BackgroundTransparency = 1
	URL.Position = UDim2.new(0.216666669, 0, 0.166666672, 0)
	URL.Size = UDim2.new(0, 194, 0, 20)
	URL.Font = Enum.Font.SourceSansSemibold
	URL.Text = url
	URL.TextColor3 = Color3.fromRGB(200, 200, 200)
	URL.TextSize = 20
	URL.TextXAlignment = Enum.TextXAlignment.Left

	TextLabel.Text = url

	TextButton.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(URL.Text)
		else
			--LocalPlayer:Kick('Trash Executor')
			print('Clidado', TextButton, URL.Text)
		end
	end)
end

--// Logger
AddText('GET', 'https://google.com')

--[[
do
	local mt = getrawmetatable(game)
	local old = mt.__namecall
	setreadonly(mt, false)

	mt.__namecall = newcclosure(function(self, ...)
		local _call = {...}

		if getgenv().HttpSpy then
			if getnamecallmethod() == "HttpGet" then
				AddText('GET', tostring(_call[1]))
			elseif getnamecallmethod() == "HttpPost" then
				AddText('POST', tostring(_call[1]))
			end
		end

		return old(self, ...)
	end)

	setreadonly(mt, true)
end
]]