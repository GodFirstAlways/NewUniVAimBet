-- SilentAim.lua - Hybrid Silent Aim System (FIXED FALLBACK)
-- Manual method selection + Better error handling

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
-- STATE MANAGEMENT
-- ========================================
SilentAim.CurrentMethod = "None"
SilentAim.Active = false
SilentAim.HookInstalled = false
SilentAim.CameraSnapActive = false

-- ========================================
-- EXECUTOR CAPABILITY DETECTION
-- ========================================
local ExecutorCapabilities = {
    Level = 0,
    CanHook = false,
    CanCameraSnap = true, -- Always available
}

local function DetectCapabilities()
    print("[Silent Aim] Detecting executor capabilities...")
    
    -- Test for hookmetamethod
    local hasHookMeta = pcall(function()
        return hookmetamethod ~= nil and getrawmetatable ~= nil and setreadonly ~= nil
    end)
    
    -- Test for getnamecallmethod
    local hasNamecall = pcall(function()
        return getnamecallmethod ~= nil
    end)
    
    if hasHookMeta and hasNamecall then
        ExecutorCapabilities.CanHook = true
        ExecutorCapabilities.Level = 6
        print("[Silent Aim] ✅ Level 6+ executor - Hooking available")
    else
        ExecutorCapabilities.CanHook = false
        ExecutorCapabilities.Level = 1
        print("[Silent Aim] ⚠️ Low-level executor - Only camera snap available")
    end
    
    return ExecutorCapabilities
end

DetectCapabilities()

-- ========================================
-- SHARED UTILITIES
-- ========================================

local function GetTarget()
    if not _G.QuantumPlayerPool or #_G.QuantumPlayerPool == 0 then
        return nil
    end
    
    local settings = _G.QuantumSettings.SilentAim
    
    local filterSettings = {
        TeamCheck = settings.TeamCheck,
        FOV = settings.FOV,
    }
    
    local target = _G.QuantumHelpers.GetClosestToCenter(filterSettings)
    if not target then return nil end
    
    local targetPart = target.Parts[settings.AimPart] or target.Head
    if not targetPart then return nil end
    
    -- Hit chance check
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
-- METHOD 1: NAMECALL HOOK
-- ========================================

local OldNamecall = nil

local function SetupNamecallHook()
    if not ExecutorCapabilities.CanHook then
        warn("[Silent Aim] ❌ Executor doesn't support hooking")
        return false
    end
    
    print("[Silent Aim] Attempting to install namecall hook...")
    
    local success, err = pcall(function()
        local mt = getrawmetatable(game)
        local old_namecall = mt.__namecall
        
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(...)
            local args = {...}
            local self = args[1]
            local method = getnamecallmethod()
            
            -- Check if silent aim is enabled
            if not _G.QuantumSettings.SilentAim.Enabled then
                return old_namecall(...)
            end
            
            -- Check if method is active
            if SilentAim.CurrentMethod ~= "Namecall Hook" then
                return old_namecall(...)
            end
            
            -- Check for shooting remotes
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = self.Name:lower()
                
                -- Common shooting remote patterns
                if remoteName:find("shoot") or remoteName:find("fire") or 
                   remoteName:find("gun") or remoteName:find("bullet") or
                   remoteName:find("damage") or remoteName:find("hit") then
                    
                    local target = GetTarget()
                    
                    if target then
                        print("[Silent Aim] 🎯 Hooking shot - Target: " .. target.Player.Name)
                        
                        -- Modify arguments
                        for i = 2, #args do
                            local arg = args[i]
                            
                            -- Replace Vector3 positions
                            if typeof(arg) == "Vector3" then
                                args[i] = target.Position
                            end
                            
                            -- Replace BasePart instances
                            if typeof(arg) == "Instance" and arg:IsA("BasePart") then
                                args[i] = target.Part
                            end
                            
                            -- Replace CFrame
                            if typeof(arg) == "CFrame" then
                                args[i] = target.Part.CFrame
                            end
                            
                            -- Modify tables
                            if type(arg) == "table" then
                                if arg.Position then arg.Position = target.Position end
                                if arg.Hit then arg.Hit = target.Part end
                                if arg.Target then arg.Target = target.Part end
                                if arg.Part then arg.Part = target.Part end
                                if arg.CFrame then arg.CFrame = target.Part.CFrame end
                            end
                        end
                    end
                end
            end
            
            return old_namecall(...)
        end)
        
        setreadonly(mt, true)
        OldNamecall = old_namecall
    end)
    
    if success then
        SilentAim.HookInstalled = true
        SilentAim.CurrentMethod = "Namecall Hook"
        print("[Silent Aim] ✅ Namecall hook installed successfully!")
        return true
    else
        warn("[Silent Aim] ❌ Failed to install hook: " .. tostring(err))
        return false
    end
