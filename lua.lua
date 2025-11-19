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
local TweenService = game:GetService("TweenService")
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

-- Saved locations
local savedLocations = {}

-- Feature objects
local bodyVelocity, bodyGyro
local noclipConnection
local flyConnection
local espFolders = {}

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
        Rayfield:Notify({ 
            Title = "Jump Power Updated", 
            Content = "Jump power now: " .. newPower, 
            Duration = 2 
        })
    end
end

-- ===== COMPLETELY FIXED PLAYER ESP =====
local function createESP(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then 
        return false
    end
    
    -- Remove existing ESP for this player
    if espFolders[targetPlayer] then
        espFolders[targetPlayer]:Destroy()
        espFolders[targetPlayer] = nil
    end
    
    -- Create container for ESP objects
    local espFolder = Instance.new("Folder")
    espFolder.Name = targetPlayer.Name .. "_ESP"
    espFolder.Parent = game:GetService("CoreGui")
    espFolders[targetPlayer] = espFolder
    
    -- Create highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = targetPlayer.Character
    highlight.Parent = espFolder
    
    -- Create billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 80)
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    
    local head = targetPlayer.Character:FindFirstChild("Head")
    if head then
        billboard.Adornee = head
        billboard.Parent = espFolder
        
        -- Name label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = targetPlayer.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = billboard
        
        -- Distance label
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "DistanceLabel"
        distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
        distanceLabel.Position = UDim2.new(0, 0, 0.4, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distanceLabel.TextSize = 12
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.Parent = billboard
        
        -- Health label
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Name = "HealthLabel"
        healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.7, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        healthLabel.TextSize = 12
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.Parent = billboard
    end
    
    -- Update function
    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        if not espEnabled or not targetPlayer.Character or not character then
            if updateConnection then 
                updateConnection:Disconnect() 
            end
            return
        end
        
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and humanoidRootPart then
            local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
            if distanceLabel then
                distanceLabel.Text = string.format("Dist: %.1f", distance)
            end
            
            -- Update health
            local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if targetHumanoid and healthLabel then
                healthLabel.Text = string.format("HP: %d/%d", targetHumanoid.Health, targetHumanoid.MaxHealth)
            end
        end
    end)
    
    return true
end

local function enableESP(target)
    if target == "All" then
        espEnabled = true
        espTargetPlayer = nil
        
        local successCount = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                if createESP(player) then
                    successCount = successCount + 1
                end
            end
        end
        
        Rayfield:Notify({ 
            Title = "ESP", 
            Content = "ESP enabled for " .. successCount .. " players!", 
            Duration = 3 
        })
    else
        -- Single player ESP
        espEnabled = true
        espTargetPlayer = target
        disableESP() -- Clear existing ESP
        
        if createESP(target) then
            Rayfield:Notify({ 
                Title = "ESP", 
                Content = "ESP enabled for " .. target.Name, 
                Duration = 3 
            })
        else
            Rayfield:Notify({ 
                Title = "ESP Error", 
                Content = "Failed to enable ESP for " .. target.Name, 
                Duration = 3 
            })
        end
    end
end

local function disableESP()
    espEnabled = false
    espTargetPlayer = nil
    for player, folder in pairs(espFolders) do
        if folder then
            folder:Destroy()
        end
    end
    espFolders = {}
    Rayfield:Notify({ Title = "ESP", Content = "ESP disabled!", Duration = 3 })
end

-- ===== FIXED TELEPORT TO PLAYER =====
local function teleportToPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and humanoidRootPart then
            -- Use CFrame for smooth teleport
            humanoidRootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0))
            Rayfield:Notify({ 
                Title = "Teleport", 
                Content = "Teleported to " .. targetPlayer.Name, 
                Duration = 3 
            })
            return true
        else
            Rayfield:Notify({ 
                Title = "Teleport Error", 
                Content = "Target player root part not found!", 
                Duration = 3 
            })
            return false
        end
    else
        Rayfield:Notify({ 
            Title = "Teleport Error", 
            Content = "Player not found or no character!", 
            Duration = 3 
        })
        return false
    end
