-- Using Linoria UI Library (Lightweight & Optimized)
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

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
        Method = "Camera Snap"
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
        ShowHealthText = false,
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
    }
}

-- Create Window
local Window = Library:CreateWindow({
    Title = 'TooTrue',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Create Tabs
local Tabs = {
    Main = Window:AddTab('Aimbot'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- ========================================
-- AIMBOT TAB
-- ========================================
local AimbotBox = Tabs.Main:AddLeftGroupbox('Standard Aimbot')

AimbotBox:AddToggle('AimbotEnabled', {
    Text = 'Enable Aimbot',
    Default = false,
    Tooltip = 'Toggle aimbot on/off (Hold RMB to aim)',
    Callback = function(Value)
        _G.QuantumSettings.Aimbot.Enabled = Value
    end
})

AimbotBox:AddToggle('AimbotTeamCheck', {
    Text = 'Team Check',
    Default = false,
    Tooltip = "Don't aim at teammates",
    Callback = function(Value)
        _G.QuantumSettings.Aimbot.TeamCheck = Value
    end
})

AimbotBox:AddToggle('AimbotVisCheck', {
    Text = 'Visible Check',
    Default = true,
    Tooltip = 'Only aim at visible players',
    Callback = function(Value)
        _G.QuantumSettings.Aimbot.VisibleCheck = Value
    end
})

AimbotBox:AddToggle('AimbotIgnoreWalls', {
    Text = 'Ignore Walls',
    Default = false,
    Tooltip = 'Aim through walls',
    Callback = function(Value)
        _G.QuantumSettings.Aimbot.IgnoreWalls = Value
    end
})

AimbotBox:AddToggle('AimbotPredict', {
    Text = 'Predict Movement',
    Default = false,
    Tooltip = 'Predict player movement',
    Callback = function(Value)
        _G.QuantumSettings.Aimbot.PredictMovement = Value
    end
})

AimbotBox:AddSlider('AimbotFOV', {
    Text = 'FOV Radius',
    Default = 80,
    Min = 20,
    Max = 300,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        _G.QuantumSettings.Aimbot.FOV = Value
    end
})

AimbotBox:AddSlider('AimbotSmoothness', {
    Text = 'Smoothness',
    Default = 8,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        _G.QuantumSettings.Aimbot.Smoothness = Value
    end
})

AimbotBox:AddDropdown('AimbotAimPart', {
    Values = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso'},
    Default = 1,
    Multi = false,
    Text = 'Target Part',
    Tooltip = 'Body part to aim at',
    Callback = function(Value)
        _G.QuantumSettings.Aimbot.AimPart = Value
    end
})

-- Silent Aim
local SilentAimBox = Tabs.Main:AddRightGroupbox('Silent Aim')

SilentAimBox:AddToggle('SilentAimEnabled', {
    Text = 'Enable Silent Aim',
    Default = false,
    Tooltip = 'Automatically hit targets without moving camera',
    Callback = function(Value)
        _G.QuantumSettings.SilentAim.Enabled = Value
    end
})

SilentAimBox:AddToggle('SilentAimTeamCheck', {
    Text = 'Team Check',
    Default = false,
    Tooltip = "Don't hit teammates",
    Callback = function(Value)
        _G.QuantumSettings.SilentAim.TeamCheck = Value
    end
})

SilentAimBox:AddSlider('SilentAimFOV', {
    Text = 'FOV Radius',
    Default = 100,
    Min = 20,
    Max = 300,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        _G.QuantumSettings.SilentAim.FOV = Value
    end
})

SilentAimBox:AddSlider('SilentAimHitChance', {
    Text = 'Hit Chance %',
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        _G.QuantumSettings.SilentAim.HitChance = Value
    end
})

SilentAimBox:AddDropdown('SilentAimPart', {
    Values = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso'},
    Default = 1,
    Multi = false,
    Text = 'Target Part',
    Tooltip = 'Body part to hit',
    Callback = function(Value)
        _G.QuantumSettings.SilentAim.AimPart = Value
    end
})

SilentAimBox:AddDivider()

SilentAimBox:AddDropdown('SilentAimMethod', {
    Values = {'Camera Snap', 'Namecall Hook'},
    Default = 1,
    Multi = false,
    Text = 'Method',
    Tooltip = 'Camera Snap = Works everywhere\nNamecall Hook = High-level only',
    Callback = function(Value)
        if _G.QuantumSilentAim and _G.QuantumSilentAim.SetMethod then
            _G.QuantumSilentAim.SetMethod(Value)
        end
    end
})

SilentAimBox:AddButton({
    Text = 'Debug Info (F9)',
    Func = function()
        if _G.QuantumSilentAim and _G.QuantumSilentAim.Debug then
            _G.QuantumSilentAim.Debug()
        end
    end
})

-- Humanization
local HumanizationBox = Tabs.Main:AddRightGroupbox('Humanization')

HumanizationBox:AddToggle('HumanizationEnabled', {
    Text = 'Enable Humanization',
    Default = false,
    Tooltip = 'Make aimbot look more human-like',
    Callback = function(Value)
        _G.QuantumSettings.Humanization.Enabled = Value
    end
})

HumanizationBox:AddSlider('HumanizationShake', {
    Text = 'Aim Shake',
    Default = 2,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        _G.QuantumSettings.Humanization.Shake = Value
    end
})

HumanizationBox:AddSlider('HumanizationPrediction', {
    Text = 'Prediction Value',
    Default = 0.13,
    Min = 0,
    Max = 0.5,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        _G.QuantumSettings.Humanization.Prediction = Value
    end
})

HumanizationBox:AddSlider('HumanizationReaction', {
    Text = 'Reaction Time (ms)',
    Default = 50,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        _G.QuantumSettings.Humanization.ReactionTime = Value
    end
})

HumanizationBox:AddToggle('HumanizationAutoShoot', {
    Text = 'Auto Shoot',
    Default = false,
    Tooltip = 'Automatically shoot when target is locked',
    Callback = function(Value)
        _G.QuantumSettings.Humanization.AutoShoot = Value
    end
})

-- ========================================
-- VISUALS TAB
-- ========================================
local ESPBox = Tabs.Visuals:AddLeftGroupbox('ESP Features')

ESPBox:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
    Tooltip = 'See players through walls',
    Callback = function(Value)
        _G.QuantumSettings.ESP.Enabled = Value
        
        -- Initialize ESP if not done yet
        if Value and _G.QuantumESP and not _G.QuantumESP.Active then
            local success = _G.QuantumESP.Initialize()
            if success then
                _G.QuantumESP.Start()
            else
                Library:Notify('ESP failed to initialize. Check console.', 5)
            end
        elseif not Value and _G.QuantumESP then
            _G.QuantumESP.Stop()
        end
    end
})

ESPBox:AddDivider()

ESPBox:AddToggle('ESPBoxes', {
    Text = 'Box ESP',
    Default = true,
    Tooltip = 'Draw boxes around players',
    Callback = function(Value)
        _G.QuantumSettings.ESP.Boxes = Value
    end
})

ESPBox:AddToggle('ESPNames', {
    Text = 'Name ESP',
    Default = true,
    Tooltip = 'Show player names',
    Callback = function(Value)
        _G.QuantumSettings.ESP.Names = Value
    end
})

ESPBox:AddToggle('ESPDistance', {
    Text = 'Distance ESP',
    Default = false,
    Tooltip = 'Show distance to players',
    Callback = function(Value)
        _G.QuantumSettings.ESP.Distance = Value
    end
})

ESPBox:AddToggle('ESPHealth', {
    Text = 'Health Bar',
    Default = true,
    Tooltip = 'Show health bars',
    Callback = function(Value)
        _G.QuantumSettings.ESP.Health = Value
    end
})

ESPBox:AddToggle('ESPHealthText', {
    Text = 'Health Text',
    Default = false,
    Tooltip = 'Show health as text',
    Callback = function(Value)
        _G.QuantumSettings.ESP.ShowHealthText = Value
    end
})

ESPBox:AddToggle('ESPTracers', {
    Text = 'Tracers',
    Default = false,
    Tooltip = 'Draw lines to players',
    Callback = function(Value)
        _G.QuantumSettings.ESP.Tracers = Value
    end
})

ESPBox:AddToggle('ESPSkeleton', {
    Text = 'Skeleton ESP',
    Default = false,
    Tooltip = 'Show player skeleton',
    Callback = function(Value)
        _G.QuantumSettings.ESP.Skeleton = Value
    end
})

-- ESP Settings
local ESPSettingsBox = Tabs.Visuals:AddRightGroupbox('ESP Settings')

ESPSettingsBox:AddToggle('ESPTeamCheck', {
    Text = 'Team Check',
    Default = false,
    Tooltip = "Don't show teammates",
    Callback = function(Value)
        _G.QuantumSettings.ESP.TeamCheck = Value
    end
})

ESPSettingsBox:AddToggle('ESPShowTeam', {
    Text = 'Show Team Colors',
    Default = true,
    Tooltip = 'Color ESP by team',
    Callback = function(Value)
        _G.QuantumSettings.ESP.ShowTeam = Value
    end
})

ESPSettingsBox:AddLabel('Box Color'):AddColorPicker('ESPBoxColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Box Color',
    Transparency = 0,
    Callback = function(Value)
        _G.QuantumSettings.ESP.BoxColor = Value
    end
})

-- ========================================
-- MISC TAB
-- ========================================
local FOVBox = Tabs.Misc:AddLeftGroupbox('FOV Circle')

FOVBox:AddToggle('FOVCircle', {
    Text = 'Show FOV Circle',
    Default = true,
    Tooltip = 'Display aimbot FOV circle',
    Callback = function(Value)
        _G.QuantumSettings.Misc.FOVCircle = Value
    end
})

FOVBox:AddLabel('FOV Color'):AddColorPicker('FOVColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'FOV Color',
    Transparency = 0,
    Callback = function(Value)
        _G.QuantumSettings.Misc.FOVColor = Value
    end
})

