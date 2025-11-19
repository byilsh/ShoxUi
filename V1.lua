-- SHOX Menu - Ultimate Enhanced Version
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
    Name = "🔮 SHOX MENU ULTIMATE",
    LoadingTitle = "Loading Ultimate SHOX Menu...",
    LoadingSubtitle = "Enhanced Teleport & Server Hop Systems",
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
local StarterGui = game:GetService("StarterGui")
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
local clickTeleportEnabled = false

-- Saved locations system
local savedLocations = {}
local currentSaveName = ""

-- Feature objects
local bodyVelocity, bodyGyro
local noclipConnection
local flyConnection
local clickTeleportConnection

-- ===== ENHANCED NOTIFICATION SYSTEM =====
local function showNotification(title, text, duration)
    duration = duration or 5
    StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration;
    })
end

-- ===== ULTIMATE TELEPORT SYSTEM =====
local function enhancedTeleportToPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == player then
        showNotification("Teleport Error", "Invalid target player!")
        return false
    end

    local success, result = pcall(function()
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame + Vector3.new(0, 3, 0)})
            tween:Play()
            
            tween.Completed:Wait()
            return true
        else
            return false, "Target character not available"
        end
    end)

    if success then
        showNotification("Teleport Success", "Teleported to " .. targetPlayer.Name)
        return true
    else
        showNotification("Teleport Failed", "Failed to teleport: " .. tostring(result))
        return false
    end
end

-- ===== CLICK TELEPORT SYSTEM =====
local function teleportToTouchPosition(touchPosition)
    if character and humanoidRootPart then
        local camera = workspace.CurrentCamera
        local ray = camera:ViewportPointToRay(touchPosition.X, touchPosition.Y)
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
        if raycastResult then
            local newPosition = raycastResult.Position + Vector3.new(0, 3, 0)
            
            -- Smooth teleport with tween
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(newPosition)})
            tween:Play()
            
            showNotification("Teleported", "Teleported to clicked location!")
            return true
        else
            showNotification("Error", "No valid position found!")
            return false
        end
    else
        showNotification("Error", "Character not found!")
        return false
    end
end

local function toggleClickTeleport(value)
    clickTeleportEnabled = value
    if value then
        clickTeleportConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                teleportToTouchPosition(input.Position)
            elseif input.UserInputType == Enum.UserInputType.Touch then
                teleportToTouchPosition(input.Position)
            end
        end)
        showNotification("Click Teleport", "Click anywhere to teleport! (Mouse/Touch)")
    else
        if clickTeleportConnection then
            clickTeleportConnection:Disconnect()
        end
        showNotification("Click Teleport", "Click teleport disabled!")
    end
end

-- ===== ENHANCED SERVER HOPPING SYSTEM =====
local function enhancedServerHop(targetPlaceId)
    local placeId = targetPlaceId or game.PlaceId
    
    showNotification("Server Hop", "Finding best server for place " .. placeId, 5)
    
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
    until not Next or bestServer and bestServer.playing < 10
    
    if bestServer then
        showNotification("Server Hop", "Joining server with " .. bestServer.playing .. " players")
        TPS:TeleportToPlaceInstance(placeId, bestServer.id, player)
    else
        showNotification("Server Hop", "No servers found, using fallback")
        TPS:Teleport(placeId)
    end
end

-- ===== SENSE ESP LIBRARY INTEGRATION =====
local Sense = nil
local senseLoaded = false
local selectedESPPlayer = nil

local function loadSenseESP()
    if senseLoaded then
        showNotification("Sense ESP", "Sense ESP is already loaded!")
        return true
    end
    
    local success, result = pcall(function()
        Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()
        return Sense
    end)
    
    if success and Sense then
        senseLoaded = true
        showNotification("Sense ESP", "Sense ESP loaded successfully!")
        return true
    else
        showNotification("Sense ESP Error", "Failed to load Sense ESP!")
        return false
    end
