-- Roblox Modern Draggable Menu (Client-Side Only)
-- Place this in StarterPlayer > StarterPlayerScripts > LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Wait for character to load properly
repeat 
    RunService.Heartbeat:Wait() 
until character:FindFirstChild("HumanoidRootPart")

-- Variables for features
local flyEnabled = false
local superJumpEnabled = false
local infiniteJumpEnabled = false
local antiCollisionEnabled = false
local currentSpeed = 16

-- Fly variables (client-side only)
local flyConnection
local bodyVelocity
local bodyGyro

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernMenu"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Menu Button (initial state)
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 60, 0, 60)
MenuButton.Position = UDim2.new(0, 50, 0, 50)
MenuButton.BackgroundColor3 = Color3.fromRGB(25, 45, 80)
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.Text = "☰"
MenuButton.TextSize = 20
MenuButton.Font = Enum.Font.GothamBold
MenuButton.BorderSizePixel = 0
MenuButton.ZIndex = 10

-- Add glow effect to button
local ButtonGlow = Instance.new("UIStroke")
ButtonGlow.Color = Color3.fromRGB(0, 162, 255)
ButtonGlow.Thickness = 2
ButtonGlow.Enabled = true
ButtonGlow.Parent = MenuButton

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0.3, 0)
ButtonCorner.Parent = MenuButton

-- Main Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Visible = false
MainFrame.BorderSizePixel = 0

-- Add glow and rounded corners to main frame
local FrameGlow = Instance.new("UIStroke")
FrameGlow.Color = Color3.fromRGB(0, 162, 255)
FrameGlow.Thickness = 2
FrameGlow.Enabled = true
FrameGlow.Parent = MainFrame

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0.05, 0)
FrameCorner.Parent = MainFrame

-- Header with title and close button
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 40, 70)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0.05, 0)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MODERN MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(0.9, 0, 0.15, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "X"
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0.3, 0)
CloseCorner.Parent = CloseButton

-- Scrolling frame for features
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 5
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
ScrollingFrame.Parent = MainFrame

-- Function to create feature frames
local function CreateFeatureFrame(title, positionY)
	local frame = Instance.new("Frame")
	frame.Name = title .. "Frame"
	frame.Size = UDim2.new(1, 0, 0, 50)
	frame.Position = UDim2.new(0, 0, 0, positionY)
	frame.BackgroundColor3 = Color3.fromRGB(30, 50, 85)
	frame.BorderSizePixel = 0
	frame.Parent = ScrollingFrame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.1, 0)
	corner.Parent = frame
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
	titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.Gotham
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = frame
	
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "Toggle"
	toggleButton.Size = UDim2.new(0, 80, 0, 30)
	toggleButton.Position = UDim2.new(0.7, 0, 0.2, 0)
	toggleButton.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
	toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleButton.Text = "OFF"
	toggleButton.TextSize = 12
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.BorderSizePixel = 0
	toggleButton.Parent = frame
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0.2, 0)
	toggleCorner.Parent = toggleButton
	
	return frame
end

-- Function to create slider
local function CreateSlider(parent, min, max, defaultValue)
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Name = "Slider"
	sliderFrame.Size = UDim2.new(0.8, 0, 0, 20)
	sliderFrame.Position = UDim2.new(0.1, 0, 0.6, 0)
	sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
	sliderFrame.BorderSizePixel = 0
	sliderFrame.Parent = parent
	
	local sliderCorner = Instance.new("UICorner")
	sliderCorner.CornerRadius = UDim.new(0.5, 0)
	sliderCorner.Parent = sliderFrame
	
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
	fill.BorderSizePixel = 0
	fill.Parent = sliderFrame
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0.5, 0)
	fillCorner.Parent = fill
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "Value"
	valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
	valueLabel.Position = UDim2.new(0.85, 0, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(defaultValue)
	valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueLabel.TextSize = 12
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.Parent = sliderFrame
	
	return {frame = sliderFrame, fill = fill, value = valueLabel, min = min, max = max}
end

-- Create feature frames
local SpeedFrame = CreateFeatureFrame("🚀 Speed Changer", 0)
local SpeedSlider = CreateSlider(SpeedFrame, 16, 100, 16)

local FlyFrame = CreateFeatureFrame("✈️ Fly Mode", 60)
local SuperJumpFrame = CreateFeatureFrame("🦘 Super Jump", 120)
local InfiniteJumpFrame = CreateFeatureFrame("∞ Infinite Jump", 180)
local AntiCollisionFrame = CreateFeatureFrame("🚫 Anti Collision", 240)

-- Add elements to GUI
MenuButton.Parent = ScreenGui
MainFrame.Parent = ScreenGui
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Dragging functionality
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateInput(input)
	end
end)

