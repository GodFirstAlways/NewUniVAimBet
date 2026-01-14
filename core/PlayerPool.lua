-- Player Pool Manager - OPTIMIZED
-- Centralized player tracking with performance improvements

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Initialize global player pool
_G.QuantumPlayerPool = {}

-- Performance settings
local VisibilityCheckInterval = 5  -- Check visibility every 5 frames (not every frame!)
local VisibilityCache = {}  -- Cache visibility results

-- Player data structure
local function CreatePlayerData(player, frameCount)
    if not player.Character then return nil end
    
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not rootPart or not head then return nil end
    if humanoid.Health <= 0 then return nil end
    
    -- Get all body parts
    local parts = {
        Head = head,
        HumanoidRootPart = rootPart,
        UpperTorso = character:FindFirstChild("UpperTorso"),
        LowerTorso = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso"),
        LeftUpperArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
        RightUpperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
        LeftUpperLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
        RightUpperLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg"),
    }
    
    -- Calculate screen position
    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
    
    -- Calculate distance
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    
    -- Visibility check (CACHED - only run every X frames)
    local isVisible = false
    if not VisibilityCache[player] or (frameCount % VisibilityCheckInterval == 0) then
        local ray = Ray.new(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).Unit * distance)
        local hitPart = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        
        if hitPart and hitPart:IsDescendantOf(character) then
            isVisible = true
        end
        
        -- Cache result
        VisibilityCache[player] = isVisible
    else
        -- Use cached result
        isVisible = VisibilityCache[player]
    end
    
    -- Calculate velocity for prediction
    local velocity = rootPart.AssemblyLinearVelocity or rootPart.Velocity
    
    -- Get team info
    local isTeammate = false
    if LocalPlayer.Team and player.Team then
        isTeammate = (LocalPlayer.Team == player.Team)
    end
    
    -- Box dimensions for ESP
    local boxHeight = math.abs(headPos.Y - legPos.Y)
    local boxWidth = boxHeight / 2
    
    -- Create player data object
    return {
        -- Player info
        Player = player,
        Name = player.Name,
        DisplayName = player.DisplayName,
        UserId = player.UserId,
        Team = player.Team,
        TeamColor = player.TeamColor,
        
        -- Character references
        Character = character,
        Humanoid = humanoid,
        RootPart = rootPart,
        Head = head,
        Parts = parts,
        
        -- Health info
        Health = humanoid.Health,
        MaxHealth = humanoid.MaxHealth,
        HealthPercent = humanoid.Health / humanoid.MaxHealth,
        
        -- Position data
        Position = rootPart.Position,
        CFrame = rootPart.CFrame,
        Velocity = velocity,
        Speed = velocity.Magnitude,
        
        -- Screen data
        ScreenPosition = Vector2.new(screenPos.X, screenPos.Y),
        OnScreen = onScreen,
        HeadScreenPos = Vector2.new(headPos.X, headPos.Y),
        LegScreenPos = Vector2.new(legPos.X, legPos.Y),
        
        -- Box dimensions
        BoxWidth = boxWidth,
        BoxHeight = boxHeight,
        BoxPosition = Vector2.new(screenPos.X, screenPos.Y),
        
        -- Distance
        Distance = distance,
        DistanceFormatted = math.floor(distance) .. "m",
        
        -- Visibility (CACHED)
        IsVisible = isVisible,
        BehindWall = not isVisible,
        
        -- Team info
        IsTeammate = isTeammate,
        IsEnemy = not isTeammate,
        
        -- Mouse/Camera data
        DistanceFromMouse = nil,
        DistanceFromCenter = nil,
        AngleFromCamera = nil,
        
        -- Timestamp
        LastUpdate = tick()
    }
end

-- Calculate mouse/camera distances
local function CalculateAimData(playerData)
    if not playerData or not playerData.OnScreen then return playerData end
    
    local mouse = LocalPlayer:GetMouse()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Distance from mouse cursor
    playerData.DistanceFromMouse = (mousePos - playerData.ScreenPosition).Magnitude
    
    -- Distance from screen center (crosshair)
    playerData.DistanceFromCenter = (screenCenter - playerData.ScreenPosition).Magnitude
    
    -- Angle from camera
    local cameraLook = Camera.CFrame.LookVector
    local targetDirection = (playerData.Position - Camera.CFrame.Position).Unit
    playerData.AngleFromCamera = math.deg(math.acos(cameraLook:Dot(targetDirection)))
    
    return playerData
