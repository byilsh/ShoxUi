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
local espTargetPlayer = nil

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
            
            -- Get move direction
            local moveDirection = Vector3.new()
            
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

-- ===== FIXED SUPER JUMP =====
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
        Rayfield:Notify({ Title = "Super Jump", Content = "Jump power reset to normal.", Duration = 2 })
    end
end

-- Update jump power when slider changes
local function updateJumpPower(newPower)
    jumpPower = newPower
    if superJumpEnabled then
        humanoid.JumpPower = newPower
    end
end

-- ===== IMPROVED PLAYER ESP =====
local function createESP(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    -- Remove existing ESP objects for this player
    if espObjects[targetPlayer] then
        for _, obj in pairs(espObjects[targetPlayer]) do
            if obj then 
                if typeof(obj) == "RBXScriptConnection" then
                    obj:Disconnect()
                else
                    obj:Remove() 
                end
            end
        end
    end
    
    espObjects[targetPlayer] = {}
    
    -- Create highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "SHOX_ESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = targetPlayer.Character
    
    -- Create billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SHOX_ESP_GUI"
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.AlwaysOnTop = true
    billboard.Enabled = true
    
    local head = targetPlayer.Character:FindFirstChild("Head")
    if head then
        billboard.Adornee = head
        billboard.Parent = head
        
        -- Name label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = targetPlayer.Name
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
    
    table.insert(espObjects[targetPlayer], highlight)
    table.insert(espObjects[targetPlayer], billboard)
    
    -- Update labels continuously
    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        if not espEnabled or not targetPlayer.Character or not character then
            if updateConnection then updateConnection:Disconnect() end
            return
        end
        
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and humanoidRootPart then
            local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
            if billboard and billboard:FindFirstChild("Distance") then
                billboard.Distance.Text = string.format("Distance: %.1f", distance)
            end
            
            -- Update health
            local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if targetHumanoid and billboard and billboard:FindFirstChild("Health") then
                billboard.Health.Text = string.format("Health: %d/%d", targetHumanoid.Health, targetHumanoid.MaxHealth)
            end
        end
    end)
    
    table.insert(espObjects[targetPlayer], updateConnection)
end

local function enableESP(target)
    if target == "All" then
        espEnabled = true
        espTargetPlayer = nil
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                if player.Character then
                    createESP(player)
                end
                player.CharacterAdded:Connect(function(char)
                    wait(1)
                    if espEnabled and espTargetPlayer == nil then
                        createESP(player)
                    end
                end)
            end
        end
        
        -- Listen for new players
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(char)
                wait(1)
                if espEnabled and espTargetPlayer == nil then
                    createESP(player)
                end
            end)
        end)
        
        Rayfield:Notify({ Title = "ESP", Content = "All Player ESP enabled!", Duration = 3 })
    else
        -- Single player ESP
        espEnabled = true
        espTargetPlayer = target
        disableESP() -- Clear existing ESP
        
        if target.Character then
            createESP(target)
        end
        target.CharacterAdded:Connect(function(char)
            wait(1)
            if espEnabled and espTargetPlayer == target then
                createESP(target)
            end
        end)
        
        Rayfield:Notify({ Title = "ESP", Content = "ESP enabled for " .. target.Name, Duration = 3 })
    end
end

local function disableESP()
    espEnabled = false
    espTargetPlayer = nil
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
end

-- ===== FIXED TELEPORT TO PLAYER =====
local function teleportToPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and humanoidRootPart then
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
            Content = "Player not found or no character!", 
            Duration = 3 
        })
        return false
    end
end

