-- SHOX Menu - Enhanced with Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
    Name = "🔮 SHOX MENU",
    LoadingTitle = "Loading SHOX Menu...",
    LoadingSubtitle = "Advanced Features Loaded",
    ConfigurationSaving = { Enabled = true, FolderName = "SHOXMenu", FileName = "Settings" },
    Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
    KeySystem = false,
    ToggleUIKeybind = "K"
})

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
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
local espEnabled = false

-- Feature objects
local bodyVelocity, bodyGyro
local noclipConnection
local flyConnection
local espObjects = {}

-- ===== IMPROVED FLY USING SUPER JUMP =====
local function toggleFly(value)
    flyEnabled = value
    if value then
        -- Create physics objects for flying
        bodyVelocity = Instance.new("BodyVelocity")
        bodyGyro = Instance.new("BodyGyro")
        
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        
        bodyVelocity.Parent = humanoidRootPart
        bodyGyro.Parent = humanoidRootPart
        
        -- Main fly loop
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not character or not bodyVelocity or not bodyGyro then
                return
            end
            
            -- Set the gyro to match the camera's orientation
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
            
            -- Get move direction (works for both PC and mobile)
            local moveDirection = Vector3.new()
            
            if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
                local moveVector = UserInputService:GetMoveVector()
                moveDirection = (workspace.CurrentCamera.CFrame:VectorToWorldSpace(moveVector))
            else
                -- PC Controls
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
                -- Ascend/Descend
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection + Vector3.new(0, -1, 0)
                end
            end
            
            -- Apply velocity
            bodyVelocity.Velocity = moveDirection * 50
        end)
        
        Rayfield:Notify({ 
            Title = "Fly Mode", 
            Content = "Fly enabled! Use WASD + Space/Control to fly.", 
            Duration = 4 
        })
    else
        -- Clean up fly objects
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        Rayfield:Notify({ Title = "Fly Mode", Content = "Fly disabled.", Duration = 2 })
    end
end

-- ===== SUPER JUMP WITH POWER SELECTION =====
local jumpPower = 100
local function toggleSuperJump(value)
    superJumpEnabled = value
    if value then
        humanoid.JumpPower = jumpPower
        Rayfield:Notify({ 
            Title = "Super Jump", 
            Content = "Jump power set to " .. jumpPower, 
            Duration = 2 
        })
    else
        humanoid.JumpPower = 50
        Rayfield:Notify({ Title = "Super Jump", Content = "Jump power set to normal.", Duration = 2 })
    end
end

-- ===== IMPROVED PLAYER ESP =====
local function createESP(player)
    if not player.Character then return end
    
    -- Remove existing ESP objects
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            if obj then obj:Remove() end
        end
    end
    
    espObjects[player] = {}
    
    -- Create highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "SHOX_ESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character
    
    -- Create billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SHOX_ESP_GUI"
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.AlwaysOnTop = true
    billboard.Enabled = true
    
    local head = player.Character:FindFirstChild("Head")
    if head then
        billboard.Adornee = head
        billboard.Parent = head
        
        -- Name label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = billboard
        
        -- Distance label
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "Distance"
        distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
        distanceLabel.Position = UDim2.new(0, 0, 0.3, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distanceLabel.TextSize = 12
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.Parent = billboard
        
        -- Health label
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Name = "Health"
        healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.6, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        healthLabel.TextSize = 12
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.Parent = billboard
    end
    
    table.insert(espObjects[player], highlight)
    table.insert(espObjects[player], billboard)
    
    -- Update labels continuously
    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        if not espEnabled or not player.Character or not character then
            if updateConnection then updateConnection:Disconnect() end
            return
        end
        
        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and humanoidRootPart then
            local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
            if billboard and billboard:FindFirstChild("Distance") then
                billboard.Distance.Text = string.format("Distance: %.1f", distance)
            end
            
            -- Update health
            local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if targetHumanoid and billboard and billboard:FindFirstChild("Health") then
                billboard.Health.Text = string.format("Health: %d/%d", targetHumanoid.Health, targetHumanoid.MaxHealth)
            end
        end
    end)
    
    table.insert(espObjects[player], updateConnection)
