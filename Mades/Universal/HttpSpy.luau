-- Gui to Lua

-- Instances:
local HttpSpy = Instance.new("ScreenGui")
local Background = Instance.new("Frame")
local Topbar = Instance.new("Frame")
local Icon = Instance.new("ImageLabel")
local Exit = Instance.new("TextButton")
local ImageLabel = Instance.new("ImageLabel")
local Minimize = Instance.new("TextButton")
local ImageLabel_2 = Instance.new("ImageLabel")
local TopBar = Instance.new("Frame")
local ImageLabel_3 = Instance.new("ImageLabel")
local ImageLabel_4 = Instance.new("ImageLabel")
local Title = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")
local MainContainer = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local UICorner_2 = Instance.new("UICorner")
local TemplateText = Instance.new("TextButton")

--Properties:

HttpSpy.Name = "HttpSpy"
HttpSpy.Parent = game.CoreGui
HttpSpy.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
HttpSpy.ResetOnSpawn = false

Background.Name = "Background"
Background.Parent = HttpSpy
Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Background.BackgroundTransparency = 0.140
Background.BorderColor3 = Color3.fromRGB(139, 139, 139)
Background.BorderSizePixel = 0
Background.Position = UDim2.new(0.506695807, 0, 0.56610918, 0)
Background.Size = UDim2.new(0, 402, 0, 262)
Background.Active = true
Background.Draggable = true

Topbar.Name = "Topbar"
Topbar.Parent = Background
Topbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Topbar.BackgroundTransparency = 1.000
Topbar.Size = UDim2.new(1, 0, 0, 25)

Icon.Name = "Icon"
Icon.Parent = Topbar
Icon.AnchorPoint = Vector2.new(0, 0.5)
Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Icon.BackgroundTransparency = 1.000
Icon.Position = UDim2.new(0, 10, 0.5, 0)
Icon.Size = UDim2.new(0, 13, 0, 13)
Icon.Image = "rbxgameasset://Images/menuIcon"

Exit.Name = "Exit"
Exit.Parent = Topbar
Exit.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Exit.BackgroundTransparency = 0.180
Exit.BorderSizePixel = 0
Exit.Position = UDim2.new(0.870000005, 0, 0, 0)
Exit.Size = UDim2.new(-0.00899999961, 40, 1.04299998, -10)
Exit.Font = Enum.Font.Gotham
Exit.Text = "X"
Exit.TextColor3 = Color3.fromRGB(255, 255, 255)
Exit.TextSize = 13.000
Exit.MouseButton1Click:Connect(function()
HttpSpy:Destroy()
end)

ImageLabel.Parent = Exit
ImageLabel.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.Position = UDim2.new(0.999998331, 0, 0, 0)
ImageLabel.Size = UDim2.new(0, 9, 0, 16)
ImageLabel.Image = "http://www.roblox.com/asset/?id=8650484523"
ImageLabel.ImageColor3 = Color3.fromRGB(12, 4, 20)
ImageLabel.ImageTransparency = 0.180

Minimize.Name = "Minimize"
Minimize.Parent = Topbar
Minimize.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Minimize.BackgroundTransparency = 0.180
Minimize.BorderSizePixel = 0
Minimize.Position = UDim2.new(0.804174006, 0, 0, 0)
Minimize.Size = UDim2.new(0.00100000005, 27, 1.04299998, -10)
Minimize.Font = Enum.Font.Gotham
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextSize = 18.000

ImageLabel_2.Parent = Minimize
ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel_2.BackgroundTransparency = 1.000
ImageLabel_2.Position = UDim2.new(-0.455000013, 1, 0, 0)
ImageLabel_2.Size = UDim2.new(0, 12, 0, 16)
ImageLabel_2.Image = "http://www.roblox.com/asset/?id=10555881849"
ImageLabel_2.ImageColor3 = Color3.fromRGB(12, 4, 20)
ImageLabel_2.ImageTransparency = 0.180

TopBar.Name = "TopBar"
TopBar.Parent = Topbar
TopBar.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
TopBar.BackgroundTransparency = 0.180
TopBar.BorderSizePixel = 0
TopBar.Position = UDim2.new(0.268202901, 0, -0.00052294743, 0)
TopBar.Size = UDim2.new(0, 186, 0, 16)

ImageLabel_3.Parent = TopBar
ImageLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel_3.BackgroundTransparency = 1.000
ImageLabel_3.Position = UDim2.new(0.999999642, 0, -0.00046946716, 0)
ImageLabel_3.Size = UDim2.new(0, 14, 0, 16)
ImageLabel_3.Image = "http://www.roblox.com/asset/?id=8650484523"
ImageLabel_3.ImageColor3 = Color3.fromRGB(12, 4, 20)
ImageLabel_3.ImageTransparency = 0.180

