-- Tracer.lua - Lines from screen to players
-- Shows direction and distance to players

_G.QuantumTracerESP = _G.QuantumTracerESP or {}
local TracerESP = _G.QuantumTracerESP

TracerESP.Tracers = {} -- Store all active tracers

-- Create tracer line for a player
function TracerESP.CreateTracer(player)
    if TracerESP.Tracers[player] then
        return TracerESP.Tracers[player]
    end
    
    local tracer = {
        Line = Drawing.new("Line"),
    }
    
    -- Line properties
    tracer.Line.Thickness = 1
    tracer.Line.Transparency = 0.7
    tracer.Line.Visible = false
    
    TracerESP.Tracers[player] = tracer
    return tracer
end

-- Draw tracer for a player
function TracerESP.Draw(playerData)
    local player = playerData.Player
    local tracer = TracerESP.CreateTracer(player)
    
    -- Get player position on screen
    local targetPos = playerData.LegScreenPos  -- Aim for feet
    
    if not targetPos then
        TracerESP.Remove(player)
        return
    end
    
    -- Get screen dimensions
    local Camera = workspace.CurrentCamera
    local screenSize = Camera.ViewportSize
    
    -- Start position (bottom center of screen)
    local startPos = Vector2.new(screenSize.X / 2, screenSize.Y)
    
    -- Determine tracer color
    local tracerColor = Color3.new(1, 1, 1)  -- Default white
    if _G.QuantumSettings.ESP.ShowTeam and playerData.TeamColor then
        tracerColor = playerData.TeamColor.Color
    end
    
    -- Draw line from bottom center to player
    tracer.Line.From = startPos
    tracer.Line.To = targetPos
    tracer.Line.Color = tracerColor
    tracer.Line.Visible = true
end

-- Remove tracer for a specific player
function TracerESP.Remove(player)
    local tracer = TracerESP.Tracers[player]
    if not tracer then return end
    
    tracer.Line.Visible = false
end

-- Delete tracer completely
function TracerESP.Delete(player)
    local tracer = TracerESP.Tracers[player]
    if not tracer then return end
    
    if tracer.Line then
        tracer.Line:Remove()
    end
    
    TracerESP.Tracers[player] = nil
end

-- Clear all tracers
function TracerESP.ClearAll()
    for player, _ in pairs(TracerESP.Tracers) do
        TracerESP.Delete(player)
    end
    TracerESP.Tracers = {}
end

-- Cleanup invalid players
function TracerESP.CleanupInvalid(validPlayers)
    local validLookup = {}
    for _, playerData in ipairs(validPlayers) do
        if playerData and playerData.Player then
            validLookup[playerData.Player] = true
        end
    end
    
    for player, _ in pairs(TracerESP.Tracers) do
        if not validLookup[player] then
            TracerESP.Delete(player)
        end
    end
end

print("[Tracer ESP] Tracer.lua loaded successfully")
print("[Tracer ESP] Lines from bottom center to players")
print("[Tracer ESP] Use _G.QuantumTracerESP to access functions")