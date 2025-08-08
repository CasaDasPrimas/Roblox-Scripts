if not game:IsLoaded() then
  game.Loaded:wait()
end

if _G.FTF then warn("Ocalism: Already Executed") return end
_G.FTF = true

local MapId = {
  [893973440] = "Normal Map",
  [1738581510] = "Trading Post",
  [132745842491660] = "Pro Server",
  [17539432357] = "Area de Teste"
}
  
if not MapId[game.PlaceId] then
  local localplr = game.Players.LocalPlayer
  localplr:Kick("you're dumb? \n This is not the Flee The Facility map nigga")
  return
end

-- game-variables
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
local PlayerStats = lp:FindFirstChild("TempPlayerStatsModule")
local PlayerSave = lp:FindFirstChild("SavedPlayerStatsModule")
local gameActive = re:WaitForChild("IsGameActive")
local remote = re:WaitForChild("RemoteEvent")
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

-- contramedidas 
task.spawn(function()
  local vip = w:FindFirstChild("VipBoard")
  for _, part in ipairs(vip:GetDescendants()) do
    if part:IsA("ClickDetector") then
      part:Destroy()
    end
  end
end)

-- functions
local function GetRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso')
	return rootPart
end

local function getTorso(x)
  x = x or character
	return x:FindFirstChild("Torso") or x:FindFirstChild("HumanoidRootPart")
end

local function r15(plr)
	if plr.Character:FindFirstChildOfClass('Humanoid').RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

local function RandomChar()
    local length = math.random(1, 5)
    local array = {}
    for i = 1, length do
      array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
end

_G.config = {
  anti_afk = nil,
  anti_chatspy = nil,
  anti_error = nil,
  anti_fling = nil,
  backpack = nil,
  bang = nil,
  dog = nil, -- future
  drag = nil, -- future
  fling = nil,
  focus = nil,
  fullbright = nil,
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
  view = nil,
  void = nil,
}

if not isfolder("Ocalism/Config") then
  makefolder("Ocalism/Config")
end

local function save()
local save_name = "Ocalism/Config/config.json"
local data = http:JSONEncode(_G.config)
  writefile(save_name, data)
end

local function load_config()
local save_name = "Ocalism/Config/config.json"
  if isfile(save_name) then
    local data = readfile(save_name)
    _G.config = http:JSONDecode(data)
  end
end


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

load_config()

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/DevBeto-Cyber/Workspace/refs/heads/main/Library.txt", true))()

local Window = Fluent:CreateWindow(
  {
    Title = "Ocalism - by Beto       ",
    SubTitle = mk:GetProductInfo(893973440).Name,
    TabWidth = 180,
    Size = UDim2.fromOffset(530, 350),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.Insert
  }
)

local Tabs = {
  Status = Window:AddTab(
    {
      Title = "Game Status",
      Icon = "database"
    }
  ),
  Main = Window:AddTab(
    {
      Title = "Main",
      Icon = "book"
    }
  ),
  Esp = Window:AddTab(
    {
      Title = "Esp",
      Icon = "eye"
    }
  ),
  Players = Window:AddTab(
    {
      Title = "Players",
      Icon = "users"
    }
  ),
  Settings = Window:AddTab(
      {
        Title = "Settings",
        Icon = "settings"
      }
    ),
}

local stats = Tabs.Status:AddSection("Hello!" .. lp.DisplayName)
local tempo = "Calculando..."

  local paragraph = stats:AddParagraph(
  {
    Title = "Run time: " .. tempo,
    Content = ""
  }
)

task.spawn(function()
    repeat
      local totalS = math.floor(w.DistributedGameTime)
      local h = math.floor(totalS / 3600)
      local m = math.floor((totalS % 3600) / 60)
      local s = totalS % 60

      if h > 0 then
        tempo = string.format("%d Hour(s), %d Minute(s), %d Second(s)", h, m, s)
      elseif m > 0 then
        tempo = string.format("%d Minute(s), %d Second(s)", m, s)
      else
        tempo = string.format("%d Second(s)", s)
      end
        paragraph:SetTitle("Run time: " .. tempo)
      task.wait(1)
    until not _G.FTF
end)

  local beastchances = ""
  local Detector = stats:AddParagraph(
    {
      Title = "Calculando...",
      Content = ""
    }
  )

local lpValue = 0
local lastState = gameActive.Value

local beastLoop = gameActive:GetPropertyChangedSignal("Value"):Connect(function()
  if lastState == true and gameActive.Value == false then
    --lpValue += 1
  end
  lastState = gameActive.Value
end)

task.spawn(function()
  repeat
    local highpoint = 0
    local beast
    for _, plrs in pairs(pl:GetPlayers()) do
      if plrs:FindFirstChild("SavedPlayerStatsModule") then
        local saved = plrs:FindFirstChild("SavedPlayerStatsModule"):WaitForChild("BeastChance").Value
        if plrs == lp and saved == 0 then
          lpValue = 0
        end
        if saved > highpoint then
          highpoint = saved
          beast = plrs
        elseif saved == highpoint then
          if plrs == lp and lpValue >= 4 then
            beast = lp
          end
        end
      end
    end
    
    if beast then
      if beast == lp then
        beastchances = "Is You"
      elseif beast ~= lp then
        beastchances = beast.Name
      end
    else
      beastchance = "Unknown"
    end
    
    Detector:SetTitle("The Next Beast is: " .. beastchances)
    task.wait(1.5)
  until not _G.FTF
end)


local Main = Tabs.Main:AddSection("")
local Active

Main:AddButton(
  {
    Title = "Shiftlock",
    Description = "",
    Callback = function()
      
    task.spawn(function()
      if folder:FindFirstChild("Shiftlock (CoreGui)") then return end
      if not MapId[game.PlaceId] then return
        else
        local ScreenGui = Instance.new("ScreenGui")
        local Button = Instance.new("ImageButton")
        local Cursor = Instance.new("ImageLabel")
        local States = {
          Off = "rbxasset://textures/ui/mouseLock_off@2x.png",
          On = "rbxasset://textures/ui/mouseLock_on@2x.png",
          Lock = "rbxasset://textures/MouseLockedCursor.png",
          Lock2 = "rbxasset://SystemCursors/Cross"
        }
        
        local MaxLength = 900000
        local EnabledOffset = CFrame.new(1.7, 0, 0)
        local DisabledOffset = CFrame.new(-1.7, 0, 0)

        ScreenGui.Name = "Shiftlock (CoreGui)"
        ScreenGui.Parent = folder
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.ResetOnSpawn = false
        
        Button.Parent = ScreenGui
        Button.BackgroundTransparency = 1
        Button.Position = UDim2.new(0.8, 0, 0.35, 0)
        Button.Size = UDim2.new(0.0636147112, 0, 0.0661305636, 0)
        Button.SizeConstraint = Enum.SizeConstraint.RelativeXX
        Button.Image = States.Off

        Cursor.Name = "Cursor"
        Cursor.Parent = ScreenGui
        Cursor.Image = States.Lock
        Cursor.Size = UDim2.new(0.03, 0, 0.03, 0)
        Cursor.Position = UDim2.new(0.5, 0, 0.5, 0)
        Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
        Cursor.SizeConstraint = Enum.SizeConstraint.RelativeXX
        Cursor.BackgroundTransparency = 1
        Cursor.Visible = false
  
Button.MouseButton1Click:Connect(function()
  if not Active then
    Active = rs.RenderStepped:Connect(function()
        Button.Image = States.On
        if character and character:FindFirstChild("Humanoid") and w.CurrentCamera and not PlayerStats.Ragdoll.Value and not PlayerStats.Captured.Value then
            hum.AutoRotate = false
            Cursor.Visible = true
        
            GetRoot(character).CFrame = CFrame.new(GetRoot(character).Position,Vector3.new(w.CurrentCamera.CFrame.LookVector.X * MaxLength,GetRoot(character).Position.Y,w.CurrentCamera.CFrame.LookVector.Z * MaxLength))
        
            w.CurrentCamera.CFrame = w.CurrentCamera.CFrame * EnabledOffset 
        
            w.CurrentCamera.Focus = CFrame.fromMatrix(w.CurrentCamera.Focus.Position,w.CurrentCamera.CFrame.RightVector,w.CurrentCamera.CFrame.UpVector) * EnabledOffset
            end
        end)
    else
        if character and character:FindFirstChild("Humanoid") then
            hum.AutoRotate = true
        end
        Button.Image = States.Off
        if w.CurrentCamera then
            w.CurrentCamera.CFrame = w.CurrentCamera.CFrame * DisabledOffset
        end
        Cursor.Visible = false
        pcall(
            function()
                Active:Disconnect()
                Active = nil
            end)
          end
        end)
      end
    end)
end
  }
)

