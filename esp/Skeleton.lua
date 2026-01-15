-- Skeleton.lua - Optimized Skeleton ESP
-- Draws skeleton connections between body parts

_G.QuantumSkeletonESP = _G.QuantumSkeletonESP or {}
local SkeletonESP = _G.QuantumSkeletonESP

SkeletonESP.Skeletons = {} -- Store all active skeletons

-- Bone connections for R15 (modern) rigs
local R15Connections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    
    -- Left Arm
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    
    -- Right Arm
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    
    -- Left Leg
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    
    -- Right Leg
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

-- Bone connections for R6 (classic) rigs
local R6Connections = {
    {"Head", "Torso"},
    
    -- Arms
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    
    -- Legs
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

-- Create skeleton lines for a player
function SkeletonESP.CreateSkeleton(player)
    if SkeletonESP.Skeletons[player] then
        return SkeletonESP.Skeletons[player]
    end
    
    local skeleton = {
        Lines = {},
        IsR15 = nil,  -- Detect rig type
    }
    
    -- Create 14 lines (max needed for R15)
    for i = 1, 14 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 2
        line.Transparency = 1
        skeleton.Lines[i] = line
    end
    
    SkeletonESP.Skeletons[player] = skeleton
    return skeleton
end

-- Detect if character is R15 or R6
local function DetectRigType(character)
    if character:FindFirstChild("UpperTorso") then
        return "R15"
    elseif character:FindFirstChild("Torso") then
        return "R6"
    end
    return nil
end

-- Get part position on screen
local function GetPartScreenPos(part)
    if not part then return nil end
    
    local Camera = workspace.CurrentCamera
    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
    
    if not onScreen then return nil end
    
    return Vector2.new(pos.X, pos.Y)
end

-- Draw skeleton for a player
function SkeletonESP.Draw(playerData)
    local player = playerData.Player
    local character = playerData.Character
    local skeleton = SkeletonESP.CreateSkeleton(player)
    
    if not character then
        SkeletonESP.Remove(player)
        return
    end
    
    -- Detect rig type
    local rigType = DetectRigType(character)
    if not rigType then
        SkeletonESP.Remove(player)
        return
    end
    
    -- Get connections based on rig type
    local connections = rigType == "R15" and R15Connections or R6Connections
    
    -- Determine skeleton color
    local skeletonColor = Color3.fromRGB(255, 255, 255)
    if _G.QuantumSettings.ESP.ShowTeam and playerData.TeamColor then
        skeletonColor = playerData.TeamColor.Color
    end
    
    -- Draw each bone connection
    local lineIndex = 1
    for _, connection in ipairs(connections) do
        local part1Name = connection[1]
        local part2Name = connection[2]
        
        -- Get parts from character
        local part1 = character:FindFirstChild(part1Name)
        local part2 = character:FindFirstChild(part2Name)
        
        local line = skeleton.Lines[lineIndex]
        
        -- Check if both parts exist and are on screen
        if part1 and part2 then
            -- Get screen positions
            local pos1 = GetPartScreenPos(part1)
            local pos2 = GetPartScreenPos(part2)
            
            -- Draw line if both positions are valid
            if pos1 and pos2 and line then
                line.From = pos1
                line.To = pos2
                line.Color = skeletonColor
                line.Visible = true
            elseif line then
                line.Visible = false
            end
        elseif line then
            -- Hide line if parts are missing
            line.Visible = false
        end
        
        lineIndex = lineIndex + 1
    end
    
    -- Hide unused lines
    for i = lineIndex, #skeleton.Lines do
        if skeleton.Lines[i] then
            skeleton.Lines[i].Visible = false
        end
    end
end

-- Remove skeleton for a specific player
function SkeletonESP.Remove(player)
    local skeleton = SkeletonESP.Skeletons[player]
    if not skeleton then return end
    
    -- Hide all lines
    for _, line in ipairs(skeleton.Lines) do
        if line then
            line.Visible = false
        end
    end
end

-- Delete skeleton completely
function SkeletonESP.Delete(player)
    local skeleton = SkeletonESP.Skeletons[player]
    if not skeleton then return end
    
    -- Remove all line objects
    for _, line in ipairs(skeleton.Lines) do
        if line then
            line:Remove()
        end
    end
    
    SkeletonESP.Skeletons[player] = nil
end

-- Clear all skeletons
function SkeletonESP.ClearAll()
    for player, _ in pairs(SkeletonESP.Skeletons) do
        SkeletonESP.Delete(player)
    end
    SkeletonESP.Skeletons = {}
end

-- Cleanup invalid players
function SkeletonESP.CleanupInvalid(validPlayers)
    local validLookup = {}
    for _, playerData in ipairs(validPlayers) do
        if playerData and playerData.Player then
            validLookup[playerData.Player] = true
        end
    end
    
    -- Remove skeletons for players not in valid list
    for player, _ in pairs(SkeletonESP.Skeletons) do
        if not validLookup[player] then
            SkeletonESP.Delete(player)
        end
    end
end

print("[Skeleton ESP] Skeleton.lua loaded successfully")
print("[Skeleton ESP] Supports both R6 and R15 rigs")
print("[Skeleton ESP] Use _G.QuantumSkeletonESP to access functions")