-- Menu button dragging
local menuButtonDragging = false
local menuDragInput, menuDragStart, menuStartPos

MenuButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		menuButtonDragging = true
		menuDragStart = input.Position
		menuStartPos = MenuButton.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				menuButtonDragging = false
			end
		end)
	end
end)

MenuButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		menuDragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == menuDragInput and menuButtonDragging then
		local delta = input.Position - menuDragStart
		MenuButton.Position = UDim2.new(menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X, menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y)
	end
end)

-- Button click events
MenuButton.MouseButton1Click:Connect(function()
	if not menuButtonDragging then -- Only open if not dragging
		MainFrame.Visible = true
		MenuButton.Visible = false
	end
end)

CloseButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	MenuButton.Visible = true
end)

-- Feature implementations
local function ToggleFly()
	if flyEnabled then
		-- Disable fly
		if bodyVelocity then
			bodyVelocity:Destroy()
			bodyGyro:Destroy()
		end
		if flyConnection then
			flyConnection:Disconnect()
		end
		FlyFrame:FindFirstChild("Toggle").Text = "OFF"
		FlyFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(60, 80, 120)
	else
		-- Enable fly
		bodyVelocity = Instance.new("BodyVelocity")
		bodyGyro = Instance.new("BodyGyro")
		
		bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
		bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
		
		bodyVelocity.Parent = character:WaitForChild("HumanoidRootPart")
		bodyGyro.Parent = character:WaitForChild("HumanoidRootPart")
		
		flyConnection = RunService.Heartbeat:Connect(function()
			if character and character:FindFirstChild("HumanoidRootPart") then
				bodyGyro.CFrame = workspace.CurrentCamera.CFrame
				local moveDirection = Vector3.new()
				
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then
					moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then
					moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then
					moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then
					moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
				end
				
				bodyVelocity.Velocity = moveDirection * 50
			end
		end)
		
		FlyFrame:FindFirstChild("Toggle").Text = "ON"
		FlyFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(0, 180, 80)
	end
	flyEnabled = not flyEnabled
end

local function ToggleSuperJump()
	superJumpEnabled = not superJumpEnabled
	if superJumpEnabled then
		humanoid.JumpPower = 100
		SuperJumpFrame:FindFirstChild("Toggle").Text = "ON"
		SuperJumpFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(0, 180, 80)
	else
		humanoid.JumpPower = 50
		SuperJumpFrame:FindFirstChild("Toggle").Text = "OFF"
		SuperJumpFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(60, 80, 120)
	end
end

local function ToggleInfiniteJump()
	infiniteJumpEnabled = not infiniteJumpEnabled
	if infiniteJumpEnabled then
		InfiniteJumpFrame:FindFirstChild("Toggle").Text = "ON"
		InfiniteJumpFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(0, 180, 80)
	else
		InfiniteJumpFrame:FindFirstChild("Toggle").Text = "OFF"
		InfiniteJumpFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(60, 80, 120)
	end
end

