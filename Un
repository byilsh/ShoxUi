-- Load the Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
    Name = "Modern Menu",
    LoadingTitle = "Loading Menu",
    LoadingSubtitle = "by Your Name",
    ConfigurationSaving = { Enabled = true, FolderName = "ModernMenu", FileName = "Settings" },
    Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
    KeySystem = false, -- Set to true if you use a key system
    ToggleUIKeybind = "K"
})

-- Create tabs
local MainTab = Window:CreateTab("Player Mods", "settings")
local PlayerTab = Window:CreateTab("Player ESP", "users") -- New tab for player tracking

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Ensure character exists
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Feature states
local noclipEnabled = false
local flyEnabled = false
local superJumpEnabled = false
local infiniteJumpEnabled = false

-- Player ESP variables
local espEnabled = false
local targetPlayer = nil
local espObjects = {}
local lineConnection = nil

-- Feature objects (for fly and noclip)
local bodyVelocity, bodyGyro
local noclipConnection

-- ===== PLAYER ESP FUNCTIONS =====

local function createCheckmark(playerCharacter)
    if not playerCharacter then return end
    
    -- Remove existing ESP objects for this player
    if espObjects[playerCharacter] then
        for _, obj in pairs(espObjects[playerCharacter]) do
            if obj then
                obj:Destroy()
            end
        end
    end
    
    espObjects[playerCharacter] = {}
    
    -- Create billboard GUI for checkmark
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP"
    billboard.Size = UDim2.new(0, 50, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Enabled = true
    
    local head = playerCharacter:FindFirstChild("Head")
    if not head then return end
    
    billboard.Adornee = head
    billboard.Parent = head
    
    -- Create checkmark label
    local checkmark = Instance.new("TextLabel")
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = "✓"
    checkmark.TextColor3 = Color3.fromRGB(0, 255, 0)
    checkmark.TextSize = 30
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Parent = billboard
    
    -- Create distance label
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(2, 0, 0, 20)
    distanceLabel.Position = UDim2.new(-0.5, 0, 0, -25)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceLabel.TextSize = 14
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Parent = billboard
    
    table.insert(espObjects[playerCharacter], billboard)
    
    return billboard
end

local function createLineToPlayer()
    if not targetPlayer or not targetPlayer.Character then return end
    if not character or not humanoidRootPart then return end
    
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    -- Remove existing line
    if espObjects.line then
        espObjects.line:Destroy()
        espObjects.line = nil
    end
    
    -- Create line (beam)
    local beam = Instance.new("Beam")
    beam.Name = "PlayerLine"
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
    beam.Width0 = 0.2
    beam.Width1 = 0.2
    beam.FaceCamera = true
    
    -- Create attachments for the beam
    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "LineAttachment"
    attachment0.Parent = humanoidRootPart
    
    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "LineAttachment"
    attachment1.Parent = targetRoot
    
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Parent = humanoidRootPart
    
    espObjects.line = beam
    table.insert(espObjects, attachment0)
    table.insert(espObjects, attachment1)
    
    return beam
end

local function updateLineAndDistance()
    if not espEnabled or not targetPlayer or not targetPlayer.Character then return end
    if not character or not humanoidRootPart then return end
    
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    -- Update distance text
    local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
    local billboard = targetPlayer.Character.Head:FindFirstChild("PlayerESP")
    if billboard and billboard:FindFirstChild("Distance") then
        billboard.Distance.Text = string.format("%.1f studs", distance)
    end
    
    -- Line is automatically updated by the Beam
end

local function findPlayerByName(username)
    username = string.lower(username)
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local nameMatch = string.lower(plr.Name) == username
            local displayNameMatch = string.lower(plr.DisplayName) == username
            
            if nameMatch or displayNameMatch then
                return plr
            end
        end
    end
    
    return nil
end

local function enablePlayerESP(username)
    if espEnabled then
        disablePlayerESP()
    end
    
    targetPlayer = findPlayerByName(username)
    
    if not targetPlayer then
        Rayfield:Notify({ 
            Title = "Player ESP", 
            Content = "Player '" .. username .. "' not found!", 
            Duration = 3 
        })
        return false
    end
    
    espEnabled = true
    
    -- Wait for target player's character
    if targetPlayer.Character then
        createCheckmark(targetPlayer.Character)
        createLineToPlayer()
    end
    
    -- Listen for character changes
    local characterAddedConnection
    characterAddedConnection = targetPlayer.CharacterAdded:Connect(function(newChar)
        wait(1) -- Wait for character to load
        createCheckmark(newChar)
        createLineToPlayer()
    end)
    
    -- Update line and distance continuously
    lineConnection = RunService.Heartbeat:Connect(updateLineAndDistance)
    
    Rayfield:Notify({ 
        Title = "Player ESP", 
        Content = "Now tracking " .. targetPlayer.Name, 
        Duration = 3 
    })
    
    return true
end

local function disablePlayerESP()
    espEnabled = false
    targetPlayer = nil
    
    if lineConnection then
        lineConnection:Disconnect()
        lineConnection = nil
    end
    
    -- Clean up all ESP objects
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    
    espObjects = {}
    
    Rayfield:Notify({ 
        Title = "Player ESP", 
        Content = "Player tracking disabled", 
        Duration = 2 
    })
end

-- ===== ANTI-COLLISION (NOCLIP) =====
local function toggleNoclip(value)
    noclipEnabled = value
    if value then
        noclipConnection = RunService.Heartbeat:Connect(function()
            if character and noclipEnabled then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        Rayfield:Notify({ Title = "Noclip", Content = "Anti-collision enabled.", Duration = 2 })
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        Rayfield:Notify({ Title = "Noclip", Content = "Anti-collision disabled.", Duration = 2 })
    end
end

-- ===== FLY FUNCTION (WORKS ON MOBILE) =====
local function toggleFly(value)
    flyEnabled = value
    if value then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyGyro = Instance.new("BodyGyro")
        
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        
        bodyVelocity.Parent = humanoidRootPart
        bodyGyro.Parent = humanoidRootPart
        
        local flyConnection
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not character or not bodyVelocity or not bodyGyro then
                flyConnection:Disconnect()
                return
            end
            
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
            
            local moveDirection = Vector3.new()
            
            if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
                local moveVector = UserInputService:GetMoveVector()
                moveDirection = (workspace.CurrentCamera.CFrame:VectorToWorldSpace(moveVector))
            else
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
            end
            
            bodyVelocity.Velocity = moveDirection * 50
        end)
        
        Rayfield:Notify({ Title = "Fly", Content = "Fly mode enabled. Use movement keys/joystick.", Duration = 4 })
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        Rayfield:Notify({ Title = "Fly", Content = "Fly mode disabled.", Duration = 2 })
    end
end

-- ===== SUPER JUMP =====
local function toggleSuperJump(value)
    superJumpEnabled = value
    if value then
        humanoid.JumpPower = 100
        Rayfield:Notify({ Title = "Super Jump", Content = "Jump power set to 100.", Duration = 2 })
    else
        humanoid.JumpPower = 50
        Rayfield:Notify({ Title = "Super Jump", Content = "Jump power set to normal.", Duration = 2 })
    end
end

-- ===== INFINITE JUMP =====
local function toggleInfiniteJump(value)
    infiniteJumpEnabled = value
    if value then
        Rayfield:Notify({ Title = "Infinite Jump", Content = "Infinite jump enabled.", Duration = 2 })
    else
        Rayfield:Notify({ Title = "Infinite Jump", Content = "Infinite jump disabled.", Duration = 2 })
    end
end

-- Connect the infinite jump handler
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ===== CREATE UI ELEMENTS =====

-- Speed Slider
MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        humanoid.WalkSpeed = Value
    end,
})