local MovementBox = Tabs.Misc:AddLeftGroupbox('Movement')

MovementBox:AddToggle('InfiniteJump', {
    Text = 'Infinite Jump',
    Default = false,
    Tooltip = 'Jump infinitely',
    Callback = function(Value)
        _G.QuantumSettings.Misc.InfiniteJump = Value
    end
})

MovementBox:AddToggle('SpeedHack', {
    Text = 'Speed Hack',
    Default = false,
    Tooltip = 'Increase walk speed',
    Callback = function(Value)
        _G.QuantumSettings.Misc.SpeedHack = Value
    end
})

MovementBox:AddSlider('SpeedValue', {
    Text = 'Speed Amount',
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        _G.QuantumSettings.Misc.SpeedValue = Value
    end
})

local CombatBox = Tabs.Misc:AddRightGroupbox('Combat')

CombatBox:AddToggle('RemoveRecoil', {
    Text = 'No Recoil',
    Default = false,
    Tooltip = 'Remove weapon recoil',
    Callback = function(Value)
        _G.QuantumSettings.Misc.RemoveRecoil = Value
    end
})

CombatBox:AddToggle('AntiLock', {
    Text = 'Anti-Lock',
    Default = false,
    Tooltip = 'Counter enemy aimbot',
    Callback = function(Value)
        _G.QuantumSettings.Misc.AntiLock = Value
    end
})

-- ========================================
-- UI SETTINGS TAB
-- ========================================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({'MenuKeybind'})

ThemeManager:SetFolder('QuantumApex')
SaveManager:SetFolder('QuantumApex/configs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])

ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()

-- UI Toggle Keybind
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightControl', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

-- Notify loaded
Library:Notify('Quantum Apex v2.1 Loaded!', 5)

print("[Quantum UI] Linoria UI loaded successfully")
print("[Quantum UI] Ultra-lightweight & optimized")