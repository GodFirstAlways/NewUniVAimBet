-- gui/mainWindow.lua
-- Custom UI Library - Fully customizable

local Library = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Customization Settings (CHANGE THESE TO CUSTOMIZE YOUR UI)
Library.Theme = {
    -- Main Colors
    Background = Color3.fromRGB(25, 25, 30),
    Topbar = Color3.fromRGB(35, 35, 40),
    TabBackground = Color3.fromRGB(30, 30, 35),
    
    -- Accent Colors
    Accent = Color3.fromRGB(88, 101, 242), -- Discord purple, change to your favorite color!
    AccentHover = Color3.fromRGB(108, 121, 255),
    
    -- Element Colors
    ElementBackground = Color3.fromRGB(40, 40, 45),
    ElementBackgroundHover = Color3.fromRGB(50, 50, 55),
    
    -- Text Colors
    TitleText = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(200, 200, 200),
    DisabledText = Color3.fromRGB(120, 120, 120),
    
    -- Toggle Colors
    ToggleOn = Color3.fromRGB(67, 181, 129),
    ToggleOff = Color3.fromRGB(80, 80, 85),
    
    -- Other
    CornerRadius = 10,
    FontSize = isMobile and 16 or 14,
    TitleFontSize = isMobile and 20 or 18,
}

-- Animation Settings
Library.AnimationSpeed = 0.2

function Library:Init(title)
    title = title or "My Custom UI"
    
    -- Remove existing GUI if present
    local existing = playerGui:FindFirstChild("CustomUILib")
    if existing then existing:Destroy() end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomUILib"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, isMobile and 55 or 45, 0, isMobile and 55 or 45)
    toggleBtn.Position = UDim2.new(0, 15, 0, 80)
    toggleBtn.BackgroundColor3 = self.Theme.Accent
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = screenGui
    
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0.5, 0)
    
    local toggleIcon = Instance.new("ImageLabel")
    toggleIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
    toggleIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Image = "rbxassetid://3926305904"
    toggleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    toggleIcon.ImageRectOffset = Vector2.new(644, 204)
    toggleIcon.ImageRectSize = Vector2.new(36, 36)
    toggleIcon.Parent = toggleBtn
    
    -- Main Container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, isMobile and 350 or 500, 0, isMobile and 450 or 550)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = self.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, self.Theme.CornerRadius)
    
    -- Drop shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.ZIndex = 0
    shadow.Parent = mainFrame
    
    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, isMobile and 55 or 45)
    topbar.BackgroundColor3 = self.Theme.Topbar
    topbar.BorderSizePixel = 0
    topbar.Parent = mainFrame
    
    local topbarCorner = Instance.new("UICorner")
    topbarCorner.CornerRadius = UDim.new(0, self.Theme.CornerRadius)
    topbarCorner.Parent = topbar
    
    -- Fix for topbar rounded corners at bottom
    local topbarFix = Instance.new("Frame")
    topbarFix.Size = UDim2.new(1, 0, 0, self.Theme.CornerRadius)
    topbarFix.Position = UDim2.new(0, 0, 1, -self.Theme.CornerRadius)
    topbarFix.BackgroundColor3 = self.Theme.Topbar
    topbarFix.BorderSizePixel = 0
    topbarFix.Parent = topbar
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.Theme.TitleText
    titleLabel.TextSize = self.Theme.TitleFontSize
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topbar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, isMobile and 40 or 35, 0, isMobile and 40 or 35)
    closeBtn.Position = UDim2.new(1, isMobile and -47 or -42, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = isMobile and 18 or 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = topbar
    
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, isMobile and 70 or 60, 1, isMobile and -60 or -50)
    tabContainer.Position = UDim2.new(0, 5, 0, isMobile and 60 or 50)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = tabContainer
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, isMobile and -80 or -70, 1, isMobile and -65 or -55)
    contentContainer.Position = UDim2.new(0, isMobile and 75 or 65, 0, isMobile and 60 or 50)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    
    -- Toggle functionality
    local isOpen = false
    
    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        mainFrame.Visible = isOpen
        
        local tween = TweenService:Create(toggleBtn, TweenInfo.new(self.AnimationSpeed), {
            Rotation = isOpen and 90 or 0
        })
        tween:Play()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        isOpen = false
        mainFrame.Visible = false
        toggleBtn.Rotation = 0
    end)
    
    -- Hover effects
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
    end)
    
    -- Make draggable
    self:MakeDraggable(topbar, mainFrame)
    
    -- Store references
    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.TabContainer = tabContainer
    self.ContentContainer = contentContainer
    self.Tabs = {}
    self.CurrentTab = nil
    
    return self