end

local function configureSenseForPlayer(targetPlayer)
    if not Sense then return end
    
    if targetPlayer == "All" then
        -- Configure for all enemies
        Sense.teamSettings.enemy.enabled = true
        Sense.teamSettings.enemy.box = true
        Sense.teamSettings.enemy.boxColor[1] = Color3.new(1, 0, 0)
        Sense.teamSettings.friendly.enabled = false
    else
        -- Configure for specific player
        Sense.teamSettings.enemy.enabled = true
        Sense.teamSettings.enemy.box = true
        Sense.teamSettings.enemy.boxColor[1] = Color3.new(0, 1, 0)
        Sense.teamSettings.friendly.enabled = false
        
        -- Override team check for specific player
        Sense.Overrides.GetTeam = function(player)
            if player == targetPlayer then
                return "enemy"
            end
            return "friendly"
        end
    end
end

local function toggleSenseESP(target)
    if not senseLoaded then
        if not loadSenseESP() then return end
    end
    
    if target == "All" then
        selectedESPPlayer = nil
        configureSenseForPlayer("All")
        Sense.Load()
        showNotification("Sense ESP", "ESP enabled for all players!")
    else
        selectedESPPlayer = target
        configureSenseForPlayer(target)
        Sense.Load()
        showNotification("Sense ESP", "ESP enabled for " .. target.Name)
    end
end

local function unloadSenseESP()
    if Sense then
        Sense.Unload()
        Sense = nil
        senseLoaded = false
        selectedESPPlayer = nil
        showNotification("Sense ESP", "Sense ESP unloaded!")
    end
end

-- ===== FIXED JUMP POWER SYSTEM =====
local jumpPowerValue = 100

local function updateJumpPower(newPower)
    jumpPowerValue = newPower
    if humanoid then
        if superJumpEnabled then
            humanoid.JumpPower = newPower
        end
    end
    showNotification("Jump Power", "Jump power set to: " .. newPower, 2)
end

local function toggleSuperJump(value)
    superJumpEnabled = value
    if humanoid then
        if value then
            humanoid.JumpPower = jumpPowerValue
        else
            humanoid.JumpPower = 50
        end
    end
    showNotification("Super Jump", value and "Enabled" or "Disabled", 2)
end

-- ===== ANTI-COLLISION (NOCLIP) SYSTEM =====
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
        showNotification("Noclip", "Anti-collision enabled!", 2)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
        showNotification("Noclip", "Anti-collision disabled!", 2)
    end
end

-- ===== FLY SYSTEM =====
local function toggleFly(value)
    flyEnabled = value
    if value then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyGyro = Instance.new("BodyGyro")
        
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        
        bodyVelocity.Parent = humanoidRootPart
        bodyGyro.Parent = humanoidRootPart
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled then return end
            
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
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDirection = moveDirection + Vector3.new(0, -1, 0)
            end
            
            bodyVelocity.Velocity = moveDirection * 50
        end)
        showNotification("Fly Mode", "Fly enabled! WASD + Space/Ctrl", 4)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        showNotification("Fly Mode", "Fly disabled!", 2)
    end
end

-- ===== INFINITE JUMP =====
local function toggleInfiniteJump(value)
    infiniteJumpEnabled = value
    showNotification("Infinite Jump", value and "Enabled" or "Disabled", 2)
end

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ===== SAVED LOCATIONS SYSTEM =====
local function saveCurrentLocation(name)
    if not name or name == "" then
        name = "Location_" .. os.time()
    end
    
    if humanoidRootPart then
        savedLocations[name] = {
            Position = humanoidRootPart.Position,
            CFrame = humanoidRootPart.CFrame
        }
        
        showNotification("Location Saved", "Saved as: " .. name)
        return true
    end
    return false
end

local function teleportToSavedLocation(name)
    if savedLocations[name] and humanoidRootPart then
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = savedLocations[name].CFrame})
        tween:Play()
        
        showNotification("Teleport", "Teleported to: " .. name)
        return true
    else
        showNotification("Location Error", "Location not found: " .. name)
        return false
    end
