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
    EasingStyle = Enum.EasingStyle.Quint,
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
        TweenInfo.new(duration, Config.EasingStyle, Config.EasingDirection),
        properties
    )
    tween:Play()
    if callback then
        tween.Completed:Connect(callback)
    end
    return tween
end

function Utils:Spring(obj, properties, duration)
    duration = duration or 0.5
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
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
    
    Utils:Tween(ImageLabel, {ImageTransparency = 0, Size = UDim2.new(0, 400, 0, 400)}, 1)
    
    task.wait(duration)
    
    Utils:Tween(Container, {BackgroundTransparency = 1}, 0.8)
    Utils:Tween(ImageLabel, {ImageTransparency = 1, Size = UDim2.new(0, 450, 0, 450)}, 0.8, function()
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
    Main.ClipsDescendants = true
    Main.Parent = MainGui
    Utils:CreateCorner(Main, 16)
    Utils:CreateStroke(Main, Config.Colors.Border, 1)
    
    Utils:Tween(Main, {Size = Config.WindowSize}, 0.65)
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 50, 1, 50)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.3
    Shadow.ZIndex = 0
    Shadow.Parent = Main
    
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundColor3 = Config.Colors.Topbar
    Topbar.BackgroundTransparency = 0.15
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main
    Utils:CreateCorner(Topbar, 16)
    
    local TopbarFix = Instance.new("Frame")
    TopbarFix.Size = UDim2.new(1, 0, 0, 16)
    TopbarFix.Position = UDim2.new(0, 0, 1, -16)
    TopbarFix.BackgroundColor3 = Config.Colors.Topbar
    TopbarFix.BackgroundTransparency = 0.15
    TopbarFix.BorderSizePixel = 0
    TopbarFix.Parent = Topbar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 18, 0, 0)
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
    CreditsLabel.Position = UDim2.new(0, 18, 0, 18)
    CreditsLabel.BackgroundTransparency = 1
    CreditsLabel.Font = Enum.Font.Gotham
    CreditsLabel.Text = "ScawsHub"
    CreditsLabel.TextColor3 = Config.Colors.TextDark
    CreditsLabel.TextSize = 9
    CreditsLabel.TextXAlignment = Enum.TextXAlignment.Left
    CreditsLabel.TextTransparency = 0.4
    CreditsLabel.Parent = Topbar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.Position = UDim2.new(1, -12, 0.5, 0)
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
    MinimizeButton.Position = UDim2.new(1, -47, 0.5, 0)
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
    Sidebar.Parent = Main
    
    local SidebarBottomCorner = Instance.new("Frame")
    SidebarBottomCorner.Size = UDim2.new(1, 0, 0, 16)
    SidebarBottomCorner.Position = UDim2.new(0, 0, 1, -16)
    SidebarBottomCorner.BackgroundColor3 = Config.Colors.Sidebar
    SidebarBottomCorner.BackgroundTransparency = 0.15
    SidebarBottomCorner.BorderSizePixel = 0
    SidebarBottomCorner.Parent = Sidebar
    
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
    TabContainer.Size = UDim2.new(1, -10, 1, -55)
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
    
    local SessionInfoButton = Instance.new("TextButton")
    SessionInfoButton.Name = "SessionInfo"
    SessionInfoButton.Size = UDim2.new(1, -10, 0, 36)
    SessionInfoButton.Position = UDim2.new(0, 5, 1, -41)
    SessionInfoButton.BackgroundColor3 = Config.Colors.Background
    SessionInfoButton.BackgroundTransparency = 1
    SessionInfoButton.BorderSizePixel = 0
    SessionInfoButton.Font = Enum.Font.GothamSemibold
    SessionInfoButton.Text = "  Session Info"
    SessionInfoButton.TextColor3 = Config.Colors.TextDark
    SessionInfoButton.TextSize = 14
    SessionInfoButton.TextXAlignment = Enum.TextXAlignment.Left
    SessionInfoButton.Parent = Sidebar
    Utils:CreateCorner(SessionInfoButton, 10)
    
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Position = UDim2.new(0, Config.SidebarWidth, 0, 45)
    ContentArea.Size = UDim2.new(1, -Config.SidebarWidth, 1, -45)
    ContentArea.BackgroundColor3 = Config.Colors.Main
    ContentArea.BackgroundTransparency = 0.15
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = Main
    
    local ContentBottomCorner = Instance.new("Frame")
    ContentBottomCorner.Size = UDim2.new(1, 0, 0, 16)
    ContentBottomCorner.Position = UDim2.new(0, 0, 1, -16)
    ContentBottomCorner.BackgroundColor3 = Config.Colors.Main
    ContentBottomCorner.BackgroundTransparency = 0.15
    ContentBottomCorner.BorderSizePixel = 0
    ContentBottomCorner.Parent = ContentArea
    
    local BottomCornerFrame = Instance.new("Frame")
    BottomCornerFrame.Size = UDim2.new(1, 0, 0, 16)
    BottomCornerFrame.Position = UDim2.new(0, 0, 1, -16)
    BottomCornerFrame.BackgroundColor3 = Config.Colors.Background
    BottomCornerFrame.BackgroundTransparency = 0.15
    BottomCornerFrame.BorderSizePixel = 0
    BottomCornerFrame.Parent = Main
    
    Utils:MakeDraggable(Main, Topbar)
    
    local Window = {
        Gui = MainGui,
        Main = Main,
        Topbar = Topbar,
        Sidebar = Sidebar,
        TabContainer = TabContainer,
        ContentArea = ContentArea,
        SessionInfoButton = SessionInfoButton,
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        Minimized = false,
        IsTransitioning = false,
    }
    
    CloseButton.MouseButton1Click:Connect(function()
        Utils:Spring(CloseButton, {BackgroundTransparency = 0.3, Size = UDim2.new(0, 26, 0, 26)}, 0.15)
        task.wait(0.08)
        Utils:Spring(CloseButton, {BackgroundTransparency = 0.6, Size = UDim2.new(0, 30, 0, 30)}, 0.15)
        Utils:Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.5, function()
            MainGui:Destroy()
        end)
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        Utils:Spring(MinimizeButton, {BackgroundTransparency = 0.3, Size = UDim2.new(0, 26, 0, 26)}, 0.15)
        task.wait(0.08)
        Utils:Spring(MinimizeButton, {BackgroundTransparency = 0.6, Size = UDim2.new(0, 30, 0, 30)}, 0.15)
        
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            MinimizeButton.Text = "+"
            Utils:Tween(Main, {Size = UDim2.new(0, Config.WindowSize.X.Offset, 0, 45)}, 0.45)
        else
            MinimizeButton.Text = "−"
            Utils:Tween(Main, {Size = Config.WindowSize}, 0.45)
        end
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Utils:Spring(CloseButton, {BackgroundTransparency = 0.3}, 0.25)
    end)
    CloseButton.MouseLeave:Connect(function()
        Utils:Spring(CloseButton, {BackgroundTransparency = 0.6}, 0.25)
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        Utils:Spring(MinimizeButton, {BackgroundTransparency = 0.3}, 0.25)
    end)
    MinimizeButton.MouseLeave:Connect(function()
        Utils:Spring(MinimizeButton, {BackgroundTransparency = 0.6}, 0.25)
    end)
    
    local SessionInfoTab = Window:CreateSessionInfoTab()
    
    SessionInfoButton.MouseButton1Click:Connect(function()
        Window:SelectTab(SessionInfoTab)
    end)
    
    SessionInfoButton.MouseEnter:Connect(function()
        if Window.CurrentTab ~= SessionInfoTab then
            Utils:Spring(SessionInfoButton, {BackgroundTransparency = 0.88}, 0.3)
        end
    end)
    
    SessionInfoButton.MouseLeave:Connect(function()
        if Window.CurrentTab ~= SessionInfoTab then
            Utils:Spring(SessionInfoButton, {BackgroundTransparency = 1}, 0.3)
        end
    end)
    
    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Name = name
        Tab.Button = nil
        Tab.Content = nil
        Tab.Elements = {}
        Tab.IsSessionInfo = false
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Size = UDim2.new(1, -10, 0, 36)
        TabButton.BackgroundColor3 = Config.Colors.Background
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = "  " .. name
        TabButton.TextColor3 = Config.Colors.TextDark
        TabButton.TextSize = 14
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabContainer
        Utils:CreateCorner(TabButton, 10)
        
        Tab.Button = TabButton
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "_Content"
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
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
                Utils:Spring(TabButton, {BackgroundTransparency = 0.88}, 0.3)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utils:Spring(TabButton, {BackgroundTransparency = 1}, 0.3)
            end
        end)
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            task.delay(0.1, function()
                Window:SelectTab(Tab)
            end)
        end
        
        function Tab:CreateButton(settings)
            settings = settings or {}
            local buttonName = settings.Name or "Button"
            local callback = settings.Callback or function() end
            
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = buttonName
            ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
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
            ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
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
            SliderFrame.Size = UDim2.new(1, 0, 0, 58)
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
            DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
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
                    Utils:Spring(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40 + #options * 34 + 6)}, 0.35)
                    Utils:Spring(Arrow, {Rotation = 270}, 0.35)
                else
                    Utils:Spring(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.35)
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
                OptionButton.BackgroundColor3 = Config.Colors.Border
                OptionButton.BackgroundTransparency = 0.5
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
                    Utils:Spring(OptionButton, {BackgroundColor3 = Config.Colors.Accent, BackgroundTransparency = 0.2}, 0.25)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Utils:Spring(OptionButton, {BackgroundColor3 = Config.Colors.Border, BackgroundTransparency = 0.5}, 0.25)
                end)
            end
            
            return DropdownFrame
        end
        
        function Tab:CreateLabel(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 28)
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
    
    function Window:CreateSessionInfoTab()
        local Tab = {}
        Tab.Name = "Session Info"
        Tab.Button = SessionInfoButton
        Tab.Content = nil
        Tab.Elements = {}
        Tab.IsSessionInfo = true
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "SessionInfo_Content"
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
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
        
        local function CreateInfoFrame(labelText, valueText)
            local InfoFrame = Instance.new("Frame")
            InfoFrame.Size = UDim2.new(1, 0, 0, 36)
            InfoFrame.BackgroundColor3 = Config.Colors.Background
            InfoFrame.BackgroundTransparency = 0.2
            InfoFrame.BorderSizePixel = 0
            InfoFrame.Parent = TabContent
            Utils:CreateCorner(InfoFrame, 10)
            Utils:CreateStroke(InfoFrame, Config.Colors.Border, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, -16, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = labelText
            Label.TextColor3 = Config.Colors.TextDark
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = InfoFrame
            
            local Value = Instance.new("TextLabel")
            Value.Size = UDim2.new(0.5, -16, 1, 0)
            Value.Position = UDim2.new(0.5, 4, 0, 0)
            Value.BackgroundTransparency = 1
            Value.Font = Enum.Font.GothamBold
            Value.Text = valueText
            Value.TextColor3 = Config.Colors.Accent
            Value.TextSize = 12
            Value.TextXAlignment = Enum.TextXAlignment.Right
            Value.Parent = InfoFrame
            
            return Value
        end
        
        local uptimeLabel = CreateInfoFrame("Uptime", "0s")
        local fpsLabel = CreateInfoFrame("FPS", "0")
        local pingLabel = CreateInfoFrame("Ping", "0ms")
        local jobIdLabel = CreateInfoFrame("Job ID", game.JobId)
        local placeIdLabel = CreateInfoFrame("Place ID", tostring(game.PlaceId))
        local playerCountLabel = CreateInfoFrame("Players", tostring(#Players:GetPlayers()))
        
        local function CreateActionButton(text, callback)
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
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
            Button.Text = text
            Button.TextColor3 = Config.Colors.Text
            Button.TextSize = 13
            Button.TextXAlignment = Enum.TextXAlignment.Center
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
        end
        
        CreateActionButton("Rejoin Server", function()
            TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
        end)
        
        CreateActionButton("Server Hop", function()
            local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            if servers and servers.data then
                for _, server in ipairs(servers.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Players.LocalPlayer)
                        return
                    end
                end
            end
        end)
        
        local CreditsFrame = Instance.new("Frame")
        CreditsFrame.Size = UDim2.new(1, 0, 0, 32)
        CreditsFrame.BackgroundTransparency = 1
        CreditsFrame.Parent = TabContent
        
        local CreditsText = Instance.new("TextLabel")
        CreditsText.Size = UDim2.new(1, -24, 1, 0)
        CreditsText.Position = UDim2.new(0, 12, 0, 0)
        CreditsText.BackgroundTransparency = 1
        CreditsText.Font = Enum.Font.GothamBold
        CreditsText.Text = "ScawsHub"
        CreditsText.TextColor3 = Config.Colors.Accent
        CreditsText.TextSize = 11
        CreditsText.TextXAlignment = Enum.TextXAlignment.Center
        CreditsText.TextTransparency = 0.3
        CreditsText.Parent = CreditsFrame
        
        local lastUpdate = tick()
        local frameCount = 0
        local fps = 0
        
        RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            if tick() - lastUpdate >= 1 then
                fps = frameCount
                frameCount = 0
                lastUpdate = tick()
                
                if Tab.Content.Visible then
                    local uptime = math.floor(tick() - SessionStartTime)
                    local hours = math.floor(uptime / 3600)
                    local minutes = math.floor((uptime % 3600) / 60)
                    local seconds = uptime % 60
                    
                    uptimeLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                    fpsLabel.Text = tostring(fps)
                    pingLabel.Text = tostring(math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())) .. "ms"
                    playerCountLabel.Text = tostring(#Players:GetPlayers())
                end
            end
        end)
        
        table.insert(Window.Tabs, Tab)
        
        return Tab
    end
    
    function Window:SelectTab(tab)
        if self.IsTransitioning then return end
        if self.CurrentTab == tab then return end
        
        self.IsTransitioning = true
        
        for _, t in ipairs(self.Tabs) do
            if t == tab then
                if t.IsSessionInfo then
                    Utils:Spring(SessionInfoButton, {BackgroundTransparency = 0.75, TextColor3 = Config.Colors.Text}, 0.3)
                else
                    Utils:Spring(t.Button, {BackgroundTransparency = 0.75, TextColor3 = Config.Colors.Text}, 0.3)
                end
                
                task.wait(0.15)
                
                t.Content.Visible = true
                t.Content.Position = UDim2.new(0, 30, 0, 10)
                
                for _, element in ipairs(t.Content:GetChildren()) do
                    if element:IsA("GuiObject") and not element:IsA("UIListLayout") then
                        element.BackgroundTransparency = 1
                        
                        for _, child in ipairs(element:GetDescendants()) do
                            if child:IsA("TextLabel") or child:IsA("TextButton") then
                                child.TextTransparency = 1
                            elseif child:IsA("Frame") or child:IsA("ImageLabel") then
                                child.BackgroundTransparency = 1
                                if child:IsA("ImageLabel") then
                                    child.ImageTransparency = 1
                                end
                            end
                        end
                    end
                end
                
                Utils:Tween(t.Content, {Position = UDim2.new(0, 10, 0, 10)}, 0.3)
                
                task.wait(0.05)
                
                for i, element in ipairs(t.Content:GetChildren()) do
                    if element:IsA("GuiObject") and not element:IsA("UIListLayout") then
                        task.spawn(function()
                            task.wait(i * 0.02)
                            
                            local originalBgTrans = 0.2
                            if element:FindFirstChild("BackgroundTransparency") then
                                originalBgTrans = element.BackgroundTransparency
                            end
                            
                            Utils:Tween(element, {BackgroundTransparency = originalBgTrans}, 0.25)
                            
                            for _, child in ipairs(element:GetDescendants()) do
                                if child:IsA("TextLabel") or child:IsA("TextButton") then
                                    Utils:Tween(child, {TextTransparency = 0}, 0.25)
                                elseif child:IsA("Frame") and child.Name ~= "UICorner" and child.Name ~= "UIStroke" then
                                    local childBgTrans = 0
                                    if child.Name == "Separator" then
                                        childBgTrans = 0.5
                                    end
                                    Utils:Tween(child, {BackgroundTransparency = childBgTrans}, 0.25)
                                elseif child:IsA("ImageLabel") then
                                    Utils:Tween(child, {ImageTransparency = 0}, 0.25)
                                end
                            end
                        end)
                    end
                end
            else
                if t.IsSessionInfo then
                    Utils:Spring(SessionInfoButton, {BackgroundTransparency = 1, TextColor3 = Config.Colors.TextDark}, 0.3)
                else
                    Utils:Spring(t.Button, {BackgroundTransparency = 1, TextColor3 = Config.Colors.TextDark}, 0.3)
                end
                
                if t.Content.Visible then
                    for _, element in ipairs(t.Content:GetChildren()) do
                        if element:IsA("GuiObject") and not element:IsA("UIListLayout") then
                            task.spawn(function()
                                Utils:Tween(element, {BackgroundTransparency = 1}, 0.15)
                                
                                for _, child in ipairs(element:GetDescendants()) do
                                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                                        Utils:Tween(child, {TextTransparency = 1}, 0.15)
                                    elseif child:IsA("Frame") or child:IsA("ImageLabel") then
                                        if child:IsA("ImageLabel") then
                                            Utils:Tween(child, {ImageTransparency = 1}, 0.15)
                                        end
                                        Utils:Tween(child, {BackgroundTransparency = 1}, 0.15)
                                    end
                                end
                            end)
                        end
                    end
                    
                    task.delay(0.15, function()
                        t.Content.Visible = false
                    end)
                end
            end
        end
        
        self.CurrentTab = tab
        
        task.delay(0.4, function()
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
    end
    
    local existingNotifs = {}
    for _, child in ipairs(notifGui:GetChildren()) do
        if child:IsA("Frame") then
            table.insert(existingNotifs, child)
        end
    end
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 340, 0, 90)
    Notification.Position = UDim2.new(1, 360, 1, -110 - #existingNotifs * 100)
    Notification.BackgroundColor3 = Config.Colors.Background
    Notification.BackgroundTransparency = 0.08
    Notification.BorderSizePixel = 0
    Notification.ClipsDescendants = false
    Notification.Parent = notifGui
    Utils:CreateCorner(Notification, 14)
    Utils:CreateStroke(Notification, Config.Colors.Border, 1)
    
    local Blur = Instance.new("ImageLabel")
    Blur.Name = "Blur"
    Blur.AnchorPoint = Vector2.new(0.5, 0.5)
    Blur.Position = UDim2.new(0.5, 0, 0.5, 0)
    Blur.Size = UDim2.new(1, 40, 1, 40)
    Blur.BackgroundTransparency = 1
    Blur.Image = "rbxassetid://5554236805"
    Blur.ImageColor3 = Config.Colors.Background
    Blur.ImageTransparency = 0.5
    Blur.ZIndex = -1
    Blur.Parent = Notification
    Utils:CreateCorner(Blur, 18)
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.4
    Shadow.ZIndex = -2
    Shadow.Parent = Notification
    Utils:CreateCorner(Shadow, 16)
    
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
    Content.Parent = Notification
    
    local targetPos = UDim2.new(1, -350, 1, -110 - #existingNotifs * 100)
    Utils:Spring(Notification, {Position = targetPos}, 0.5)
    
    task.delay(duration, function()
        Utils:Spring(Notification, {Position = UDim2.new(1, 360, 1, Notification.Position.Y.Offset), BackgroundTransparency = 1}, 0.5)
        Utils:Spring(Shadow, {ImageTransparency = 1}, 0.5)
        Utils:Spring(Blur, {ImageTransparency = 1}, 0.5)
        Utils:Spring(Title, {TextTransparency = 1}, 0.5)
        Utils:Spring(Content, {TextTransparency = 1}, 0.5)
        Utils:Spring(Indicator, {BackgroundTransparency = 1}, 0.5)
        
        task.wait(0.5)
        Notification:Destroy()
        
        task.wait(0.1)
        local currentNotifs = {}
        for _, notif in ipairs(notifGui:GetChildren()) do
            if notif:IsA("Frame") then
                table.insert(currentNotifs, notif)
            end
        end
        
        for i, notif in ipairs(currentNotifs) do
            Utils:Spring(notif, {
                Position = UDim2.new(1, -350, 1, -110 - (i - 1) * 100)
            }, 0.4)
        end
    end)
end

return ScawsHub
