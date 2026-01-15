-- Main loader
local repo = "https://raw.githubusercontent.com/GodFirstAlways/NewUniVAimBet/main/"

print("[1/5] Player Pool...")
loadstring(game:HttpGet(repo .. "core/PlayerPool.lua"))()
task.wait(0.2)

print("[2/5] ESP...")
loadstring(game:HttpGet(repo .. "esp/Box.lua"))()
loadstring(game:HttpGet(repo .. "esp/Name.lua"))()
loadstring(game:HttpGet(repo .. "esp/Skeleton.lua"))()
loadstring(game:HttpGet(repo .. "esp/HealthBar.lua"))()
loadstring(game:HttpGet(repo .. "esp/Tracer.lua"))()
loadstring(game:HttpGet(repo .. "esp/Esp.lua"))()
task.wait(0.1)

print("[3/5] UI...")
loadstring(game:HttpGet(repo .. "gui/ui.lua"))()
task.wait(0.2)

print("[4/5] Silent Aim...")
loadstring(game:HttpGet(repo .. "features/SilentAim.lua"))()
task.wait(0.2)

print("[5/5] Init...")
if _G.QuantumESP then
    _G.QuantumESP.Initialize()
end

print("✅ Loaded")