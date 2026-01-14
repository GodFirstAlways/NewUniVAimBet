-- Main loader for Quantum Aimbot
local repo = "https://raw.githubusercontent.com/GodFirstAlways/NewUniVAimBet/main/"

print("Loading Quantum...")

-- Load UI first
loadstring(game:HttpGet(repo .. "gui/ui.lua"))()

-- Wait for UI to initialize
task.wait(0.5)

-- Load core features
loadstring(game:HttpGet(repo .. "aimbot.lua"))()
loadstring(game:HttpGet(repo .. "silentaim.lua"))()
loadstring(game:HttpGet(repo .. "humanization.lua"))()
loadstring(game:HttpGet(repo .. "esp.lua"))()

print("Quantum fully loaded!")