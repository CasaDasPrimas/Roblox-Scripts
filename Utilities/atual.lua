local LocalPlayer = game:GetService('Players').LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local NetworkClient = game:GetService('NetworkClient')
local HttpService = game:GetService('HttpService')
local VirtualUser = game:GetService('VirtualUser')
local RunService = game:GetService('RunService')
local Debris = game:GetService('Debris')
local Stats = game:GetService('Stats')

local Character = LocalPlayer.Character
local Camera = workspace.CurrentCamera
local Runtime = workspace.Runtime
local Alive = workspace.Alive
local Dead = workspace.Dead

local MouseLocation = UserInputService:GetMouseLocation()

setfpscap(240)

_G.config = {
    auto_parry = nil,
    -- curve_method = {}
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

local Fluent = loadstring(game:HttpGet('https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/release.lua'))()

local Window = Fluent:CreateWindow({
    Title = 'Primas',
    SubTitle = '',
    TabWidth = 115,
    Size = UDim2.fromOffset(440, 315),
    Acrylic = false,
    Theme = 'Grape',
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Initial = {}

Initial.ball = {
    player_balls = nil,
    client_ball = nil,
    player_ball = nil,

    events = {
        last_curve_position = Vector3.zero,
        last_velocity = Vector3.zero,
        aero_dynamic_time = tick(),
        parry_distance_max = 0,
        auto_spam = false,
        ball_radians = 0,
        last_warping = 0,
        parried = false,
        parry_range = 0,
        curved = false,
        last_speed = 0,
        max_speed = 0,
        last_hit = 0,
        distance = 0,
        parries = 0,
        radians = 0,
        speed = 0
    }
}

Initial.target = {
    current = nil,
    from = nil
}

local Pointer = {}

local Remotes = {}

local MetaTables = {}

local Player = {}

Player.properties = {
    server_position = Vector3.zero,
    ping = 0,
    dot = 0
}

local function linear_predict(a, b, time_volume)
	return a + (b - a) * time_volume
end

function Pointer:pointer()
    local mouse_position = Camera:ScreenPointToRay(MouseLocation.X, MouseLocation.Y, 0)

    return CFrame.lookAt(mouse_position.Origin, mouse_position.Origin + mouse_position.Direction)
end

function Initial.get_ball()
    for _, ball in workspace.Balls:GetChildren() do
        if ball:GetAttribute('realBall') then
            return ball
        end
    end
end

function Initial.get_client_ball()
    for _, ball in workspace.Balls:GetChildren() do
        if not ball:GetAttribute('realBall') then
            return ball
        end
    end
end

function Initial.get_balls()
    local balls = {}

    for _, ball_instance in workspace.Balls:GetChildren() do
        if ball_instance:GetAttribute('realBall') then
            table.insert(balls, ball_instance)
        end
    end

    return balls
end

Initial.ball.player_ball = Initial.get_ball()
-- Initial.ball.player_balls = Initial.get_balls()
Initial.ball.client_ball = Initial.get_client_ball()

function Player:aim_player()
	local closest_entity = nil
	local minimal_dot_product = -math.huge
	local camera_direction = Camera.CFrame.LookVector

	for _, player in Alive:GetChildren() do
		if not player then
			return
		end

		if player.Name ~= LocalPlayer.Name then
			if not player:FindFirstChild('HumanoidRootPart') then
				return
			end

			local entity_direction = (player.HumanoidRootPart.Position - Camera.CFrame.Position).Unit
			local dot_product = camera_direction:Dot(entity_direction)

			if dot_product > minimal_dot_product then
				minimal_dot_product = dot_product
				closest_entity = player
			end
		end
	end

	return closest_entity
end

function Player:closest_player_to_cursor()
    local closest_player = nil
    local max_distance = -math.huge

    for _, player in Alive:GetChildren() do
        if player == Character then
            return
        end

        if player.Parent ~= Alive then
            return
        end

        local player_direction = (player.PrimaryPart.Position - Camera.CFrame.Position).Unit
        local pointer = Pointer:pointer()
        local dot_product = pointer.LookVector:Dot(player_direction)

        if dot_product > max_distance then
            max_distance = dot_product
            closest_player = player
        end
    end

    return closest_player
end

local function valid_args(args)
    return #args == 7 and type(args[2]) == 'string' and type(args[3]) == 'number' and typeof(args[4]) == 'CFrame' and type(args[5]) == 'table' and type(args[6]) == 'table' and type(args[7]) == 'boolean'
end

function Initial.hook(remote)
    if not Remotes[remote] then
        local meta = getrawmetatable(remote)

        if not MetaTables[meta] then
            Remotes[meta] = true
            setreadonly(meta, false)

            local old_index = meta.__index
            meta.__index = function(self, key)

                if key == 'FireServer' and self:IsA('RemoteEvent') then
                    return function(_, ...)
                        local args = {...}

                        if valid_args(args) then
                            if not Remotes[self] then
                                Remotes[self] = args
                            end
                        end

                        return old_index(self, 'FireServer')(_, table.unpack(args))
                    end
                elseif key == 'InvokeServer' and self:IsA('RemoteFunction') then
                    return function(_, ...)
                        local args = {...}

                        if valid_args(args) then
                            if not Remotes[self] then
                                Remotes[self] = args
                            end
                        end

                        return old_index(self, 'InvokeServer')(_, table.unpack(args))
                    end
                end

                return old_index(self, key)
            end

            setreadonly(meta, true)
        end
    end
end

for _, remote in pairs(ReplicatedStorage:GetChildren()) do
    if remote:IsA('RemoteEvent') or remote:IsA('RemoteFunction') then
        Initial.hook(remote)
    end
end

ReplicatedStorage.ChildAdded:Connect(function(child)
    if child:IsA('RemoteEvent') or child:IsA('RemoteFunction') then
        Initial.hook(child)
    end
end)

function Initial.parry_remote()
    for remote, args in pairs(Remotes) do
        if typeof(remote) ~= 'Instance' then
            return
        end

        if not remote:IsDescendantOf(game) then
            return
        end

        if remote:IsA('RemoteEvent') then
            remote:FireServer(unpack(args))
        elseif remote:IsA('RemoteFunction') then
            remote:InvokeServer(unpack(args))
        end
    end
end

function Initial.parry_direction()
    local ball_events = Initial.ball.events

    if ball_events.parried and not ball_events.auto_spam then
        return
	end

    ball_events.parries = ball_events.parries + 1
    ball_events.last_hit = tick()

    local direction = Camera.CFrame
    local camera_direction = Camera.CFrame.Position

    local target_position = Player.properties.server_position

    if not _G.config.auto_spam then
        ball_events.parried = true

        local current_curve = _G.curve_method

        if current_curve == 'Dot' then
            direction = CFrame.new(Character.PrimaryPart.Position, target_position)
        end
    else
        direction = CFrame.new(camera_direction, target_position)

        Initial.parry_remote()

        task.delay(0.25, function()
            if ball_events.parries  > 0 then
                ball_events.parries = ball_events.parries - 1
            end
        end)

        return
    end

    Initial.parry_remote()

    task.delay(0.25, function()
        if ball_events.parries  > 0 then
            ball_events.parries = ball_events.parries - 1
        end
    end)
end

function Initial.reset()
    Player.properties.server_position = Vector3.zero
    Initial.ball.events.parried = false
    Initial.ball.events.curved = false
    Initial.ball.events.max_speed = 0
    Initial.ball.events.parries = 0
    Initial.target.current = nil
    Initial.target.from = nil
end

function Initial.ball_curved()
	local target = Initial.target.current

	if not target then
		return false
	end

    local current_target = Initial.target.current.Name

    if not Initial.ball.player_ball then
        return false
    end

    local ball_events = Initial.ball.events

	if target.PrimaryPart:FindFirstChild('MaxShield') and current_target ~= LocalPlayer.Name and ball_events.distance < 50 then
		return false
	end

	if Initial.ball.player_ball:FindFirstChild('AeroDynamicSlashVFX') then
        Debris:AddItem(Initial.ball.player_ball.AeroDynamicSlashVFX, 0)

		ball_events.auto_spam = false
		ball_events.aero_dynamic_time = tick()
	end

	if Runtime:FindFirstChild('Tornado') then
		if ball_events.distance > 5 and (tick() - ball_events.aero_dynamic_time) < (Runtime.Tornado:GetAttribute('TornadoTime') or 1) + 0.314159 then
			return true
		end
	end

	local ball_velocity = Initial.ball.player_ball.AssemblyLinearVelocity
	local ball_direction = (Character.HumanoidRootPart.Position - Initial.ball.player_ball.Position).Unit

	-- local ball_position = Initial.ball.player_ball.Position

	local dot_product = ball_direction:Dot(Initial.ball.player_ball.AssemblyLinearVelocity.Unit)

	local speed_threshold = math.min(ball_events.speed / 100, 40)
	local angle_threshold = 40 * math.max(dot_product, 0)

	local player_ping = Player.properties.ping

	local accurate_direction = ball_velocity.Unit
	accurate_direction = accurate_direction * ball_direction

	local direction_difference = (accurate_direction - ball_velocity).Unit
	local accurate_dot = ball_velocity.Unit:Dot(direction_difference)
	local dot_difference = dot_product - accurate_dot
	local dot_threshold = 0.5 - player_ping / 1000

	local reach_time = ball_events.distance / ball_events.max_speed - (player_ping / 1000)
	local enough_speed = ball_events.max_speed > 100

	local ball_distance_threshold = 15 - math.min(ball_events.distance / 1000, 15) + angle_threshold + speed_threshold

	if enough_speed and reach_time > player_ping / 10 then
		ball_distance_threshold = math.max(ball_distance_threshold - 15, 15)
	end

	if ball_events.distance < ball_distance_threshold then
		return false
	end

	if ball_events.distance < 0.018 then
		ball_events.last_curve_position = Initial.ball.player_ball.position
		ball_events.last_warping = tick()
	end

	if (tick() - ball_events.last_warping) < (reach_time / 1.5) then
		return true
	end

	if dot_difference < dot_threshold then
		return true
	end

	return dot_product < dot_threshold
end

workspace.Balls.ChildAdded:Connect(function(child)
	if child:GetAttribute('realBall') then
		Initial.ball.player_ball = child
		Initial.target.current = Alive:FindFirstChild(Initial.ball.player_ball:GetAttribute('target'))
	end

	if Character.Parent == Dead then
		Initial.reset()
	end
end)

ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(slash, root)
	task.spawn(function()
        if Character.Parent == Dead then
            return
        end

		Initial.ball.events.parried = false
	end)

	if Initial.ball.events.auto_spam then
		Initial.parry_direction()
	end
end)

ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
	Initial.ball.events.last_hit = tick()

	if Character.Parent ~= Alive then
		return
	end

	if Initial.ball.events.auto_spam then
		Initial.parry_direction()
	end
end)

RunService.PreSimulation:Connect(function()
	if not Initial.ball.events.auto_spam then
		return
    end

	Initial.parry_direction()
end)

RunService.PreSimulation:Connect(function()
	NetworkClient:SetOutgoingKBPSLimit(math.huge)

	if not Character then
		return
	end

	if not Character.PrimaryPart then
		return
	end

    Player.properties.ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue()
end)

RunService.PreSimulation:Connect(function()
    local ball = Initial.ball.player_ball

    if not ball then
		return
	end

    Initial.target.aim = (not UserInputService.TouchEnabled and Player:closest_player_to_cursor() or Player:aim_player())

    if ball:GetAttribute('from') ~= nil then
		Initial.target.from = Alive:FindFirstChild(ball:GetAttribute('from'))
	end

    Initial.target.current = Alive:FindFirstChild(ball:GetAttribute('target'))

	if Initial.target == nil then
		return
	end
end)

RunService.PostSimulation:Connect(function()
    local auto_parry_enabled = _G.config.auto_parry

    if not auto_parry_enabled then
        Initial.reset()
    end

    local ball = Initial.ball.player_ball

    if not ball then
        return
    end

    local ball_events = Initial.ball.events

    if not Character.Parent == Dead then
        return
    end

    if not Initial.target.current == Dead then
        return
    end

    local ball_curved = Initial.ball_curved()

	local ping_threshold = math.clamp(Player.properties.ping / 10, 10, 15)
    local buffer_threshold = ball_events.speed > 100

	ball_events.parry_range = ping_threshold + math.max(ball_events.speed / 2.5, 15) * buffer_threshold
	ball_events.parry_distance_max = ping_threshold + ball_events.max_speed / 2.5 * buffer_threshold

    if Initial.target.current == LocalPlayer.Name then
        return
    end

    if (ball_events.distance < ball_events.parry_range or ball_events.distance < ball_events.parry_distance_max) then
        return
    end

    if not ball_curved then
        return
    end

    Initial.parry_direction()

    task.spawn(function()
		repeat
			RunService.PreSimulation:Wait()
		until
			(tick() - ball_events.last_hit) > 1 - (ping_threshold / 100)

		ball_events.parried = false
	end)
end)

local blatant_tab = Window:AddTab({ Title = 'Blatant', Icon = 'skull' })

blatant_tab:AddToggle('Toggle', {
    Title = 'Auto Parry',
    Default = _G.config.auto_parry or false,
    Callback = function(state)
        _G.config.auto_parry = state
        save_cfg()
    end
})

blatant_tab:AddDropdown('Dropdown', {
    Title = 'Curve Method',
    Values = { 'None', 'Dot', --[['Backwards', 'Random']] },
    Multi = false,
    Default = 1,
    Callback = function(state)
        _G.curve_method = state
    end
})

--[[
blatant_tab:AddToggle('Toggle', {
    Title = 'Auto Spam',
    Default = _G.config.auto_spam or false,
    Callback = function(state)
        _G.config.auto_spam = state
        save_cfg()
    end
})
]]

Window:SelectTab(1)

Fluent:Notify({
    Title = 'Primas',
    Content = 'Loaded.',
    Duration = 4
})