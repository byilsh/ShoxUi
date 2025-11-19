-- SHOX Menu - Enhanced with Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
    Name = "🔮 SHOX MENU ULTIMATE",
    LoadingTitle = "Loading SHOX Menu...",
    LoadingSubtitle = "Advanced Fly & Teleport Systems",
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

-- Feature objects
local bodyVelocity, bodyGyro
local noclipConnection
local flyConnection
local espObjects = {}

-- ===== ADVANCED FLY SYSTEM =====
local flySpeed = 50
local flyActive = false
local flyControls = {f = 0, b = 0, l = 0, r = 0}
local lastControls = {f = 0, b = 0, l = 0, r = 0}

local function updateFlySpeed(newSpeed)
    flySpeed = newSpeed
    Rayfield:Notify({
        Title = "Fly Speed",
        Content = "Fly speed set to: " .. newSpeed,
        Duration = 2
    })
end

local function toggleAdvancedFly(value)
    flyEnabled = value
    if value then
        -- Create physics objects for flying
        local rootPart = humanoidRootPart
        
        bodyVelocity = Instance.new("BodyVelocity")
        bodyGyro = Instance.new("BodyGyro")
        
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        
        bodyVelocity.Parent = rootPart
        bodyGyro.Parent = rootPart
        
        humanoid.PlatformStand = true
        flyActive = true
        
        -- Main advanced fly loop
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not character then
                return
            end
            
            bodyGyro.CFrame = workspace.CurrentCamera.CoordinateFrame
            
            if flyControls.l + flyControls.r ~= 0 or flyControls.f + flyControls.b ~= 0 then
                bodyVelocity.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (flyControls.f + flyControls.b)) + 
                                       ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(flyControls.l + flyControls.r, 
                                       (flyControls.f + flyControls.b) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * flySpeed
                lastControls = {f = flyControls.f, b = flyControls.b, l = flyControls.l, r = flyControls.r}
            elseif (flyControls.l + flyControls.r == 0 and flyControls.f + flyControls.b == 0) then
                bodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
            end
        end)
        
        -- Key handling for advanced controls
        local inputBeganConnection
        local inputEndedConnection
        
        inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                flyControls.f = 1
            elseif input.KeyCode == Enum.KeyCode.S then
                flyControls.b = -1
            elseif input.KeyCode == Enum.KeyCode.A then
                flyControls.l = -1
            elseif input.KeyCode == Enum.KeyCode.D then
                flyControls.r = 1
            elseif input.KeyCode == Enum.KeyCode.Space then
                -- Up movement
                humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            elseif input.KeyCode == Enum.KeyCode.LeftControl then
                -- Down movement
                humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, -3, 0)
            end
        end)
        
        inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                flyControls.f = 0
            elseif input.KeyCode == Enum.KeyCode.S then
                flyControls.b = 0
            elseif input.KeyCode == Enum.KeyCode.A then
                flyControls.l = 0
            elseif input.KeyCode == Enum.KeyCode.D then
                flyControls.r = 0
            end
        end)
        
        -- Store connections for cleanup
        flyControls.connections = {inputBeganConnection, inputEndedConnection}
        
        Rayfield:Notify({ 
            Title = "Advanced Fly", 
            Content = "Fly enabled! WASD to move, Space/Control for up/down", 
            Duration = 5 
        })
    else
        -- Clean up fly objects
        flyActive = false
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        
        -- Clean up input connections
        if flyControls.connections then
            for _, connection in pairs(flyControls.connections) do
                if connection then connection:Disconnect() end
            end
        end
        
        flyControls = {f = 0, b = 0, l = 0, r = 0}
        humanoid.PlatformStand = false
        
        Rayfield:Notify({ Title = "Advanced Fly", Content = "Fly disabled.", Duration = 2 })
    end
end

-- ===== FIXED JUMP POWER SYSTEM =====
local jumpPower = 100
local function updateJumpPower(newPower)
    jumpPower = newPower
    if superJumpEnabled and humanoid then
        humanoid.JumpPower = newPower
    end
    Rayfield:Notify({
        Title = "Jump Power",
        Content = "Jump power set to: " .. newPower,
        Duration = 2
    })
end

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

-- ===== WORKING PLAYER ESP =====
local function createESP(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    -- Remove existing ESP objects
    if espObjects[targetPlayer] then
        for _, obj in pairs(espObjects[targetPlayer]) do
            if obj then obj:Remove() end
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

-- ===== ENHANCED TELEPORT SYSTEM WITH SEARCH =====
local function teleportToPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == Players.LocalPlayer then
        Rayfield:Notify({
            Title = "Teleport Error",
            Content = "Invalid target player!",
            Duration = 3
        })
        return false
    end

    if targetPlayer.Character then
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
            Content = "Player '" .. targetPlayer.Name .. "' has no character!", 
            Duration = 3 
        })
        return false
    end
end

-- ===== ENHANCED SERVER HOPPING =====
local function enhancedServerHop(targetPlaceId)
    local placeId = targetPlaceId or game.PlaceId
    
    Rayfield:Notify({ 
        Title = "Server Hop", 
        Content = "Finding best server...", 
        Duration = 5 
    })
    
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"
    
    local _servers = Api..placeId.."/servers/Public?sortOrder=Asc&limit=100"
    
    local function ListServers(cursor)
        local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
        return Http:JSONDecode(Raw)
    end

    local bestServer = nil
    local lowestPlayers = math.huge
    local Next
    
    repeat
        local success, Servers = pcall(ListServers, Next)
        if success and Servers and Servers.data then
            for _, server in ipairs(Servers.data) do
                if server.playing and server.playing < lowestPlayers and server.id ~= game.JobId then
                    lowestPlayers = server.playing
                    bestServer = server
                end
            end
            Next = Servers.nextPageCursor
        else
            break
        end
    until not Next
    
    if bestServer then
        Rayfield:Notify({ 
            Title = "Server Hop", 
            Content = "Joining server with " .. bestServer.playing .. " players", 
            Duration = 3 
        })
        TPS:TeleportToPlaceInstance(placeId, bestServer.id, player)
    else
        Rayfield:Notify({ 
            Title = "Server Hop", 
            Content = "No servers found, using fallback", 
            Duration = 3 
        })
        TPS:Teleport(placeId)
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

