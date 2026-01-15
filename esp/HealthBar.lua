-- HealthBar.lua - Traditional Health Bar with Gradient
-- Vertical bar on side of ESP box

_G.QuantumHealthBarESP = _G.QuantumHealthBarESP or {}
local HealthBarESP = _G.QuantumHealthBarESP

HealthBarESP.HealthBars = {} -- Store all active health bars

-- Smooth color gradient based on health percentage
local function GetHealthGradient(healthPercent)
    if healthPercent >= 0.75 then
        -- 75-100%: Green to Yellow-Green
        local t = (healthPercent - 0.75) / 0.25
        return Color3.new(1 - t * 0.5, 1, 0) -- Transitions from yellow-green to pure green
    elseif healthPercent >= 0.5 then
        -- 50-75%: Yellow to Yellow-Green
        local t = (healthPercent - 0.5) / 0.25
        return Color3.new(1, 1, 0 + t * 0) -- Yellow
    elseif healthPercent >= 0.25 then
        -- 25-50%: Orange to Yellow
        local t = (healthPercent - 0.25) / 0.25
        return Color3.new(1, 0.5 + t * 0.5, 0) -- Orange to Yellow
    else
        -- 0-25%: Red to Orange
        local t = healthPercent / 0.25
        return Color3.new(1, 0 + t * 0.5, 0) -- Red to Orange
    end
end

-- Create health bar components for a player
function HealthBarESP.CreateHealthBar(player)
    if HealthBarESP.HealthBars[player] then
        return HealthBarESP.HealthBars[player]
    end
    
    local healthBar = {
        -- Background (shows max health)
        Background = Drawing.new("Line"),
        -- Foreground (actual health)
        Foreground = Drawing.new("Line"),
    }
    
    -- Background properties (dark gray, full height)
    healthBar.Background.Thickness = 3
    healthBar.Background.Color = Color3.fromRGB(30, 30, 30)
    healthBar.Background.Transparency = 0.8
    healthBar.Background.Visible = false
    
    -- Foreground properties (colored based on health)
    healthBar.Foreground.Thickness = 3
    healthBar.Foreground.Transparency = 1
    healthBar.Foreground.Visible = false
    
    HealthBarESP.HealthBars[player] = healthBar
    return healthBar
end

-- Draw health bar for a player
function HealthBarESP.Draw(playerData)
    local player = playerData.Player
    local healthBar = HealthBarESP.CreateHealthBar(player)
    
    -- Get box dimensions
    local headPos = playerData.HeadScreenPos
    local legPos = playerData.LegScreenPos
    
    if not headPos or not legPos then
        HealthBarESP.Remove(player)
        return
    end
    
    -- Calculate box dimensions
    local height = math.abs(headPos.Y - legPos.Y)
    local width = height / 2
    local centerX = (headPos.X + legPos.X) / 2
    
    -- Health bar position (left side of box)
    local barX = centerX - width/2 - 5  -- 5 pixels left of box
    local barTopY = headPos.Y
    local barBottomY = legPos.Y
    
    -- Get health percentage
    local healthPercent = playerData.HealthPercent
    
    -- Calculate foreground height based on health
    local healthHeight = height * healthPercent
    local healthY = barBottomY - healthHeight
    
    -- Draw background (full height, dark)
    healthBar.Background.From = Vector2.new(barX, barTopY)
    healthBar.Background.To = Vector2.new(barX, barBottomY)
    healthBar.Background.Visible = true
    
    -- Draw foreground (health percentage, colored)
    if healthPercent > 0 then
        healthBar.Foreground.From = Vector2.new(barX, barBottomY)
        healthBar.Foreground.To = Vector2.new(barX, healthY)
        healthBar.Foreground.Color = GetHealthGradient(healthPercent)
        healthBar.Foreground.Visible = true
    else
        healthBar.Foreground.Visible = false
    end
end

-- Remove health bar for a specific player
function HealthBarESP.Remove(player)
    local healthBar = HealthBarESP.HealthBars[player]
    if not healthBar then return end
    
    healthBar.Background.Visible = false
    healthBar.Foreground.Visible = false
end

-- Delete health bar completely
function HealthBarESP.Delete(player)
    local healthBar = HealthBarESP.HealthBars[player]
    if not healthBar then return end
    
    if healthBar.Background then healthBar.Background:Remove() end
    if healthBar.Foreground then healthBar.Foreground:Remove() end
    
    HealthBarESP.HealthBars[player] = nil
end

-- Clear all health bars
function HealthBarESP.ClearAll()
    for player, _ in pairs(HealthBarESP.HealthBars) do
        HealthBarESP.Delete(player)
    end
    HealthBarESP.HealthBars = {}
end

-- Cleanup invalid players
function HealthBarESP.CleanupInvalid(validPlayers)
    local validLookup = {}
    for _, playerData in ipairs(validPlayers) do
        if playerData and playerData.Player then
            validLookup[playerData.Player] = true
        end
    end
    
    for player, _ in pairs(HealthBarESP.HealthBars) do
        if not validLookup[player] then
            HealthBarESP.Delete(player)
        end
    end
end

print("[Health Bar ESP] HealthBar.lua loaded successfully")
print("[Health Bar ESP] Traditional vertical bar with smooth gradient")
print("[Health Bar ESP] Use _G.QuantumHealthBarESP to access functions")