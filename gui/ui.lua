-- Using Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Quantum Apex",
    SubTitle = "Universal Aimbot v2.1",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
    ESP = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Config = Window:AddTab({ Title = "Config", Icon = "folder" }),
}

-- Settings Storage
_G.QuantumSettings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        VisibleCheck = true,
        FOV = 80,
        Smoothness = 8,
        AimPart = "Head",
        IgnoreWalls = false,
        PredictMovement = false
    },
    SilentAim = {
        Enabled = false,
        TeamCheck = false,
        FOV = 100,
        HitChance = 100,
        AimPart = "Head",
        Method = "Namecall"
    },
    Humanization = {
        Enabled = false,
        Shake = 2,
        Prediction = 0.13,
        AutoShoot = false,
        ReactionTime = 50
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Distance = false,
        Health = true,
        Tracers = false,
        TeamCheck = false,
        BoxColor = Color3.fromRGB(255, 255, 255),
        ShowTeam = true,
        Skeleton = false,
        Chams = false
    },
    Misc = {
        FOVCircle = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
        RemoveRecoil = false,
        InfiniteJump = false,
        SpeedHack = false,
        SpeedValue = 16,
        AntiLock = false
    },
    Config = {
        AutoSave = true,
        ConfigName = "default"
    }
}

-- Home Tab
local WelcomeSection = Tabs.Home:AddSection("Welcome")

Tabs.Home:AddParagraph({
    Title = "Quantum Apex",
    Content = "Universal aimbot system for Roblox FPS games. Configure your settings in the tabs above."
})

local StatsSection = Tabs.Home:AddSection("Statistics")

local StatusLabel = Tabs.Home:AddParagraph({
    Title = "Status",
    Content = "Waiting for modules..."
})

local GameInfo = Tabs.Home:AddParagraph({
    Title = "Game Info",
    Content = "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "\nPlace ID: " .. game.PlaceId
})

Tabs.Home:AddButton({
    Title = "Copy Game Link",
    Description = "Copy current game link to clipboard",
    Callback = function()
        setclipboard("https://www.roblox.com/games/" .. game.PlaceId)
        Fluent:Notify({
            Title = "Copied",
            Content = "Game link copied to clipboard!",
            Duration = 3
        })
    end
})