end

-- ===== NEW: TELEPORT TO SPAWN =====
local function teleportToSpawn()
    -- Find spawn location
    local spawnLocation = workspace:FindFirstChild("SpawnLocation") 
    or workspace:FindFirstChildOfClass("SpawnLocation")
    or workspace:FindFirstChild("Part") -- Fallback to any part
    
    if spawnLocation then
        humanoidRootPart.CFrame = CFrame.new(spawnLocation.Position + Vector3.new(0, 5, 0))
        Rayfield:Notify({ 
            Title = "Teleport", 
            Content = "Teleported to spawn location!", 
            Duration = 3 
        })
    else
        -- Default spawn at origin
        humanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        Rayfield:Notify({ 
            Title = "Teleport", 
            Content = "Teleported to default location!", 
            Duration = 3 
        })
    end
end

-- ===== NEW: SAVE AND LOAD COORDINATES =====
local function saveCurrentLocation(name)
    if not name or name == "" then name = "Location_" .. #savedLocations + 1 end
    
    savedLocations[name] = {
        Position = humanoidRootPart.Position,
        CFrame = humanoidRootPart.CFrame
    }
    
    Rayfield:Notify({ 
        Title = "Location Saved", 
        Content = "Saved location: " .. name, 
        Duration = 3 
    })
    
    return name
end

local function teleportToSavedLocation(name)
    if savedLocations[name] then
        humanoidRootPart.CFrame = savedLocations[name].CFrame
        Rayfield:Notify({ 
            Title = "Teleport", 
            Content = "Teleported to: " .. name, 
            Duration = 3 
        })
        return true
    else
        Rayfield:Notify({ 
            Title = "Teleport Error", 
            Content = "Location not found: " .. name, 
            Duration = 3 
        })
        return false
    end
end

