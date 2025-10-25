--[[
    ScawsHUB - Modular UI Library
    Inspired by Rayfield Interface Suite
    Version: 1.0.0
    
    Features:
    - Sleek dark-themed interface
    - Smooth animations using TweenService
    - Draggable windows
    - Tab system with sidebar
    - Notification system
    - Modular component architecture
    - Performance optimized
    - F2 to terminate script (debug mode)
]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Main Library
local ScawsHub = {}
ScawsHub.__index = ScawsHub

-- Configuration
local Config = {
    -- Animation settings
    AnimationSpeed = 0.5,
    EasingStyle = Enum.EasingStyle.Quint,
    EasingDirection = Enum.EasingDirection.Out,
    
    -- Color scheme (dark theme)
    Colors = {
        Background = Color3.fromRGB(20, 20, 25),
        Topbar = Color3.fromRGB(25, 25, 30),
        Sidebar = Color3.fromRGB(25, 25, 30),
        Main = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(88, 101, 242), -- Discord-like purple
        AccentHover = Color3.fromRGB(108, 121, 262),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 150),
        Border = Color3.fromRGB(40, 40, 45),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(240, 71, 71),
    },
    
    -- UI Settings
    WindowSize = UDim2.new(0, 550, 0, 400),
    SidebarWidth = 150,
}

-- Utility Functions
local Utils = {}

function Utils:Tween(obj, properties, duration, callback)
    duration = duration or Config.AnimationSpeed
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration, Config.EasingStyle, Config.EasingDirection),
        properties
    )
    tween:Play()
    if callback then
        tween.Completed:Connect(callback)
    end
    return tween
end

function Utils:MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Utils:Tween(frame, {
                Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            }, 0.1)
        end
    end)
end

function Utils:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

function Utils:CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.Colors.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