-- Toggle for Fly
MainTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = toggleFly,
})

-- Toggle for Super Jump
MainTab:CreateToggle({
    Name = "Super Jump",
    CurrentValue = false,
    Flag = "SuperJumpToggle",
    Callback = toggleSuperJump,
})

-- Toggle for Infinite Jump
MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = toggleInfiniteJump,
})

-- Toggle for Anti-Collision (Noclip)
MainTab:CreateToggle({
    Name = "Anti-Collision",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = toggleNoclip,
})

-- ===== PLAYER ESP UI ELEMENTS =====

local currentPlayerInput = ""

-- Player name input
PlayerTab:CreateInput({
    Name = "Player Username",
    PlaceholderText = "Enter username",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        currentPlayerInput = Text
    end,
})

-- Button to enable ESP for player
PlayerTab:CreateButton({
    Name = "Track Player",
    Callback = function()
        if currentPlayerInput and currentPlayerInput ~= "" then
            enablePlayerESP(currentPlayerInput)
        else
            Rayfield:Notify({ 
                Title = "Player ESP", 
                Content = "Please enter a username first!", 
                Duration = 3 
            })
        end
    end,
})

-- Button to disable ESP
PlayerTab:CreateButton({
    Name = "Stop Tracking",
    Callback = function()
        disablePlayerESP()
    end,
})

-- Toggle for auto-refresh ESP (in case player respawns)
PlayerTab:CreateToggle({
    Name = "Auto Refresh ESP",
    CurrentValue = false,
    Flag = "AutoRefreshESP",
    Callback = function(Value)
        if Value and espEnabled and targetPlayer then
            -- Auto-refresh logic can be added here
            Rayfield:Notify({ 
                Title = "Auto Refresh", 
                Content = "ESP will auto-refresh on player respawn", 
                Duration = 2 
            })
        end
    end,
})

-- Player list for quick selection
local playerDropdown = PlayerTab:CreateDropdown({
    Name = "Quick Player Select",
    Options = {},
    CurrentOption = "",
    Flag = "PlayerDropdown",
    Callback = function(Option)
        if Option and Option ~= "" then
            currentPlayerInput = Option
            enablePlayerESP(Option)
        end
    end,
})

-- Function to update player dropdown
local function updatePlayerDropdown()
    local playerNames = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(playerNames, plr.Name)
        end
    end
    playerDropdown:Refresh(playerNames, true) -- true to clear current selection
end

-- Update player list when players join/leave
Players.PlayerAdded:Connect(updatePlayerDropdown)
Players.PlayerRemoving:Connect(updatePlayerDropdown)
updatePlayerDropdown() -- Initial update

-- Button to reset character state
MainTab:CreateButton({
    Name = "Reset All Features",
    Callback = function()
        toggleFly(false)
        toggleNoclip(false)
        toggleSuperJump(false)
        toggleInfiniteJump(false)
        disablePlayerESP()
        humanoid.WalkSpeed = 16
        
        Rayfield:Notify({ Title = "Reset", Content = "All features have been reset to default.", Duration = 3 })
    end,
})

-- Handle character respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    repeat RunService.Heartbeat:Wait() until character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid")
    
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Reset features on respawn
    toggleFly(false)
    toggleNoclip(false)
    toggleSuperJump(false)
    toggleInfiniteJump(false)
    humanoid.WalkSpeed = 16
    
    -- Recreate line if ESP is active
    if espEnabled and targetPlayer then
        wait(2) -- Wait for character to fully load
        createLineToPlayer()
    end
end)

Rayfield:Notify({ Title = "Menu Loaded", Content = "Modern Menu with Player ESP has been successfully loaded!", Duration = 5 })
print("Modern Menu with Player ESP loaded successfully!")