Main:AddToggle("Erro", 
  {
    Title = "Anti Error",
    Default = _G.config.anti_error or false,
    Callback = function(value)
    _G.config.anti_error = value
    save()

    while _G.config.anti_error do
        local currentAnim = PlayerStats:WaitForChild("CurrentAnimation")
        if currentAnim.Value == "Typing" then
          remote:FireServer("SetPlayerMinigameResult", true)
        end
        if _G.config.anti_error and not _G.FTF then
          break
        end
        task.wait()
    end
  end
  }
)

Main:AddToggle("touch_fling", 
  {
    Title = "Touch Fling",
    Default = _G.config.touch_fling or false,
    Callback = function(value)
    G.config.touch_fling = value
    save()

    spawn(function()
      if _G.config.touch_fling then
        task.spawn(function()
          local rv
          while _G.config.touch_fling do
            task.wait()
            pcall(function()
              local root = GetRoot(lp.Character)
              if root then
                rv = root.Velocity
                root.Velocity = Vector3.new(math.random(-150, 150), -25000, math.random(-150, 150))
              end
            end)
            rs.Heartbeat:Wait()
          end
          -- Restaura a velocidade original ao desativar
          pcall(function()
            local root = GetRoot(lp.Character)
            if root and rv then
              root.Velocity = rv
            end
          end)
        end)
      end
    end)
  end
})

local propertyTable = {} -- armazena valores originais
local Loop

Main:AddToggle("loopfb", {
    Title = "Full Brightness",
    Default = _G.config.fullbright or false,
    Callback = function(val)
        _G.config.fullbright = val; save()
        if _G.config.fullbright then
            for k,v in pairs({Brightness=Light.Brightness,FogEnd=Light.FogEnd,GlobalShadows=Light.GlobalShadows,OutdoorAmbient=Light.OutdoorAmbient,ClockTime=Light.ClockTime}) do
                propertyTable[k] = v
            end
            if Loop then Loop:Disconnect() end
            Loop = rs.RenderStepped:Connect(function()
                local other = re:FindFirstChild("CurrentMap").Value
                local airport = w:FindFirstChild("Airport by deadlybones28")
                Light.Brightness = 2
                Light.FogEnd = 100000
                Light.GlobalShadows = false
                Light.OutdoorAmbient = Color3.fromRGB(128,128,128)
                if other ~= airport then Light.ClockTime = 14 end
                if not _G.FTF then Loop:Disconnect() end
            end)
        else
            if Loop then Loop:Disconnect() end
            for k,v in pairs(propertyTable) do Light[k] = v end
            table.clear(propertyTable)
        end
    end
})

local beastSec = Tabs.Main:AddSection("Beast Area")

beastSec:AddToggle("third",{
  Title = "Third Person",
  Default = _G.config.thirdp or false,
  Callback = function(val)
  _G.config.thirdp = val; save()
  while _G.config.thirdp do
    lp.CameraMode = "Classic"
    task.wait()
    if not _G.config.thirdp or _G.FTF then break end
  end
  if PlayerStats and PlayerStats.IsBeast.Value then
    lp.CameraMode = "LockFirstPerson"
  end
end
})

beastSec:AddToggle("tie",{
  Title = "Auto Tie",
  Default = _G.config.tie or false,
  Callback = function(value)
  _G.config.tie = value
  print(_G.config.tie)
  end
})

beastSec:AddToggle("freeze",{
  Title = "Freeze Aura",
  Default = _G.config.frAura or false,
  Callback = function(val)
  _G.config.frAura = val; save()
  print(_G.config.frAura)
  end
})

-- enable cralw, remove fog, teleport to pc and exit, auto interact, auto escape, hit aura, no stun, beast sound, anti afk,   

