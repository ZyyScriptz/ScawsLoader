local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local ScawsHub = {}
ScawsHub.__index = ScawsHub

local Config = {
    AnimationSpeed = 0.45,
    EasingStyle = Enum.EasingStyle.Quart,
    EasingDirection = Enum.EasingDirection.Out,
    
    Colors = {
        Background = Color3.fromRGB(28, 28, 35),
        Topbar = Color3.fromRGB(32, 32, 40),
        Sidebar = Color3.fromRGB(32, 32, 40),
        Main = Color3.fromRGB(35, 35, 42),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(108, 121, 262),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(160, 160, 170),
        Border = Color3.fromRGB(50, 50, 58),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(240, 71, 71),
    },
    
    WindowSize = UDim2.new(0, 550, 0, 400),
    SidebarWidth = 150,
}

local SessionStartTime = tick()

local Utils = {}

function Utils:Tween(obj, properties, duration, callback)
    duration = duration or Config.AnimationSpeed
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    if callback then
        tween.Completed:Connect(callback)
    end
    return tween
end

function Utils:Spring(obj, properties, duration)
    duration = duration or 0.4
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

function Utils:SmoothFade(obj, targetTransparency, duration)
    duration = duration or 0.3
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {BackgroundTransparency = targetTransparency}
    )
    tween:Play()
    return tween
end

function Utils:MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            local tween = TweenService:Create(
                frame,
                TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                {
                    Position = UDim2.new(
                        framePos.X.Scale,
                        framePos.X.Offset + delta.X,
                        framePos.Y.Scale,
                        framePos.Y.Offset + delta.Y
                    )
                }
            )
            tween:Play()
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
    stroke.Transparency = 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function ScawsHub:CreateLoadingScreen(settings)
    settings = settings or {}
    local imageId = "rbxassetid://119216623675384"
    local duration = settings.Duration or 3
    
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "ScawsHub_Loading"
    LoadingGui.ResetOnSpawn = false
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LoadingGui.IgnoreGuiInset = true
    
    if gethui then
        LoadingGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(LoadingGui)
        LoadingGui.Parent = CoreGui
    else
        LoadingGui.Parent = CoreGui
    end
    
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 1, 0)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.Parent = LoadingGui
    
    local ImageLabel = Instance.new("ImageLabel")
    ImageLabel.Name = "Logo"
    ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel.Size = UDim2.new(0, 300, 0, 300)
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.Image = imageId
    ImageLabel.ImageTransparency = 1
    ImageLabel.ScaleType = Enum.ScaleType.Fit
    ImageLabel.Parent = Container
    
    print("[ScawsHUB] Loading image:", imageId)
    
    Utils:Tween(ImageLabel, {ImageTransparency = 0, Size = UDim2.new(0, 400, 0, 400)}, 1.2)
    
    task.wait(duration)
    
    Utils:Tween(Container, {BackgroundTransparency = 1}, 0.6)
    Utils:Tween(ImageLabel, {ImageTransparency = 1, Size = UDim2.new(0, 450, 0, 450)}, 0.6, function()
        task.wait(0.1)
        LoadingGui:Destroy()
    end)
end

