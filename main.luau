local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local ScawsHub = {}
ScawsHub.__index = ScawsHub

local Config = {
    AnimationSpeed = 0.45,
    EasingStyle = Enum.EasingStyle.Quint,
    EasingDirection = Enum.EasingDirection.Out,
    
    Colors = {
        Background = Color3.fromRGB(15, 15, 20),
        Topbar = Color3.fromRGB(20, 20, 25),
        Sidebar = Color3.fromRGB(20, 20, 25),
        Main = Color3.fromRGB(25, 25, 30),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(108, 121, 262),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(140, 140, 150),
        Border = Color3.fromRGB(35, 35, 40),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(240, 71, 71),
    },
    
    WindowSize = UDim2.new(0, 580, 0, 420),
    SidebarWidth = 160,
    CornerRadius = 16,
    SmallCornerRadius = 12,
}

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

function Utils:Spring(obj, properties, callback)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
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
            Utils:Tween(frame, {
                Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            }, 0.12)
        end
    end)
end

function Utils:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Config.CornerRadius)
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

function Utils:AddBlur(parent, intensity)
    local blur = Instance.new("Frame")
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    blur.BackgroundTransparency = 0.98
    blur.BorderSizePixel = 0
    blur.ZIndex = 0
    blur.Parent = parent
    return blur
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
    
    local success, err = pcall(function()
        if gethui then
            LoadingGui.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(LoadingGui)
            LoadingGui.Parent = CoreGui
        elseif get_hidden_gui or gethui then
            LoadingGui.Parent = (get_hidden_gui or gethui)()
        else
            LoadingGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    
    if not success then
        LoadingGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 1, 0)
    Container.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Container.BackgroundTransparency = 0
    Container.BorderSizePixel = 0
    Container.Parent = LoadingGui
    
    local ImageLabel = Instance.new("ImageLabel")
    ImageLabel.Name = "Logo"
    ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel.Size = UDim2.new(0, 280, 0, 280)
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.Image = imageId
    ImageLabel.ImageTransparency = 1
    ImageLabel.ScaleType = Enum.ScaleType.Fit
    ImageLabel.Parent = Container
    
    print("[ScawsHUB] Loading image:", imageId)
    
    Utils:Spring(ImageLabel, {ImageTransparency = 0, Size = UDim2.new(0, 350, 0, 350)})
    
    task.wait(duration)
    
    Utils:Tween(Container, {BackgroundTransparency = 1}, 0.7)
    Utils:Tween(ImageLabel, {ImageTransparency = 1, Size = UDim2.new(0, 400, 0, 400)}, 0.7, function()
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
    
    local success, err = pcall(function()
        if gethui then
            MainGui.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(MainGui)
            MainGui.Parent = CoreGui
        elseif get_hidden_gui or gethui then
            MainGui.Parent = (get_hidden_gui or gethui)()
        else
            MainGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    
    if not success then
        MainGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
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
    Utils:CreateCorner(Main, Config.CornerRadius)
    Utils:CreateStroke(Main, Config.Colors.Border, 1)
    
    Utils:Spring(Main, {Size = Config.WindowSize})
    
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
    Topbar.Size = UDim2.new(1, 0, 0, 50)
    Topbar.BackgroundColor3 = Config.Colors.Topbar
    Topbar.BackgroundTransparency = 0.2
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main
    Utils:CreateCorner(Topbar, Config.CornerRadius)
    
    local TopbarFix = Instance.new("Frame")
    TopbarFix.Size = UDim2.new(1, 0, 0, Config.CornerRadius)
    TopbarFix.Position = UDim2.new(0, 0, 1, -Config.CornerRadius)
    TopbarFix.BackgroundColor3 = Config.Colors.Topbar
    TopbarFix.BackgroundTransparency = 0.2
    TopbarFix.BorderSizePixel = 0
    TopbarFix.Parent = Topbar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = windowTitle
    TitleLabel.TextColor3 = Config.Colors.Text
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.Position = UDim2.new(1, -12, 0.5, 0)
    CloseButton.Size = UDim2.new(0, 34, 0, 34)
    CloseButton.BackgroundColor3 = Config.Colors.Border
    CloseButton.BackgroundTransparency = 0.3
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Config.Colors.Text
    CloseButton.TextSize = 20
    CloseButton.Parent = Topbar
    Utils:CreateCorner(CloseButton, 17)
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
    MinimizeButton.Position = UDim2.new(1, -52, 0.5, 0)
    MinimizeButton.Size = UDim2.new(0, 34, 0, 34)
    MinimizeButton.BackgroundColor3 = Config.Colors.Border
    MinimizeButton.BackgroundTransparency = 0.3
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Config.Colors.Text
    MinimizeButton.TextSize = 20
    MinimizeButton.Parent = Topbar
    Utils:CreateCorner(MinimizeButton, 17)
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Position = UDim2.new(0, 0, 0, 50)
    Sidebar.Size = UDim2.new(0, Config.SidebarWidth, 1, -50)
    Sidebar.BackgroundColor3 = Config.Colors.Sidebar
    Sidebar.BackgroundTransparency = 0.25
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    
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
    TabContainer.Size = UDim2.new(1, -12, 1, -12)
    TabContainer.Position = UDim2.new(0, 6, 0, 6)
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
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 12)
    end)
    
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Position = UDim2.new(0, Config.SidebarWidth, 0, 50)
    ContentArea.Size = UDim2.new(1, -Config.SidebarWidth, 1, -50)
    ContentArea.BackgroundColor3 = Config.Colors.Main
    ContentArea.BackgroundTransparency = 0.2
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = Main
    
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
    }
    
    CloseButton.MouseButton1Click:Connect(function()
        Utils:Spring(CloseButton, {BackgroundTransparency = 0.1, Size = UDim2.new(0, 30, 0, 30)})
        task.wait(0.1)
        Utils:Spring(CloseButton, {BackgroundTransparency = 0.3, Size = UDim2.new(0, 34, 0, 34)})
        Utils:Spring(Main, {Size = UDim2.new(0, 0, 0, 0)})
        task.wait(0.5)
        MainGui:Destroy()
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        Utils:Spring(MinimizeButton, {BackgroundTransparency = 0.1, Size = UDim2.new(0, 30, 0, 30)})
        task.wait(0.1)
        Utils:Spring(MinimizeButton, {BackgroundTransparency = 0.3, Size = UDim2.new(0, 34, 0, 34)})
        
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            MinimizeButton.Text = "+"
            Utils:Spring(Main, {Size = UDim2.new(0, Config.WindowSize.X.Offset, 0, 50)})
        else
            MinimizeButton.Text = "−"
            Utils:Spring(Main, {Size = Config.WindowSize})
        end
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Utils:Tween(CloseButton, {BackgroundTransparency = 0.1, BackgroundColor3 = Config.Colors.Error}, 0.25)
    end)
    CloseButton.MouseLeave:Connect(function()
        Utils:Tween(CloseButton, {BackgroundTransparency = 0.3, BackgroundColor3 = Config.Colors.Border}, 0.25)
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        Utils:Tween(MinimizeButton, {BackgroundTransparency = 0.1}, 0.25)
    end)
    MinimizeButton.MouseLeave:Connect(function()
        Utils:Tween(MinimizeButton, {BackgroundTransparency = 0.3}, 0.25)
    end)
    
    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Name = name
        Tab.Button = nil
        Tab.Content = nil
        Tab.Elements = {}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Size = UDim2.new(1, -12, 0, 42)
        TabButton.BackgroundColor3 = Config.Colors.Background
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = "  " .. name
        TabButton.TextColor3 = Config.Colors.TextDark
        TabButton.TextSize = 15
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabContainer
        Utils:CreateCorner(TabButton, Config.SmallCornerRadius)
        
        Tab.Button = TabButton
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "_Content"
        TabContent.Size = UDim2.new(1, -24, 1, -24)
        TabContent.Position = UDim2.new(0, 12, 0, 12)
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
        ContentLayout.Padding = UDim.new(0, 12)
        ContentLayout.Parent = TabContent
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 24)
        end)
        
        Tab.Content = TabContent
        
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utils:Tween(TabButton, {BackgroundTransparency = 0.7}, 0.25)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utils:Tween(TabButton, {BackgroundTransparency = 1}, 0.25)
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
            ButtonFrame.Size = UDim2.new(1, 0, 0, 46)
            ButtonFrame.BackgroundColor3 = Config.Colors.Background
            ButtonFrame.BackgroundTransparency = 0.3
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Parent = TabContent
            Utils:CreateCorner(SliderFill, 3)
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Size = UDim2.new(1, 0, 1, 24)
            SliderButton.Position = UDim2.new(0, 0, 0, -12)
            SliderButton.BackgroundTransparency = 1
            SliderButton.Text = ""
            SliderButton.Parent = SliderBG
            
            local dragging = false
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                local value = math.floor((min + (max - min) * pos) / increment + 0.5) * increment
                value = math.clamp(value, min, max)
                
                ValueLabel.Text = tostring(value)
                Utils:Tween(SliderFill, {Size = UDim2.new((value - min) / (max - min), 0, 1, 0)}, 0.12)
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
            DropdownFrame.Size = UDim2.new(1, 0, 0, 46)
            DropdownFrame.BackgroundColor3 = Config.Colors.Background
            DropdownFrame.BackgroundTransparency = 0.3
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = TabContent
            DropdownFrame.ClipsDescendants = true
            Utils:CreateCorner(DropdownFrame, Config.SmallCornerRadius)
            Utils:CreateStroke(DropdownFrame, Config.Colors.Border, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -48, 0, 46)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = dropdownName .. ": " .. default
            Label.TextColor3 = Config.Colors.Text
            Label.TextSize = 15
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropdownFrame
            
            local Arrow = Instance.new("TextLabel")
            Arrow.AnchorPoint = Vector2.new(1, 0.5)
            Arrow.Size = UDim2.new(0, 24, 0, 24)
            Arrow.Position = UDim2.new(1, -12, 0, 23)
            Arrow.BackgroundTransparency = 1
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Text = "▼"
            Arrow.TextColor3 = Config.Colors.TextDark
            Arrow.TextSize = 11
            Arrow.Parent = DropdownFrame
            
            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Size = UDim2.new(1, 0, 0, #options * 40)
            OptionsContainer.Position = UDim2.new(0, 0, 0, 46)
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.Parent = DropdownFrame
            
            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsLayout.Padding = UDim.new(0, 4)
            OptionsLayout.Parent = OptionsContainer
            
            local isOpen = false
            local currentValue = default
            
            local function ToggleDropdown()
                isOpen = not isOpen
                if isOpen then
                    Utils:Spring(DropdownFrame, {Size = UDim2.new(1, 0, 0, 46 + #options * 40 + 8)})
                    Utils:Spring(Arrow, {Rotation = 180})
                else
                    Utils:Spring(DropdownFrame, {Size = UDim2.new(1, 0, 0, 46)})
                    Utils:Spring(Arrow, {Rotation = 0})
                end
            end
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(1, 0, 0, 46)
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Text = ""
            DropdownButton.ZIndex = 2
            DropdownButton.Parent = DropdownFrame
            
            DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
            
            for _, option in ipairs(options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, -12, 0, 38)
                OptionButton.BackgroundColor3 = Config.Colors.Border
                OptionButton.BackgroundTransparency = 0.4
                OptionButton.BorderSizePixel = 0
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Text = "  " .. option
                OptionButton.TextColor3 = Config.Colors.Text
                OptionButton.TextSize = 14
                OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                OptionButton.Parent = OptionsContainer
                Utils:CreateCorner(OptionButton, 10)
                
                OptionButton.MouseButton1Click:Connect(function()
                    currentValue = option
                    Label.Text = dropdownName .. ": " .. option
                    ToggleDropdown()
                    callback(option)
                end)
                
                OptionButton.MouseEnter:Connect(function()
                    Utils:Tween(OptionButton, {BackgroundColor3 = Config.Colors.Accent, BackgroundTransparency = 0.15}, 0.25)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Utils:Tween(OptionButton, {BackgroundColor3 = Config.Colors.Border, BackgroundTransparency = 0.4}, 0.25)
                end)
            end
            
            return DropdownFrame
        end
        
        function Tab:CreateLabel(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 34)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.Parent = TabContent
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -24, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.Gotham
            Label.Text = text
            Label.TextColor3 = Config.Colors.TextDark
            Label.TextSize = 14
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
        for _, t in ipairs(self.Tabs) do
            if t == tab then
                Utils:Spring(t.Button, {BackgroundTransparency = 0.65, TextColor3 = Config.Colors.Text})
                t.Content.Visible = true
            else
                Utils:Spring(t.Button, {BackgroundTransparency = 1, TextColor3 = Config.Colors.TextDark})
                t.Content.Visible = false
            end
        end
        self.CurrentTab = tab
    end
    
    return Window
end

function ScawsHub:CreateNotification(settings)
    settings = settings or {}
    local title = settings.Title or "Notification"
    local content = settings.Content or ""
    local duration = settings.Duration or 5
    local type = settings.Type or "Info"
    
    local Players = game:GetService("Players")
    local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local notifGui = PlayerGui:FindFirstChild("ScawsHub_Notifications")
    if not notifGui then
        notifGui = Instance.new("ScreenGui")
        notifGui.Name = "ScawsHub_Notifications"
        notifGui.ResetOnSpawn = false
        notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        notifGui.IgnoreGuiInset = true
        
        local success, err = pcall(function()
            if gethui then
                notifGui.Parent = gethui()
            elseif get_hidden_gui or gethui then
                notifGui.Parent = (get_hidden_gui or gethui)()
            else
                notifGui.Parent = PlayerGui
            end
        end)
        
        if not success then
            notifGui.Parent = PlayerGui
        end
    end
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 340, 0, 90)
    Notification.Position = UDim2.new(1, 360, 1, -110 - (#notifGui:GetChildren() - 1) * 100)
    Notification.BackgroundColor3 = Config.Colors.Background
    Notification.BackgroundTransparency = 0.15
    Notification.BorderSizePixel = 0
    Notification.Parent = notifGui
    Utils:CreateCorner(Notification, Config.SmallCornerRadius)
    Utils:CreateStroke(Notification, Config.Colors.Border, 1)
    
    local colorMap = {
        Info = Config.Colors.Accent,
        Success = Config.Colors.Success,
        Warning = Config.Colors.Warning,
        Error = Config.Colors.Error
    }
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 6, 1, 0)
    Indicator.BackgroundColor3 = colorMap[type] or Config.Colors.Accent
    Indicator.BackgroundTransparency = 0.2
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Notification
    Utils:CreateCorner(Indicator, Config.SmallCornerRadius)
    
    local IndicatorFix = Instance.new("Frame")
    IndicatorFix.Size = UDim2.new(0, 6, 1, 0)
    IndicatorFix.Position = UDim2.new(0, 6, 0, 0)
    IndicatorFix.BackgroundColor3 = colorMap[type] or Config.Colors.Accent
    IndicatorFix.BackgroundTransparency = 0.2
    IndicatorFix.BorderSizePixel = 0
    IndicatorFix.Parent = Notification
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 0, 30)
    Title.Position = UDim2.new(0, 20, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Config.Colors.Text
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Notification
    
    local Content = Instance.new("TextLabel")
    Content.Size = UDim2.new(1, -30, 0, 48)
    Content.Position = UDim2.new(0, 20, 0, 38)
    Content.BackgroundTransparency = 1
    Content.Font = Enum.Font.Gotham
    Content.Text = content
    Content.TextColor3 = Config.Colors.TextDark
    Content.TextSize = 14
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextYAlignment = Enum.TextYAlignment.Top
    Content.TextWrapped = true
    Content.Parent = Notification
    
    local targetPos = UDim2.new(1, -350, 1, -110 - (#notifGui:GetChildren() - 1) * 100)
    Utils:Spring(Notification, {Position = targetPos})
    
    task.delay(duration, function()
        Utils:Spring(Notification, {Position = UDim2.new(1, 360, 1, Notification.Position.Y.Offset)})
        task.wait(0.5)
        Notification:Destroy()
        
        for i, notif in ipairs(notifGui:GetChildren()) do
            if notif:IsA("Frame") then
                Utils:Spring(notif, {
                    Position = UDim2.new(1, -350, 1, -110 - (i - 1) * 100)
                })
            end
        end
    end)
end

return ScawsHubCorner(ButtonFrame, Config.SmallCornerRadius)
            Utils:CreateStroke(ButtonFrame, Config.Colors.Border, 1)
            
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -24, 1, -12)
            Button.Position = UDim2.new(0, 12, 0, 6)
            Button.BackgroundTransparency = 1
            Button.Font = Enum.Font.GothamSemibold
            Button.Text = buttonName
            Button.TextColor3 = Config.Colors.Text
            Button.TextSize = 15
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Parent = ButtonFrame
            
            Button.MouseButton1Click:Connect(function()
                Utils:Spring(ButtonFrame, {BackgroundColor3 = Config.Colors.Accent, BackgroundTransparency = 0.1})
                task.wait(0.15)
                Utils:Spring(ButtonFrame, {BackgroundColor3 = Config.Colors.Background, BackgroundTransparency = 0.3})
                callback()
            end)
            
            Button.MouseEnter:Connect(function()
                Utils:Tween(ButtonFrame, {BackgroundTransparency = 0.1}, 0.25)
            end)
            
            Button.MouseLeave:Connect(function()
                Utils:Tween(ButtonFrame, {BackgroundTransparency = 0.3}, 0.25)
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
            ToggleFrame.Size = UDim2.new(1, 0, 0, 46)
            ToggleFrame.BackgroundColor3 = Config.Colors.Background
            ToggleFrame.BackgroundTransparency = 0.3
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent
            Utils:CreateCorner(ToggleFrame, Config.SmallCornerRadius)
            Utils:CreateStroke(ToggleFrame, Config.Colors.Border, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -75, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = toggleName
            Label.TextColor3 = Config.Colors.Text
            Label.TextSize = 15
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.AnchorPoint = Vector2.new(1, 0.5)
            ToggleButton.Position = UDim2.new(1, -12, 0.5, 0)
            ToggleButton.Size = UDim2.new(0, 50, 0, 26)
            ToggleButton.BackgroundColor3 = Config.Colors.Border
            ToggleButton.BackgroundTransparency = 0.3
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Text = ""
            ToggleButton.Parent = ToggleFrame
            Utils:CreateCorner(ToggleButton, 13)
            
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
            ToggleIndicator.Position = UDim2.new(0, 3, 0.5, -10)
            ToggleIndicator.BackgroundColor3 = Config.Colors.TextDark
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Parent = ToggleButton
            Utils:CreateCorner(ToggleIndicator, 10)
            
            local toggled = default
            
            local function UpdateToggle()
                if toggled then
                    Utils:Spring(ToggleButton, {BackgroundColor3 = Config.Colors.Accent, BackgroundTransparency = 0.1})
                    Utils:Spring(ToggleIndicator, {Position = UDim2.new(1, -23, 0.5, -10), BackgroundColor3 = Config.Colors.Text})
                else
                    Utils:Spring(ToggleButton, {BackgroundColor3 = Config.Colors.Border, BackgroundTransparency = 0.3})
                    Utils:Spring(ToggleIndicator, {Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = Config.Colors.TextDark})
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
            SliderFrame.Size = UDim2.new(1, 0, 0, 66)
            SliderFrame.BackgroundColor3 = Config.Colors.Background
            SliderFrame.BackgroundTransparency = 0.3
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent
            Utils:CreateCorner(SliderFrame, Config.SmallCornerRadius)
            Utils:CreateStroke(SliderFrame, Config.Colors.Border, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -24, 0, 22)
            Label.Position = UDim2.new(0, 12, 0, 8)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = sliderName
            Label.TextColor3 = Config.Colors.Text
            Label.TextSize = 15
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.AnchorPoint = Vector2.new(1, 0)
            ValueLabel.Size = UDim2.new(0, 70, 0, 22)
            ValueLabel.Position = UDim2.new(1, -12, 0, 8)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = Config.Colors.Accent
            ValueLabel.TextSize = 15
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local SliderBG = Instance.new("Frame")
            SliderBG.Size = UDim2.new(1, -24, 0, 6)
            SliderBG.Position = UDim2.new(0, 12, 0, 40)
            SliderBG.BackgroundColor3 = Config.Colors.Border
            SliderBG.BackgroundTransparency = 0.4
            SliderBG.BorderSizePixel = 0
            SliderBG.Parent = SliderFrame
            Utils:CreateCorner(SliderBG, 3)
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Config.Colors.Accent
            SliderFill.BackgroundTransparency = 0.2
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBG
            Utils:Create