local PlB = Tabs.Esp:AddSection("")
  
  eventEditor = (function()
	local events = {}

	local function registerEvent(name,sets)
		events[name] = {
			commands = {},
			sets = sets or {}
		}
	end

	local onEdited = nil

	local function fireEvent(name,...)
		local args = {...}
		local event = events[name]
		if event then
			for i,cmd in pairs(event.commands) do
				local metCondition = true
				for idx,set in pairs(event.sets) do
					local argVal = args[idx]
					local cmdSet = cmd[2][idx]
					local condType = set.Type
					if condType == "Player" then
						if cmdSet == 0 then
							metCondition = metCondition and (tostring(Players.LocalPlayer) == argVal)
						elseif cmdSet ~= 1 then
							metCondition = metCondition and table.find(getPlayer(cmdSet,Players.LocalPlayer),argVal)
						end
					elseif condType == "String" then
						if cmdSet ~= 0 then
							metCondition = metCondition and string.find(argVal:lower(),cmdSet:lower())
						end
					elseif condType == "Number" then
						if cmdSet ~= 0 then
							metCondition = metCondition and tonumber(argVal)<=tonumber(cmdSet)
						end
					end
					if not metCondition then break end
				end

				if metCondition then
					pcall(task.spawn(function()
						local cmdStr = cmd[1]
						for count,arg in pairs(args) do
							cmdStr = cmdStr:gsub("%$"..count,arg)
						end
						wait(cmd[3] or 0)
						execCmd(cmdStr)
					end))
				end
			end
		end
	end
	return {
		FireEvent = fireEvent
	}
end)()
  
  local ESPenabled = false
  
  local function ESP(pl)
    task.spawn(function()
        for i,v in pairs(cg:GetChildren()) do
            if v.Name == pl.Name..'_ESP' then
                v:Destroy()
            end
        end
        wait()
        if pl.Character and pl.Name ~= lp.Name and not cg:FindFirstChild(pl.Name..'_ESP') then
            local ESPholder = Instance.new("Folder")
            ESPholder.Name = pl.Name..'_ESP'
            ESPholder.Parent = cg
            if pl.Character and pl.Character:FindFirstChild('Head') then
                local BillboardGui = Instance.new("BillboardGui")
                local TextLabel = Instance.new("TextLabel")
                BillboardGui.Adornee = pl.Character.Head
                BillboardGui.Name = pl.Name
                BillboardGui.Parent = ESPholder
                BillboardGui.Size = UDim2.new(0, 100, 0, 150)
                BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
                BillboardGui.AlwaysOnTop = true
                TextLabel.Parent = BillboardGui
                TextLabel.BackgroundTransparency = 1
                TextLabel.Position = UDim2.new(0, 0, 0, -50)
                TextLabel.Size = UDim2.new(0, 100, 0, 100)
                TextLabel.Font = fonte
                TextLabel.TextSize = 20
                TextLabel.TextColor3 = Color3.new(1, 1, 1)
                TextLabel.TextStrokeTransparency = 0
                TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
                TextLabel.Text = 'Name: '..pl.Name
                TextLabel.ZIndex = 10
				local espLoopFunc
				local teamChange
				local addedFunc
				addedFunc = pl.CharacterAdded:Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until GetRoot(pl.Character) and pl.Character:FindFirstChildOfClass("Humanoid")
						ESP(pl)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = pl:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until GetRoot(pl.Character) and pl.Character:FindFirstChildOfClass("Humanoid")
						ESP(pl)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function espLoop()
					if cg:FindFirstChild(pl.Name..'_ESP') then
						if pl.Character and GetRoot(pl.Character) and pl.Character:FindFirstChildOfClass("Humanoid") and lp.Character and GetRoot(lp.Character) and lp.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((GetRoot(lp.Character).Position - GetRoot(pl.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..pl.Name..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						espLoopFunc:Disconnect()
					end
				end
				espLoopFunc = rs.RenderStepped:Connect(espLoop)
			end
		end
	end)
end
  
  PlB:AddToggle("players and beast",
  {
    Title = "Esp Players and Beast",
    Default = _G.config.players or false,
    Callback = function(value)
    _G.config.players = value
    save()
    
    spawn(function()
        if _G.config.players then
            local workspace = game:GetService("Workspace")
            local player = game:GetService("Players").LocalPlayer
            local camera = workspace.CurrentCamera
            
            local Box_Color = Color3.fromRGB(0, 255, 50)
            local Box_Thickness = 1.4
            local Box_Transparency = 1
            
            local Tracers = true
            local Tracer_Color = Color3.fromRGB(0, 255, 50)
            local Tracer_Thickness = 1.4
            local Tracer_Transparency = 1
            local Autothickness = false
            
            local Team_Check = true
            local red = Color3.fromRGB(227, 52, 52)
            local green = Color3.fromRGB(88, 217, 24)
            
            local function getBeast()
    local listplayers = pl:GetChildren()
    for _, player in ipairs(listplayers) do
        local character = player.Character
        if character ~= nil and character:FindFirstChild("BeastPowers") then
            return player
        end
    end
end

local function NewLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(1, 1)
    line.Color = Box_Color
    line.Thickness = Box_Thickness
    line.Transparency = Box_Transparency
    return line
end

--// Main Function:
for _, v in pairs(pl:GetPlayers()) do
    --// Lines for 3D box (12)
    local lines = {
        line1 = NewLine(),
        line2 = NewLine(),
        line3 = NewLine(),
        line4 = NewLine(),
        line5 = NewLine(),
        line6 = NewLine(),
        line7 = NewLine(),
        line8 = NewLine(),
        line9 = NewLine(),
        line10 = NewLine(),
        line11 = NewLine(),
        line12 = NewLine(),
        Tracer = NewLine()
    }

    lines.Tracer.Color = Tracer_Color
    lines.Tracer.Thickness = Tracer_Thickness
    lines.Tracer.Transparency = Tracer_Transparency

    --// Updates ESP (lines) in render loop
    local function linhas()
        local connection
        connection =
            game:GetService("RunService").RenderStepped:Connect(
            function()
                if
                    _G.config.players and v.Character and v.Character:FindFirstChild("Humanoid") and
                        v.Character:FindFirstChild("HumanoidRootPart") and
                        v.Name ~= player.Name and
                        v.Character.Humanoid.Health > 0 and
                        v.Character:FindFirstChild("Head")
                  then
                    local pos, vis = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                    if vis then
                        local Scale = v.Character.Head.Size.Y / 2
                        local Size = Vector3.new(2, 3, 1.5) * (Scale * 2) -- Change this for different box size

                        local Top1 =
                            camera:WorldToViewportPoint(
                            (v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, -Size.Z)).p
                        )
                        local Top2 =
                            camera:WorldToViewportPoint(
                            (v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, Size.Z)).p
                        )
                        local Top3 =
                            camera:WorldToViewportPoint(
                            (v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, Size.Z)).p
                        )
                        local Top4 =
                            camera:WorldToViewportPoint(
                            (v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, -Size.Z)).p
                        )

                        local Bottom1 =
                            camera:WorldToViewportPoint(
                            (v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, -Size.Z)).p
                        )
                        local Bottom2 =
                            camera:WorldToViewportPoint(
                            (v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, Size.Z)).p
                        )
                        local Bottom3 =
                            camera:WorldToViewportPoint(
                            (v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, Size.Z)).p
                        )
                        local Bottom4 =
                            camera:WorldToViewportPoint(
                            (v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, -Size.Z)).p
                        )

                        --// Top:
                        lines.line1.From = Vector2.new(Top1.X, Top1.Y)
                        lines.line1.To = Vector2.new(Top2.X, Top2.Y)

                        lines.line2.From = Vector2.new(Top2.X, Top2.Y)
                        lines.line2.To = Vector2.new(Top3.X, Top3.Y)

                        lines.line3.From = Vector2.new(Top3.X, Top3.Y)
                        lines.line3.To = Vector2.new(Top4.X, Top4.Y)

                        lines.line4.From = Vector2.new(Top4.X, Top4.Y)
                        lines.line4.To = Vector2.new(Top1.X, Top1.Y)

                        --// Bottom:
                        lines.line5.From = Vector2.new(Bottom1.X, Bottom1.Y)
                        lines.line5.To = Vector2.new(Bottom2.X, Bottom2.Y)

                        lines.line6.From = Vector2.new(Bottom2.X, Bottom2.Y)
                        lines.line6.To = Vector2.new(Bottom3.X, Bottom3.Y)

                        lines.line7.From = Vector2.new(Bottom3.X, Bottom3.Y)
                        lines.line7.To = Vector2.new(Bottom4.X, Bottom4.Y)

                        lines.line8.From = Vector2.new(Bottom4.X, Bottom4.Y)
                        lines.line8.To = Vector2.new(Bottom1.X, Bottom1.Y)

                        --//S ides:
                        lines.line9.From = Vector2.new(Bottom1.X, Bottom1.Y)
                        lines.line9.To = Vector2.new(Top1.X, Top1.Y)

                        lines.line10.From = Vector2.new(Bottom2.X, Bottom2.Y)
                        lines.line10.To = Vector2.new(Top2.X, Top2.Y)

                        lines.line11.From = Vector2.new(Bottom3.X, Bottom3.Y)
                        lines.line11.To = Vector2.new(Top3.X, Top3.Y)

                        lines.line12.From = Vector2.new(Bottom4.X, Bottom4.Y)
                        lines.line12.To = Vector2.new(Top4.X, Top4.Y)

                        --// Tracer:
                        if Tracers then
                            local trace =
                                camera:WorldToViewportPoint(
                                (v.Character.HumanoidRootPart.CFrame * CFrame.new(0, -Size.Y, 0)).p
                            )
                            lines.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            lines.Tracer.To = Vector2.new(trace.X, trace.Y)
                        end

                        --// Teamcheck:
                        if Team_Check then
                            local beastPlayer = getBeast()
                            if v == beastPlayer then
                                for _, x in pairs(lines) do
                                    x.Color = red
                                end
                            else
                                for _, x in pairs(lines) do
                                    x.Color = green
                                end
                            end
                        end

                        --// Autothickness:
                        if Autothickness then
                            local distance =
                                (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                            local value = math.clamp(1 / distance * 100, 0.1, 4) --0.1 é a espessura mínima, 4 é a máxima
                            for _, x in pairs(lines) do
                                x.Thickness = value
                            end
                        else
                            for _, x in pairs(lines) do
                                x.Thickness = Box_Thickness
                            end
                        end

                        for _, x in pairs(lines) do
                            if x ~= lines.Tracer then
                                x.Visible = true
                            end
                        end
                        if Tracers then
                            lines.Tracer.Visible = true
                        end
                    else
                        for _, x in pairs(lines) do
                            x.Visible = false
                        end
                    end
                else
                    for _, x in pairs(lines) do
                        x.Visible = false
                    end
                    if not pl:FindFirstChild(v.Name) then
                        connection:Disconnect()
                    end
                end
            end
        )
    end
    coroutine.wrap(linhas)()
end

