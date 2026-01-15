-- SilentAim.lua - Hybrid Silent Aim System
-- Intelligently uses best method based on executor capabilities
-- Works on ALL executors (Level 1 to Level 7+)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

_G.QuantumSilentAim = _G.QuantumSilentAim or {}
local SilentAim = _G.QuantumSilentAim

-- ========================================
-- EXECUTOR CAPABILITY DETECTION
-- ========================================
local ExecutorCapabilities = {
    Level = 0,
    HasNamecallHook = false,
    HasIndexHook = false,
    HasNewIndexHook = false,
    Method = "None"
}

-- Detect executor capabilities
local function DetectCapabilities()
    print("[Silent Aim] Detecting executor capabilities...")
    
    local level = 0
    
    -- Test for hookmetamethod (Level 6+)
    local hasHookMeta = pcall(function()
        local test = hookmetamethod
        return test ~= nil
    end)
    
    -- Test for getnamecallmethod (Level 4+)
    local hasNamecall = pcall(function()
        local test = getnamecallmethod
        return test ~= nil
    end)
    
    -- Test for hookfunction (Level 5+)
    local hasHookFunc = pcall(function()
        local test = hookfunction
        return test ~= nil
    end)
    
    -- Determine level and capabilities
    if hasHookMeta and hasNamecall then
        level = 6
        ExecutorCapabilities.HasNamecallHook = true
        ExecutorCapabilities.Method = "Namecall Hook (Best)"
        print("[Silent Aim] ✅ Level 6+ detected - Using TRUE silent aim (hooking)")
    elseif hasHookFunc then
        level = 5
        ExecutorCapabilities.HasIndexHook = true
        ExecutorCapabilities.Method = "Function Hook"
        print("[Silent Aim] ✅ Level 5 detected - Using function hooking")
    else
        level = 1
        ExecutorCapabilities.Method = "Camera Snap (Universal)"
        print("[Silent Aim] ⚠️ Low-level executor detected")
        print("[Silent Aim] ✅ Using CAMERA SNAP method (works on all executors)")
    end
    
    ExecutorCapabilities.Level = level
    return ExecutorCapabilities
end

-- Run detection
DetectCapabilities()

-- ========================================
-- SHARED UTILITIES
-- ========================================

-- Get target based on settings
local function GetTarget()
    if not _G.QuantumPlayerPool or #_G.QuantumPlayerPool == 0 then
        return nil
    end
    
    local settings = _G.QuantumSettings.SilentAim
    
    -- Filter settings
    local filterSettings = {
        TeamCheck = settings.TeamCheck,
        FOV = settings.FOV,
    }
    
    -- Get closest to center (crosshair)
    local target = _G.QuantumHelpers.GetClosestToCenter(filterSettings)
    
    if not target then return nil end
    
    -- Get target part
    local targetPart = target.Parts[settings.AimPart] or target.Head
    if not targetPart then return nil end
    
    -- Check hit chance
    if math.random(1, 100) > settings.HitChance then
        return nil
    end
    
    return {
        Player = target.Player,
        Part = targetPart,
        Position = targetPart.Position,
        Character = target.Character
    }
end

-- ========================================
-- METHOD 1: TRUE SILENT AIM (HIGH-LEVEL)
-- ========================================

local NamecallHook = nil
local OldNamecall = nil

