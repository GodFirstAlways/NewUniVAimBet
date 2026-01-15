-- Main loader for Quantum Aimbot
local repo = "https://raw.githubusercontent.com/GodFirstAlways/NewUniVAimBet/main/"

print("=================================")
print("      QUANTUM APEX v2.1")
print("=================================")

-- Load Player Pool FIRST (required by all features)
print("[1/7] Loading Player Pool...")
loadstring(game:HttpGet(repo .. "core/PlayerPool.lua?v=" .. tick()))()
task.wait(0.2)

-- Load ESP modules
print("[2/7] Loading ESP Modules...")
loadstring(game:HttpGet(repo .. "esp/Box.lua?v=" .. tick()))()
loadstring(game:HttpGet(repo .. "esp/Name.lua?v=" .. tick()))()
loadstring(game:HttpGet(repo .. "esp/Skeleton.lua?v=" .. tick()))()
loadstring(game:HttpGet(repo .. "esp/HealthBar.lua?v=" .. tick()))()
loadstring(game:HttpGet(repo .. "esp/Tracer.lua?v=" .. tick()))()
task.wait(0.1)

print("[3/7] Loading ESP Manager...")
loadstring(game:HttpGet(repo .. "esp/Esp.lua?v=" .. tick()))()
task.wait(0.1)

-- Load UI
print("[4/7] Loading UI...")
loadstring(game:HttpGet(repo .. "gui/ui.lua?v=" .. tick()))()
task.wait(0.3)

-- Load Silent Aim
print("[5/7] Loading Silent Aim...")
loadstring(game:HttpGet(repo .. "features/silentaim.lua?v=" .. tick()))()
task.wait(0.2)

-- Load aimbot features (commented out until created)
print("[6/7] Skipping Other Aimbot Features...")
-- loadstring(game:HttpGet(repo .. "features/aimbot.lua"))()
-- loadstring(game:HttpGet(repo .. "features/humanization.lua"))()
-- task.wait(0.2)

-- Initialize ESP system
print("[7/7] Initializing Systems...")
if _G.QuantumESP then
    _G.QuantumESP.Initialize()
end

print("=================================")
print("   ✅ QUANTUM APEX LOADED!")
print("=================================")
print("Silent Aim: " .. (_G.QuantumSilentAim and "✅ Loaded" or "❌ Failed"))
print("ESP: " .. (_G.QuantumESP and "✅ Loaded" or "❌ Failed"))
print("=================================")
print("Press F9 to open console")
print("Use _G.QuantumSilentAim.Debug() for debug info")
print("=================================")