-- ===== MAIN TAB =====
MainTab:CreateSection("Movement")

MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
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
    Callback = updateJumpPower,
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = 50,
    Callback = updateFlySpeed,
})

MainTab:CreateToggle({
    Name = "Advanced Fly Mode",
    CurrentValue = false,
    Callback = toggleAdvancedFly,
})

MainTab:CreateToggle({
    Name = "Super Jump",
    CurrentValue = false,
    Callback = toggleSuperJump,
})

MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = toggleInfiniteJump,
})

MainTab:CreateToggle({
    Name = "Anti-Collision (Noclip)",
    CurrentValue = false,
    Callback = toggleNoclip,
})

-- ===== ESP TAB =====
ESPTab:CreateSection("Player ESP")

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(value)
        if value then
            enableESP()
        else
            disableESP()
        end
    end,
})

-- ===== ENHANCED TELEPORT TAB WITH SEARCH =====
TeleportTab:CreateSection("Player Teleport")

-- Search functionality
local searchText = ""
local allPlayers = {}
local filteredPlayers = {}

local function updatePlayerList()
    allPlayers = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(allPlayers, player.Name)
        end
    end
    table.sort(allPlayers)
    
    -- Filter players based on search
    filteredPlayers = {}
    if searchText == "" then
        filteredPlayers = allPlayers
    else
        for _, playerName in pairs(allPlayers) do
            if string.find(string.lower(playerName), string.lower(searchText)) then
                table.insert(filteredPlayers, playerName)
            end
        end
    end
end

-- Search input
TeleportTab:CreateInput({
    Name = "🔍 Search Players",
    PlaceholderText = "Type to search players...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        searchText = Text
        updatePlayerList()
        refreshTeleportButtons()
    end,
})

-- Refresh button
TeleportTab:CreateButton({
    Name = "🔄 Refresh Player List",
    Callback = function()
        updatePlayerList()
        refreshTeleportButtons()
        Rayfield:Notify({
            Title = "Player List",
            Content = "Player list refreshed!",
            Duration = 2
        })
    end,
})

-- Container for teleport buttons
local teleportButtonsContainer = {}
local function refreshTeleportButtons()
    -- Remove old buttons
    for _, button in pairs(teleportButtonsContainer) do
        button:Destroy()
    end
    teleportButtonsContainer = {}
    
    -- Create new buttons for filtered players
    for _, playerName in pairs(filteredPlayers) do
        local button = TeleportTab:CreateButton({
            Name = "🚀 TP to " .. playerName,
            Callback = function()
                local targetPlayer = Players:FindFirstChild(playerName)
                if targetPlayer then
                    teleportToPlayer(targetPlayer)
                else
                    Rayfield:Notify({
                        Title = "Teleport Error",
                        Content = "Player not found: " .. playerName,
                        Duration = 3
                    })
                end
            end,
        })
        table.insert(teleportButtonsContainer, button)
    end
    
    -- Show message if no players found
    if #filteredPlayers == 0 and searchText ~= "" then
        TeleportTab:CreateLabel("No players found matching: " .. searchText)
    end
end

-- Initial player list setup
updatePlayerList()
refreshTeleportButtons()

-- Auto-refresh when players join/leave
Players.PlayerAdded:Connect(function()
    updatePlayerList()
    refreshTeleportButtons()
end)

Players.PlayerRemoving:Connect(function()
    updatePlayerList()
    refreshTeleportButtons()
end)

-- ===== SERVER TAB =====
ServerTab:CreateSection("Server Hopping")

local popularGames = {
    {Name = "Adopt Me", ID = 920587237},
    {Name = "Brookhaven RP", ID = 4924922222},
    {Name = "Prison Life", ID = 155615604},
    {Name = "MeepCity", ID = 370731277},
    {Name = "Tower of Hell", ID = 1962086868},
    {Name = "Arsenal", ID = 286090429},
    {Name = "Jailbreak", ID = 606849621}
}

local gameNames = {}
for _, game in pairs(popularGames) do
    table.insert(gameNames, game.Name)
end

local selectedGameName = ""
ServerTab:CreateDropdown({
    Name = "Popular Games",
    Options = gameNames,
    CurrentOption = "",
    Callback = function(Option)
        selectedGameName = Option
    end,
})

ServerTab:CreateButton({
    Name = "🎮 Enhanced Server Hop to Game",
    Callback = function()
        if selectedGameName and selectedGameName ~= "" then
            for _, game in pairs(popularGames) do
                if game.Name == selectedGameName then
                    enhancedServerHop(game.ID)
                    return
                end
            end
        else
            Rayfield:Notify({
                Title = "Selection Error",
                Content = "Please select a game!",
                Duration = 3
            })
        end
    end,
})

ServerTab:CreateSection("Current Server")

ServerTab:CreateButton({
    Name = "🔄 Enhanced Server Hop (Current)",
    Callback = function()
        enhancedServerHop(game.PlaceId)
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
    toggleAdvancedFly(false)
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
    Title = "SHOX MENU ULTIMATE", 
    Content = "Advanced Fly & Enhanced Teleport Loaded! Use K to toggle menu.", 
    Duration = 6 
})

print("🔮 SHOX MENU ULTIMATE - Advanced Systems Activated!")