local function SetupNamecallHook()
    if not ExecutorCapabilities.HasNamecallHook then
        return false
    end
    
    print("[Silent Aim] Setting up namecall hook...")
    
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(...)
        local args = {...}
        local method = getnamecallmethod()
        
        -- Check if this is a shooting remote
        if method == "FireServer" or method == "InvokeServer" then
            if _G.QuantumSettings.SilentAim.Enabled then
                local target = GetTarget()
                
                if target then
                    -- Modify arguments to hit target
                    -- This is game-specific, but common patterns:
                    
                    -- Pattern 1: Args contain position/part directly
                    for i, arg in ipairs(args) do
                        if typeof(arg) == "Vector3" then
                            args[i] = target.Position
                        elseif typeof(arg) == "Instance" and arg:IsA("BasePart") then
                            args[i] = target.Part
                        elseif typeof(arg) == "CFrame" then
                            args[i] = target.Part.CFrame
                        end
                    end
                    
                    -- Pattern 2: Args contain table with hit info
                    for i, arg in ipairs(args) do
                        if type(arg) == "table" then
                            if arg.Position then
                                arg.Position = target.Position
                            end
                            if arg.Hit then
                                arg.Hit = target.Part
                            end
                            if arg.Target then
                                arg.Target = target.Part
                            end
                            if arg.Part then
                                arg.Part = target.Part
                            end
                            if arg.CFrame then
                                arg.CFrame = target.Part.CFrame
                            end
                        end
                    end
                end
            end
        end
        
        return old_namecall(unpack(args))
    end)
    
    setreadonly(mt, true)
    OldNamecall = old_namecall
    
    print("[Silent Aim] ✅ Namecall hook installed successfully")
    return true
end

-- ========================================
-- METHOD 2: CAMERA SNAP (LOW-LEVEL)
-- ========================================

local CameraSnap = {
    Active = false,
    OriginalCFrame = nil,
    SnapStartTick = 0,
    SnapDuration = 0.033, -- 2 frames at 60fps
    IsSnapping = false,
    Connection = nil
}

-- Detect shooting (game-agnostic)
local function IsPlayerShooting()
    -- Method 1: Check if Mouse1 is down
    local mouse1Down = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    
    -- Method 2: Check if player has a tool equipped
    local character = LocalPlayer.Character
    if not character then return false end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return false end
    
    -- Method 3: Check if tool is activated
    -- (Some games use tool.Activated event)
    
    return mouse1Down and tool ~= nil
end

-- Perform camera snap
local function PerformCameraSnap(target)
    if CameraSnap.IsSnapping then return end
    
    -- Save original camera position
    CameraSnap.OriginalCFrame = Camera.CFrame
    CameraSnap.IsSnapping = true
    CameraSnap.SnapStartTick = tick()
    
    -- Calculate look-at position (aim at target part)
    local targetPos = target.Position
    local camPos = Camera.CFrame.Position
    local lookAt = CFrame.new(camPos, targetPos)
    
    -- SNAP TO TARGET (instant)
    Camera.CFrame = lookAt
    
    -- Schedule snap back after 2 frames
    task.wait(CameraSnap.SnapDuration)
    
    if CameraSnap.OriginalCFrame then
        -- SNAP BACK (instant)
        Camera.CFrame = CameraSnap.OriginalCFrame
    end
    
    CameraSnap.IsSnapping = false
end

-- Camera snap loop
local function SetupCameraSnap()
    print("[Silent Aim] Setting up camera snap method...")
    
    -- Listen for shooting
    CameraSnap.Connection = RunService.RenderStepped:Connect(function()
        if not _G.QuantumSettings.SilentAim.Enabled then return end
        if CameraSnap.IsSnapping then return end
        
        -- Check if player is shooting
        if IsPlayerShooting() then
            local target = GetTarget()
            
            if target then
                -- Perform camera snap
                task.spawn(function()
                    PerformCameraSnap(target)
                end)
            end
        end
    end)
    
    print("[Silent Aim] ✅ Camera snap method ready")
    return true
end

-- ========================================
-- INITIALIZATION
-- ========================================

function SilentAim.Initialize()
    print("========================================")
    print("  QUANTUM SILENT AIM - HYBRID SYSTEM")
    print("========================================")
    
    -- Check dependencies
    if not _G.QuantumPlayerPool then
        warn("[Silent Aim] ❌ Player Pool not loaded!")
        return false
    end
    
    if not _G.QuantumHelpers then
        warn("[Silent Aim] ❌ Helper functions not loaded!")
        return false
    end
    
    -- Setup based on executor capabilities
    local success = false
    
    if ExecutorCapabilities.HasNamecallHook then
        -- Try high-level method first
        success = SetupNamecallHook()
        
        if not success then
            warn("[Silent Aim] Hooking failed, falling back to camera snap...")
            ExecutorCapabilities.Method = "Camera Snap (Fallback)"
            success = SetupCameraSnap()
        end
    else
        -- Use low-level method
        success = SetupCameraSnap()
    end
    
    if success then
        print("[Silent Aim] ✅ Silent Aim initialized successfully!")
        print("[Silent Aim] Method: " .. ExecutorCapabilities.Method)
        print("[Silent Aim] Executor Level: " .. ExecutorCapabilities.Level)
        SilentAim.Active = true
    else
        warn("[Silent Aim] ❌ Failed to initialize silent aim")
    end
    
    return success