end

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

MainTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Callback = toggleFly,
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
ESPTab:CreateSection("Sense ESP")

local function getPlayerOptions()
    local options = {"All"}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(options, p.Name)
        end
    end
    return options
end

local selectedESPPlayerName = "All"
local espDropdown = ESPTab:CreateDropdown({
    Name = "Select Player for ESP",
    Options = getPlayerOptions(),
    CurrentOption = "All",
    Callback = function(Option)
        selectedESPPlayerName = Option
    end,
})

ESPTab:CreateButton({
    Name = "🎯 Enable ESP for Selected",
    Callback = function()
        if selectedESPPlayerName == "All" then
            toggleSenseESP("All")
        else
            local targetPlayer = Players:FindFirstChild(selectedESPPlayerName)
            if targetPlayer then
                toggleSenseESP(targetPlayer)
            else
                showNotification("ESP Error", "Player not found!")
            end
        end
    end,
})

ESPTab:CreateButton({
    Name = "❌ Unload Sense ESP",
    Callback = unloadSenseESP,
})

-- ===== TELEPORT TAB =====
TeleportTab:CreateSection("Player Teleport")

local selectedTeleportPlayer = ""
local teleportDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player to Teleport",
    Options = getPlayerOptions(),
    CurrentOption = "",
    Callback = function(Option)
        selectedTeleportPlayer = Option
    end,
})

TeleportTab:CreateButton({
    Name = "🚀 Teleport to Selected Player",
    Callback = function()
        if selectedTeleportPlayer and selectedTeleportPlayer ~= "" and selectedTeleportPlayer ~= "All" then
            local targetPlayer = Players:FindFirstChild(selectedTeleportPlayer)
            if targetPlayer then
                enhancedTeleportToPlayer(targetPlayer)
            else
                showNotification("Teleport Error", "Player not found!")
            end
        else
            showNotification("Teleport Error", "Please select a player!")
        end
    end,
})

TeleportTab:CreateSection("Click Teleport")

TeleportTab:CreateToggle({
    Name = "Enable Click Teleport",
    CurrentValue = false,
    Callback = toggleClickTeleport,
})

TeleportTab:CreateSection("Saved Locations")

local locationNameInput = ""
TeleportTab:CreateInput({
    Name = "Location Name",
    PlaceholderText = "Enter save name",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        locationNameInput = Text
    end,
})

TeleportTab:CreateButton({
    Name = "💾 Save Current Location",
    Callback = function()
        if locationNameInput and locationNameInput ~= "" then
            saveCurrentLocation(locationNameInput)
        else
            showNotification("Save Error", "Please enter a location name!")
        end
    end,
})

-- Display saved locations
TeleportTab:CreateSection("Your Saved Locations")

local function refreshSavedLocationsDisplay()
    for name, _ in pairs(savedLocations) do
        TeleportTab:CreateButton({
            Name = "📍 " .. name,
            Callback = function()
                teleportToSavedLocation(name)
            end,
        })
    end
end

TeleportTab:CreateButton({
    Name = "🔄 Refresh Saved Locations",
    Callback = refreshSavedLocationsDisplay,
})

-- ===== SERVER TAB =====
ServerTab:CreateSection("Enhanced Server Hopping")

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
            showNotification("Selection Error", "Please select a game!")
        end
    end,
})

ServerTab:CreateSection("Current Game")

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
    toggleClickTeleport(false)
    humanoid.WalkSpeed = 16
    
    showNotification("Respawn", "Character respawned - features reset")
end)

-- ===== INITIALIZATION =====
loadSenseESP()
showNotification("SHOX MENU ULTIMATE", "All systems loaded! Use K to toggle menu.", 6)

print("🎮 SHOX MENU ULTIMATE - Enhanced Systems Activated!")