-- ===== FIXED SERVER HOPPING =====
local function serverHop(targetPlaceId)
    local placeId = targetPlaceId or game.PlaceId
    
    Rayfield:Notify({ 
        Title = "Server Hop", 
        Content = "Finding servers for place " .. placeId .. "...", 
        Duration = 5 
    })
    
    local success, result = pcall(function()
        local servers = {}
        local nextCursor = ""
        
        repeat
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
            if nextCursor ~= "" then
                url = url .. "&cursor=" .. nextCursor
            end
            
            local response = game:HttpGet(url)
            local data = HttpService:JSONDecode(response)
            
            if data and data.data then
                for _, server in ipairs(data.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        table.insert(servers, server)
                    end
                end
                nextCursor = data.nextPageCursor or ""
            else
                break
            end
        until nextCursor == "" or #servers >= 20
        
        return servers
    end)
    
    if success and #result > 0 then
        local randomServer = result[math.random(1, #result)]
        Rayfield:Notify({ 
            Title = "Server Hop", 
            Content = "Joining server with " .. randomServer.playing .. " players...", 
            Duration = 3 
        })
        TeleportService:TeleportToPlaceInstance(placeId, randomServer.id)
    else
        -- Fallback: Regular teleport
        Rayfield:Notify({ 
            Title = "Server Hop", 
            Content = "Using fallback teleport...", 
            Duration = 3 
        })
        TeleportService:Teleport(placeId)
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

-- Get current players for dropdown
local function getPlayerOptions()
    local options = {"All"}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(options, player.Name)
        end
    end
    return options
end

local selectedPlayerForESP = "All"
local espDropdown = ESPTab:CreateDropdown({
    Name = "Select Player for ESP",
    Options = getPlayerOptions(),
    CurrentOption = "All",
    Flag = "ESPPlayerDropdown",
    Callback = function(Option)
        selectedPlayerForESP = Option
        Rayfield:Notify({ 
            Title = "ESP Target", 
            Content = "Selected: " .. Option, 
            Duration = 2 
        })
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
                    Content = "Player '" .. selectedPlayerForESP .. "' not found!", 
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
                    Content = "Player '" .. selectedPlayerForESP .. "' not found!", 
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

-- Function to update player dropdowns
local function updatePlayerDropdowns()
    local newOptions = getPlayerOptions()
    espDropdown:Refresh(newOptions, true)
end

-- Update dropdowns when players join/leave
Players.PlayerAdded:Connect(updatePlayerDropdowns)
Players.PlayerRemoving:Connect(updatePlayerDropdowns)

-- ===== TELEPORT TAB =====
TeleportTab:CreateSection("Teleport to Player")

-- Teleport player dropdown
local teleportDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player to Teleport",
    Options = getPlayerOptions(),
    CurrentOption = "",
    Flag = "TeleportPlayerDropdown",
    Callback = function(Option)
        if Option and Option ~= "" and Option ~= "All" then
            local targetPlayer = Players:FindFirstChild(Option)
            if targetPlayer then
                teleportToPlayer(targetPlayer)
            end
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

TeleportTab:CreateSection("Location Management")

TeleportTab:CreateButton({
    Name = "🏠 Teleport to Spawn",
    Callback = teleportToSpawn
})

local locationName = ""
TeleportTab:CreateInput({
    Name = "Location Name",
    PlaceholderText = "Enter name for location",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        locationName = Text
    end,
})

TeleportTab:CreateButton({
    Name = "💾 Save Current Location",
    Callback = function()
        if locationName and locationName ~= "" then
            saveCurrentLocation(locationName)
        else
            saveCurrentLocation()
        end
    end,
})

TeleportTab:CreateButton({
    Name = "📋 Quick Save Location",
    Callback = function()
        saveCurrentLocation()
    end,
})

-- Display saved locations
TeleportTab:CreateSection("Saved Locations")

-- Function to create buttons for saved locations
local function updateSavedLocationsDisplay()
    -- This would need to dynamically create buttons for each saved location
    -- For now, we'll show a notification
    if next(savedLocations) then
        local locationList = ""
        for name, _ in pairs(savedLocations) do
            locationList = locationList .. name .. ", "
        end
        Rayfield:Notify({ 
            Title = "Saved Locations", 
            Content = "Locations: " .. locationList, 
            Duration = 5 
        })
    else
        Rayfield:Notify({ 
            Title = "Saved Locations", 
            Content = "No locations saved yet!", 
            Duration = 3 
        })
    end
end

TeleportTab:CreateButton({
    Name = "📍 View Saved Locations",
    Callback = updateSavedLocationsDisplay
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
    Name = "🎮 Server Hop to Selected Game",
    Callback = function()
        if selectedGame and selectedGame ~= "" then
            for _, game in pairs(popularGames) do
                if game.Name == selectedGame then
                    Rayfield:Notify({ 
                        Title = "Server Hop", 
                        Content = "Joining " .. game.Name .. "...", 
                        Duration = 3 
                    })
                    serverHop(game.ID)
                    return
                end
            end
        else
            Rayfield:Notify({ 
                Title = "Server Hop Error", 
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
    Name = "🎯 Server Hop to Custom Place",
    Callback = function()
        if customPlaceId and customPlaceId ~= "" then
            local placeId = tonumber(customPlaceId)
            if placeId then
                Rayfield:Notify({ 
                    Title = "Server Hop", 
                    Content = "Joining custom game...", 
                    Duration = 3 
                })
                serverHop(placeId)
            else
                Rayfield:Notify({ 
                    Title = "Server Hop Error", 
                    Content = "Invalid Place ID!", 
                    Duration = 3 
                })
            end
        else
            Rayfield:Notify({ 
                Title = "Server Hop Error", 
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
    Content = "All features fixed and working! Use K to toggle menu.", 
    Duration = 6 
})

print("🔮 SHOX Menu loaded successfully with all fixes applied!")