Tabs.Home:AddButton({
    Title = "Rejoin Server",
    Description = "Rejoin current server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

local CreditsSection = Tabs.Home:AddSection("Credits")

Tabs.Home:AddParagraph({
    Title = "Developer",
    Content = "Created by GodFirstAlways\nVersion: 2.1.0\nLast Updated: " .. os.date("%m/%d/%Y")
})

-- Aimbot Tab
local AimbotSection = Tabs.Aimbot:AddSection("Standard Aimbot")

Tabs.Aimbot:AddToggle("AimbotEnabled", {
    Title = "Enable Aimbot",
    Description = "Toggle aimbot on/off (Hold RMB to aim)",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.Aimbot.Enabled = v
    end
})

Tabs.Aimbot:AddToggle("AimbotTeamCheck", {
    Title = "Team Check",
    Description = "Don't aim at teammates",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.Aimbot.TeamCheck = v
    end
})

Tabs.Aimbot:AddToggle("AimbotVisCheck", {
    Title = "Visible Check",
    Description = "Only aim at visible players",
    Default = true,
    Callback = function(v)
        _G.QuantumSettings.Aimbot.VisibleCheck = v
    end
})

Tabs.Aimbot:AddToggle("AimbotIgnoreWalls", {
    Title = "Ignore Walls",
    Description = "Aim through walls",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.Aimbot.IgnoreWalls = v
    end
})

Tabs.Aimbot:AddToggle("AimbotPredict", {
    Title = "Predict Movement",
    Description = "Predict player movement",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.Aimbot.PredictMovement = v
    end
})

Tabs.Aimbot:AddSlider("AimbotFOV", {
    Title = "FOV Radius",
    Description = "Field of view circle size",
    Default = 80,
    Min = 20,
    Max = 300,
    Rounding = 0,
    Callback = function(v)
        _G.QuantumSettings.Aimbot.FOV = v
    end
})

Tabs.Aimbot:AddSlider("AimbotSmoothness", {
    Title = "Smoothness",
    Description = "How smooth the aimbot moves (higher = smoother)",
    Default = 8,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Callback = function(v)
        _G.QuantumSettings.Aimbot.Smoothness = v
    end
})

Tabs.Aimbot:AddDropdown("AimbotAimPart", {
    Title = "Target Part",
    Description = "Body part to aim at",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Default = 1,
    Callback = function(v)
        _G.QuantumSettings.Aimbot.AimPart = v
    end
})

-- Silent Aim Section
local SilentAimSection = Tabs.Aimbot:AddSection("Silent Aim")

Tabs.Aimbot:AddToggle("SilentAimEnabled", {
    Title = "Enable Silent Aim",
    Description = "Automatically hit targets without moving camera",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.SilentAim.Enabled = v
    end
})

Tabs.Aimbot:AddToggle("SilentAimTeamCheck", {
    Title = "Team Check",
    Description = "Don't hit teammates",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.SilentAim.TeamCheck = v
    end
})

Tabs.Aimbot:AddSlider("SilentAimFOV", {
    Title = "FOV Radius",
    Description = "Detection range for silent aim",
    Default = 100,
    Min = 20,
    Max = 300,
    Rounding = 0,
    Callback = function(v)
        _G.QuantumSettings.SilentAim.FOV = v
    end
})

Tabs.Aimbot:AddSlider("SilentAimHitChance", {
    Title = "Hit Chance %",
    Description = "Chance to hit target (anti-detection)",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        _G.QuantumSettings.SilentAim.HitChance = v
    end
})

Tabs.Aimbot:AddDropdown("SilentAimPart", {
    Title = "Target Part",
    Description = "Body part to hit",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Default = 1,
    Callback = function(v)
        _G.QuantumSettings.SilentAim.AimPart = v
    end
})

Tabs.Aimbot:AddDropdown("SilentAimMethod", {
    Title = "Hook Method",
    Description = "Method to hook remote events",
    Values = {"Namecall", "Index", "Auto"},
    Default = 1,
    Callback = function(v)
        _G.QuantumSettings.SilentAim.Method = v
    end
})

-- Humanization Section
local HumanizationSection = Tabs.Aimbot:AddSection("Humanization")

Tabs.Aimbot:AddToggle("HumanizationEnabled", {
    Title = "Enable Humanization",
    Description = "Make aimbot look more human-like",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.Humanization.Enabled = v
    end
})

Tabs.Aimbot:AddSlider("HumanizationShake", {
    Title = "Aim Shake",
    Description = "Random shake intensity",
    Default = 2,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(v)
        _G.QuantumSettings.Humanization.Shake = v
    end
})

Tabs.Aimbot:AddSlider("HumanizationPrediction", {
    Title = "Prediction Value",
    Description = "Movement prediction amount",
    Default = 0.13,
    Min = 0,
    Max = 0.5,
    Rounding = 2,
    Callback = function(v)
        _G.QuantumSettings.Humanization.Prediction = v
    end
})

Tabs.Aimbot:AddSlider("HumanizationReaction", {
    Title = "Reaction Time (ms)",
    Description = "Delay before aiming at new target",
    Default = 50,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        _G.QuantumSettings.Humanization.ReactionTime = v
    end
})

Tabs.Aimbot:AddToggle("HumanizationAutoShoot", {
    Title = "Auto Shoot",
    Description = "Automatically shoot when target is locked",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.Humanization.AutoShoot = v
    end
})

-- ESP Tab (Visuals)
local ESPSection = Tabs.ESP:AddSection("Player ESP")

Tabs.ESP:AddToggle("ESPEnabled", {
    Title = "Enable ESP",
    Description = "See players through walls",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.ESP.Enabled = v
        
        -- Initialize ESP if not done yet
        if v and _G.QuantumESP and not _G.QuantumESP.Active then
            local success = _G.QuantumESP.Initialize()
            if success then
                _G.QuantumESP.Start()
            else
                Fluent:Notify({
                    Title = "ESP Error",
                    Content = "Failed to initialize ESP. Check console.",
                    Duration = 5
                })
            end
        elseif not v and _G.QuantumESP then
            _G.QuantumESP.Stop()
        end
    end
})

Tabs.ESP:AddToggle("ESPBoxes", {
    Title = "Box ESP",
    Description = "Draw boxes around players",
    Default = true,
    Callback = function(v)
        _G.QuantumSettings.ESP.Boxes = v
    end
})

Tabs.ESP:AddToggle("ESPNames", {
    Title = "Name ESP",
    Description = "Show player names",
    Default = true,
    Callback = function(v)
        _G.QuantumSettings.ESP.Names = v
    end
})

Tabs.ESP:AddToggle("ESPDistance", {
    Title = "Distance ESP",
    Description = "Show distance to players",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.ESP.Distance = v
    end
})

Tabs.ESP:AddToggle("ESPHealth", {
    Title = "Health Bar",
    Description = "Show health bars",
    Default = true,
    Callback = function(v)
        _G.QuantumSettings.ESP.Health = v
    end
})

Tabs.ESP:AddToggle("ESPTracers", {
    Title = "Tracers",
    Description = "Draw lines to players",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.ESP.Tracers = v
    end
})

Tabs.ESP:AddToggle("ESPSkeleton", {
    Title = "Skeleton ESP",
    Description = "Show player skeleton",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.ESP.Skeleton = v
    end
})

Tabs.ESP:AddToggle("ESPChams", {
    Title = "Chams",
    Description = "Highlight players through walls",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.ESP.Chams = v
    end
})

Tabs.ESP:AddToggle("ESPTeamCheck", {
    Title = "Team Check",
    Description = "Don't show teammates",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.ESP.TeamCheck = v
    end
})

Tabs.ESP:AddToggle("ESPShowTeam", {
    Title = "Show Team Colors",
    Description = "Color ESP by team",
    Default = true,
    Callback = function(v)
        _G.QuantumSettings.ESP.ShowTeam = v
    end
})

-- Misc Tab
local FOVSection = Tabs.Misc:AddSection("FOV Circle")

Tabs.Misc:AddToggle("FOVCircle", {
    Title = "Show FOV Circle",
    Description = "Display aimbot FOV circle",
    Default = true,
    Callback = function(v)
        _G.QuantumSettings.Misc.FOVCircle = v
    end
})

Tabs.Misc:AddColorpicker("FOVColor", {
    Title = "FOV Color",
    Description = "Circle color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(v)
        _G.QuantumSettings.Misc.FOVColor = v
    end
})

local MovementSection = Tabs.Misc:AddSection("Movement")

Tabs.Misc:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Description = "Jump infinitely",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.Misc.InfiniteJump = v
    end
})