end

-- ========================================
-- CONTROL FUNCTIONS
-- ========================================

function SilentAim.Enable()
    _G.QuantumSettings.SilentAim.Enabled = true
    print("[Silent Aim] ✅ Silent Aim enabled")
end

function SilentAim.Disable()
    _G.QuantumSettings.SilentAim.Enabled = false
    print("[Silent Aim] ⭕ Silent Aim disabled")
end

function SilentAim.Toggle()
    _G.QuantumSettings.SilentAim.Enabled = not _G.QuantumSettings.SilentAim.Enabled
    if _G.QuantumSettings.SilentAim.Enabled then
        print("[Silent Aim] ✅ Silent Aim enabled")
    else
        print("[Silent Aim] ⭕ Silent Aim disabled")
    end
end

function SilentAim.GetStatus()
    return {
        Active = SilentAim.Active,
        Enabled = _G.QuantumSettings.SilentAim.Enabled,
        Method = ExecutorCapabilities.Method,
        Level = ExecutorCapabilities.Level,
        SupportsHooking = ExecutorCapabilities.HasNamecallHook
    }
end

function SilentAim.Unload()
    print("[Silent Aim] Unloading...")
    
    -- Restore namecall hook
    if OldNamecall then
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        mt.__namecall = OldNamecall
        setreadonly(mt, true)
        print("[Silent Aim] ✅ Namecall hook restored")
    end
    
    -- Disconnect camera snap
    if CameraSnap.Connection then
        CameraSnap.Connection:Disconnect()
        CameraSnap.Connection = nil
        print("[Silent Aim] ✅ Camera snap disconnected")
    end
    
    print("[Silent Aim] ✅ Silent Aim unloaded")
end

-- ========================================
-- DEBUG FUNCTIONS
-- ========================================

function SilentAim.Debug()
    print("========================================")
    print("  SILENT AIM DEBUG INFO")
    print("========================================")
    print("Executor Level: " .. ExecutorCapabilities.Level)
    print("Method: " .. ExecutorCapabilities.Method)
    print("Has Namecall Hook: " .. tostring(ExecutorCapabilities.HasNamecallHook))
    print("Active: " .. tostring(SilentAim.Active))
    print("Enabled: " .. tostring(_G.QuantumSettings.SilentAim.Enabled))
    print("Camera Snapping: " .. tostring(CameraSnap.IsSnapping))
    
    local target = GetTarget()
    if target then
        print("Current Target: " .. target.Player.Name)
        print("Target Part: " .. tostring(target.Part))
    else
        print("Current Target: None")
    end
    print("========================================")
end

-- ========================================
-- AUTO-INITIALIZE
-- ========================================

-- Auto-initialize when loaded
print("[Silent Aim] Module loaded, waiting for dependencies...")

-- Wait for dependencies
task.spawn(function()
    local attempts = 0
    while not _G.QuantumPlayerPool or not _G.QuantumHelpers do
        task.wait(0.5)
        attempts = attempts + 1
        
        if attempts > 10 then
            warn("[Silent Aim] ❌ Timeout waiting for dependencies")
            return
        end
    end
    
    -- Initialize after dependencies are ready
    task.wait(1)
    SilentAim.Initialize()
end)

print("[Silent Aim] ✅ Module ready")
print("[Silent Aim] Use _G.QuantumSilentAim.Debug() for info")
print("[Silent Aim] Use _G.QuantumSilentAim.Toggle() to control")