function ScawsHub:CreateWindow(settings)
    settings = settings or {}
    local windowTitle = settings.Name or "ScawsHUB"
    local showLoading = settings.ShowLoading ~= false
    
    if showLoading then
        self:CreateLoadingScreen({
            Duration = settings.LoadingDuration or 3
        })
    end
    
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "ScawsHub_Main"
    MainGui.ResetOnSpawn = false
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.IgnoreGuiInset = true
    
    if gethui then
        MainGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(MainGui)
        MainGui.Parent = CoreGui
    else
        MainGui.Parent = CoreGui
    end
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.BackgroundColor3 = Config.Colors.Background
    Main.BackgroundTransparency = 0.15
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = false
    Main.Parent = MainGui
    Utils:CreateCorner(Main, 16)
    Utils:CreateStroke(Main, Config.Colors.Border, 1)
    
    local MainInner = Instance.new("Frame")
    MainInner.Name = "MainInner"
    MainInner.Size = UDim2.new(1, 0, 1, 0)
    MainInner.Position = UDim2.new(0, 0, 0, 0)
    MainInner.BackgroundTransparency = 1
    MainInner.ClipsDescendants = true
    MainInner.BorderSizePixel = 0
    MainInner.Parent = Main
    Utils:CreateCorner(MainInner, 16)
    
    Utils:Tween(Main, {Size = Config.WindowSize}, 0.8)
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 45, 1, 45)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.2
    Shadow.ZIndex = 0
    Shadow.Parent = Main
    
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundColor3 = Config.Colors.Topbar
    Topbar.BackgroundTransparency = 0.15
    Topbar.BorderSizePixel = 0
    Topbar.ClipsDescendants = true
    Topbar.Parent = MainInner
    Utils:CreateCorner(Topbar, 16)
    
    local TopbarFix = Instance.new("Frame")
    TopbarFix.Size = UDim2.new(1, 0, 0, 20)
    TopbarFix.Position = UDim2.new(0, 0, 1, -20)
    TopbarFix.BackgroundColor3 = Config.Colors.Topbar
    TopbarFix.BackgroundTransparency = 0.15
    TopbarFix.BorderSizePixel = 0
    TopbarFix.Parent = Topbar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 18, 0, -5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = windowTitle
    TitleLabel.TextColor3 = Config.Colors.Text
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    
    local CreditsLabel = Instance.new("TextLabel")
    CreditsLabel.Name = "Credits"
    CreditsLabel.Size = UDim2.new(0, 100, 1, 0)
    CreditsLabel.Position = UDim2.new(0, 18, 0, 15)
    CreditsLabel.BackgroundTransparency = 1
    CreditsLabel.Font = Enum.Font.Gotham
    CreditsLabel.Text = "by ScawsHub"
    CreditsLabel.TextColor3 = Config.Colors.TextDark
    CreditsLabel.TextSize = 9
    CreditsLabel.TextXAlignment = Enum.TextXAlignment.Left
    CreditsLabel.TextTransparency = 0.6
    CreditsLabel.Parent = Topbar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.Position = UDim2.new(1, -8, 0.5, 0)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.BackgroundColor3 = Config.Colors.Border
    CloseButton.BackgroundTransparency = 0.6
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Config.Colors.Text
    CloseButton.TextSize = 18
    CloseButton.Parent = Topbar
    Utils:CreateCorner(CloseButton, 15)
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
    MinimizeButton.Position = UDim2.new(1, -43, 0.5, 0)
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.BackgroundColor3 = Config.Colors.Border
    MinimizeButton.BackgroundTransparency = 0.6
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Config.Colors.Text
    MinimizeButton.TextSize = 16
    MinimizeButton.Parent = Topbar
    Utils:CreateCorner(MinimizeButton, 15)
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.Size = UDim2.new(0, Config.SidebarWidth, 1, -45)
    Sidebar.BackgroundColor3 = Config.Colors.Sidebar
    Sidebar.BackgroundTransparency = 0.15
    Sidebar.BorderSizePixel = 0
    Sidebar.ClipsDescendants = true
    Sidebar.Parent = MainInner
    
    local SidebarBottomFix = Instance.new("Frame")
    SidebarBottomFix.Name = "BottomFix"
    SidebarBottomFix.Size = UDim2.new(1, 2, 0, 20)
    SidebarBottomFix.Position = UDim2.new(0, -1, 1, -20)
    SidebarBottomFix.BackgroundColor3 = Config.Colors.Sidebar
    SidebarBottomFix.BackgroundTransparency = 0.15
    SidebarBottomFix.BorderSizePixel = 0
    SidebarBottomFix.Parent = Sidebar
    
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Position = UDim2.new(1, 0, 0, 0)
    Separator.Size = UDim2.new(0, 1, 1, 0)
    Separator.BackgroundColor3 = Config.Colors.Border
    Separator.BackgroundTransparency = 0.5
    Separator.BorderSizePixel = 0
    Separator.Parent = Sidebar
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -10, 1, -10)
    TabContainer.Position = UDim2.new(0, 5, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 4
    TabContainer.ScrollBarImageColor3 = Config.Colors.Accent
    TabContainer.ScrollBarImageTransparency = 0.3
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = Sidebar
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 8)
    TabLayout.Parent = TabContainer
    
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Position = UDim2.new(0, Config.SidebarWidth, 0, 45)
    ContentArea.Size = UDim2.new(1, -Config.SidebarWidth, 1, -45)
    ContentArea.BackgroundColor3 = Config.Colors.Main
    ContentArea.BackgroundTransparency = 0.15
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = MainInner
    
    local ContentBottomFix = Instance.new("Frame")
    ContentBottomFix.Name = "BottomFix"
    ContentBottomFix.Size = UDim2.new(1, 1, 0, 20)
    ContentBottomFix.Position = UDim2.new(0, 0, 1, -20)
    ContentBottomFix.BackgroundColor3 = Config.Colors.Main
    ContentBottomFix.BackgroundTransparency = 0.15
    ContentBottomFix.BorderSizePixel = 0
    ContentBottomFix.Parent = ContentArea
    
    Utils:MakeDraggable(Main, Topbar)
    
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
        IsTransitioning = false,
    }
    
    CloseButton.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(
            CloseButton,
            TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.3, Size = UDim2.new(0, 26, 0, 26)}
        )
        tween:Play()
        task.wait(0.08)
        local tween2 = TweenService:Create(
            CloseButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.6, Size = UDim2.new(0, 30, 0, 30)}
        )
        tween2:Play()
        
        local closeTween = TweenService:Create(
            Main,
            TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0)}
        )
        closeTween:Play()
        closeTween.Completed:Connect(function()
            MainGui:Destroy()
        end)
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(
            MinimizeButton,
            TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.3, Size = UDim2.new(0, 26, 0, 26)}
        )
        tween:Play()
        task.wait(0.08)
        local tween2 = TweenService:Create(
            MinimizeButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.6, Size = UDim2.new(0, 30, 0, 30)}
        )
        tween2:Play()
        
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            MinimizeButton.Text = "+"
            local minTween = TweenService:Create(
                Main,
                TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {Size = UDim2.new(0, Config.WindowSize.X.Offset, 0, 45)}
            )
            minTween:Play()
        else
            MinimizeButton.Text = "−"
            local maxTween = TweenService:Create(
                Main,
                TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {Size = Config.WindowSize}
            )
            maxTween:Play()
        end
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Utils:Spring(CloseButton, {BackgroundTransparency = 0.3}, 0.3)
    end)
    CloseButton.MouseLeave:Connect(function()
        Utils:Spring(CloseButton, {BackgroundTransparency = 0.6}, 0.3)
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        Utils:Spring(MinimizeButton, {BackgroundTransparency = 0.3}, 0.3)
    end)
    MinimizeButton.MouseLeave:Connect(function()
        Utils:Spring(MinimizeButton, {BackgroundTransparency = 0.6}, 0.3)
    end)
    
    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Name = name
        Tab.Button = nil
        Tab.Content = nil
        Tab.Elements = {}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Size = UDim2.new(1, -10, 0, 36)
        TabButton.BackgroundColor3 = Config.Colors.Accent
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = "  " .. name
        TabButton.TextColor3 = Config.Colors.TextDark
        TabButton.TextSize = 14
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.ZIndex = 2
        TabButton.Parent = TabContainer
        Utils:CreateCorner(TabButton, 10)
        
        Tab.Button = TabButton
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "_Content"
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = Config.Colors.Accent
        TabContent.ScrollBarImageTransparency = 0.3
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentArea
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.Parent = TabContent
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        Tab.Content = TabContent
        
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utils:Spring(TabButton, {BackgroundTransparency = 0.85}, 0.25)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utils:Spring(TabButton, {BackgroundTransparency = 1}, 0.25)
            end
        end)
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            Window:SelectTab(Tab)
        end
        
        function Tab:CreateButton(settings)
            settings = settings or {}
            local buttonName = settings.Name or "Button"
            local callback = settings.Callback or function() end
            
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = buttonName
            ButtonFrame.Size = UDim2.new(1, -6, 0, 40)
            ButtonFrame.BackgroundColor3 = Config.Colors.Background
            ButtonFrame.BackgroundTransparency = 0.2
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Parent = TabContent
            Utils:CreateCorner(ButtonFrame, 10)
            Utils:CreateStroke(ButtonFrame, Config.Colors.Border, 1)
            
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -20, 1, -8)
            Button.Position = UDim2.new(0, 10, 0, 4)
            Button.BackgroundTransparency = 1
            Button.Font = Enum.Font.GothamSemibold
            Button.Text = buttonName
            Button.TextColor3 = Config.Colors.Text
            Button.TextSize = 14
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Parent = ButtonFrame
            
            Button.MouseButton1Click:Connect(function()
                Utils:Spring(ButtonFrame, {BackgroundColor3 = Config.Colors.Accent, BackgroundTransparency = 0}, 0.15)
                task.wait(0.1)
                Utils:Spring(ButtonFrame, {BackgroundColor3 = Config.Colors.Background, BackgroundTransparency = 0.2}, 0.2)
                callback()
            end)
            
            Button.MouseEnter:Connect(function()
                Utils:Spring(ButtonFrame, {BackgroundColor3 = Config.Colors.Border, BackgroundTransparency = 0.1}, 0.25)
            end)
            
            Button.MouseLeave:Connect(function()
                Utils:Spring(ButtonFrame, {BackgroundColor3 = Config.Colors.Background, BackgroundTransparency = 0.2}, 0.25)
            end)
            
            return ButtonFrame
        end
        
        function Tab:CreateToggle(settings)
            settings = settings or {}
            local toggleName = settings.Name or "Toggle"
            local default = settings.Default or false
            local callback = settings.Callback or function() end
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = toggleName
            ToggleFrame.Size = UDim2.new(1, -6, 0, 40)
            ToggleFrame.BackgroundColor3 = Config.Colors.Background
            ToggleFrame.BackgroundTransparency = 0.2
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent
            Utils:CreateCorner(ToggleFrame, 10)
            Utils:CreateStroke(ToggleFrame, Config.Colors.Border, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -65, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = toggleName
            Label.TextColor3 = Config.Colors.Text
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.AnchorPoint = Vector2.new(1, 0.5)
            ToggleButton.Position = UDim2.new(1, -12, 0.5, 0)
            ToggleButton.Size = UDim2.new(0, 44, 0, 24)
            ToggleButton.BackgroundColor3 = Config.Colors.Border
            ToggleButton.BackgroundTransparency = 0.2
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Text = ""
            ToggleButton.Parent = ToggleFrame
            Utils:CreateCorner(ToggleButton, 12)
            
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Size = UDim2.new(0, 18, 0, 18)
            ToggleIndicator.Position = UDim2.new(0, 3, 0.5, -9)
            ToggleIndicator.BackgroundColor3 = Config.Colors.TextDark
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Parent = ToggleButton
            Utils:CreateCorner(ToggleIndicator, 9)
            
            local toggled = default
            
            local function UpdateToggle()
                if toggled then
                    Utils:Spring(ToggleButton, {BackgroundColor3 = Config.Colors.Accent, BackgroundTransparency = 0}, 0.3)
                    Utils:Spring(ToggleIndicator, {Position = UDim2.new(1, -21, 0.5, -9), BackgroundColor3 = Config.Colors.Text}, 0.3)
                else
                    Utils:Spring(ToggleButton, {BackgroundColor3 = Config.Colors.Border, BackgroundTransparency = 0.2}, 0.3)
                    Utils:Spring(ToggleIndicator, {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Config.Colors.TextDark}, 0.3)
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
            SliderFrame.Size = UDim2.new(1, -6, 0, 58)
            SliderFrame.BackgroundColor3 = Config.Colors.Background
            SliderFrame.BackgroundTransparency = 0.2
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent
            Utils:CreateCorner(SliderFrame, 10)
            Utils:CreateStroke(SliderFrame, Config.Colors.Border, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 12, 0, 6)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = sliderName
            Label.TextColor3 = Config.Colors.Text
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.AnchorPoint = Vector2.new(1, 0)
            ValueLabel.Size = UDim2.new(0, 60, 0, 20)
            ValueLabel.Position = UDim2.new(1, -12, 0, 6)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = Config.Colors.Accent
            ValueLabel.TextSize = 14
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local SliderBG = Instance.new("Frame")
            SliderBG.Size = UDim2.new(1, -24, 0, 6)
            SliderBG.Position = UDim2.new(0, 12, 0, 36)
            SliderBG.BackgroundColor3 = Config.Colors.Border
            SliderBG.BackgroundTransparency = 0.3
            SliderBG.BorderSizePixel = 0
            SliderBG.Parent = SliderFrame
            Utils:CreateCorner(SliderBG, 3)
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Config.Colors.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBG
            Utils:CreateCorner(SliderFill, 3)
            
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
                Utils:Spring(SliderFill, {Size = UDim2.new((value - min) / (max - min), 0, 1, 0)}, 0.2)
                callback(value)
            end
            
            SliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(input)
                end
            end)
            
            SliderButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            return SliderFrame
        end
        
        function Tab:CreateDropdown(settings)
            settings = settings or {}
            local dropdownName = settings.Name or "Dropdown"
            local options = settings.Options or {}
            local default = settings.Default or (options[1] or "None")
            local callback = settings.Callback or function() end
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = dropdownName
            DropdownFrame.Size = UDim2.new(1, -6, 0, 40)
            DropdownFrame.BackgroundColor3 = Config.Colors.Background
            DropdownFrame.BackgroundTransparency = 0.2
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = TabContent
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.ZIndex = 10
            Utils:CreateCorner(DropdownFrame, 10)
            Utils:CreateStroke(DropdownFrame, Config.Colors.Border, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -40, 0, 40)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = dropdownName .. ": " .. default
            Label.TextColor3 = Config.Colors.Text
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropdownFrame
            
            local Arrow = Instance.new("TextLabel")
            Arrow.AnchorPoint = Vector2.new(1, 0.5)
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Position = UDim2.new(1, -12, 0, 20)
            Arrow.BackgroundTransparency = 1
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Text = "›"
            Arrow.TextColor3 = Config.Colors.TextDark
            Arrow.TextSize = 16
            Arrow.Rotation = 90
            Arrow.Parent = DropdownFrame
            
            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Size = UDim2.new(1, 0, 0, #options * 34)
            OptionsContainer.Position = UDim2.new(0, 0, 0, 40)
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.Parent = DropdownFrame
            
            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsLayout.Padding = UDim.new(0, 2)
            OptionsLayout.Parent = OptionsContainer
            
            local isOpen = false
            local currentValue = default
            
            local function ToggleDropdown()
                isOpen = not isOpen
                if isOpen then
                    Utils:Spring(DropdownFrame, {Size = UDim2.new(1, -6, 0, 40 + #options * 34 + 6)}, 0.35)
                    Utils:Spring(Arrow, {Rotation = 270}, 0.35)
                else
                    Utils:Spring(DropdownFrame, {Size = UDim2.new(1, -6, 0, 40)}, 0.35)
                    Utils:Spring(Arrow, {Rotation = 90}, 0.35)
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
                OptionButton.Size = UDim2.new(1, -12, 0, 32)
                OptionButton.BackgroundColor3 = Config.Colors.Background
                OptionButton.BackgroundTransparency = 0.3
                OptionButton.BorderSizePixel = 0
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Text = "  " .. option
                OptionButton.TextColor3 = Config.Colors.Text
                OptionButton.TextSize = 13
                OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                OptionButton.Parent = OptionsContainer
                Utils:CreateCorner(OptionButton, 8)
                
                OptionButton.MouseButton1Click:Connect(function()
                    currentValue = option
                    Label.Text = dropdownName .. ": " .. option
                    ToggleDropdown()
                    callback(option)
                end)
                
                OptionButton.MouseEnter:Connect(function()
                    Utils:Spring(OptionButton, {BackgroundColor3 = Config.Colors.Accent, BackgroundTransparency = 0.15}, 0.25)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Utils:Spring(OptionButton, {BackgroundColor3 = Config.Colors.Background, BackgroundTransparency = 0.3}, 0.25)
                end)
            end
            
            return DropdownFrame
        end
        
        function Tab:CreateLabel(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, -6, 0, 28)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.Parent = TabContent
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -24, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
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
    
    function Window:SelectTab(tab)
        if self.IsTransitioning then return end
        if self.CurrentTab == tab then return end
        
        self.IsTransitioning = true
        
        for _, t in ipairs(self.Tabs) do
            if t == tab then
                Utils:Spring(t.Button, {BackgroundTransparency = 0.8, TextColor3 = Config.Colors.Text}, 0.4)
                
                if self.CurrentTab and self.CurrentTab.Content.Visible then
                    for _, element in ipairs(self.CurrentTab.Content:GetChildren()) do
                        if element:IsA("GuiObject") and not element:IsA("UIListLayout") then
                            local fadeOutTween = TweenService:Create(
                                element,
                                TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
                                {
                                    Position = UDim2.new(element.Position.X.Scale, element.Position.X.Offset - 20, element.Position.Y.Scale, element.Position.Y.Offset),
                                    BackgroundTransparency = 1
                                }
                            )
                            fadeOutTween:Play()
                            
                            if element:IsA("TextLabel") or element:IsA("TextButton") then
                                Utils:Tween(element, {TextTransparency = 1}, 0.2)
                            end
                            
                            for _, child in ipairs(element:GetChildren()) do
                                if child:IsA("TextLabel") or child:IsA("TextButton") then
                                    Utils:Tween(child, {TextTransparency = 1}, 0.2)
                                elseif child:IsA("Frame") and child.Name ~= "UICorner" and child.Name ~= "UIStroke" then
                                    Utils:Tween(child, {BackgroundTransparency = 1}, 0.2)
                                end
                            end
                        end
                    end
                end
                
                task.wait(0.22)
                
                if self.CurrentTab then
                    self.CurrentTab.Content.Visible = false
                end
                
                t.Content.Visible = true
                
                for i, element in ipairs(t.Content:GetChildren()) do
                    if element:IsA("GuiObject") and not element:IsA("UIListLayout") then
                        local originalBgTrans = element.BackgroundTransparency
                        local originalPos = element.Position
                        
                        element.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 20, originalPos.Y.Scale, originalPos.Y.Offset)
                        element.BackgroundTransparency = 1
                        
                        if element:IsA("TextLabel") or element:IsA("TextButton") then
                            element.TextTransparency = 1
                        end
                        
                        for _, child in ipairs(element:GetChildren()) do
                            if child:IsA("TextLabel") or child:IsA("TextButton") then
                                child.TextTransparency = 1
                            elseif child:IsA("Frame") and child.Name ~= "UICorner" and child.Name ~= "UIStroke" then
                                child.BackgroundTransparency = 1
                            end
                        end
                        
                        task.spawn(function()
                            task.wait(i * 0.03)
                            
                            local fadeInTween = TweenService:Create(
                                element,
                                TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                                {Position = originalPos, BackgroundTransparency = originalBgTrans}
                            )
                            fadeInTween:Play()
                            
                            if element:IsA("TextLabel") or element:IsA("TextButton") then
                                Utils:Tween(element, {TextTransparency = 0}, 0.5)
                            end
                            
                            for _, child in ipairs(element:GetChildren()) do
                                if child:IsA("TextLabel") or child:IsA("TextButton") then
                                    Utils:Tween(child, {TextTransparency = 0}, 0.5)
                                elseif child:IsA("Frame") and child.Name ~= "UICorner" and child.Name ~= "UIStroke" then
                                    local origTrans = child:GetAttribute("OriginalTransparency") or 0.2
                                    Utils:Tween(child, {BackgroundTransparency = origTrans}, 0.5)
                                end
                            end
                        end)
                    end
                end
            else
                Utils:Spring(t.Button, {BackgroundTransparency = 1, TextColor3 = Config.Colors.TextDark}, 0.4)
            end
        end
        
        self.CurrentTab = tab
        
        task.delay(0.6, function()
            self.IsTransitioning = false
        end)
    end
    
    return Window
end

function ScawsHub:CreateNotification(settings)
    settings = settings or {}
    local title = settings.Title or "Notification"
    local content = settings.Content or ""
    local duration = settings.Duration or 5
    local type = settings.Type or "Info"
    
    local notifGui = game:GetService("CoreGui"):FindFirstChild("ScawsHub_Notifications")
    if not notifGui then
        notifGui = Instance.new("ScreenGui")
        notifGui.Name = "ScawsHub_Notifications"
        notifGui.ResetOnSpawn = false
        notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        notifGui.IgnoreGuiInset = true
        
        if gethui then
            notifGui.Parent = gethui()
        else
            notifGui.Parent = CoreGui
        end
        
        local NotifContainer = Instance.new("Frame")
        NotifContainer.Name = "NotifContainer"
        NotifContainer.AnchorPoint = Vector2.new(1, 1)
        NotifContainer.Position = UDim2.new(1, -10, 1, -10)
        NotifContainer.Size = UDim2.new(0, 360, 1, -20)
        NotifContainer.BackgroundTransparency = 1
        NotifContainer.Parent = notifGui
        
        local NotifLayout = Instance.new("UIListLayout")
        NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
        NotifLayout.Padding = UDim.new(0, 12)
        NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        NotifLayout.Parent = NotifContainer
    end
    
    local NotifContainer = notifGui:FindFirstChild("NotifContainer")
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 0, 0, 90)
    Notification.BackgroundTransparency = 1
    Notification.BorderSizePixel = 0
    Notification.Parent = NotifContainer
    
    local BlurFrame = Instance.new("Frame")
    BlurFrame.Name = "BlurFrame"
    BlurFrame.Size = UDim2.new(1, 0, 1, 0)
    BlurFrame.Position = UDim2.new(0, 0, 0, 0)
    BlurFrame.BackgroundColor3 = Config.Colors.Background
    BlurFrame.BackgroundTransparency = 0.7
    BlurFrame.BorderSizePixel = 0
    BlurFrame.ZIndex = 1
    BlurFrame.Parent = Notification
    Utils:CreateCorner(BlurFrame, 14)
    Utils:CreateStroke(BlurFrame, Config.Colors.Border, 1.5)
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 60, 1, 40)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.4
    Shadow.ZIndex = 0
    Shadow.Parent = Notification
    Utils:CreateCorner(Shadow, 25)
    
    local colorMap = {
        Info = Config.Colors.Accent,
        Success = Config.Colors.Success,
        Warning = Config.Colors.Warning,
        Error = Config.Colors.Error
    }
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 4, 1, -16)
    Indicator.Position = UDim2.new(0, 8, 0, 8)
    Indicator.BackgroundColor3 = colorMap[type] or Config.Colors.Accent
    Indicator.BorderSizePixel = 0
    Indicator.ZIndex = 2
    Indicator.Parent = Notification
    Utils:CreateCorner(Indicator, 2)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -28, 0, 26)
    Title.Position = UDim2.new(0, 20, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Config.Colors.Text
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextTransparency = 1
    Title.ZIndex = 2
    Title.Parent = Notification
    
    local Content = Instance.new("TextLabel")
    Content.Size = UDim2.new(1, -28, 0, 48)
    Content.Position = UDim2.new(0, 20, 0, 36)
    Content.BackgroundTransparency = 1
    Content.Font = Enum.Font.Gotham
    Content.Text = content
    Content.TextColor3 = Config.Colors.TextDark
    Content.TextSize = 13
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextYAlignment = Enum.TextYAlignment.Top
    Content.TextWrapped = true
    Content.TextTransparency = 1
    Content.ZIndex = 2
    Content.Parent = Notification
    
    local Credits = Instance.new("TextLabel")
    Credits.Size = UDim2.new(0, 80, 0, 12)
    Credits.Position = UDim2.new(1, -88, 1, -18)
    Credits.BackgroundTransparency = 1
    Credits.Font = Enum.Font.Gotham
    Credits.Text = "ScawsHub"
    Credits.TextColor3 = Config.Colors.TextDark
    Credits.TextSize = 9
    Credits.TextXAlignment = Enum.TextXAlignment.Right
    Credits.TextTransparency = 1
    Credits.ZIndex = 2
    Credits.Parent = Notification
    
    Utils:Spring(Notification, {Size = UDim2.new(0, 340, 0, 90)}, 0.5)
    
    task.wait(0.15)
    Utils:Tween(Title, {TextTransparency = 0}, 0.4)
    Utils:Tween(Content, {TextTransparency = 0}, 0.4)
    Utils:Tween(Credits, {TextTransparency = 0.5}, 0.4)
    
    task.delay(duration, function()
        Utils:Tween(Title, {TextTransparency = 1}, 0.3)
        Utils:Tween(Content, {TextTransparency = 1}, 0.3)
        Utils:Tween(Credits, {TextTransparency = 1}, 0.3)
        Utils:Tween(Indicator, {BackgroundTransparency = 1}, 0.3)
        
        Utils:Spring(Notification, {Size = UDim2.new(0, 0, 0, 90)}, 0.4)
        Utils:Spring(BlurFrame, {BackgroundTransparency = 1}, 0.4)
        Utils:Spring(Shadow, {ImageTransparency = 1}, 0.4)
        
        task.wait(0.45)
        Notification:Destroy()
    end)
end

return ScawsHub