-- Loading Screen
function ScawsHub:CreateLoadingScreen(settings)
    settings = settings or {}
    local title = settings.Title or "ScawsHUB"
    local subtitle = settings.Subtitle or "Loading Interface..."
    local duration = settings.Duration or 3
    
    -- Create ScreenGui
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "ScawsHub_Loading"
    LoadingGui.ResetOnSpawn = false
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        LoadingGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(LoadingGui)
        LoadingGui.Parent = CoreGui
    else
        LoadingGui.Parent = CoreGui
    end
    
    -- Background
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Config.Colors.Background
    Background.BorderSizePixel = 0
    Background.Parent = LoadingGui
    
    -- Loading Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0, 400, 0, 200)
    Container.BackgroundTransparency = 1
    Container.Parent = Background
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Config.Colors.Text
    Title.TextSize = 36
    Title.TextTransparency = 1
    Title.Parent = Container
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, 0, 0, 30)
    Subtitle.Position = UDim2.new(0, 0, 0, 60)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = subtitle
    Subtitle.TextColor3 = Config.Colors.TextDark
    Subtitle.TextSize = 16
    Subtitle.TextTransparency = 1
    Subtitle.Parent = Container
    
    -- Progress Bar Background
    local ProgressBG = Instance.new("Frame")
    ProgressBG.Name = "ProgressBG"
    ProgressBG.Size = UDim2.new(0, 350, 0, 4)
    ProgressBG.Position = UDim2.new(0.5, -175, 0, 120)
    ProgressBG.BackgroundColor3 = Config.Colors.Border
    ProgressBG.BorderSizePixel = 0
    ProgressBG.BackgroundTransparency = 1
    ProgressBG.Parent = Container
    Utils:CreateCorner(ProgressBG, 2)
    
    -- Progress Bar
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Config.Colors.Accent
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = ProgressBG
    Utils:CreateCorner(ProgressBar, 2)
    
    -- Status Text
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Position = UDim2.new(0, 0, 0, 140)
    Status.BackgroundTransparency = 1
    Status.Font = Enum.Font.Gotham
    Status.Text = "Initializing..."
    Status.TextColor3 = Config.Colors.TextDark
    Status.TextSize = 14
    Status.TextTransparency = 1
    Status.Parent = Container
    
    -- Fade in animations
    Utils:Tween(Title, {TextTransparency = 0}, 0.5)
    Utils:Tween(Subtitle, {TextTransparency = 0}, 0.5)
    task.wait(0.3)
    Utils:Tween(ProgressBG, {BackgroundTransparency = 0}, 0.3)
    Utils:Tween(Status, {TextTransparency = 0}, 0.3)
    
    -- Simulate loading
    local loadingSteps = {
        {text = "Initializing components...", progress = 0.2},
        {text = "Loading modules...", progress = 0.4},
        {text = "Setting up interface...", progress = 0.6},
        {text = "Configuring settings...", progress = 0.8},
        {text = "Finalizing...", progress = 1.0},
    }
    
    for _, step in ipairs(loadingSteps) do
        Status.Text = step.text
        Utils:Tween(ProgressBar, {Size = UDim2.new(step.progress, 0, 1, 0)}, 0.5)
        task.wait(duration / #loadingSteps)
    end
    
    -- Fade out
    Status.Text = "Complete!"
    task.wait(0.5)
    Utils:Tween(Background, {BackgroundTransparency = 1}, 0.5)
    Utils:Tween(Title, {TextTransparency = 1}, 0.5)
    Utils:Tween(Subtitle, {TextTransparency = 1}, 0.5)
    Utils:Tween(Status, {TextTransparency = 1}, 0.5)
    Utils:Tween(ProgressBG, {BackgroundTransparency = 1}, 0.5)
    task.wait(0.5)
    
    LoadingGui:Destroy()
end

-- Create Window
function ScawsHub:CreateWindow(settings)
    settings = settings or {}
    local windowTitle = settings.Name or "ScawsHUB"
    local showLoading = settings.ShowLoading ~= false
    
    -- Show loading screen
    if showLoading then
        self:CreateLoadingScreen({
            Title = settings.LoadingTitle or "ScawsHUB",
            Subtitle = settings.LoadingSubtitle or "Initializing...",
            Duration = settings.LoadingDuration or 3
        })
    end
    
    -- Create main ScreenGui
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "ScawsHub_Main"
    MainGui.ResetOnSpawn = false
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        MainGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(MainGui)
        MainGui.Parent = CoreGui
    else
        MainGui.Parent = CoreGui
    end
    
    -- Main Window Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = Config.WindowSize
    Main.BackgroundColor3 = Config.Colors.Background
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = MainGui
    Utils:CreateCorner(Main, 10)
    Utils:CreateStroke(Main, Config.Colors.Border, 1)
    
    -- Drop shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ZIndex = 0
    Shadow.Parent = Main
    
    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Config.Colors.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main
    Utils:CreateCorner(Topbar, 10)
    
    -- Fix topbar corners (only top corners rounded)
    local TopbarFix = Instance.new("Frame")
    TopbarFix.Size = UDim2.new(1, 0, 0, 10)
    TopbarFix.Position = UDim2.new(0, 0, 1, -10)
    TopbarFix.BackgroundColor3 = Config.Colors.Topbar
    TopbarFix.BorderSizePixel = 0
    TopbarFix.Parent = Topbar
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = windowTitle
    TitleLabel.TextColor3 = Config.Colors.Text
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.Position = UDim2.new(1, -10, 0.5, 0)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.BackgroundColor3 = Config.Colors.Error
    CloseButton.BackgroundTransparency = 0.9
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Config.Colors.Text
    CloseButton.TextSize = 16
    CloseButton.Parent = Topbar
    Utils:CreateCorner(CloseButton, 6)
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
    MinimizeButton.Position = UDim2.new(1, -45, 0.5, 0)
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.BackgroundColor3 = Config.Colors.Warning
    MinimizeButton.BackgroundTransparency = 0.9
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Config.Colors.Text
    MinimizeButton.TextSize = 16
    MinimizeButton.Parent = Topbar
    Utils:CreateCorner(MinimizeButton, 6)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.Size = UDim2.new(0, Config.SidebarWidth, 1, -40)
    Sidebar.BackgroundColor3 = Config.Colors.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    
    -- Sidebar separator
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Position = UDim2.new(1, 0, 0, 0)
    Separator.Size = UDim2.new(0, 1, 1, 0)
    Separator.BackgroundColor3 = Config.Colors.Border
    Separator.BorderSizePixel = 0
    Separator.Parent = Sidebar
    
    -- Tab Container (in sidebar)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -10, 1, -10)
    TabContainer.Position = UDim2.new(0, 5, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 4
    TabContainer.ScrollBarImageColor3 = Config.Colors.Accent
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = Sidebar
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContainer
    
    -- Update canvas size when tabs are added
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Position = UDim2.new(0, Config.SidebarWidth, 0, 40)
    ContentArea.Size = UDim2.new(1, -Config.SidebarWidth, 1, -40)
    ContentArea.BackgroundColor3 = Config.Colors.Main
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = Main
    
    -- Make window draggable
    Utils:MakeDraggable(Main, Topbar)
    
    -- Window object
    local Window = {
        Gui = MainGui,
        Main = Main,
        Topbar = Topbar,
        Sidebar = Sidebar,
        TabContainer = TabContainer,
        ContentArea = ContentArea,
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        Minimized = false,
    }
    
    -- Close button functionality
    CloseButton.MouseButton1Click:Connect(function()
        Utils:Tween(CloseButton, {BackgroundTransparency = 0.7}, 0.1, function()
            Utils:Tween(CloseButton, {BackgroundTransparency = 0.9}, 0.1)
        end)
        Utils:Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, function()
            MainGui:Destroy()
        end)
    end)
    
    -- Minimize button functionality
    MinimizeButton.MouseButton1Click:Connect(function()
        Utils:Tween(MinimizeButton, {BackgroundTransparency = 0.7}, 0.1, function()
            Utils:Tween(MinimizeButton, {BackgroundTransparency = 0.9}, 0.1)
        end)
        
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            MinimizeButton.Text = "+"
            Utils:Tween(Main, {Size = UDim2.new(0, Config.WindowSize.X.Offset, 0, 40)}, 0.3)
        else
            MinimizeButton.Text = "−"
            Utils:Tween(Main, {Size = Config.WindowSize}, 0.3)
        end
    end)
    
    -- Button hover effects
    CloseButton.MouseEnter:Connect(function()
        Utils:Tween(CloseButton, {BackgroundTransparency = 0.7}, 0.2)
    end)
    CloseButton.MouseLeave:Connect(function()
        Utils:Tween(CloseButton, {BackgroundTransparency = 0.9}, 0.2)
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        Utils:Tween(MinimizeButton, {BackgroundTransparency = 0.7}, 0.2)
    end)
    MinimizeButton.MouseLeave:Connect(function()
        Utils:Tween(MinimizeButton, {BackgroundTransparency = 0.9}, 0.2)
    end)
    
    -- Create Tab function
    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Name = name
        Tab.Button = nil
        Tab.Content = nil
        Tab.Elements = {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Size = UDim2.new(1, -10, 0, 35)
        TabButton.BackgroundColor3 = Config.Colors.Background
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = "  " .. name
        TabButton.TextColor3 = Config.Colors.TextDark
        TabButton.TextSize = 14
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabContainer
        Utils:CreateCorner(TabButton, 6)
        
        Tab.Button = TabButton
        
        -- Tab Content Frame
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "_Content"
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Config.Colors.Accent
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentArea
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.Parent = TabContent
        
        -- Update canvas size
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        Tab.Content = TabContent
        
        -- Tab button click
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        -- Hover effects
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utils:Tween(TabButton, {BackgroundTransparency = 0.95}, 0.2)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utils:Tween(TabButton, {BackgroundTransparency = 1}, 0.2)
            end
        end)
        
        -- Add tab to window
        table.insert(Window.Tabs, Tab)
        
        -- Select first tab automatically
        if #Window.Tabs == 1 then
            Window:SelectTab(Tab)
        end
        
        -- Create Button function
        function Tab:CreateButton(settings)
            settings = settings or {}
            local buttonName = settings.Name or "Button"
            local callback = settings.Callback or function() end
            
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = buttonName
            ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
            ButtonFrame.BackgroundColor3 = Config.Colors.Background
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Parent = TabContent
            Utils:CreateCorner(ButtonFrame, 6)
            Utils:CreateStroke(ButtonFrame, Config.Colors.Border, 1)
            
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -20, 1, -10)
            Button.Position = UDim2.new(0, 10, 0, 5)
            Button.BackgroundTransparency = 1
            Button.Font = Enum.Font.Gotham
            Button.Text = buttonName
            Button.TextColor3 = Config.Colors.Text
            Button.TextSize = 14
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Parent = ButtonFrame
            
            Button.MouseButton1Click:Connect(function()
                Utils:Tween(ButtonFrame, {BackgroundColor3 = Config.Colors.Accent}, 0.1, function()
                    Utils:Tween(ButtonFrame, {BackgroundColor3 = Config.Colors.Background}, 0.1)
                end)
                callback()
            end)
            
            Button.MouseEnter:Connect(function()
                Utils:Tween(ButtonFrame, {BackgroundColor3 = Config.Colors.Border}, 0.2)
            end)
            
            Button.MouseLeave:Connect(function()
                Utils:Tween(ButtonFrame, {BackgroundColor3 = Config.Colors.Background}, 0.2)
            end)
            
            return ButtonFrame
        end
        
        -- Create Toggle function
        function Tab:CreateToggle(settings)
            settings = settings or {}
            local toggleName = settings.Name or "Toggle"
            local default = settings.Default or false
            local callback = settings.Callback or function() end
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = toggleName
            ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
            ToggleFrame.BackgroundColor3 = Config.Colors.Background
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent
            Utils:CreateCorner(ToggleFrame, 6)
            Utils:CreateStroke(ToggleFrame, Config.Colors.Border, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.Gotham
            Label.Text = toggleName
            Label.TextColor3 = Config.Colors.Text
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.AnchorPoint = Vector2.new(1, 0.5)
            ToggleButton.Position = UDim2.new(1, -10, 0.5, 0)
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.BackgroundColor3 = Config.Colors.Border
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Text = ""
            ToggleButton.Parent = ToggleFrame
            Utils:CreateCorner(ToggleButton, 10)
            
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
            ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
            ToggleIndicator.BackgroundColor3 = Config.Colors.TextDark
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Parent = ToggleButton
            Utils:CreateCorner(ToggleIndicator, 8)
            
            local toggled = default
            
            local function UpdateToggle()
                if toggled then
                    Utils:Tween(ToggleButton, {BackgroundColor3 = Config.Colors.Accent}, 0.2)
                    Utils:Tween(ToggleIndicator, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Config.Colors.Text}, 0.2)
                else
                    Utils:Tween(ToggleButton, {BackgroundColor3 = Config.Colors.Border}, 0.2)
                    Utils:Tween(ToggleIndicator, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Config.Colors.TextDark}, 0.2)
                end
                callback(toggled)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                UpdateToggle()
            end)
            
            UpdateToggle()
            
            return ToggleFrame
        end
        
        -- Create Slider function
        function Tab:CreateSlider(settings)
            settings = settings or {}
            local sliderName = settings.Name or "Slider"
            local min = settings.Min or 0
            local max = settings.Max or 100
            local default = settings.Default or min
            local increment = settings.Increment or 1
            local callback = settings.Callback or function() end
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = sliderName
            SliderFrame.Size = UDim2.new(1, 0, 0, 60)
            SliderFrame.BackgroundColor3 = Config.Colors.Background
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent
            Utils:CreateCorner(SliderFrame, 6)
            Utils:CreateStroke(SliderFrame, Config.Colors.Border, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.Gotham
            Label.Text = sliderName
            Label.TextColor3 = Config.Colors.Text
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.AnchorPoint = Vector2.new(1, 0)
            ValueLabel.Size = UDim2.new(0, 60, 0, 20)
            ValueLabel.Position = UDim2.new(1, -10, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = Config.Colors.Accent
            ValueLabel.TextSize = 14
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local SliderBG = Instance.new("Frame")
            SliderBG.Size = UDim2.new(1, -20, 0, 4)
            SliderBG.Position = UDim2.new(0, 10, 0, 35)
            SliderBG.BackgroundColor3 = Config.Colors.Border
            SliderBG.BorderSizePixel = 0
            SliderBG.Parent = SliderFrame
            Utils:CreateCorner(SliderBG, 2)
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Config.Colors.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBG
            Utils:CreateCorner(SliderFill, 2)
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Size = UDim2.new(1, 0, 1, 20)
            SliderButton.Position = UDim2.new(0, 0, 0, -10)
            SliderButton.BackgroundTransparency = 1
            SliderButton.Text = ""
            SliderButton.Parent = SliderBG
            
            local dragging = false
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                local value = math.floor((min + (max - min) * pos) / increment + 0.5) * increment
                value = math.clamp(value, min, max)
                
                ValueLabel.Text = tostring(value)
                Utils:Tween(SliderFill, {Size = UDim2.new((value - min) / (max - min), 0, 1, 0)}, 0.1)
                callback(value)
            end
            
            SliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    UpdateSlider(input)
                end
            end)
            
            SliderButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
            
            return SliderFrame
        end
        
        -- Create Dropdown function
        function Tab:CreateDropdown(settings)
            settings = settings or {}
            local dropdownName = settings.Name or "Dropdown"
            local options = settings.Options or {}
            local default = settings.Default or (options[1] or "None")
            local callback = settings.Callback or function() end
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = dropdownName
            DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
            DropdownFrame.BackgroundColor3 = Config.Colors.Background
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = TabContent
            DropdownFrame.ClipsDescendants = true
            Utils:CreateCorner(DropdownFrame, 6)
            Utils:CreateStroke(DropdownFrame, Config.Colors.Border, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -40, 0, 40)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.Gotham
            Label.Text = dropdownName .. ": " .. default
            Label.TextColor3 = Config.Colors.Text
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropdownFrame
            
            local Arrow = Instance.new("TextLabel")
            Arrow.AnchorPoint = Vector2.new(1, 0.5)
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Position = UDim2.new(1, -10, 0, 20)
            Arrow.BackgroundTransparency = 1
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Text = "▼"
            Arrow.TextColor3 = Config.Colors.TextDark
            Arrow.TextSize = 10
            Arrow.Parent = DropdownFrame
            
            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Size = UDim2.new(1, 0, 0, #options * 35)
            OptionsContainer.Position = UDim2.new(0, 0, 0, 40)
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.Parent = DropdownFrame
            
            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsLayout.Parent = OptionsContainer
            
            local isOpen = false
            local currentValue = default
            
            local function ToggleDropdown()
                isOpen = not isOpen
                if isOpen then
                    Utils:Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40 + #options * 35)}, 0.3)
                    Utils:Tween(Arrow, {Rotation = 180}, 0.3)
                else
                    Utils:Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.3)
                    Utils:Tween(Arrow, {Rotation = 0}, 0.3)
                end
            end
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(1, 0, 0, 40)
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Text = ""
            DropdownButton.ZIndex = 2
            DropdownButton.Parent = DropdownFrame
            
            DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
            
            for _, option in ipairs(options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, -10, 0, 35)
                OptionButton.BackgroundColor3 = Config.Colors.Border
                OptionButton.BackgroundTransparency = 0.5
                OptionButton.BorderSizePixel = 0
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Text = "  " .. option
                OptionButton.TextColor3 = Config.Colors.Text
                OptionButton.TextSize = 13
                OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                OptionButton.Parent = OptionsContainer
                Utils:CreateCorner(OptionButton, 4)
                
                OptionButton.MouseButton1Click:Connect(function()
                    currentValue = option
                    Label.Text = dropdownName .. ": " .. option
                    ToggleDropdown()
                    callback(option)
                end)
                
                OptionButton.MouseEnter:Connect(function()
                    Utils:Tween(OptionButton, {BackgroundColor3 = Config.Colors.Accent, BackgroundTransparency = 0.3}, 0.2)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Utils:Tween(OptionButton, {BackgroundColor3 = Config.Colors.Border, BackgroundTransparency = 0.5}, 0.2)
                end)
            end
            
            return DropdownFrame
        end
        
        -- Create Label function
        function Tab:CreateLabel(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 30)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.Parent = TabContent
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.Gotham
            Label.Text = text
            Label.TextColor3 = Config.Colors.TextDark
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.Parent = LabelFrame
            
            return {
                Frame = LabelFrame,
                UpdateText = function(newText)
                    Label.Text = newText
                end
            }
        end
        
        return Tab
    end
    
    -- Select tab function
    function Window:SelectTab(tab)
        for _, t in ipairs(self.Tabs) do
            if t == tab then
                Utils:Tween(t.Button, {BackgroundTransparency = 0.9, TextColor3 = Config.Colors.Text}, 0.2)
                t.Content.Visible = true
            else
                Utils:Tween(t.Button, {BackgroundTransparency = 1, TextColor3 = Config.Colors.TextDark}, 0.2)
                t.Content.Visible = false
            end
        end
        self.CurrentTab = tab
    end
    
    return Window
end

-- Notification System
function ScawsHub:CreateNotification(settings)
    settings = settings or {}
    local title = settings.Title or "Notification"
    local content = settings.Content or ""
    local duration = settings.Duration or 5
    local type = settings.Type or "Info" -- Info, Success, Warning, Error
    
    -- Get or create notification container
    local notifGui = game:GetService("CoreGui"):FindFirstChild("ScawsHub_Notifications")
    if not notifGui then
        notifGui = Instance.new("ScreenGui")
        notifGui.Name = "ScawsHub_Notifications"
        notifGui.ResetOnSpawn = false
        notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        if gethui then
            notifGui.Parent = gethui()
        else
            notifGui.Parent = CoreGui
        end
    end
    
    -- Notification frame
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 300, 0, 80)
    Notification.Position = UDim2.new(1, -320, 1, 100)
    Notification.BackgroundColor3 = Config.Colors.Background
    Notification.BorderSizePixel = 0
    Notification.Parent = notifGui
    Utils:CreateCorner(Notification, 8)
    Utils:CreateStroke(Notification, Config.Colors.Border, 1)
    
    -- Color indicator based on type
    local colorMap = {
        Info = Config.Colors.Accent,
        Success = Config.Colors.Success,
        Warning = Config.Colors.Warning,
        Error = Config.Colors.Error
    }
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 4, 1, 0)
    Indicator.BackgroundColor3 = colorMap[type] or Config.Colors.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Notification
    Utils:CreateCorner(Indicator, 8)
    
    -- Fix indicator corner (left side only)
    local IndicatorFix = Instance.new("Frame")
    IndicatorFix.Size = UDim2.new(0, 4, 1, 0)
    IndicatorFix.Position = UDim2.new(0, 4, 0, 0)
    IndicatorFix.BackgroundColor3 = colorMap[type] or Config.Colors.Accent
    IndicatorFix.BorderSizePixel = 0
    IndicatorFix.Parent = Notification
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 15, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Config.Colors.Text
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Notification
    
    -- Content
    local Content = Instance.new("TextLabel")
    Content.Size = UDim2.new(1, -20, 0, 45)
    Content.Position = UDim2.new(0, 15, 0, 30)
    Content.BackgroundTransparency = 1
    Content.Font = Enum.Font.Gotham
    Content.Text = content
    Content.TextColor3 = Config.Colors.TextDark
    Content.TextSize = 13
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextYAlignment = Enum.TextYAlignment.Top
    Content.TextWrapped = true
    Content.Parent = Notification
    
    -- Slide in animation
    local targetPos = UDim2.new(1, -320, 1, -100 - (#notifGui:GetChildren() - 1) * 90)
    Utils:Tween(Notification, {Position = targetPos}, 0.5)
    
    -- Auto dismiss
    task.delay(duration, function()
        Utils:Tween(Notification, {Position = UDim2.new(1, -320, 1, 100)}, 0.5, function()
            Notification:Destroy()
            
            -- Reposition remaining notifications
            for i, notif in ipairs(notifGui:GetChildren()) do
                if notif:IsA("Frame") then
                    Utils:Tween(notif, {
                        Position = UDim2.new(1, -320, 1, -100 - (i - 1) * 90)
                    }, 0.3)
                end
            end
        end)
    end)
end

-- F2 Termination (Debug)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F2 then
        -- Destroy all ScawsHub GUIs
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if string.find(gui.Name, "ScawsHub") then
                gui:Destroy()
            end
        end
        
        -- Try destroying from gethui if available
        if gethui then
            for _, gui in ipairs(gethui():GetChildren()) do
                if string.find(gui.Name, "ScawsHub") then
                    gui:Destroy()
                end
            end
        end

    end
end)

return ScawsHub
