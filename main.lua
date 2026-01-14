-- Main loader for Quantum Aimbot
local repo = "https://raw.githubusercontent.com/GodFirstAlways/NewUniVAimBet/main/"

print("=================================")
print("      QUANTUM APEX v2.1")
print("=================================")

-- Load Player Pool FIRST (required by all features)
print("[1/6] Loading Player Pool...")
loadstring(game:HttpGet(repo .. "core/PlayerPool.lua"))()
task.wait(0.2)

-- Load ESP modules
print("[2/6] Loading Box ESP...")
loadstring(game:HttpGet(repo .. "esp/Box.lua"))()
task.wait(0.1)

print("[3/6] Loading ESP Manager...")
loadstring(game:HttpGet(repo .. "esp/ESP.lua"))()
task.wait(0.1)

-- Load UI
print("[4/6] Loading UI...")
loadstring(game:HttpGet(repo .. "gui/ui.lua"))()
task.wait(0.3)

-- Load aimbot features
print("[5/6] Loading Aimbot Features...")
loadstring(game:HttpGet(repo .. "features/aimbot.lua"))()
loadstring(game:HttpGet(repo .. "features/silentaim.lua"))()
loadstring(game:HttpGet(repo .. "features/humanization.lua"))()
task.wait(0.2)

-- Initialize ESP system
print("[6/6] Initializing ESP...")
if _G.QuantumESP then
    _G.QuantumESP.Initialize()
end

print("=================================")
print("  Quantum Fully Loaded!")
print("  Press RightControl to open UI")
print("=================================")