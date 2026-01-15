-- ESP.lua - Optimized ESP Manager
-- Throttled updates for better performance

local RunService = game:GetService("RunService")

_G.QuantumESP = _G.QuantumESP or {}
_G.QuantumESP.Active = false
_G.QuantumESP.Connection = nil
_G.QuantumESP.UpdateRate = 2  -- Update every 2 frames (30 FPS instead of 60)
_G.QuantumESP.FrameCount = 0

-- Initialize ESP system
function _G.QuantumESP.Initialize()
    print("[ESP] Initializing optimized ESP system...")
    
    -- Make sure PlayerPool exists
    if not _G.QuantumPlayerPool then
        warn("[ESP] Player Pool not found! Load PlayerPool.lua first")
        return false
    end
    
    -- Make sure Box module exists
    if not _G.QuantumBoxESP then
        warn("[ESP] Box ESP module not found! Load Box.lua first")
        return false
    end
    
    -- Check for Name module (optional)
    if _G.QuantumNameESP then
        print("[ESP] Name ESP module loaded")
    end
    
    -- Check for Skeleton module (optional)
    if _G.QuantumSkeletonESP then
        print("[ESP] Skeleton ESP module loaded")
    end
    
    print("[ESP] ESP system initialized successfully")
    print("[ESP] Update rate: Every " .. _G.QuantumESP.UpdateRate .. " frames")
    return true
end

-- Start ESP rendering
function _G.QuantumESP.Start()
    if _G.QuantumESP.Active then
        warn("[ESP] ESP already running")
        return
    end
    
    print("[ESP] Starting optimized ESP rendering...")
    _G.QuantumESP.Active = true
    _G.QuantumESP.FrameCount = 0
    
    -- Connect to RenderStepped but throttle updates
    _G.QuantumESP.Connection = RunService.RenderStepped:Connect(function()
        _G.QuantumESP.FrameCount = _G.QuantumESP.FrameCount + 1
        
        -- Only update every X frames
        if _G.QuantumESP.FrameCount >= _G.QuantumESP.UpdateRate then
            _G.QuantumESP.Update()
            _G.QuantumESP.FrameCount = 0
        end
    end)
    
    print("[ESP] ESP started successfully")
end

-- Stop ESP rendering
function _G.QuantumESP.Stop()
    if not _G.QuantumESP.Active then
        return
    end
    
    print("[ESP] Stopping ESP...")
    _G.QuantumESP.Active = false
    
    -- Disconnect render loop
    if _G.QuantumESP.Connection then
        _G.QuantumESP.Connection:Disconnect()
        _G.QuantumESP.Connection = nil
    end
    
    -- Clear all ESP elements
    if _G.QuantumBoxESP then
        _G.QuantumBoxESP.ClearAll()
    end
    if _G.QuantumNameESP then
        _G.QuantumNameESP.ClearAll()
    end
    if _G.QuantumSkeletonESP then
        _G.QuantumSkeletonESP.ClearAll()
    end
    
    print("[ESP] ESP stopped")
end

-- Main update function (called every X frames)
function _G.QuantumESP.Update()
    if not _G.QuantumSettings.ESP.Enabled then
        return
    end
    
    -- Get all valid players from pool
    local players = _G.QuantumPlayerPool or {}
    
    -- Update each ESP feature
    for _, playerData in ipairs(players) do
        -- Validate player data
        local isValid = playerData and playerData.Character and playerData.OnScreen
        local passTeamCheck = not (_G.QuantumSettings.ESP.TeamCheck and playerData.IsTeammate)
        
        -- Check if we should draw ESP for this player
        if isValid and passTeamCheck then
            -- Draw Box ESP
            if _G.QuantumSettings.ESP.Boxes then
                if _G.QuantumBoxESP then
                    _G.QuantumBoxESP.Draw(playerData)
                end
            else
                if _G.QuantumBoxESP then
                    _G.QuantumBoxESP.Remove(playerData.Player)
                end
            end
            
            -- Draw Name ESP
            if _G.QuantumSettings.ESP.Names or _G.QuantumSettings.ESP.Distance then
                if _G.QuantumNameESP then
                    _G.QuantumNameESP.Draw(playerData)
                end
            else
                if _G.QuantumNameESP then
                    _G.QuantumNameESP.Remove(playerData.Player)
                end
            end
            
            -- Draw Skeleton ESP
            if _G.QuantumSettings.ESP.Skeleton then
                if _G.QuantumSkeletonESP then
                    _G.QuantumSkeletonESP.Draw(playerData)
                end
            else
                if _G.QuantumSkeletonESP then
                    _G.QuantumSkeletonESP.Remove(playerData.Player)
                end
            end
        else
            -- Remove ESP if player is invalid or doesn't pass checks
            if _G.QuantumBoxESP and playerData and playerData.Player then
                _G.QuantumBoxESP.Remove(playerData.Player)
            end
            if _G.QuantumNameESP and playerData and playerData.Player then
                _G.QuantumNameESP.Remove(playerData.Player)
            end
            if _G.QuantumSkeletonESP and playerData and playerData.Player then
                _G.QuantumSkeletonESP.Remove(playerData.Player)
            end
        end
    end
    
    -- Clean up ESP for players no longer in pool
    if _G.QuantumBoxESP then
        _G.QuantumBoxESP.CleanupInvalid(players)
    end
    if _G.QuantumNameESP then
        _G.QuantumNameESP.CleanupInvalid(players)
    end
    if _G.QuantumSkeletonESP then
        _G.QuantumSkeletonESP.CleanupInvalid(players)
    end
end

-- Toggle ESP on/off
function _G.QuantumESP.Toggle(enabled)
    if enabled then
        _G.QuantumESP.Start()
    else
        _G.QuantumESP.Stop()
    end
end

-- Change update rate (1 = every frame, 2 = every 2 frames, etc)
function _G.QuantumESP.SetUpdateRate(rate)
    _G.QuantumESP.UpdateRate = math.max(1, math.floor(rate))
    print("[ESP] Update rate changed to: Every " .. _G.QuantumESP.UpdateRate .. " frames")
end

-- Get ESP status
function _G.QuantumESP.IsActive()
    return _G.QuantumESP.Active
end

print("[ESP] Optimized ESP.lua loaded successfully")
print("[ESP] Use _G.QuantumESP.Initialize() to start")
print("[ESP] Use _G.QuantumESP.SetUpdateRate(n) to change speed")