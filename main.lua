-- Load the UI library from GitHub
local gui = loadstring(game:HttpGet("https://raw.githubusercontent.com/GodFirstAlways/NewUniVAimBet/main/gui/ui.lua"))()

-- Initialize the UI
local ui = gui:Init("TooTrue Aimbot")

-- Create tabs
local mainTab = ui:CreateTab("Main", "🎯")
local miscTab = ui:CreateTab("Misc", "⚙️")

-- Add elements
ui:AddButton(mainTab, "Activate Aimbot", function()
    print("Aimbot activated!")
end)

ui:AddToggle(mainTab, "ESP", false, function(state)
    print("ESP toggled:", state)
end)

ui:AddLabel(miscTab, "Made with TooTrue UI")
