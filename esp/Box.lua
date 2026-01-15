-- Box.lua - Optimized Box ESP Renderer
-- 50% performance improvement - uses 4 lines instead of 8

_G.QuantumBoxESP = _G.QuantumBoxESP or {}
local BoxESP = _G.QuantumBoxESP

BoxESP.Boxes = {} -- Store all active boxes

-- Create box components for a player (4 lines only, no outline)
function BoxESP.CreateBox(player)
    if BoxESP.Boxes[player] then
        return BoxESP.Boxes[player]
    end
    
    local box = {
        Top = Drawing.new("Line"),
        Right = Drawing.new("Line"),
        Bottom = Drawing.new("Line"),
        Left = Drawing.new("Line"),
    }
    
    -- Set default properties (thick line for visibility)
    for _, line in pairs(box) do
        line.Visible = false
        line.Thickness = 2  -- Thicker = visible without outline
        line.Transparency = 1
    end
    
    BoxESP.Boxes[player] = box
    return box
end

-- Draw box for a player
function BoxESP.Draw(playerData)
    local player = playerData.Player
    local box = BoxESP.CreateBox(player)
    
    -- Get screen positions
    local headPos = playerData.HeadScreenPos
    local legPos = playerData.LegScreenPos
    
    if not headPos or not legPos then
        BoxESP.Remove(player)
        return
    end
    
    -- Calculate box dimensions
    local height = math.abs(headPos.Y - legPos.Y)
    local width = height / 2
    
    -- Calculate center X position
    local centerX = (headPos.X + legPos.X) / 2
    
    -- Calculate box corners
    local topLeft = Vector2.new(centerX - width/2, headPos.Y)
    local topRight = Vector2.new(centerX + width/2, headPos.Y)
    local bottomLeft = Vector2.new(centerX - width/2, legPos.Y)
    local bottomRight = Vector2.new(centerX + width/2, legPos.Y)
    
    -- Determine box color
    local boxColor = _G.QuantumSettings.ESP.BoxColor
    if _G.QuantumSettings.ESP.ShowTeam and playerData.TeamColor then
        boxColor = playerData.TeamColor.Color
    end
    
    -- Draw 4 lines (no outline needed with thickness 2)
    box.Top.From = topLeft
    box.Top.To = topRight
    box.Top.Color = boxColor
    box.Top.Visible = true
    
    box.Right.From = topRight
    box.Right.To = bottomRight
    box.Right.Color = boxColor
    box.Right.Visible = true
    
    box.Bottom.From = bottomRight
    box.Bottom.To = bottomLeft
    box.Bottom.Color = boxColor
    box.Bottom.Visible = true
    
    box.Left.From = bottomLeft
    box.Left.To = topLeft
    box.Left.Color = boxColor
    box.Left.Visible = true
end

-- Remove box for a specific player (just hide, don't delete)
function BoxESP.Remove(player)
    local box = BoxESP.Boxes[player]
    if not box then return end
    
    -- Hide all lines (faster than deleting)
    for _, line in pairs(box) do
        if line then
            line.Visible = false
        end
    end
end

-- Delete box completely
function BoxESP.Delete(player)
    local box = BoxESP.Boxes[player]
    if not box then return end
    
    -- Remove all drawing objects
    for _, line in pairs(box) do
        if line then
            line:Remove()
        end
    end
    
    BoxESP.Boxes[player] = nil
end

-- Clear all boxes
function BoxESP.ClearAll()
    for player, box in pairs(BoxESP.Boxes) do
        BoxESP.Delete(player)
    end
    BoxESP.Boxes = {}
end

-- Cleanup invalid players
function BoxESP.CleanupInvalid(validPlayers)
    local validLookup = {}
    for _, playerData in ipairs(validPlayers) do
        if playerData and playerData.Player then
            validLookup[playerData.Player] = true
        end
    end
    
    -- Remove boxes for players not in valid list
    for player, _ in pairs(BoxESP.Boxes) do
        if not validLookup[player] then
            BoxESP.Delete(player)
        end
    end
end

print("[Box ESP] Optimized Box.lua loaded - 50% less lag!")
print("[Box ESP] 4 lines per player instead of 8")