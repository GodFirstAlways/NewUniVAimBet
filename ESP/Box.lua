-- Box.lua - Box ESP Renderer
-- Handles drawing boxes around players

_G.QuantumBoxESP = _G.QuantumBoxESP or {}
local BoxESP = _G.QuantumBoxESP

BoxESP.Boxes = {} -- Store all active boxes

-- Create box components for a player
function BoxESP.CreateBox(player)
    if BoxESP.Boxes[player] then
        return BoxESP.Boxes[player]
    end
    
    local box = {
        -- Main box (4 lines)
        TopLeft = Drawing.new("Line"),
        TopRight = Drawing.new("Line"),
        BottomLeft = Drawing.new("Line"),
        BottomRight = Drawing.new("Line"),
        
        -- Box outline (4 lines for border)
        OutlineTopLeft = Drawing.new("Line"),
        OutlineTopRight = Drawing.new("Line"),
        OutlineBottomLeft = Drawing.new("Line"),
        OutlineBottomRight = Drawing.new("Line"),
    }
    
    -- Set default properties for main box
    for _, line in pairs({box.TopLeft, box.TopRight, box.BottomLeft, box.BottomRight}) do
        line.Visible = false
        line.Thickness = 1
        line.Transparency = 1
    end
    
    -- Set default properties for outline
    for _, line in pairs({box.OutlineTopLeft, box.OutlineTopRight, box.OutlineBottomLeft, box.OutlineBottomRight}) do
        line.Visible = false
        line.Thickness = 3
        line.Color = Color3.new(0, 0, 0)
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
    
    -- Draw outline first (black border)
    box.OutlineTopLeft.From = topLeft
    box.OutlineTopLeft.To = topRight
    box.OutlineTopLeft.Visible = true
    
    box.OutlineTopRight.From = topRight
    box.OutlineTopRight.To = bottomRight
    box.OutlineTopRight.Visible = true
    
    box.OutlineBottomRight.From = bottomRight
    box.OutlineBottomRight.To = bottomLeft
    box.OutlineBottomRight.Visible = true
    
    box.OutlineBottomLeft.From = bottomLeft
    box.OutlineBottomLeft.To = topLeft
    box.OutlineBottomLeft.Visible = true
    
    -- Draw main box on top
    box.TopLeft.From = topLeft
    box.TopLeft.To = topRight
    box.TopLeft.Color = boxColor
    box.TopLeft.Visible = true
    
    box.TopRight.From = topRight
    box.TopRight.To = bottomRight
    box.TopRight.Color = boxColor
    box.TopRight.Visible = true
    
    box.BottomRight.From = bottomRight
    box.BottomRight.To = bottomLeft
    box.BottomRight.Color = boxColor
    box.BottomRight.Visible = true
    
    box.BottomLeft.From = bottomLeft
    box.BottomLeft.To = topLeft
    box.BottomLeft.Color = boxColor
    box.BottomLeft.Visible = true
end

-- Remove box for a specific player
function BoxESP.Remove(player)
    local box = BoxESP.Boxes[player]
    if not box then return end
    
    -- Hide all lines
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
    -- Create lookup table of valid players
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

print("[Box ESP] Box.lua loaded successfully")
print("[Box ESP] Use _G.QuantumBoxESP to access functions")