end

local function RemoveNamecallHook()
    if OldNamecall and SilentAim.HookInstalled then
        pcall(function()
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            mt.__namecall = OldNamecall
            setreadonly(mt, true)
        end)
        SilentAim.HookInstalled = false
        print("[Silent Aim] ✅ Namecall hook removed")
    end
end

-- ========================================
-- METHOD 2: CAMERA SNAP
-- ========================================

local CameraSnap = {
    OriginalCFrame = nil,
    IsSnapping = false,
    Connection = nil,
    LastShotTime = 0
}

local function IsPlayerShooting()
    -- Check Mouse1 down
    local mouse1Down = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    
    if not mouse1Down then return false end
    
    -- Check tool equipped
    local character = LocalPlayer.Character
    if not character then return false end
    
    local tool = character:FindFirstChildOfClass("Tool")
    return tool ~= nil
end

local function PerformCameraSnap(target)
    if CameraSnap.IsSnapping then return end
    
    -- Prevent rapid snapping
    local currentTime = tick()
    if currentTime - CameraSnap.LastShotTime < 0.1 then return end
    
    CameraSnap.LastShotTime = currentTime
    CameraSnap.IsSnapping = true
    
    -- Save original position
    CameraSnap.OriginalCFrame = Camera.CFrame
    
    -- Calculate aim position
    local targetPos = target.Position
    local camPos = Camera.CFrame.Position
    local lookAt = CFrame.new(camPos, targetPos)
    
    print("[Silent Aim] 📷 Camera snap - Target: " .. target.Player.Name)
    
    -- FRAME 1: Snap to target
    Camera.CFrame = lookAt
    
    -- Wait 2 frames (0.033s at 60fps)
    RunService.RenderStepped:Wait()
    RunService.RenderStepped:Wait()
    
    -- FRAME 3: Snap back
    if CameraSnap.OriginalCFrame then
        Camera.CFrame = CameraSnap.OriginalCFrame
    end
    
    CameraSnap.IsSnapping = false
end

local function SetupCameraSnap()
    print("[Silent Aim] Setting up camera snap method...")
    
    if CameraSnap.Connection then
        CameraSnap.Connection:Disconnect()
    end
    
    CameraSnap.Connection = RunService.RenderStepped:Connect(function()
        if not _G.QuantumSettings.SilentAim.Enabled then return end
        if SilentAim.CurrentMethod ~= "Camera Snap" then return end
        if CameraSnap.IsSnapping then return end
        
        if IsPlayerShooting() then
            local target = GetTarget()
            if target then
                task.spawn(function()
                    PerformCameraSnap(target)
                end)
            end
        end
    end)
    
    SilentAim.CameraSnapActive = true
    SilentAim.CurrentMethod = "Camera Snap"
    print("[Silent Aim] ✅ Camera snap active")
    return true
end

local function RemoveCameraSnap()
    if CameraSnap.Connection then
        CameraSnap.Connection:Disconnect()
        CameraSnap.Connection = nil
        SilentAim.CameraSnapActive = false
        print("[Silent Aim] ✅ Camera snap disconnected")
    end
end

-- ========================================
-- METHOD SWITCHING
-- ========================================

