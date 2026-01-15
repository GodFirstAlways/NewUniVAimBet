-- Name.lua - Optimized Name ESP Renderer
-- Shows player names, distance, and health

_G.QuantumNameESP = _G.QuantumNameESP or {}
local NameESP = _G.QuantumNameESP

NameESP.Names = {} -- Store all active name texts

-- Create name text for a player
function NameESP.CreateName(player)
    if NameESP.Names[player] then
        return NameESP.Names[player]
    end
    
    local nameText = {
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Text"),
    }
    
    -- Name text properties
    nameText.Name.Size = 13
    nameText.Name.Center = true
    nameText.Name.Outline = true
    nameText.Name.OutlineColor = Color3.new(0, 0, 0)
    nameText.Name.Font = 2  -- Font 2 = UI font (clean and readable)
    nameText.Name.Visible = false
    nameText.Name.Transparency = 1
    
    -- Distance text properties
    nameText.Distance.Size = 12
    nameText.Distance.Center = true
    nameText.Distance.Outline = true
    nameText.Distance.OutlineColor = Color3.new(0, 0, 0)
    nameText.Distance.Font = 2
    nameText.Distance.Visible = false
    nameText.Distance.Transparency = 1
    
    -- Health text properties
    nameText.Health.Size = 12
    nameText.Health.Center = true
    nameText.Health.Outline = true
    nameText.Health.OutlineColor = Color3.new(0, 0, 0)
    nameText.Health.Font = 2
    nameText.Health.Visible = false
    nameText.Health.Transparency = 1
    
    NameESP.Names[player] = nameText
    return nameText
end

-- Get health color based on percentage
local function GetHealthColor(healthPercent)
    -- Red → Yellow → Green gradient
    if healthPercent > 0.75 then
        return Color3.fromRGB(0, 255, 0)  -- Green
    elseif healthPercent > 0.5 then
        return Color3.fromRGB(255, 255, 0)  -- Yellow
    elseif healthPercent > 0.25 then
        return Color3.fromRGB(255, 165, 0)  -- Orange
    else
        return Color3.fromRGB(255, 0, 0)  -- Red
    end
end

-- Draw name for a player
function NameESP.Draw(playerData)
    local player = playerData.Player
    local nameText = NameESP.CreateName(player)
    
    -- Get head screen position (name goes above head)
    local headPos = playerData.HeadScreenPos
    
    if not headPos then
        NameESP.Remove(player)
        return
    end
    
    -- Determine text color
    local textColor = Color3.new(1, 1, 1)  -- Default white
    if _G.QuantumSettings.ESP.ShowTeam and playerData.TeamColor then
        textColor = playerData.TeamColor.Color
    end
    
    -- Vertical spacing
    local yOffset = 0
    
    -- Draw Display Name (above)
    if _G.QuantumSettings.ESP.Names then
        nameText.Name.Text = playerData.DisplayName
        nameText.Name.Position = Vector2.new(headPos.X, headPos.Y - 30 + yOffset)
        nameText.Name.Color = textColor
        nameText.Name.Visible = true
        yOffset = yOffset + 15
    else
        nameText.Name.Visible = false
    end
    
    -- Draw Username (below display name)
    if _G.QuantumSettings.ESP.Names and playerData.DisplayName ~= playerData.Name then
        nameText.Distance.Text = "@" .. playerData.Name
        nameText.Distance.Position = Vector2.new(headPos.X, headPos.Y - 30 + yOffset)
        nameText.Distance.Color = Color3.fromRGB(180, 180, 180)  -- Gray
        nameText.Distance.Visible = true
        yOffset = yOffset + 13
    elseif _G.QuantumSettings.ESP.Distance then
        -- If names are the same, show distance instead
        nameText.Distance.Text = playerData.DistanceFormatted
        nameText.Distance.Position = Vector2.new(headPos.X, headPos.Y - 30 + yOffset)
        nameText.Distance.Color = Color3.fromRGB(200, 200, 200)
        nameText.Distance.Visible = true
        yOffset = yOffset + 13
    else
        nameText.Distance.Visible = false
    end
    
    -- Draw Health (if enabled in settings)
    if _G.QuantumSettings.ESP.Health and _G.QuantumSettings.ESP.ShowHealthText then
        local healthPercent = playerData.HealthPercent
        local healthColor = GetHealthColor(healthPercent)
        
        nameText.Health.Text = math.floor(playerData.Health) .. " HP"
        nameText.Health.Position = Vector2.new(headPos.X, headPos.Y - 30 + yOffset)
        nameText.Health.Color = healthColor
        nameText.Health.Visible = true
    else
        nameText.Health.Visible = false
    end
end

-- Remove name for a specific player
function NameESP.Remove(player)
    local nameText = NameESP.Names[player]
    if not nameText then return end
    
    -- Hide all text elements
    nameText.Name.Visible = false
    nameText.Distance.Visible = false
    nameText.Health.Visible = false
end

-- Delete name completely
function NameESP.Delete(player)
    local nameText = NameESP.Names[player]
    if not nameText then return end
    
    -- Remove all text objects
    if nameText.Name then nameText.Name:Remove() end
    if nameText.Distance then nameText.Distance:Remove() end
    if nameText.Health then nameText.Health:Remove() end
    
    NameESP.Names[player] = nil
end

-- Clear all names
function NameESP.ClearAll()
    for player, _ in pairs(NameESP.Names) do
        NameESP.Delete(player)
    end
    NameESP.Names = {}
end

-- Cleanup invalid players
function NameESP.CleanupInvalid(validPlayers)
    local validLookup = {}
    for _, playerData in ipairs(validPlayers) do
        if playerData and playerData.Player then
            validLookup[playerData.Player] = true
        end
    end
    
    -- Remove names for players not in valid list
    for player, _ in pairs(NameESP.Names) do
        if not validLookup[player] then
            NameESP.Delete(player)
        end
    end
end

print("[Name ESP] Name.lua loaded successfully")
print("[Name ESP] Shows: Name, Distance, Health")
print("[Name ESP] Use _G.QuantumNameESP to access functions")