end

function Library:MakeDraggable(handle, frame)
    local dragging = false
    local dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Library:CreateTab(name, icon)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name
    tabButton.Size = UDim2.new(1, 0, 0, isMobile and 60 or 50)
    tabButton.BackgroundColor3 = self.Theme.TabBackground
    tabButton.Text = ""
    tabButton.AutoButtonColor = false
    tabButton.Parent = self.TabContainer
    
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 8)
    
    -- Tab icon (you can change icons later)
    local tabIcon = Instance.new("TextLabel")
    tabIcon.Size = UDim2.new(1, 0, 1, 0)
    tabIcon.BackgroundTransparency = 1
    tabIcon.Text = icon or "📁"
    tabIcon.TextSize = isMobile and 24 or 20
    tabIcon.Parent = tabButton
    
    -- Content frame for this tab
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, -10, 1, -10)
    tabContent.Position = UDim2.new(0, 5, 0, 5)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = self.Theme.Accent
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.Visible = false
    tabContent.Parent = self.ContentContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = tabContent
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Tab switching
    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = self.Theme.TabBackground
        end
        
        tabContent.Visible = true
        tabButton.BackgroundColor3 = self.Theme.Accent
        self.CurrentTab = tabContent
    end)
    
    -- Hover effect
    tabButton.MouseEnter:Connect(function()
        if tabButton.BackgroundColor3 ~= self.Theme.Accent then
            TweenService:Create(tabButton, TweenInfo.new(0.1), {BackgroundColor3 = self.Theme.ElementBackgroundHover}):Play()
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if tabButton.BackgroundColor3 ~= self.Theme.Accent then
            TweenService:Create(tabButton, TweenInfo.new(0.1), {BackgroundColor3 = self.Theme.TabBackground}):Play()
        end
    end)
    
    -- Store tab
    local tab = {
        Button = tabButton,
        Content = tabContent,
        Elements = {}
    }
    
    self.Tabs[name] = tab
    
    -- Make first tab active
    if not self.CurrentTab then
        tabButton.BackgroundColor3 = self.Theme.Accent
        tabContent.Visible = true
        self.CurrentTab = tabContent
    end
    
    return tab
end

function Library:AddButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, isMobile and 45 or 38)
    button.BackgroundColor3 = self.Theme.ElementBackground
    button.Text = text
    button.TextColor3 = self.Theme.TitleText
    button.TextSize = self.Theme.FontSize
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = tab.Content
    
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    
    button.MouseButton1Click:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = self.Theme.Accent}):Play()
        wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = self.Theme.ElementBackground}):Play()
        
        callback()
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = self.Theme.ElementBackgroundHover}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = self.Theme.ElementBackground}):Play()
    end)
    
    return button
end

function Library:AddToggle(tab, text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, isMobile and 45 or 38)
    toggleFrame.BackgroundColor3 = self.Theme.ElementBackground
    toggleFrame.Parent = tab.Content
    
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Theme.TitleText
    label.TextSize = self.Theme.FontSize
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, isMobile and 45 or 40, 0, isMobile and 25 or 22)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, 0)
    toggleBtn.AnchorPoint = Vector2.new(0, 0.5)
    toggleBtn.BackgroundColor3 = default and self.Theme.ToggleOn or self.Theme.ToggleOff
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = toggleFrame
    
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, isMobile and 19 or 16, 0, isMobile and 19 or 16)
    circle.Position = default and UDim2.new(1, isMobile and -22 or -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    circle.AnchorPoint = Vector2.new(0, 0.5)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggleBtn
    
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local state = default
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        
        TweenService:Create(toggleBtn, TweenInfo.new(self.AnimationSpeed), {
            BackgroundColor3 = state and self.Theme.ToggleOn or self.Theme.ToggleOff
        }):Play()
        
        TweenService:Create(circle, TweenInfo.new(self.AnimationSpeed), {
            Position = state and UDim2.new(1, isMobile and -22 or -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        }):Play()
        
        callback(state)
    end)
    
    return toggleFrame
end

function Library:AddLabel(tab, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, isMobile and 35 or 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Theme.SubText
    label.TextSize = self.Theme.FontSize
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = tab.Content
    
    return label
end

return Library