local function ToggleAntiCollision()
	antiCollisionEnabled = not antiCollisionEnabled
	if antiCollisionEnabled then
		-- Client-side anti-collision
		local function disableCollision(part)
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
		
		-- Disable collision for existing parts
		for _, part in pairs(character:GetDescendants()) do
			disableCollision(part)
		end
		
		-- Disable collision for new parts
		local connection
		connection = character.DescendantAdded:Connect(function(part)
			disableCollision(part)
		end)
		
		AntiCollisionFrame:FindFirstChild("Toggle").Text = "ON"
		AntiCollisionFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(0, 180, 80)
	else
		-- Re-enable collision
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
		AntiCollisionFrame:FindFirstChild("Toggle").Text = "OFF"
		AntiCollisionFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(60, 80, 120)
	end
end

-- Connect toggle buttons
FlyFrame:FindFirstChild("Toggle").MouseButton1Click:Connect(ToggleFly)
SuperJumpFrame:FindFirstChild("Toggle").MouseButton1Click:Connect(ToggleSuperJump)
InfiniteJumpFrame:FindFirstChild("Toggle").MouseButton1Click:Connect(ToggleInfiniteJump)
AntiCollisionFrame:FindFirstChild("Toggle").MouseButton1Click:Connect(ToggleAntiCollision)

-- Infinite jump implementation (client-side)
UserInputService.JumpRequest:Connect(function()
	if infiniteJumpEnabled and character and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Speed slider implementation
SpeedSlider.frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local connection
		connection = RunService.Heartbeat:Connect(function()
			local mouse = UserInputService:GetMouseLocation()
			local relativeX = math.clamp((mouse.X - SpeedSlider.frame.AbsolutePosition.X) / SpeedSlider.frame.AbsoluteSize.X, 0, 1)
			local newValue = math.floor(SpeedSlider.min + relativeX * (SpeedSlider.max - SpeedSlider.min))
			
			SpeedSlider.fill.Size = UDim2.new(relativeX, 0, 1, 0)
			SpeedSlider.value.Text = tostring(newValue)
			currentSpeed = newValue
			humanoid.WalkSpeed = newValue
		end)
		
		local function stopSliding(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				connection:Disconnect()
			end
		end
		
		UserInputService.InputEnded:Connect(stopSliding)
	end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	repeat 
		RunService.Heartbeat:Wait() 
	until character:FindFirstChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	
	-- Reset features on respawn
	flyEnabled = false
	superJumpEnabled = false
	infiniteJumpEnabled = false
	antiCollisionEnabled = false
	
	-- Reset UI toggles
	if FlyFrame and FlyFrame:FindFirstChild("Toggle") then
		FlyFrame:FindFirstChild("Toggle").Text = "OFF"
		FlyFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(60, 80, 120)
	end
	if SuperJumpFrame and SuperJumpFrame:FindFirstChild("Toggle") then
		SuperJumpFrame:FindFirstChild("Toggle").Text = "OFF"
		SuperJumpFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(60, 80, 120)
	end
	if InfiniteJumpFrame and InfiniteJumpFrame:FindFirstChild("Toggle") then
		InfiniteJumpFrame:FindFirstChild("Toggle").Text = "OFF"
		InfiniteJumpFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(60, 80, 120)
	end
	if AntiCollisionFrame and AntiCollisionFrame:FindFirstChild("Toggle") then
		AntiCollisionFrame:FindFirstChild("Toggle").Text = "OFF"
		AntiCollisionFrame:FindFirstChild("Toggle").BackgroundColor3 = Color3.fromRGB(60, 80, 120)
	end
	
	-- Reset speed
	humanoid.WalkSpeed = 16
	currentSpeed = 16
	if SpeedSlider then
		SpeedSlider.fill.Size = UDim2.new(0, 0, 1, 0)
		SpeedSlider.value.Text = "16"
	end
	
	-- Clean up fly if active
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyGyro:Destroy()
	end
	if flyConnection then
		flyConnection:Disconnect()
	end
end)

-- Initial setup
humanoid.WalkSpeed = currentSpeed

print("Modern Menu loaded! Drag the button/menu to move it around.")
