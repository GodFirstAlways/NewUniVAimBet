-- ESP.lua - Main ESP Manager
-- Handles enabling/disabling ESP features and updating all players

local RunService = game:GetService("RunService")

_G.QuantumESP = _G.QuantumESP or {}
_G.QuantumESP.Active = false
_G.QuantumESP.Connection = nil

-- Initialize ESP system
function _G.QuantumESP.Initialize()
    print("[ESP] Initializing ESP system...")
    
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
    
    print("[ESP] ESP system initialized successfully")
    return true
end

-- Start ESP rendering
function _G.QuantumESP.Start()
    if _G.QuantumESP.Active then
        warn("[ESP] ESP already running")
        return
    end
    
    print("[ESP] Starting ESP rendering...")
    _G.QuantumESP.Active = true
    
    -- Connect to RenderStepped for smooth ESP updates
    _G.QuantumESP.Connection = RunService.RenderStepped:Connect(function()
        _G.QuantumESP.Update()
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
    
    print("[ESP] ESP stopped")
end

-- Main update function (called every frame)
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
        else
            -- Remove ESP if player is invalid or doesn't pass checks
            if _G.QuantumBoxESP and playerData and playerData.Player then
                _G.QuantumBoxESP.Remove(playerData.Player)
            end
        end
    end
    
    -- Clean up ESP for players no longer in pool
    if _G.QuantumBoxESP then
        _G.QuantumBoxESP.CleanupInvalid(players)
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

-- Get ESP status
function _G.QuantumESP.IsActive()
    return _G.QuantumESP.Active
end

print("[ESP] ESP.lua loaded successfully")
print("[ESP] Use _G.QuantumESP.Initialize() to start")