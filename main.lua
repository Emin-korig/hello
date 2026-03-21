-- [[ trickyhub v1.0.0 - Clean Source Code ]] --
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- [[ НАСТРОЙКИ ПО УМОЛЧАНИЮ ]] --
local flying = false
local noclip = false
local godmode = false 
local clickTPEnabled = true -- Переменная для Click TP
local speedVal = 100 
local jumpVal = 150  
local flySpeed = 80 
local bv, bg 

-- Переменные для перетаскивания
local dragging, dragInput, dragStart, startPos

-- [[ УВЕДОМЛЕНИЕ О ЗАПУСКЕ ]] --
StarterGui:SetCore("SendNotification", {
	Title = "trickyhub",
	Text = "Loaded! Middle Click to TP.",
	Duration = 5,
})

-- [[ СОЗДАНИЕ ГУИ (ИНТЕРФЕЙСА) ]] --
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "trickyhub_ui"
screenGui.IgnoreGuiInset = true 
screenGui.ResetOnSpawn = false 
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 550, 0, 420)
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true 
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(40, 40, 45)
mainStroke.Thickness = 1

local title = Instance.new("TextLabel", mainFrame)
title.Name = "Title"
title.Size = UDim2.new(0, 200, 0, 50)
title.Position = UDim2.new(0, 20, 0, 10)
title.BackgroundTransparency = 1
title.Text = "trickyhub"
title.TextColor3 = Color3.fromRGB(0, 160, 255)
title.TextSize = 28
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 150, 1, -80)
sidebar.Position = UDim2.new(0, 10, 0, 70)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22) 
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local scriptsBtn = Instance.new("TextButton", sidebar)
scriptsBtn.Size = UDim2.new(1, -16, 0, 45)
scriptsBtn.Position = UDim2.new(0, 8, 0, 8)
scriptsBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255) 
scriptsBtn.Text = "Scripts"
scriptsBtn.TextColor3 = Color3.fromRGB(20, 20, 20) 
scriptsBtn.Font = Enum.Font.GothamMedium
scriptsBtn.TextSize = 15
Instance.new("UICorner", scriptsBtn).CornerRadius = UDim.new(0, 6)

local container = Instance.new("ScrollingFrame", mainFrame)
container.Size = UDim2.new(1, -180, 1, -80)
container.Position = UDim2.new(0, 170, 0, 70)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 2.5, 0)
container.ScrollBarThickness = 2
container.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255) 

local grid = Instance.new("UIGridLayout", container)
grid.CellSize = UDim2.new(0, 115, 0, 45) 
grid.CellPadding = UDim2.new(0, 10, 0, 10) 

-- [[ ЛОГИКА CLICK TP (НА КОЛЕСИКО) ]] --
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and clickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton3 then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- Телепортируем на позицию мышки + небольшой подъем вверх
            char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
        end
    end
end)

-- [[ ЛОГИКА ПЕРЕТАСКИВАНИЯ ]] --
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- [[ ЛОГИКА RIGHT ALT ]] --
UIS.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.RightAlt then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

-- [[ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ КНОПОК ]] --
local function createBtn(text, func)
	local b = Instance.new("TextButton", container)
	b.BackgroundColor3 = Color3.fromRGB(30, 30, 35) 
	b.Text = text
	b.TextColor3 = Color3.fromRGB(230, 230, 230) 
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 13
	b.AutoButtonColor = true 
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6) 
	b.MouseButton1Click:Connect(func)
    return b
end

-- [[ ЛОГИКА GOD MODE, FLY И ДРУГИХ ]] --
local function toggleFly()
	flying = not flying
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart
	local hum = char:FindFirstChildOfClass("Humanoid")
	if flying then
		if hum then hum.PlatformStand = true end
		bv = Instance.new("BodyVelocity", root)
		bv.MaxForce = Vector3.new(1,1,1) * math.huge
		bg = Instance.new("BodyGyro", root)
		bg.MaxTorque = Vector3.new(1,1,1) * math.huge
		task.spawn(function()
			while flying do
				local d = Vector3.new(0,0,0)
				if UIS:IsKeyDown(Enum.KeyCode.W) then d += camera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then d -= camera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.A) then d -= camera.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.D) then d += camera.CFrame.RightVector end
				bv.Velocity = d.Magnitude > 0 and d.Unit * flySpeed or Vector3.new(0,0,0)
				bg.CFrame = camera.CFrame
				task.wait()
			end
			if bv then bv:Destroy() end if bg then bg:Destroy() end
			if hum then hum.PlatformStand = false end
		end)
	end
end

local function toggleGod()
	godmode = not godmode
	task.spawn(function()
		while godmode and player.Character do
			pcall(function()
				local h = player.Character:FindFirstChildOfClass("Humanoid")
				if h then h.Health = h.MaxHealth end
			end)
			task.wait(0.1)
		end
	end)
end

-- [[ НАПОЛНЕНИЕ ФУНКЦИЯМИ ]] --
createBtn("God Mode", toggleGod)

local tpBtn = createBtn("Click TP: ON", function() end)
tpBtn.MouseButton1Click:Connect(function()
    clickTPEnabled = not clickTPEnabled
    tpBtn.Text = clickTPEnabled and "Click TP: ON" or "Click TP: OFF"
    tpBtn.TextColor3 = clickTPEnabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(230, 230, 230)
end)

createBtn("Fly", toggleFly)

createBtn("Speed", function() 
	local hum = player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = (hum.WalkSpeed == 16 and speedVal or 16) end
end)

createBtn("Jump", function() 
	local humonoid = player.Character:FindFirstChildOfClass("Humanoid")
	if humonoid then 
		humonoid.UseJumpPower = true 
		humonoid.JumpPower = (humonoid.JumpPower <= 51 and jumpVal or 50)
	end
end)

createBtn("Noclip", function() 
	noclip = not noclip
	local conn
	conn = RunService.Stepped:Connect(function()
		if noclip and player.Character then
			for _, v in pairs(player.Character:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide = false end
			end
		else
			conn:Disconnect()
		end
	end)
end)

createBtn("Headless", function()
	local h = player.Character:FindFirstChild("Head")
	if h then h.Transparency = (h.Transparency == 0 and 1 or 0) end
end)

createBtn("Spin", function()
	local r = player.Character:FindFirstChild("HumanoidRootPart")
	if not r then return end
	if r:FindFirstChild("Spin") then r.Spin:Destroy() else
		local s = Instance.new("BodyAngularVelocity", r) s.Name = "Spin"
		s.MaxTorque = Vector3.new(0, math.huge, 0) s.AngularVelocity = Vector3.new(0, 100, 0)
	end
end)

createBtn("Ghost", function()
	noclip = true
	for _, v in pairs(player.Character:GetDescendants()) do
		if v:IsA("BasePart") then v.Transparency = (v.Transparency == 0 and 0.5 or 0) v.CanCollide = false end
	end
end)

createBtn("Anti-AFK", function()
	player.Idled:Connect(function()
		game:GetService("VirtualUser"):CaptureController()
		game:GetService("VirtualUser"):ClickButton2(Vector2.new())
	end)
end)

print("trickyhub v1.0.0 Loaded! Middle Click to TP.")