end

local function enableESP()
    espEnabled = true
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if player.Character then
                createESP(player)
            end
            player.CharacterAdded:Connect(function(char)
                wait(1)
                if espEnabled then
                    createESP(player)
                end
            end)
        end
    end
    
    -- Listen for new players
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            wait(1)
            if espEnabled then
                createESP(player)
            end
        end)
    end)
    
    Rayfield:Notify({ Title = "ESP", Content = "Player ESP enabled!", Duration = 3 })
end

local function disableESP()
    espEnabled = false
    for player, objects in pairs(espObjects) do
        for _, obj in pairs(objects) do
            if obj then
                if typeof(obj) == "RBXScriptConnection" then
                    obj:Disconnect()
                else
                    obj:Destroy()
                end
            end
        end
    end
    espObjects = {}
    Rayfield:Notify({ Title = "ESP", Content = "Player ESP disabled!", Duration = 3 })
end

-- ===== TELEPORT TO PLAYER =====
local function teleportToPlayer(username)
    local targetPlayer = nil
    username = string.lower(username)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if string.lower(player.Name) == username or string.lower(player.DisplayName) == username then
                targetPlayer = player
                break
            end
        end
    end
    
    if targetPlayer and targetPlayer.Character then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            humanoidRootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
            Rayfield:Notify({ 
                Title = "Teleport", 
                Content = "Teleported to " .. targetPlayer.Name, 
                Duration = 3 
            })
            return true
        end
    else
        Rayfield:Notify({ 
            Title = "Teleport", 
            Content = "Player '" .. username .. "' not found!", 
            Duration = 3 
        })
        return false
    end
end

-- ===== SERVER HOPPING =====
local function serverHop()
    local placeId = game.PlaceId
    local servers = {}
    
    Rayfield:Notify({ 
        Title = "Server Hop", 
        Content = "Finding empty server...", 
        Duration = 5 
    })
    
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < 5 and server.id ~= game.JobId then
                table.insert(servers, server)
            end
        end
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(placeId, randomServer.id)
        else
            Rayfield:Notify({ 
                Title = "Server Hop", 
                Content = "No empty servers found!", 
                Duration = 3 
            })
        end
    else
        Rayfield:Notify({ 
            Title = "Server Hop", 
            Content = "Failed to find servers!", 
            Duration = 3 
        })
    end
end

-- ===== GAME FILES VIEWER =====
local function listGameFiles()
    local files = {}
    
    -- List all instances in the game
    local function scanInstance(instance, depth)
        if depth > 3 then return end -- Limit depth to avoid performance issues
        
        local fileInfo = {
            Name = instance.Name,
            ClassName = instance.ClassName,
            FullName = instance:GetFullName(),
            Children = {}
        }
        
        for _, child in pairs(instance:GetChildren()) do
            table.insert(fileInfo.Children, scanInstance(child, depth + 1))
        end
        
        return fileInfo
    end
    
    -- Scan important services
    local services = {
        "Workspace", "Players", "Lighting", "ReplicatedStorage", 
        "ServerStorage", "StarterPack", "StarterPlayer", "StarterGui"
    }
    
    for _, serviceName in pairs(services) do
        local service = game:GetService(serviceName)
        if service then
            table.insert(files, scanInstance(service, 0))
        end
    end
    
    return files
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

-- ===== CREATE TABS =====
local MainTab = Window:CreateTab("Player Mods", "settings")
local ESPTab = Window:CreateTab("Player ESP", "users")
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local ServerTab = Window:CreateTab("Server", "server")
local FilesTab = Window:CreateTab("Game Files", "file-text")

-- ===== MAIN TAB =====
MainTab:CreateSection("Movement")

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

MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 10,
    Suffix = "Power",
    CurrentValue = 100,
    Flag = "JumpPower",
    Callback = function(Value)
        jumpPower = Value
        if superJumpEnabled then
            humanoid.JumpPower = Value
        end
    end,
})

MainTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = toggleFly,
})

MainTab:CreateToggle({
    Name = "Super Jump",
    CurrentValue = false,
    Flag = "SuperJumpToggle",
    Callback = toggleSuperJump,
})

MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = toggleInfiniteJump,
})

MainTab:CreateToggle({
    Name = "Anti-Collision (Noclip)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = toggleNoclip,
})

-- ===== ESP TAB =====
ESPTab:CreateSection("Player ESP")

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(value)
        if value then
            enableESP()
        else
            disableESP()
        end
    end,
})

ESPTab:CreateDropdown({
    Name = "Quick Player Select",
    Options = {},
    CurrentOption = "",
    Flag = "PlayerDropdown",
    Callback = function(Option)
        if Option and Option ~= "" then
            -- This can be used for quick ESP targeting
            Rayfield:Notify({ 
                Title = "ESP Target", 
                Content = "Now highlighting: " .. Option, 
                Duration = 3 
            })
        end
    end,
})

-- Function to update player dropdown
local function updatePlayerDropdown()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    -- This would need to be refreshed in the actual dropdown
end

-- ===== TELEPORT TAB =====
local teleportInput = ""
TeleportTab:CreateSection("Teleport to Player")

TeleportTab:CreateInput({
    Name = "Player Username",
    PlaceholderText = "Enter username",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        teleportInput = Text
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if teleportInput and teleportInput ~= "" then
            teleportToPlayer(teleportInput)
        else
            Rayfield:Notify({ 
                Title = "Teleport", 
                Content = "Please enter a username first!", 
                Duration = 3 
            })
        end
    end,
})

TeleportTab:CreateSection("Quick Teleport")

-- Create quick teleport buttons for online players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        TeleportTab:CreateButton({
            Name = "TP to " .. player.Name,
            Callback = function()
                teleportToPlayer(player.Name)
            end,
        })
    end
end

-- ===== SERVER TAB =====
ServerTab:CreateSection("Server Management")

ServerTab:CreateButton({
    Name = "Server Hop (Find Empty)",
    Callback = serverHop,
})

ServerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId)
    end,
})

ServerTab:CreateLabel("Current Players: " .. #Players:GetPlayers())

-- ===== GAME FILES TAB =====
local filesContent = ""
FilesTab:CreateSection("Game Files Explorer")

FilesTab:CreateButton({
    Name = "Scan Game Files",
    Callback = function()
        local files = listGameFiles()
        filesContent = HttpService:JSONEncode(files)
        
        Rayfield:Notify({ 
            Title = "File Scan", 
            Content = "Game files scanned successfully!", 
            Duration = 3 
        })
    end,
})

FilesTab:CreateInput({
    Name = "File Content",
    PlaceholderText = "File content will appear here after scan",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        -- This can be used to edit file content
    end,
})

FilesTab:CreateButton({
    Name = "View Client Scripts",
    Callback = function()
        local scripts = {}
        
        -- Find local scripts
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                table.insert(scripts, {
                    Name = obj.Name,
                    Path = obj:GetFullName(),
                    Class = obj.ClassName
                })
            end
        end
        
        filesContent = HttpService:JSONEncode(scripts)
        Rayfield:Notify({ 
            Title = "Scripts", 
            Content = "Found " .. #scripts .. " client scripts!", 
            Duration = 3 
        })
    end,
})

-- ===== CHARACTER RESPAWN HANDLING =====
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
    
    -- Re-enable ESP if it was active
    if espEnabled then
        wait(2)
        enableESP()
    end
end)

-- Initial setup
humanoid.WalkSpeed = 16

Rayfield:Notify({ 
    Title = "SHOX Menu Loaded", 
    Content = "Advanced features ready! Use K to toggle menu.", 
    Duration = 6 
})

print("🔮 SHOX Menu loaded successfully with advanced features!")
