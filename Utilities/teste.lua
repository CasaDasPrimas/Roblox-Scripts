if _G.FTF then warn("Ocalism: Already Executed") return end
_G.FTF = true
local cg = game:GetService("CoreGui")
local gui = game:GetService("GuiService")
local http = game:GetService("HttpService")
local ip = game:GetService("UserInputService")
local Light = game:GetService("Lighting")
local mk = game:GetService("MarketplaceService")
local pl = game:GetService("Players")
local lp = pl.LocalPlayer
local rs = game:GetService("RunService")
local re = game:GetService("ReplicatedStorage")
local sg = game:GetService("StarterGui")
local vim = game:GetService("VirtualInputManager")
local vr = game:GetService("VirtualUser")
local w = game:GetService("Workspace")
local chatservice = game:GetService("TextChatService")

--script-variables
--local PlayerStats = lp:FindFirstChild("TempPlayerStatsModule")
--local PlayerSave = lp:FindFirstChild("SavedPlayerStatsModule")
--local gameActive = re:WaitForChild("IsGameActive")
--local remote = re:WaitForChild("RemoteEvent")
local character = lp.Character or lp.CharacterAdded:Wait()
local hum = character:FindFirstChild("Humanoid")
local ScriptWhitelist = {}
local power_fling
local fonte = Enum.Font.Fantasy
local folder

if not cg:FindFirstChild("Ocalism") then
    folder = Instance.new("Folder")
    folder.Name = "Ocalism"
    folder.Parent = cg
end
--//tables\\

local connections = {}

_G.config = {
    anti_afk = nil,
    anti_chatspy = nil,
    anti_error = nil,
    anti_fling = nil,
    backpack = nil,
    bang = nil,
    dog = nil, -- future
    drag = nil, -- future
    eggChams = nil,
    fling = nil,
    focus = nil,
    fullbright = nil,
    Fps = nil,
    headsit = nil,
    jump = nil,
    list = nil,
    pc = nil,
    players = nil,
    pod = nil,
    saida = nil,
    speed = nil,
    touch_fling = nil,
    thirdp = nil,
    tag = nil,
    view = nil,
    void = nil
}

--//baixo\\--
local CheckMobile = function()
    if ip.TouchEnabled then
    return true
    end
end

IsMobile = CheckMobile()

local largura, altura

if not IsMobile then
    largura, altura = 600, 460
else
    local screengui = Instance.new("ScreenGui")
    local button = Instance.new("ImageButton")
    local UICorner = Instance.new("UICorner")

    screengui.Name = "ImageButton"
    screengui.Parent = cg
    screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    button.Parent = screengui
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0.120833337, 0, 0.0952890813, 0)
    button.Size = UDim2.new(0, 50, 0, 50)
    button.Draggable = true
    button.Image = "rbxassetid://18540832673"
    button.MouseButton1Click:connect(
        function()
            vim:SendKeyEvent(true, "Insert", false, game)
            vim:SendKeyEvent(false, "Insert", false, game)
        end
    )
    UICorner.Parent = button
end




local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/DevBeto-Cyber/Workspace/refs/heads/main/Library.txt", true))()

local Window =
    Fluent:CreateWindow(
    {
        Title = "Ocalism - by Beto      ",
        SubTitle = "Área de Testes",
        TabWidth = 180,
        Size = UDim2.fromOffset(530, 350),
        Acrylic = false,
        Theme = "Darker",
        MinimizeKey = Enum.KeyCode.Insert
    }
)



local Main_tab = {
    Home = Window:AddTab(
        {
            Title = "Home",
            Icon = "home"
        }
    )
}


local event = Main_tab.Home:AddSection("")

--local event = Tabs.Events:AddSection("Easter Event")
local eggs = {
    Facility_0 = false,
    Homestead = false,
    Airport = false,
    Optimus = false,
    Arcade = false,
    Nuclear = false,
    Mansion = false,
    School = false,
    Zoo = false,
    Sewer = false,
    Golden = true,
    Feberge = true,
    Diamond = true
}


event:AddToggle("",
    {
        Title = "Egg Chams",
        Default = _G.config.eggChams or false,
        Callback = function(value)
        _G.config.eggChams = value

            task.spawn(function()
                while _G.config.eggChams do
                    for _, FindEgg in ipairs(w:GetChildren()) do
                        if FindEgg:IsA("Model") and eggs[FindEgg.Name] ~= nil then
                            if not FindEgg:FindFirstChild("EggH") then
                                local h = Instance.new("Highlight")
                                h.Name = "EggH"
                                h.Parent = FindEgg
                                h.Adornee = FindEgg
                                h.FillTransparency = 0.37
                                h.OutlineColor = Color3.new(1, 1, 1)
                                h.OutlineTransparency = 0.77
                                if eggs[FindEgg.Name] == true then
                                    h.FillColor = Color3.new(0, 0, 1)
                                else
                                    h.FillColor = Color3.new(1, 1, 0)
                                end
                            end
                        end
                    end
                    if not _G.FTF then
                        break
                    end
                    task.wait()
                end
                    for _, v in ipairs(w:GetChildren()) do
                        if v:IsA("Model") then
                            local highlight = v:FindFirstChild("EggH")
                            if highlight then
                                highlight:Destroy()
                            end
                        end
                    end
                end
            )
        end
    }
)