pl.PlayerAdded:Connect(
    function(newplr)
        --// Lines for 3D box (12)
        local lines = {
            line1 = NewLine(),
            line2 = NewLine(),
            line3 = NewLine(),
            line4 = NewLine(),
            line5 = NewLine(),
            line6 = NewLine(),
            line7 = NewLine(),
            line8 = NewLine(),
            line9 = NewLine(),
            line10 = NewLine(),
            line11 = NewLine(),
            line12 = NewLine(),
            Tracer = NewLine()
        }

        lines.Tracer.Color = Tracer_Color
        lines.Tracer.Thickness = Tracer_Thickness
        lines.Tracer.Transparency = Tracer_Transparency

        local function linhas()
            local connection
            connection =
                game:GetService("RunService").RenderStepped:Connect(
                function()
                    if
                        _G.config.players and newplr.Character and newplr.Character:FindFirstChild("Humanoid") and
                            newplr.Character:FindFirstChild("HumanoidRootPart") and
                            newplr.Name ~= player.Name and
                            newplr.Character.Humanoid.Health > 0 and
                            newplr.Character:FindFirstChild("Head")
                      then
                        local pos, vis = camera:WorldToViewportPoint(newplr.Character.HumanoidRootPart.Position)
                        if vis then
                            local Scale = newplr.Character.Head.Size.Y / 2
                            local Size = Vector3.new(2, 3, 1.5) * (Scale * 2) -- Change this for different box size

                            local Top1 =
                                camera:WorldToViewportPoint(
                                (newplr.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, -Size.Z)).p
                            )
                            local Top2 =
                                camera:WorldToViewportPoint(
                                (newplr.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, Size.Z)).p
                            )
                            local Top3 =
                                camera:WorldToViewportPoint(
                                (newplr.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, Size.Z)).p
                            )
                            local Top4 =
                                camera:WorldToViewportPoint(
                                (newplr.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, -Size.Z)).p
                            )

                            local Bottom1 =
                                camera:WorldToViewportPoint(
                                (newplr.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, -Size.Z)).p
                            )
                            local Bottom2 =
                                camera:WorldToViewportPoint(
                                (newplr.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, Size.Z)).p
                            )
                            local Bottom3 =
                                camera:WorldToViewportPoint(
                                (newplr.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, Size.Z)).p
                            )
                            local Bottom4 =
                                camera:WorldToViewportPoint(
                                (newplr.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, -Size.Z)).p
                            )

                            --// Top:
                            lines.line1.From = Vector2.new(Top1.X, Top1.Y)
                            lines.line1.To = Vector2.new(Top2.X, Top2.Y)

                            lines.line2.From = Vector2.new(Top2.X, Top2.Y)
                            lines.line2.To = Vector2.new(Top3.X, Top3.Y)

                            lines.line3.From = Vector2.new(Top3.X, Top3.Y)
                            lines.line3.To = Vector2.new(Top4.X, Top4.Y)

                            lines.line4.From = Vector2.new(Top4.X, Top4.Y)
                            lines.line4.To = Vector2.new(Top1.X, Top1.Y)

                            --// Bottom:
                            lines.line5.From = Vector2.new(Bottom1.X, Bottom1.Y)
                            lines.line5.To = Vector2.new(Bottom2.X, Bottom2.Y)

                            lines.line6.From = Vector2.new(Bottom2.X, Bottom2.Y)
                            lines.line6.To = Vector2.new(Bottom3.X, Bottom3.Y)

                            lines.line7.From = Vector2.new(Bottom3.X, Bottom3.Y)
                            lines.line7.To = Vector2.new(Bottom4.X, Bottom4.Y)

                            lines.line8.From = Vector2.new(Bottom4.X, Bottom4.Y)
                            lines.line8.To = Vector2.new(Bottom1.X, Bottom1.Y)

                            --//S ides:
                            lines.line9.From = Vector2.new(Bottom1.X, Bottom1.Y)
                            lines.line9.To = Vector2.new(Top1.X, Top1.Y)

                            lines.line10.From = Vector2.new(Bottom2.X, Bottom2.Y)
                            lines.line10.To = Vector2.new(Top2.X, Top2.Y)

                            lines.line11.From = Vector2.new(Bottom3.X, Bottom3.Y)
                            lines.line11.To = Vector2.new(Top3.X, Top3.Y)

                            lines.line12.From = Vector2.new(Bottom4.X, Bottom4.Y)
                            lines.line12.To = Vector2.new(Top4.X, Top4.Y)

                            --// Tracer:
                            if Tracers then
                                local trace =
                                    camera:WorldToViewportPoint(
                                    (newplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, -Size.Y, 0)).p
                                )
                                lines.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                                lines.Tracer.To = Vector2.new(trace.X, trace.Y)
                            end

                            --// Teamcheck:
                            if Team_Check then
                                local beastPlayer = getBeast()
                                if newplr == beastPlayer then
                                    for _, x in pairs(lines) do
                                        x.Color = red
                                    end
                                else
                                    for _, x in pairs(lines) do
                                        x.Color = green
                                    end
                                end
                            end

                            --// Autothickness:
                            if Autothickness then
                                local distance =
                                    (player.Character.HumanoidRootPart.Position -
                                    newplr.Character.HumanoidRootPart.Position).magnitude
                                local value = math.clamp(1 / distance * 100, 0.1, 4) --0.1 é a espessura mínima, 4 é a máxima
                                for _, x in pairs(lines) do
                                    x.Thickness = value
                                end
                            else
                                for _, x in pairs(lines) do
                                    x.Thickness = Box_Thickness
                                end
                            end

                            for _, x in pairs(lines) do
                                if x ~= lines.Tracer then
                                    x.Visible = true
                                end
                            end
                            if Tracers then
                                lines.Tracer.Visible = true
                            end
                        else
                            for _, x in pairs(lines) do
                                x.Visible = false
                            end
                        end
                    else
                        for _, x in pairs(lines) do
                            x.Visible = false
                        end
                        if not pl:FindFirstChild(newplr.Name) then
                            connection:Disconnect()
                        end
                    end
                end
            )
        end
        coroutine.wrap(linhas)()
    end
)
  ESPenabled = true
		for i,v in pairs(pl:GetChildren()) do
			if v.ClassName == "Player" and v.Name ~= lp.Name then
				ESP(v)
			end
		end
		
	joins = pl.PlayerAdded:Connect(function(plr)
	eventEditor.FireEvent("OnJoin",plr.Name)
	if ESPenabled then
		repeat wait(1) until plr.Character and GetRoot(plr.Character)
		ESP(plr)
	end
end)

  exites = pl.PlayerRemoving:Connect(function(player)
	if ESPenabled then
		for i,v in pairs(cg:GetChildren()) do
			if v.Name == player.Name..'_ESP' then
				v:Destroy()
				end
      end
    end
  end)
        else
          if ESPenabled then
          ESPenabled = false
            for i,c in pairs(cg:GetChildren()) do
              if string.sub(c.Name, -4) == '_ESP' then
                  c:Destroy()
                  joins:Disconnect()
                  exites:Disconnect()
                  end
                end
              end
            end
          end)
        end
  }
)