Tabs.Misc:AddToggle("SpeedHack", {
    Title = "Speed Hack",
    Description = "Increase walk speed",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.Misc.SpeedHack = v
    end
})

Tabs.Misc:AddSlider("SpeedValue", {
    Title = "Speed Amount",
    Description = "Walk speed multiplier",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        _G.QuantumSettings.Misc.SpeedValue = v
    end
})

local CombatSection = Tabs.Misc:AddSection("Combat")

Tabs.Misc:AddToggle("RemoveRecoil", {
    Title = "No Recoil",
    Description = "Remove weapon recoil",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.Misc.RemoveRecoil = v
    end
})

Tabs.Misc:AddToggle("AntiLock", {
    Title = "Anti-Lock",
    Description = "Counter enemy aimbot",
    Default = false,
    Callback = function(v)
        _G.QuantumSettings.Misc.AntiLock = v
    end
})

-- Config Tab
local ConfigSection = Tabs.Config:AddSection("Configuration")

Tabs.Config:AddToggle("AutoSave", {
    Title = "Auto Save",
    Description = "Automatically save settings",
    Default = true,
    Callback = function(v)
        _G.QuantumSettings.Config.AutoSave = v
    end
})

Tabs.Config:AddInput("ConfigName", {
    Title = "Config Name",
    Description = "Name for your configuration",
    Default = "default",
    Placeholder = "Enter config name...",
    Callback = function(v)
        _G.QuantumSettings.Config.ConfigName = v
    end
})

Tabs.Config:AddButton({
    Title = "Save Config",
    Description = "Save current settings",
    Callback = function()
        -- Config save logic will be in separate module
        Fluent:Notify({
            Title = "Config",
            Content = "Config saved successfully!",
            Duration = 3
        })
    end
})

Tabs.Config:AddButton({
    Title = "Load Config",
    Description = "Load saved settings",
    Callback = function()
        -- Config load logic will be in separate module
        Fluent:Notify({
            Title = "Config",
            Content = "Config loaded successfully!",
            Duration = 3
        })
    end
})

Tabs.Config:AddButton({
    Title = "Reset to Default",
    Description = "Reset all settings",
    Callback = function()
        -- Reset logic will be in separate module
        Fluent:Notify({
            Title = "Config",
            Content = "Settings reset to default!",
            Duration = 3
        })
    end
})

local DebuggingSection = Tabs.Config:AddSection("Debugging")

Tabs.Config:AddButton({
    Title = "Print Settings",
    Description = "Print current settings to console",
    Callback = function()
        print("=== Quantum Settings ===")
        for category, settings in pairs(_G.QuantumSettings) do
            print("\n[" .. category .. "]")
            for setting, value in pairs(settings) do
                print("  " .. setting .. " = " .. tostring(value))
            end
        end
    end
})

Tabs.Config:AddButton({
    Title = "Destroy UI",
    Description = "Close and remove the UI",
    Callback = function()
        Fluent:Destroy()
    end
})

-- Load notification
Fluent:Notify({
    Title = "Quantum Apex",
    Content = "UI Loaded - Ready for modules",
    Duration = 5
})