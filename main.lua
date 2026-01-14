local gui = require("gui/mainWindow")

-- Initialize the UI
local ui = gui:Init("My Custom Script")

-- Create tabs
local mainTab = ui:CreateTab("Main", "🏠")
local miscTab = ui:CreateTab("Misc", "⚙️")

-- Add elements
ui:AddButton(mainTab, "Click Me", function()
    print("Button clicked!")
end)

ui:AddToggle(mainTab, "ESP", false, function(state)
    print("ESP:", state)
end)

ui:AddLabel(miscTab, "This is a label")