ImageLabel_4.Parent = TopBar
ImageLabel_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel_4.BackgroundTransparency = 1.000
ImageLabel_4.Position = UDim2.new(-0.0817726701, 0, 0, 0)
ImageLabel_4.Size = UDim2.new(0, 16, 0, 16)
ImageLabel_4.Image = "http://www.roblox.com/asset/?id=10555881849"
ImageLabel_4.ImageColor3 = Color3.fromRGB(12, 4, 20)
ImageLabel_4.ImageTransparency = 0.180

Title.Name = "Title"
Title.Parent = TopBar
Title.AnchorPoint = Vector2.new(0, 0.5)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.BorderSizePixel = 0
Title.Position = UDim2.new(-0.150533721, 32, 0.415876389, 0)
Title.Size = UDim2.new(0.522161067, 80, 1.11675644, -7)
Title.Font = Enum.Font.SourceSansLight
Title.Text = "Http Spy"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 17.000
Title.TextWrapped = true

UICorner.CornerRadius = UDim.new(0, 9)
UICorner.Parent = Background

MainContainer.Name = "MainContainer"
MainContainer.Parent = Background
MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
MainContainer.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
MainContainer.BackgroundTransparency = 0.180
MainContainer.BorderColor3 = Color3.fromRGB(16, 16, 16)
MainContainer.BorderSizePixel = 0
MainContainer.Position = UDim2.new(0.5, 0, 0.540076315, 0)
MainContainer.Size = UDim2.new(1, -10, 0.91984731, -10)
MainContainer.BottomImage = "rbxgameasset://Images/scrollBottom (1)"
MainContainer.MidImage = "rbxgameasset://Images/scrollMid"
MainContainer.ScrollBarThickness = 4
MainContainer.TopImage = "rbxgameasset://Images/scrollTop"
MainContainer.AutomaticCanvasSize = "XY"

UIListLayout.Parent = MainContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 3)

UICorner_2.Parent = MainContainer


local script = Instance.new('LocalScript', MainContainer)

TemplateText.Name = "TemplateText"
TemplateText.Parent = HttpSpy.Background.MainContainer.LocalScript
TemplateText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TemplateText.BackgroundTransparency = 0.7
TemplateText.BorderSizePixel = 0
TemplateText.Position = UDim2.new(3.75832236e-08, 0, 0, 0)
TemplateText.Size = UDim2.new(1.00000012, 0, 0, 20)
TemplateText.Font = Enum.Font.SourceSansSemibold
TemplateText.Text = "ur mom"
TemplateText.TextColor3 = Color3.fromRGB(255, 255, 255)
TemplateText.TextScaled = true
TemplateText.TextSize = 14.000
TemplateText.TextWrapped = true
TemplateText.TextXAlignment = Enum.TextXAlignment.Center
TemplateText.TextYAlignment = Enum.TextYAlignment.Center

--// Função: Scroll automático para frames com UIListLayout
local function registerDynamicScrollingFrame(frame)
	local layout = frame:FindFirstChildWhichIsA("UIListLayout")
	if not layout then return end

	local function updateCanvasSize()
		frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end

	updateCanvasSize()
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
end

local Template = TemplateText

--// Função: Log de requisições com headers
local function logRequest(text, headers)
	local label = Template:Clone()

	if typeof(headers) == "table" then
		local lines = {}
		for k, v in next, headers do
			table.insert(lines, tostring(k) .. ": " .. tostring(v))
		end
		text = text .. " (HEADERS: " .. table.concat(lines, ", ") .. ")"
	end

	label.Text = text
	label.Parent = script.Parent

	pcall(function()
		label.MouseButton1Click:Connect(function()
			setclipboard(text)
		end)
	end)
end

--// Inicializa frame dinâmico
registerDynamicScrollingFrame(MainContainer)

--// Hook de métodos HttpGet e HttpPost via metamétodo
do
	local mt = getrawmetatable(game)
	local old = mt.__namecall
	setreadonly(mt, false)

	mt.__namecall = newcclosure(function(self, ...)
		local method = getnamecallmethod()
		local args = { ... }

		if method == "HttpGet" then
			logRequest("Interceptado HttpGet para: " .. tostring(args[1]))
		elseif method == "HttpPost" then
			logRequest("Interceptado HttpPost para: " .. tostring(args[1]))
		end

		return old(self, ...)
	end)

	setreadonly(mt, true)
end

--// Hook de request (compatível com KRNL, Fluxus, Delta etc.)
do
	local requestFunc = request or (http and http.request)
	if requestFunc then
		local oldRequest = requestFunc

		local hooked = hookfunction(oldRequest, function(data)
			local url = tostring(data.Url or "N/A")
			local method = tostring(data.Method or "GET")
			logRequest("Request para: " .. url .. " (" .. method .. ")", data.Headers)
			return oldRequest(data)
		end)

		-- opcional: sobrescrever globalmente se permitido
		if request then
			getgenv().request = hooked
		elseif http and http.request then
			http.request = hooked
		end
	else
		warn("Nenhuma função de request compatível encontrada.")
	end
end