local Esp = Tabs.Esp:AddSection("Game")
  
  Esp:AddToggle("pc",
  {
    Title = "Esp Pc",
    Default = _G.config.pc or false,
    Callback = function(value)
    _G.config.pc = value
    save()
    
    task.spawn(function()
        if _G.config.pc then
        while _G.config.pc do task.wait()
          for _, pc in pairs(w:GetDescendants()) do
            if pc.Name == "ComputerTable" and not pc:FindFirstChild("PcH") then
              local h = Instance.new("Highlight")
              h.Name = "PcH"
              h.OutlineTransparency = 0.92
              h.Adornee = pc
              h.Parent = pc
              local tela = pc:FindFirstChild("Screen")
              if tela and tela.Color then
              h.FillColor = tela.Color
              else
                h.FillColor = Color3.fromRGB(13, 105, 172)
              end -- pegar a cor padrão 
              h.FillTransparency = .35
              tela:GetPropertyChangedSignal("Color"):Connect(function()
                if h.Parent then
                  h.FillColor = tela.Color
                  end
                end)
              end
            end
          end
        else 
          for _, v in pairs(w:GetDescendants()) do
                local verify = v:FindFirstChild("PcH")
                if verify then
                    verify:Destroy()
                end
              end
            end
        end)
      end
  }
)
-- Desconectar quando o screen for destruído
			---screen.Destroying:Connect(function()
				---if colorChangedConn then
					---colorChangedConn:Disconnect()
				---end
			---end)
  
  Esp:AddToggle("pod", 
    {
      Title = "Esp Pod",
      Default = _G.config.pod or false,
      Callback = function(value)
      _G.config.pod = value
      save()
      
      spawn(function()
        if _G.config.pod then
          while _G.config.pod do task.wait()
            for _, pod in pairs(w:GetDescendants()) do
              if pod.Name == "FreezePod" and not pod:FindFirstChild("PodH") then
                local h = Instance.new("Highlight")
                h.Name = "PodH"
                h.OutlineTransparency = 0.92
                h.Adornee = pod
                h.Parent = pod
                h.FillColor = Color3.fromRGB(0, 80, 255)
                h.FillTransparency = .5
              end
            end
          end
            else
            for _, v in pairs(w:GetDescendants()) do
              local verify = v:FindFirstChild("PodH")
                if verify then
                  verify:Destroy()
                end
              end
            end
          end)
        end
  }
)

  Esp:AddToggle("exit", 
    {
      Title = "Esp Exit",
      Default = _G.config.saida or false,
      Callback = function(value)
      _G.config.saida = value
      save()
      
      spawn(function()
        if _G.config.saida then
          while _G.config.saida do task.wait()
            for _, saida in pairs(w:GetDescendants()) do
              if saida.Name == "ExitDoor" and not saida:FindFirstChild("ExitH") then
                local h = Instance.new("Highlight")
                h.Name = "ExitH"
                h.OutlineTransparency = 0.92
                h.Adornee = saida
                h.Parent = saida
                local luz = saida:FindFirstChild("Light")
                h.FillColor = luz.Color
                h.FillTransparency = .35
                luz:GetPropertyChangedSignal("Color"):Connect(function()
                if h.Parent then
                  h.FillColor = luz.Color
                  end
                end)
              end
            end
          end
            else
              for _, v in pairs(w:GetDescendants()) do
              local verify = v:FindFirstChild("ExitH")
                if verify then
                  verify:Destroy()
                end
              end
            end
          end)
        end
  }
)

  local localplr = Tabs.localp:AddSection("")



  localplr:AddToggle("antif",
    {
      Title = "Anti-Fling",
      Default = _G.config.anti_fling or false,
      Callback = function(value)
      _G.config.anti_fling = value
      save()
      
      spawn(function()
        local antifling
        if antifling then
            antifling:Disconnect()
            antifling = nil
        end

        if _G.config.anti_fling then
            antifling =
                rs.Stepped:Connect(
                function()
                    for _, player in pairs(pl:GetPlayers()) do
                        if player ~= lp and player.Character then
                            for _, v in pairs(player.Character:GetDescendants()) do
                                if v:IsA("BasePart") then
                                    v.CanCollide = false
                                end
                            end
                        end
                    end
                end)
              end
            end)
        end
  }
)
  
  local sliders = Tabs.localp:AddSection("Sliders")

  sliders:AddSlider("speed_slider", {
    Title = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
      _G.speed = Value
    end
  }
)

  sliders:AddSlider("jump_slider", {
    Title = "JumpPower",
    Default = 36,
    Min = 36,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
      _G.jump = Value
    end
  }
)

  sliders:AddSlider("fling_power",
    {
      Title = "Fling Power",
      Default = _G.power or 1,
      Min = 1,
      Max = 100,
      Rounding = 1,
      Callback = function(value)
      _G.power = value
      if _G.power then
        power_fling = _G.power
      end
    end
  }
)

  sliders:AddToggle("Toggle", {
    Title = "WalkSpeed",
    Default = _G.config.speed or false,
    Callback = function(Value)
        _G.config.speed = Value
        save()

        spawn(function()
            while _G.config.speed do task.wait()
                lp.Character:FindFirstChild("Humanoid").WalkSpeed = _G.speed
            end
            lp.Character:FindFirstChild("Humanoid").WalkSpeed = 16
        end)
    end
  }
)


if huma and not huma.UseJumpPower then
  huma.UseJumpPower = true
end

  sliders:AddToggle("Toggle", {
    Title = "JumpPower",
    Default = _G.config.jump or false,
    Callback = function(Value)
        _G.config.jump = Value
        save()

        spawn(function()
            while _G.config.jump do task.wait()
                lp.Character:FindFirstChild("Humanoid").JumpPower = _G.jump
            end
            lp.Character:FindFirstChild("Humanoid").JumpPower = 36
        end)
    end
  }
)

  local Players = Tabs.Players:AddSection("")

  local player_list = {}

  local function get_player_list()
    player_list = {}

    for _, player in pairs(pl:GetPlayers()) do
        if player ~= lp then
            table.insert(player_list, player.Name)
        end
    end

    return player_list
  end

  local players = get_player_list()

  local select_player = Players:AddDropdown("select_player", {
    Title = "Target Player",
    Values = player_list,
    Multi = false,
    Default = "",
    Callback = function(Value)
        _G.select_player = Value
    end
    }
  )
  
  pl.PlayerRemoving:Connect(function(player)
	pcall(function()
		if player.Name == _G.select_player then
      get_player_list()
      select_player:SetValues(player_list)
			Fluent:Notify({
			Title = "Ocalism",
			Content = "Targeted player left or rejoined.",
      Duration = 2.5
			})
		end
	end)
end)

  pl.PlayerAdded:Connect(function()
	eventEditor.FireEvent("OnJoin")
	get_player_list()
  select_player:SetValues(player_list)
end)

  Players:AddButton(
    {
    Title = "Refresh Player List",
    Description = "",
    Callback = function()
        get_player_list()
        select_player:SetValues(player_list)
    end
    }
  )

  Players:AddButton(
    {
        Title = "Teleport",
        Description = "Teleport to a Targeted Player",
        Callback = function()
            local Selected = _G.select_player

            if Selected and Selected ~= "" then
                local Targeted_Player = pl:FindFirstChild(Selected)

                if Targeted_Player and Targeted_Player.Character and Targeted_Player.Character:FindFirstChild("HumanoidRootPart") then
                    local Targeted = Targeted_Player.Character.HumanoidRootPart

                    local success, err = pcall(function()
                        lp.Character.HumanoidRootPart.CFrame = Targeted.CFrame + Vector3.new(0, 3, 0)
                    end)

                    if not success then
                        Fluent:Notify(
                          {
                            Title = "Ocalism - Warn",
                            Content = "Teleportation failed:" .. tostring(err),
                            Duration = 2
                          }
                        ) 
                    end
                else
                    Fluent:Notify(
                        {
                            Title = "Ocalism - Warn",
                            Content = "Target player not found or not in a valid state.",
                            Duration = 2
                        }
                    )
                end
            else
                Fluent:Notify(
                    {
                        Title = "Ocalism - Warn",
                        Content = "Please select a valid player.",
                        Duration = 2
                    }
                )
            end
        end
    }
  )



  Players:AddToggle("view", 
    {
        Title = "View",
        Default = _G.config.view or false,
        Callback = function(value)
        _G.config.view = value
        save()
        spawn(function()
          local Targeted_Player
            while _G.config.view do task.wait()
              if _G.config.view then
                local Selected = _G.select_player
                
                if Selected and Selected ~= "" then
                    Targeted_Player = pl:FindFirstChild(Selected)
                    if Targeted_Player and Targeted_Player.Character and Targeted_Player.Character:FindFirstChild("Humanoid") then
                        w.CurrentCamera.CameraSubject = Targeted_Player.Character.Humanoid
                    end
                else
                    Fluent:Notify(
                        {
                            Title = "Ocalism - Warn",
                            Content = "No player selected.",
                            Duration = 0.2
                        }
                    )
                    w.CurrentCamera.CameraSubject = lp.Character.Humanoid
                end
            else
              if Targeted_Player then
                w.CurrentCamera.CameraSubject = lp.Character.Humanoid
                end
              end
            end
          end)
        end
    }
  )

