-- Main loader for Quantum Aimbot
local repo = "https://raw.githubusercontent.com/GodFirstAlways/NewUniVAimBet/main/"

print("=================================")
print("      QUANTUM APEX v2.1")
print("=================================")

-- Load Player Pool FIRST (required by all features)
print("[1/6] Loading Player Pool...")
loadstring(game:HttpGet(repo .. "core/PlayerPool.lua"))()
task.wait(0.2)


print("[2/6] Loading ESP Modules...")
loadstring(game:HttpGet(repo .. "esp/Box.lua"))()
loadstring(game:HttpGet(repo .. "esp/Name.lua"))()
loadstring(game:HttpGet(repo .. "esp/Skeleton.lua"))()
task.wait(0.1)

print("[3/6] Loading ESP Manager...")
loadstring(game:HttpGet(repo .. "esp/ESP.lua"))()

-- Load UI
print("[4/6] Loading UI...")
loadstring(game:HttpGet(repo .. "gui/ui.lua"))()
task.wait(0.3)

-- Load aimbot features (commented out until created)
print("[5/6] Skipping Aimbot Features (not created yet)...")
-- loadstring(game:HttpGet(repo .. "features/aimbot.lua"))()
-- loadstring(game:HttpGet(repo .. "features/silentaim.lua"))()
-- loadstring(game:HttpGet(repo .. "features/humanization.lua"))()
-- task.wait(0.2)

-- InitializeESP system
print("[6/6] Initializing ESP...")
if _G.QuantumESP then
    _G.QuantumESP.Initialize()
end

print("=================================")
print("  Quantum Fully Loaded!")
print("  Press RightControl to open UI")
print("=================================")