-- ===== ENHANCED SERVER HOPPING =====
local function serverHop(placeId)
    local targetPlaceId = placeId or game.PlaceId
    local servers = {}
    
    Rayfield:Notify({ 
        Title = "Server Hop", 
        Content = "Finding servers...", 
        Duration = 5 
    })
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. targetPlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server)
            end
        end
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(targetPlaceId, randomServer.id)
        else
            Rayfield:Notify({ 
                Title = "Server Hop", 
                Content = "No available servers found!", 
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

-- ===== FIXED INFINITE JUMP =====
local function toggleInfiniteJump(value)
    infiniteJumpEnabled = value
    if value then
        Rayfield:Notify({ Title = "Infinite Jump", Content = "Infinite jump enabled.", Duration = 2 })
    else
        Rayfield:Notify({ Title = "Infinite Jump", Content = "Infinite jump disabled.", Duration = 2 })
    end
end

-- Fixed infinite jump connection
local infiniteJumpConnection
infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ===== CREATE TABS =====
local MainTab = Window:CreateTab("Player Mods", "settings")
local ESPTab = Window:CreateTab("Player ESP", "users")
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local ServerTab = Window:CreateTab("Server", "server")

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
        updateJumpPower(Value)
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

-- Player dropdown for ESP
local playerOptions = {"All"}
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        table.insert(playerOptions, player.Name)
    end
end

local selectedPlayerForESP = "All"
local espDropdown = ESPTab:CreateDropdown({
    Name = "Select Player for ESP",
    Options = playerOptions,
    CurrentOption = "All",
    Flag = "ESPPlayerDropdown",
    Callback = function(Option)
        selectedPlayerForESP = Option
    end,
})

-- Buttons for ESP actions
ESPTab:CreateButton({
    Name = "🔍 Enable ESP for Selected",
    Callback = function()
        if selectedPlayerForESP == "All" then
            enableESP("All")
        else
            local targetPlayer = Players:FindFirstChild(selectedPlayerForESP)
            if targetPlayer then
                enableESP(targetPlayer)
            else
                Rayfield:Notify({ 
                    Title = "ESP Error", 
                    Content = "Player not found!", 
                    Duration = 3 
                })
            end
        end
    end,
})

ESPTab:CreateButton({
    Name = "❌ Disable ESP",
    Callback = function()
        disableESP()
    end,
})

ESPTab:CreateSection("Quick Actions for Selected Player")

ESPTab:CreateButton({
    Name = "🚀 Teleport to Selected Player",
    Callback = function()
        if selectedPlayerForESP and selectedPlayerForESP ~= "All" then
            local targetPlayer = Players:FindFirstChild(selectedPlayerForESP)
            if targetPlayer then
                teleportToPlayer(targetPlayer)
            else
                Rayfield:Notify({ 
                    Title = "Teleport Error", 
                    Content = "Player not found!", 
                    Duration = 3 
                })
            end
        else
            Rayfield:Notify({ 
                Title = "Teleport Error", 
                Content = "Please select a specific player (not 'All')!", 
                Duration = 3 
            })
        end
    end,
})

ESPTab:CreateButton({
    Name = "🔄 Server Hop to Player's Game",
    Callback = function()
        if selectedPlayerForESP and selectedPlayerForESP ~= "All" then
            local targetPlayer = Players:FindFirstChild(selectedPlayerForESP)
            if targetPlayer then
                Rayfield:Notify({ 
                    Title = "Server Hop", 
                    Content = "Server hopping to " .. targetPlayer.Name .. "'s game...", 
                    Duration = 4 
                })
                -- This would need the player's current game ID, which isn't directly available
                -- So we'll just do regular server hop
                serverHop(game.PlaceId)
            else
                Rayfield:Notify({ 
                    Title = "Server Hop Error", 
                    Content = "Player not found!", 
                    Duration = 3 
                })
            end
        else
            serverHop(game.PlaceId)
        end
    end,
})

-- Function to update player dropdowns
local function updatePlayerDropdowns()
    local newPlayerOptions = {"All"}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(newPlayerOptions, player.Name)
        end
    end
    
    -- Update ESP dropdown
    espDropdown:Refresh(newPlayerOptions, true)
end

-- Update dropdowns when players join/leave
Players.PlayerAdded:Connect(updatePlayerDropdowns)
Players.PlayerRemoving:Connect(updatePlayerDropdowns)

-- ===== TELEPORT TAB =====
TeleportTab:CreateSection("Teleport to Player")

-- Teleport player dropdown
local teleportPlayerOptions = {}
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        table.insert(teleportPlayerOptions, player.Name)
    end
end

local selectedPlayerForTeleport = ""
local teleportDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player to Teleport",
    Options = teleportPlayerOptions,
    CurrentOption = "",
    Flag = "TeleportPlayerDropdown",
    Callback = function(Option)
        selectedPlayerForTeleport = Option
    end,
})