end

-- Main update function with frame counter
local frameCount = 0
local function UpdatePlayerPool()
    frameCount = frameCount + 1
    local pool = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local data = CreatePlayerData(player, frameCount)
            if data then
                data = CalculateAimData(data)
                table.insert(pool, data)
            end
        end
    end
    
    -- Sort by distance (closest first)
    table.sort(pool, function(a, b)
        return a.Distance < b.Distance
    end)
    
    _G.QuantumPlayerPool = pool
    
    -- Clean visibility cache every 100 frames
    if frameCount % 100 == 0 then
        for player, _ in pairs(VisibilityCache) do
            if not Players:FindFirstChild(player.Name) then
                VisibilityCache[player] = nil
            end
        end
    end
end

-- Update every frame (but raycasts are cached)
RunService.RenderStepped:Connect(UpdatePlayerPool)

-- Helper functions for modules to use
_G.QuantumHelpers = {
    -- Get all valid players
    GetAllPlayers = function()
        return _G.QuantumPlayerPool
    end,
    
    -- Get players filtered by settings
    GetFilteredPlayers = function(settings)
        local filtered = {}
        
        for _, playerData in ipairs(_G.QuantumPlayerPool) do
            local valid = true
            
            -- Team check
            if settings.TeamCheck and playerData.IsTeammate then
                valid = false
            end
            
            -- Visible check
            if settings.VisibleCheck and not playerData.IsVisible then
                valid = false
            end
            
            -- FOV check
            if settings.FOV and playerData.DistanceFromMouse then
                if playerData.DistanceFromMouse > settings.FOV then
                    valid = false
                end
            end
            
            -- Distance check
            if settings.MaxDistance and playerData.Distance > settings.MaxDistance then
                valid = false
            end
            
            if valid then
                table.insert(filtered, playerData)
            end
        end
        
        return filtered
    end,
    
    -- Get closest player to mouse
    GetClosestToMouse = function(settings)
        local filtered = _G.QuantumHelpers.GetFilteredPlayers(settings or {})
        
        if #filtered == 0 then return nil end
        
        table.sort(filtered, function(a, b)
            return a.DistanceFromMouse < b.DistanceFromMouse
        end)
        
        return filtered[1]
    end,
    
    -- Get closest player to crosshair/center
    GetClosestToCenter = function(settings)
        local filtered = _G.QuantumHelpers.GetFilteredPlayers(settings or {})
        
        if #filtered == 0 then return nil end
        
        table.sort(filtered, function(a, b)
            return a.DistanceFromCenter < b.DistanceFromCenter
        end)
        
        return filtered[1]
    end,
    
    -- Get player by name
    GetPlayerByName = function(name)
        for _, playerData in ipairs(_G.QuantumPlayerPool) do
            if playerData.Name == name or playerData.DisplayName == name then
                return playerData
            end
        end
        return nil
    end,
    
    -- Get only visible players
    GetVisiblePlayers = function()
        local visible = {}
        for _, playerData in ipairs(_G.QuantumPlayerPool) do
            if playerData.IsVisible then
                table.insert(visible, playerData)
            end
        end
        return visible
    end,
    
    -- Get only enemies
    GetEnemies = function()
        local enemies = {}
        for _, playerData in ipairs(_G.QuantumPlayerPool) do
            if playerData.IsEnemy then
                table.insert(enemies, playerData)
            end
        end
        return enemies
    end,
    
    -- Get players in FOV
    GetPlayersInFOV = function(fov)
        local inFOV = {}
        for _, playerData in ipairs(_G.QuantumPlayerPool) do
            if playerData.DistanceFromCenter and playerData.DistanceFromCenter <= fov then
                table.insert(inFOV, playerData)
            end
        end
        return inFOV
    end,
}

print("[Quantum] OPTIMIZED Player Pool initialized")
print("[Quantum] Raycasts cached every " .. VisibilityCheckInterval .. " frames")
print("[Quantum] Use _G.QuantumPlayerPool to access player data")
print("[Quantum] Use _G.QuantumHelpers for filtering functions")