-- Toggle Fling
  
  Players:AddToggle("focus",
    {
      Title = "Focus",
      Default = _G.config.focus or false,
      Callback = function(value)
      _G.config.focus = value
      save()
      
      
    spawn(function()
      local save_pos = lp.Character.HumanoidRootPart.CFrame
      while _G.config.focus do task.wait(.2)
        if _G.config.focus then
          
            pcall(function()
              local Selected = _G.select_player

            if Selected and Selected ~= "" then
                local Targeted_Player = pl:FindFirstChild(Selected)

                if Targeted_Player and Targeted_Player.Character and Targeted_Player.Character:FindFirstChild("HumanoidRootPart") then
                    local Targeted = Targeted_Player.Character.HumanoidRootPart
                    lp.Character.HumanoidRootPart.CFrame = Targeted.CFrame + Vector3.new(0, 3, 0)
                  end
                end
            end)
          else
            if save_pos then
            lp.Character.HumanoidRootPart.CFrame = save_pos
            save_pos = nil
            end
          end
        end
    end)
  end
  }
)

  Players:AddToggle("bang",
    {
      Title = "Bang",
      Default = _G.config.bang or false,
      Callback = function(value)
      _G.config.bang = value
      save()
      
      spawn(
        function()
          if _G.config.bang then
            local Selected = _G.select_player
              if Selected and Selected ~= "" then
                local Target = pl:FindFirstChild(Selected)
                local humanoid = lp.Character:FindFirstChildWhichIsA("Humanoid")
                bangAnim = Instance.new("Animation")
                bangAnim.AnimationId = not r15(lp) and "rbxassetid://148840371" or "rbxassetid://5918726674"
                bang = humanoid:LoadAnimation(bangAnim)
                bang:Play(0.1, 1, 1)
                bang:AdjustSpeed(13)
                if Target then
                  local bangplr = Target.Name
                  local bangOffet = CFrame.new(0, 0, 1.1)
                  bangLoop = rs.Stepped:Connect(function()
                    pcall(function()
                      local otherRoot = getTorso(pl[bangplr].Character)
					            GetRoot(lp.Character).CFrame = otherRoot.CFrame * bangOffet
                    end)
                  end)
                end
              end
            else
              if bang then
              bang:Stop()
              bangAnim:Destroy()
              bangLoop:Disconnect()
            end
          end
        end)
      end 
  }
)

  Players:AddToggle("backpack", {
    Title = "Backpack",
    Default = _G.config.backpack or false,
    Callback = function(value)
        _G.config.backpack = value
        save()

        spawn(function()
            while _G.config.backpack do
                task.wait()

                local Selected = _G.select_player
                if Selected and Selected ~= "" then
                    local Target = pl:FindFirstChild(Selected)

                    if Target and Target.Character then
                        pcall(function()
                            local lpRoot = GetRoot(lp.Character)
                            local targetRoot = GetRoot(Target.Character)

                            if not lpRoot or not targetRoot then return end

                            if not lpRoot:FindFirstChild("BreakVelocity") then
                                local BodyVelocity = Instance.new("BodyAngularVelocity")
                                BodyVelocity.AngularVelocity = Vector3.new(0, 0, 0)
                                BodyVelocity.MaxTorque = Vector3.new(50000, 50000, 50000)
                                BodyVelocity.P = 1250
                                BodyVelocity.Name = "BreakVelocity"
                                BodyVelocity.Parent = lpRoot
                            end

                            lp.Character.Humanoid.Sit = true
                            lpRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.2) * CFrame.Angles(0, -3, 0)
                            lpRoot.Velocity = Vector3.new(0, 0, 0)
                        end)
                    end
                end
            end
            local lpRoot = GetRoot(lp.Character)
            if lpRoot then
                local breakVelocity = lpRoot:FindFirstChild("BreakVelocity")
                if breakVelocity then
                    breakVelocity:Destroy()
                end
                lp.Character.Humanoid.Sit = false
            end
        end)
    end
  }
)

  Players:AddToggle("headsit", {
    Title = "Headsit",
    Default = _G.config.headsit or false,
    Callback = function(value)
        _G.config.headsit = value
        save()

        spawn(function()
            while _G.config.headsit do
                task.wait()
                
                local Selected = _G.select_player
                if Selected and Selected ~= "" then
                    local Target2 = pl:FindFirstChild(Selected)

                    if Target2 and Target2.Character and Target2.Character:FindFirstChild("Head") then
                        pcall(function()
                            local Root = GetRoot(lp.Character)
                            if Root and not Root:FindFirstChild("BreakVelocity") then
                                local BodyVelocity = Instance.new("BodyAngularVelocity")
                                BodyVelocity.AngularVelocity = Vector3.new(0, 0, 0)
                                BodyVelocity.MaxTorque = Vector3.new(50000, 50000, 50000)
                                BodyVelocity.P = 1250
                                BodyVelocity.Name = "BreakVelocity"
                                BodyVelocity.Parent = Root
                            end

                            local targethead = Target2.Character.Head
                            lp.Character.Humanoid.Sit = true
                            Root.CFrame = targethead.CFrame * CFrame.new(0, 2, 0)
                            Root.Velocity = Vector3.new(0, 0, 0)
                        end)
                    end
                end
            end
            local Root = GetRoot(lp.Character)
            if Root then
                for _, v in pairs(Root:GetChildren()) do
                    if v.Name == "BreakVelocity" then
                        v:Destroy()
                    end
                end
            end
            lp.Character.Humanoid.Sit = false
        end)
    end
  }
)

  Players:AddButton({
    Title = "Whitelist",
    Description = "",
    Callback = function()
        local Selected = _G.select_player
        if Selected and Selected ~= "" then
            local Target = pl:FindFirstChild(Selected)

            if Target and Target.UserId then
                local userId = Target.UserId
                local index = table.find(ScriptWhitelist, userId)

                if index then
                    table.remove(ScriptWhitelist, index)
                    Fluent:Notify({
                        Title = "Ocalism - Whitelist",
                        Content = Target.Name .. " Removed from Whitelist",
                        Duration = 2
                    })
                else
                    table.insert(ScriptWhitelist, userId)
                    Fluent:Notify({
                        Title = "Ocalism - Whitelist",
                        Content = Target.Name .. " Added to Whitelist",
                        Duration = 2
                    })
                end
            end
        end
    end
})

  local others_tab = {
    othert = Window:AddTab(
      {
        Title = "Others",
        Icon = "database"
      }
    )
  }
  
  
  local others = others_tab.othert:AddSection("")
  
  others:AddButton(
    {
      Title = "Rapazzz",
      Description = "",
      Callback = function()
      local vis = false
      vis = not vis
      if folder:FindFirstChild("EmoteUI") then
        vis = not vis
        return end
      local canal = chatservice.TextChannels.RBXGeneral
      local sg = Instance.new("ScreenGui")
      local frame = Instance.new("Frame")
      local textbutton = Instance.new("TextButton")
      local textbox = Instance.new("TextBox")
      local L = Instance.new("TextButton")
      
      sg.Name = "EmoteUI"
      sg.Parent = folder
      sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
      
      frame.Name = "Frame"
      frame.Parent = sg
      frame.BackgroundTransparency = 1
      frame.Size = UDim2.new(0, 50, 0, 30)
      frame.Position = UDim2.new(0.121, 700, 0.0952890813, 75)
      frame.Visible = vis
      
      textbutton.Name = "TextButton"
      textbutton.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
      textbutton.BackgroundTransparency = 0.82
      textbutton.Parent = frame
      textbutton.Position = UDim2.new(0, 0, 0, 0)
      textbutton.Size = UDim2.new(1, 0, 1, 0)
      textbutton.Text = "Dance"
      textbutton.TextColor3 = Color3.fromRGB(255, 255, 255)
      textbutton.TextSize = 13
      textbutton.Font = fonte
      textbutton.BorderColor3 = Color3.fromRGB(0, 0, 0)
      
      textbox.Name = "CMD"
      textbox.Parent = frame
      textbox.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
      textbox.BackgroundTransparency = 0.82
      textbox.Position = UDim2.new(0, 0, -0.72, 0)
      textbox.Size = UDim2.new(0, 50, 0, 20)
      textbox.Font = fonte
      textbox.PlaceholderText = ""
      textbox.Text = "/e dance2"
      textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
      textbox.TextSize = 8
      textbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
      
      L.Name = "LoopTextButton"
      L.Parent = frame
      L.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
      L.BackgroundTransparency = 0.82
      L.BorderColor3 = Color3.fromRGB(0, 0, 0)
      L.Position = UDim2.new(1.04999995, 0, -0.720000029, 0)
      L.Size = UDim2.new(0, 20, 0, 20)
      L.Text = "L"
      L.TextColor3 = Color3.fromRGB(255, 255, 255)
      L.TextSize = 8
      L.Font = fonte

local function effect(button)
    if button == textbutton then
      
        button:TweenSize(UDim2.new(0.97, 0, 0.909, 0),
          Enum.EasingDirection.InOut,
          Enum.EasingStyle.Quint, 0.2, true)
        
        task.wait(0.2)
        
        button:TweenSize(UDim2.new(1, 0, 1, 0),
          Enum.EasingDirection.InOut,
          Enum.EasingStyle.Quint, 0.2, true)
        
    elseif button == L then
      
        button:TweenSize(UDim2.new(0, 18, 0, 18),
          Enum.EasingDirection.InOut,
          Enum.EasingStyle.Quint, 0.2, true)
        
        task.wait(0.2)
        
        button:TweenSize(UDim2.new(0, 20, 0, 20),
          Enum.EasingDirection.InOut,
          Enum.EasingStyle.Quint, 0.2, true)
        
    end
end

textbutton.MouseButton1Click:Connect(function()
    effect(textbutton)

    if textbox.Text == "" then
        textbox.Text = "/e dance2"
        canal:SendAsync(textbox.Text, lp)
    else
        canal:SendAsync(textbox.Text, lp)
    end
end)

local act = false

L.MouseButton1Click:Connect(function()
    effect(L)
    
    act = not act
  
    while act do
        task.wait()
        if textbox.Text == "" then
            textbox.Text = "/e dance2"
            pl:Chat(textbox.Text)
        else
            pl:Chat(textbox.Text)
          end
        end
      end)
    end
  }
)

  others:AddButton(
    {
      Title = "Fly Gui",
      Description = "",
      Callback = function()
if folder:FindFirstChild("Fly Gui But Secured") then
  return end
local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speed = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local mini2 = Instance.new("TextButton")
local textBox = Instance.new("TextBox")
  
main.Name = "Fly Gui But Secured"
main.Parent = folder
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

Frame.Name = "Fly_Gui [Secured]"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)

up.Name = game:GetService("HttpService"):GenerateGUID()
up.Parent = main["Fly_Gui [Secured]"]
up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
up.Size = UDim2.new(0, 44, 0, 28)
up.Font = fonte
up.Text = "↑"
up.TextColor3 = Color3.fromRGB(0, 0, 0)
up.TextSize = 14.000

down.Name = game:GetService("HttpService"):GenerateGUID()
down.Parent = main["Fly_Gui [Secured]"]
down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
down.Position = UDim2.new(0, 0, 0.491228074, 0)
down.Size = UDim2.new(0, 44, 0, 28)
down.Font = fonte
down.Text = "↓"
down.TextColor3 = Color3.fromRGB(0, 0, 0)
down.TextSize = 14.000

onof.Name = game:GetService("HttpService"):GenerateGUID()
onof.Parent = main["Fly_Gui [Secured]"]
onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
onof.Size = UDim2.new(0, 56, 0, 28)
onof.Font = fonte
onof.Text = "Fly"
onof.TextColor3 = Color3.fromRGB(0, 0, 0)
onof.TextSize = 14.000

TextLabel.Name = game:GetService("HttpService"):GenerateGUID()
TextLabel.Parent = main["Fly_Gui [Secured]"]
TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
TextLabel.Size = UDim2.new(0, 100, 0, 28)
TextLabel.Font = fonte
TextLabel.Text = "FLY GUI [Secured]"
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

plus.Name = game:GetService("HttpService"):GenerateGUID()
plus.Parent = main["Fly_Gui [Secured]"]
plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
plus.Position = UDim2.new(0.231578946, 0, 0, 0)
plus.Size = UDim2.new(0, 45, 0, 28)
plus.Font = fonte
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(0, 0, 0)
plus.TextScaled = true
plus.TextSize = 14.000
plus.TextWrapped = true

speed.Name = game:GetService("HttpService"):GenerateGUID()
speed.Parent = main["Fly_Gui [Secured]"]
speed.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
speed.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
speed.Size = UDim2.new(0, 44, 0, 28)
speed.Font = fonte
speed.Text = "1"
speed.TextColor3 = Color3.fromRGB(0,0,0)
speed.TextScaled = true
speed.TextSize = 14.000
speed.TextWrapped = true

mine.Name = game:GetService("HttpService"):GenerateGUID()
mine.Parent = main["Fly_Gui [Secured]"]
mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
mine.Size = UDim2.new(0, 45, 0, 29)
mine.Font = fonte
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(0, 0, 0)
mine.TextScaled = true
mine.TextSize = 14.000
mine.TextWrapped = true

closebutton.Name = game:GetService("HttpService"):GenerateGUID()
closebutton.Parent = main["Fly_Gui [Secured]"]
closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
closebutton.Font = "Fantasy"
closebutton.Size = UDim2.new(0, 45, 0, 28)
closebutton.Text = "X"
closebutton.TextSize = 30
closebutton.Position =  UDim2.new(0, 0, -1, 27)

mini.Name = game:GetService("HttpService"):GenerateGUID()
mini.Parent = main["Fly_Gui [Secured]"]
mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini.Font = "Fantasy"
mini.Size = UDim2.new(0, 45, 0, 28)
mini.Text = "-"
mini.TextSize = 40
mini.Position = UDim2.new(0, 44, -1, 27)

mini2.Name = game:GetService("HttpService"):GenerateGUID()
mini2.Parent = main["Fly_Gui [Secured]"]
mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini2.Font = "Fantasy"
mini2.Size = UDim2.new(0, 45, 0, 28)
mini2.Text = "+"
mini2.TextSize = 40
mini2.Position = UDim2.new(0, 44, -1, 57)
mini2.Visible = false

textBox.Name = game:GetService("HttpService"):GenerateGUID()
textBox.Size = UDim2.new(0, 100, 0, 28)
textBox.Position = UDim2.new(0.469327301, 0, -0.5, 0)
textBox.Parent = main["Fly_Gui [Secured]"]
textBox.TextScaled = true
textBox.Text = "Enter a number."
textBox.ClearTextOnFocus = true
textBox.TextWrapped = true
textBox.Font = fonte
textBox.TextColor3 = Color3.new(0, 0, 0)
textBox.BackgroundColor3 = Color3.new(1, 1, 1)


speeds = 1

local speaker = game:GetService("Players").LocalPlayer

local chr = game.Players.LocalPlayer.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")

nowe = false



Frame.Active = true -- main = gui
Frame.Draggable = true

onof.MouseButton1Click:connect(function()

	if nowe == true then
		nowe = false

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true) -- aq
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	else 
		nowe = true



		for i = 1, speeds do
			spawn(function()

				local hb = game:GetService("RunService").Heartbeat	


				tpwalking = true
				local chr = game.Players.LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end

			end)
		end
		game.Players.LocalPlayer.Character.Animate.Disabled = true
		local Char = game.Players.LocalPlayer.Character
		local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

		for i,v in next, Hum:GetPlayingAnimationTracks() do
			v:AdjustSpeed(0)
		end
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		
	end




	if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
	  
    
		local plr = game.Players.LocalPlayer
		local torso = plr.Character.Torso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0


		local bg = Instance.new("BodyGyro", torso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = torso.CFrame
		local bv = Instance.new("BodyVelocity", torso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			game:GetService("RunService").RenderStepped:Wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end
			--	game.Players.LocalPlayer.Character.Animate.Disabled = true
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false



	else
		local plr = game.Players.LocalPlayer
		local UpperTorso = plr.Character.UpperTorso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0


		local bg = Instance.new("BodyGyro", UpperTorso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = UpperTorso.CFrame
		local bv = Instance.new("BodyVelocity", UpperTorso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end

			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false



	end



end)

local tis

up.MouseButton1Down:connect(function()
	tis = up.MouseEnter:connect(function()
		while tis do
			wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
		end
	end)
end)

up.MouseLeave:connect(function()
	if tis then
		tis:Disconnect()
		tis = nil
	end
end)

local dis

down.MouseButton1Down:connect(function()
	dis = down.MouseEnter:connect(function()
		while dis do
			wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
		end
	end)
end)

down.MouseLeave:connect(function()
	if dis then
		dis:Disconnect()
		dis = nil
	end
end)


game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
	wait(0.7)
	game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
	game.Players.LocalPlayer.Character.Animate.Disabled = false

end)





plus.MouseButton1Down:connect(function()
local limit = 6969
    if speeds >= limit then -- check if speed has reached the limit
        speed.Text = "Cannot be more than 6969!"
        wait(1)
        speed.Text = speeds
    else
        speeds = speeds + 1
        speed.Text = speeds
        
        if nowe == true then
            tpwalking = false
            for i = 1, speeds do
                spawn(function()
                    local hb = game:GetService("RunService").Heartbeat	
                    tpwalking = true
                    local chr = game.Players.LocalPlayer.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end
                end)
            end
        end
    end
end)

mine.MouseButton1Down:connect(function()
	if speeds == 1 then
		speed.Text = 'cannot be less than 1'
		wait(1)
		speed.Text = speeds
	else
		speeds = speeds - 1
		speed.Text = speeds
		if nowe == true then
			tpwalking = false
			for i = 1, speeds do
				spawn(function()

					local hb = game:GetService("RunService").Heartbeat	


					tpwalking = true
					local chr = game.Players.LocalPlayer.Character
					local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
					while tpwalking and hb:Wait() and chr and hum and hum.Parent do
						if hum.MoveDirection.Magnitude > 0 then
							chr:TranslateBy(hum.MoveDirection)
						end
					end

				end)
			end
		end
	end
end)

closebutton.MouseButton1Click:Connect(function()
if nowe == true then
nowe = false
speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	main:Destroy()
elseif nowe == false then
	main:Destroy()
	end
end)
mini.MouseButton1Click:Connect(function()
	up.Visible = false
	down.Visible = false
	onof.Visible = false
	plus.Visible = false
	speed.Visible = false
	mine.Visible = false
	mini.Visible = false
	mini2.Visible = true
	textBox.Visible = false
	main["Fly_Gui [Secured]"].BackgroundTransparency = 1
	closebutton.Position =  UDim2.new(0, 0, -1, 57)
end)

mini2.MouseButton1Click:Connect(function()
	up.Visible = true
	down.Visible = true
	onof.Visible = true
	plus.Visible = true
	speed.Visible = true
	mine.Visible = true
	mini.Visible = true
	mini2.Visible = false
	textBox.Visible = true
	main["Fly_Gui [Secured]"].BackgroundTransparency = 0 
	closebutton.Position =  UDim2.new(0, 0, -1, 27)
end)

local function handleTextBoxFocusLost(enterPressed)
    if not enterPressed then return end
    local input = tonumber(textBox.Text)
    local limit = 6969
    if input then
        if input <= 0 then
        textBox.Text = "Cannot be Less than 1!"
        wait(1)
            speeds = 1
        elseif input > limit then
            speeds = limit
            textBox.Text = "Cannot be more than 6969!"
            wait(1)
            textBox.Text = ""
        else
            speeds = input
        end
        textBox.Text = tostring(speeds)
        speed.Text = tostring(speeds)
        if nowe == true then
            tpwalking = false
            for i = 1, speeds do
                spawn(function()
                    local hb = game:GetService("RunService").Heartbeat    
                    tpwalking = true
                    local chr = game.Players.LocalPlayer.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end
                end)
            end
        end
    else
        textBox.Text = "0"
    end
end

textBox.FocusLost:Connect(handleTextBoxFocusLost)

while true do task.wait()
  if nowe then
    for _, c in pairs(speaker.Character:GetDescendants()) do
      if c:IsA("BasePart") then
      c.CanCollide = false
      end
    end
  end
end

local mt = getrawmetatable(game)
local old = mt.__namecall
local protect = newcclosure or protect_function

if not protect then
protect = function(f) return f end
end

setreadonly(mt, false)
mt.__namecall = protect(function(self, ...)
local method = getnamecallmethod()
if method == "Kick" then
wait(9e9)
return
end
return old(self, ...)
end)
hookfunction(game:GetService("Players").LocalPlayer.Kick,protect(function() wait(9e9) end))
      end
    })
  
  local misc_tab = {
    miscw = Window:AddTab(
      {
        Title = "Misc",
        Icon = "align-justify"
      }
    )
  }
  
  local Misc = misc_tab.miscw:AddSection("")
  
  Misc:AddToggle("void",
    {
      Title = "Void Protection",
      Default = _G.config.void or false,
      Callback = function(value)
      _G.config.void = value
      save()
      
      spawn(function()
        if _G.config.void then
          w.FallenPartsDestroyHeight = 0/0
          else
            w.FallenPartsDestroyHeight = -10000
          end
        end)
      end
  }
)

  Misc:AddToggle("anti-spy",
    {
      Title = "Anti-ChatSpy",
      Default = _G.config.anti_chatspy or false,
      Callback = function(value)
      _G.config.anti_chatspy = value
      save()
      
      spawn(function()
        while _G.config.anti_chatspy do
          task.wait()
          pl:Chat(RandomChar())
          end
      end)
    end
  }
)

  Misc:AddButton(
    {
      Title = "Reset",
      Description = "Reset Character",
      Callback = function()
      if character then
        huma.Health = 0
      end
    end
  }
)

  Misc:AddButton(
    {
      Title = "Rejoin",
      Description = "",
      Callback = function()
      game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
      end
  }
)

  Misc:AddButton(
    {
      Title = "Server Hop",
      Description = "",
      Callback = function()
      local function Hop()
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
    local Deleted = false
    function TPReturner()
        local Site
        if foundAnything == "" then
            Site =
                game.HttpService:JSONDecode(
                game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"
                )
            )
        else
            Site =
                game.HttpService:JSONDecode(
                game:HttpGet(
                    "https://games.roblox.com/v1/games/" ..
                        PlaceID .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. foundAnything
                )
            )
        end
        local ID = ""
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
            foundAnything = Site.nextPageCursor
        end
        local num = 0
        for i, v in pairs(Site.data) do
            local Possible = true
            ID = tostring(v.id)
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _, Existing in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(Existing) then
                            Possible = false
                        end
                    else
                        if tonumber(actualHour) ~= tonumber(Existing) then
                            local delFile =
                                pcall(
                                function()
                                    AllIDs = {}
                                    table.insert(AllIDs, actualHour)
                                end
                            )
                        end
                    end
                    num = num + 1
                end
                if Possible == true then
                    table.insert(AllIDs, ID)
                    wait()
                    pcall(
                        function()
                            wait()
                            game:GetService("TeleportService"):TeleportToPlaceInstance(
                                PlaceID,
                                ID,
                                game.Players.LocalPlayer
                            )
                        end
                    )
                    wait(4)
                end
            end
        end
    end
    function Teleport()
        while wait() do
            pcall(
                function()
                    TPReturner()
                    if foundAnything ~= "" then
                        TPReturner()
                    end
                end
            )
        end
    end
    Teleport()
      end
  Hop()
end
  }
)

  Misc:AddButton(
    {
      Title = "Destroy Hub",
      Description = "",
      Callback = function()
      for _, v in pairs(cg:GetChildren()) do
        if v.Name == "Ocalism" then
          local get = gethui() or cg
          local gui = get:FindFirstChild("Library")
          _G.FTF = false
          v:Destroy()
          gui:Destroy()
          folder:Destroy()
        end
      end
    end
    }
  )