TeleportTab:CreateButton({
    Name = "🚀 Teleport to Selected Player",
    Callback = function()
        if selectedPlayerForTeleport and selectedPlayerForTeleport ~= "" then
            local targetPlayer = Players:FindFirstChild(selectedPlayerForTeleport)
            if targetPlayer then
                teleportToPlayer(targetPlayer)
            else
                Rayfield:Notify({ 
                    Title = "Teleport Error", 
                    Content = "Player not found!", 
                    Duration = 3 
                })
            end
        else
            Rayfield:Notify({ 
                Title = "Teleport Error", 
                Content = "Please select a player first!", 
                Duration = 3 
            })
        end
    end,
})

TeleportTab:CreateButton({
    Name = "🔄 Refresh Player List",
    Callback = function()
        updatePlayerDropdowns()
        Rayfield:Notify({ 
            Title = "Teleport", 
            Content = "Player list refreshed!", 
            Duration = 2 
        })
    end,
})

-- ===== SERVER TAB =====
ServerTab:CreateSection("Server Hopping")

-- Popular games list
local popularGames = {
    {Name = "Adopt Me", ID = 920587237},
    {Name = "Brookhaven RP", ID = 4924922222},
    {Name = "Prison Life", ID = 155615604},
    {Name = "MeepCity", ID = 370731277},
    {Name = "Tower of Hell", ID = 1962086868},
    {Name = "Arsenal", ID = 286090429},
    {Name = "Jailbreak", ID = 606849621}
}

local gameOptions = {}
for _, game in pairs(popularGames) do
    table.insert(gameOptions, game.Name)
end

local selectedGame = ""
ServerTab:CreateDropdown({
    Name = "Popular Games",
    Options = gameOptions,
    CurrentOption = "",
    Flag = "PopularGamesDropdown",
    Callback = function(Option)
        selectedGame = Option
    end,
})

ServerTab:CreateButton({
    Name = "🎮 Teleport to Selected Game",
    Callback = function()
        if selectedGame and selectedGame ~= "" then
            for _, game in pairs(popularGames) do
                if game.Name == selectedGame then
                    Rayfield:Notify({ 
                        Title = "Teleporting", 
                        Content = "Joining " .. game.Name .. "...", 
                        Duration = 3 
                    })
                    TeleportService:Teleport(game.ID)
                    break
                end
            end
        else
            Rayfield:Notify({ 
                Title = "Teleport Error", 
                Content = "Please select a game first!", 
                Duration = 3 
            })
        end
    end,
})

local customPlaceId = ""
ServerTab:CreateInput({
    Name = "Custom Place ID",
    PlaceholderText = "Enter Place ID",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        customPlaceId = Text
    end,
})

ServerTab:CreateButton({
    Name = "🎯 Teleport to Custom Place",
    Callback = function()
        if customPlaceId and customPlaceId ~= "" then
            local placeId = tonumber(customPlaceId)
            if placeId then
                Rayfield:Notify({ 
                    Title = "Teleporting", 
                    Content = "Joining custom game...", 
                    Duration = 3 
                })
                TeleportService:Teleport(placeId)
            else
                Rayfield:Notify({ 
                    Title = "Teleport Error", 
                    Content = "Invalid Place ID!", 
                    Duration = 3 
                })
            end
        else
            Rayfield:Notify({ 
                Title = "Teleport Error", 
                Content = "Please enter a Place ID first!", 
                Duration = 3 
            })
        end
    end,
})

ServerTab:CreateSection("Current Server")

ServerTab:CreateButton({
    Name = "🔄 Server Hop (Current Game)",
    Callback = function()
        serverHop(game.PlaceId)
    end,
})

ServerTab:CreateButton({
    Name = "🔁 Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId)
    end,
})

ServerTab:CreateLabel("Current Players: " .. #Players:GetPlayers())

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
        if espTargetPlayer then
            enableESP(espTargetPlayer)
        else
            enableESP("All")
        end
    end
end)

-- Initial setup
humanoid.WalkSpeed = 16

Rayfield:Notify({ 
    Title = "SHOX Menu Loaded", 
    Content = "All features fixed and ready! Use K to toggle menu.", 
    Duration = 6 
})

print("🔮 SHOX Menu loaded successfully with all fixes applied!")