event:AddToggle("tag",
    {
        Title = "Egg Name",
        Default = _G.config.tag or false,
        Callback = function(value)
        _G.config.tag = value
    
        task.spawn(function()
        while _G.config.tag do
            for _, eggFind in ipairs(w:GetChildren()) do
                if eggFind:IsA("Model") and eggs[eggFind.Name] ~= nil then
                    local model = eggFind
                    for _, findClick in ipairs(model:GetDescendants()) do
                        if findClick:IsA("ClickDetector") and not findClick.Parent:FindFirstChild("EggTagName") then
                            local billGui = Instance.new("BillboardGui")
                            local textLabel = Instance.new("TextLabel", billGui)
                            
                            billGui.Adornee = findClick.Parent
                            billGui.Size = UDim2.new(0, 80, 0, 15)
                            billGui.StudsOffset = Vector3.new(0, 1, 0)
                            billGui.AlwaysOnTop = true
                            billGui.Parent = findClick.Parent
                            billGui.Name = "EggTagName"
                            
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.Text = model.Name .. "Egg"
                            textLabel.TextScaled = true
                            textLabel.Parent = billGui
                            textLabel.TextStrokeTransparency = 0
                            if eggs[model.Name] == true then
                                textLabel.TextColor3 = Color3.new(0,0,1)
                            else
                                textLabel.TextColor3 = Color3.new(1,1,0)
                            end
                        end
                    end
                end
            end
            if not _G.config.tag or not _G.FTF then
                break
            end
            task.wait()
        end
            for _, search in ipairs(w:GetDescendants()) do
                if search.Name == "EggTagName" then
                    search:Destroy()
                end
            end
        end)
    end
    }
)

event:AddToggle("pick",
    {
        Title = "Auto Pick Egg",
        Default = _G.config.pick or false,
        Callback = function(value)
        _G.config.pick = value
    
        task.spawn(function()
            while _G.config.pick do
                for _, search in ipairs(w:GetChildren()) do
                    if search:IsA("Model") and eggs[search.Name] ~= nil then
                        local model = search
                        for _, getClick in ipairs(model:GetDescendants()) do
                            if getClick:IsA("ClickDetector") then
                                getClick.MaxActivationDistance = "inf"
                                fireclickdetector(getClick)
                            end
                        end
                    end
                end
                if not _G.config.pick or not _G.FTF then
                    break
                end
                task.wait()
            end
        end)
    end
    }
)

setfpscap(9e9)
event:AddToggle("",
    {
        Title = "Fps Counter",
        Default = _G.config.Fps or false,
        Callback = function(value)
        _G.config.Fps = value
        
        task.spawn(function()
            if _G.config.Fps then
                if folder:FindFirstChild("fpCounter") then return end
                local gui = Instance.new("ScreenGui",folder)
                local fps = Instance.new("TextLabel",gui)
                
                gui.Name = "fpCounter"
                
                fps.Name = "fps"
                fps.BackgroundTransparency = 1
                fps.Position = UDim2.new(.5,164,.5,-232)
                fps.Size = UDim2.new(0,50,0,20)
                fps.TextColor3 = Color3.new(1,1,1)
                fps.TextSize = 10
                fps.TextStrokeTransparency = 0
                fps.TextScaled = true
                fps.Font = fonte
                fps.Text = "Calculation..."
                while task.wait(1) do
                    fps.Text = "Fps: " .. math.floor(1 / rs.RenderStepped:Wait())
                    if not _G.config.Fps or not _G.FTF then
                        break
                    end
                end
            else
                if folder:FindFirstChild("fpCounter") then
                    folder.fpCounter:Destroy()
                end
            end
        end
        )
    end
    }
)

event:AddToggle("ping",
    {
        Title = "Ping Counter",
        Default = _G.config.ping or false,
        Callback = function(value)
        _G.config.ping = value
            
        task.spawn(function()
            if _G.config.ping then
                if folder:FindFirstChild("pgCounter") then return end
                local gui = Instance.new("ScreenGui",folder)
                local ping = Instance.new("TextLabel",gui)
                
                gui.Name = "pgCounter"
                
                ping.Name = "ping"
                ping.BackgroundTransparency = 1
                ping.Position = UDim2.new(.5, 220, .5, -232)
                ping.Size = UDim2.new(0,50,0,30)
                ping.TextColor3 = Color3.new(1,1,1)
                ping.TextSize = 20
                ping.TextStrokeTransparency = 0
                ping.TextScaled = true
                ping.Font = fonte
                ping.Text = "Calculation..."
                while task.wait(1.5) do
                    local data = game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()
                    ping.Text = string.format("Ping: %.2f",data)
                    if not _G.config.ping or not _G.FTF then
                        break
                    end
                end
            else
                if folder:FindFirstChild("pgCounter") then
                    folder.pgCounter:Destroy()
                end
            end
        end)
    end
    }
)





--ativou fica em loop verificando se existe o pc e não tem o highlight
--cria o highlight e o getpropertychangedsignal
--fazer uma lógica pra quando o pc sumir desconectar o get
--else pra parar o loop e destruir o highlight
--loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/refs/heads/main/loader.lua'))()