function SilentAim.SetMethod(method)
    print("[Silent Aim] Switching to method: " .. method)
    
    -- Disable current method
    RemoveNamecallHook()
    RemoveCameraSnap()
    SilentAim.CurrentMethod = "None"
    
    -- Enable new method
    if method == "Namecall Hook" then
        if ExecutorCapabilities.CanHook then
            local success = SetupNamecallHook()
            if not success then
                warn("[Silent Aim] Hook failed! Falling back to camera snap...")
                return SilentAim.SetMethod("Camera Snap")
            end
            _G.QuantumSettings.SilentAim.Method = "Namecall Hook"
        else
            warn("[Silent Aim] ❌ Your executor doesn't support hooking!")
            return SilentAim.SetMethod("Camera Snap")
        end
    elseif method == "Camera Snap" then
        SetupCameraSnap()
        _G.QuantumSettings.SilentAim.Method = "Camera Snap"
    elseif method == "Auto" then
        -- Try hook first, fallback to camera snap
        if ExecutorCapabilities.CanHook then
            local success = SetupNamecallHook()
            if not success then
                print("[Silent Aim] Hook failed, using camera snap...")
                SetupCameraSnap()
            end
        else
            SetupCameraSnap()
        end
        _G.QuantumSettings.SilentAim.Method = "Auto"
    end
    
    print("[Silent Aim] ✅ Now using: " .. SilentAim.CurrentMethod)
end

-- ========================================
-- INITIALIZATION
-- ========================================

function SilentAim.Initialize()
    print("========================================")
    print("  QUANTUM SILENT AIM - HYBRID SYSTEM")
    print("========================================")
    
    if not _G.QuantumPlayerPool or not _G.QuantumHelpers then
        warn("[Silent Aim] ❌ Dependencies not loaded!")
        return false
    end
    
    -- Use the method from settings
    local method = _G.QuantumSettings.SilentAim.Method or "Auto"
    SilentAim.SetMethod(method)
    
    SilentAim.Active = true
    print("[Silent Aim] ✅ Initialized successfully!")
    print("[Silent Aim] Executor Level: " .. ExecutorCapabilities.Level)
    print("[Silent Aim] Can Hook: " .. tostring(ExecutorCapabilities.CanHook))
    print("[Silent Aim] Current Method: " .. SilentAim.CurrentMethod)
    print("========================================")
    
    return true
end

-- ========================================
-- CONTROL FUNCTIONS
-- ========================================

function SilentAim.GetStatus()
    return {
        Active = SilentAim.Active,
        Enabled = _G.QuantumSettings.SilentAim.Enabled,
        CurrentMethod = SilentAim.CurrentMethod,
        HookInstalled = SilentAim.HookInstalled,
        CameraSnapActive = SilentAim.CameraSnapActive,
        ExecutorLevel = ExecutorCapabilities.Level,
        CanHook = ExecutorCapabilities.CanHook
    }
end

function SilentAim.Debug()
    local status = SilentAim.GetStatus()
    print("========================================")
    print("  SILENT AIM DEBUG")
    print("========================================")
    print("Enabled: " .. tostring(status.Enabled))
    print("Current Method: " .. status.CurrentMethod)
    print("Hook Installed: " .. tostring(status.HookInstalled))
    print("Camera Snap Active: " .. tostring(status.CameraSnapActive))
    print("Executor Level: " .. status.ExecutorLevel)
    print("Can Hook: " .. tostring(status.CanHook))
    
    local target = GetTarget()
    if target then
        print("Current Target: " .. target.Player.Name)
    else
        print("Current Target: None")
    end
    print("========================================")
end

function SilentAim.Unload()
    RemoveNamecallHook()
    RemoveCameraSnap()
    SilentAim.Active = false
    print("[Silent Aim] ✅ Unloaded")
end

-- ========================================
-- AUTO-INITIALIZE
-- ========================================

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
    
    task.wait(1)
    SilentAim.Initialize()
end)

print("[Silent Aim] ✅ Module loaded")
print("[Silent Aim] Use _G.QuantumSilentAim.Debug() for status")