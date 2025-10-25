local ScawsHub = loadstring(game:HttpGet("your_url_here"))()

local Window = ScawsHub:CreateWindow({
    Name = "Universal Script Hub",
    LoadingDuration = 2.5,
    ShowLoading = true
})

ScawsHub:CreateNotification({
    Title = "Welcome!",
    Content = "Universal Script Hub loaded successfully!",
    Duration = 4,
    Type = "Success"
})

local PlayerTab = Window:CreateTab("Player")
local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local WorldTab = Window:CreateTab("World")
local MiscTab = Window:CreateTab("Misc")

PlayerTab:CreateLabel("🏃 Movement Options")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Increment = 5,
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = value
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(enabled)
        local player = game.Players.LocalPlayer
        if enabled then
            _G.InfiniteJump = game:GetService("UserInputService").JumpRequest:Connect(function()
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            ScawsHub:CreateNotification({
                Title = "Infinite Jump",
                Content = "Enabled! Keep jumping!",
                Duration = 3,
                Type = "Success"
            })
        else
            if _G.InfiniteJump then
                _G.InfiniteJump:Disconnect()
                _G.InfiniteJump = nil
            end
        end
    end
})

PlayerTab:CreateToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(enabled)
        local player = game.Players.LocalPlayer
        _G.NoClip = enabled
        
        if enabled then
            game:GetService("RunService").Stepped:Connect(function()
                if _G.NoClip and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
            ScawsHub:CreateNotification({
                Title = "Reset",
                Content = "Character has been reset",
                Duration = 2,
                Type = "Warning"
            })
        end
    end
})

CombatTab:CreateLabel("⚔️ Combat Features")

CombatTab:CreateSlider({
    Name = "Attack Reach",
    Min = 5,
    Max = 50,
    Default = 5,
    Increment = 1,
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character then
            for _, tool in pairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                    tool.Handle.Size = Vector3.new(value, value, value)
                    tool.Handle.Transparency = 0.9
                end
            end
        end
    end
})

CombatTab:CreateToggle({
    Name = "Auto Click",
    Default = false,
    Callback = function(enabled)
        _G.AutoClick = enabled
        
        if enabled then
            spawn(function()
                while _G.AutoClick do
                    mouse1click()
                    task.wait(0.05)
                end
            end)
        end
    end
})

CombatTab:CreateToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(enabled)
        _G.KillAura = enabled
        
        if enabled then
            spawn(function()
                while _G.KillAura do
                    local player = game.Players.LocalPlayer
                    if player.Character then
                        for _, v in pairs(game.Players:GetPlayers()) do
                            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                                local distance = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                                if distance < 20 then
                                    print("Target in range:", v.Name)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

CombatTab:CreateButton({
    Name = "God Mode (Client)",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.MaxHealth = math.huge
            player.Character.Humanoid.Health = math.huge
            ScawsHub:CreateNotification({
                Title = "God Mode",
                Content = "Client-side god mode enabled",
                Duration = 3,
                Type = "Success"
            })
        end
    end
})

VisualsTab:CreateLabel("👁️ Visual Enhancements")

VisualsTab:CreateToggle({
    Name = "FullBright",
    Default = false,
    Callback = function(enabled)
        local lighting = game:GetService("Lighting")
        if enabled then
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            lighting.Brightness = 1
            lighting.ClockTime = 12
            lighting.FogEnd = 100000
            lighting.GlobalShadows = true
            lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        end
    end
})

VisualsTab:CreateSlider({
    Name = "FOV",
    Min = 70,
    Max = 120,
    Default = 70,
    Increment = 1,
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})

VisualsTab:CreateToggle({
    Name = "ESP Players",
    Default = false,
    Callback = function(enabled)
        _G.PlayerESP = enabled
        
        if enabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        else
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Highlight") then
                    player.Character.Highlight:Destroy()
                end
            end
        end
    end
})

VisualsTab:CreateDropdown({
    Name = "Time of Day",
    Options = {"Dawn", "Morning", "Noon", "Afternoon", "Evening", "Night", "Midnight"},
    Default = "Noon",
    Callback = function(option)
        local timeMap = {
            Dawn = 6,
            Morning = 8,
            Noon = 12,
            Afternoon = 15,
            Evening = 18,
            Night = 20,
            Midnight = 0
        }
        game:GetService("Lighting").ClockTime = timeMap[option]
    end
})

VisualsTab:CreateToggle({
    Name = "Remove Fog",
    Default = false,
    Callback = function(enabled)
        if enabled then
            game:GetService("Lighting").FogEnd = 100000
        else
            game:GetService("Lighting").FogEnd = 10000
        end
    end
})

WorldTab:CreateLabel("🌍 World Modifications")

WorldTab:CreateSlider({
    Name = "Gravity",
    Min = 0,
    Max = 196,
    Default = 196,
    Increment = 10,
    Callback = function(value)
        workspace.Gravity = value
    end
})

WorldTab:CreateToggle({
    Name = "Remove Textures",
    Default = false,
    Callback = function(enabled)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = enabled and 1 or 0
            end
        end
    end
})

WorldTab:CreateToggle({
    Name = "X-Ray Vision",
    Default = false,
    Callback = function(enabled)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier = enabled and 0.5 or 0
            end
        end
    end
})

WorldTab:CreateButton({
    Name = "Collect All Items",
    Callback = function()
        local collected = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") or (obj:IsA("Model") and obj:FindFirstChild("Handle")) then
                obj:MoveTo(game.Players.LocalPlayer.Character.HumanoidRootPart.Position)
                collected = collected + 1
            end
        end
        ScawsHub:CreateNotification({
            Title = "Items Collected",
            Content = "Teleported " .. collected .. " items to you",
            Duration = 3,
            Type = "Success"
        })
    end
})

WorldTab:CreateButton({
    Name = "Delete All Barriers",
    Callback = function()
        local deleted = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("wall") or obj.Name:lower():find("barrier")) then
                obj:Destroy()
                deleted = deleted + 1
            end
        end
        ScawsHub:CreateNotification({
            Title = "Barriers Removed",
            Content = "Deleted " .. deleted .. " barriers",
            Duration = 3,
            Type = "Warning"
        })
    end
})

MiscTab:CreateLabel("⚙️ Miscellaneous")

MiscTab:CreateButton({
    Name = "Created by Zyy",
    Callback = function()
        ScawsHub:CreateNotification({
            Title = "Credits",
            Content = "ScawsHUB created by Zyy",
            Duration = 3,
            Type = "Info"
        })
    end
})

MiscTab:CreateButton({
    Name = "Copy GitHub Link",
    Callback = function()
        if setclipboard then
            setclipboard("https://github.com/ZyyScriptz")
            ScawsHub:CreateNotification({
                Title = "Copied!",
                Content = "GitHub link copied to clipboard",
                Duration = 3,
                Type = "Success"
            })
        end
    end
})

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        ScawsHub:CreateNotification({
            Title = "Rejoining...",
            Content = "Rejoining server and reloading UI",
            Duration = 2,
            Type = "Info"
        })
        task.wait(0.5)
        local ts = game:GetService("TeleportService")
        local p = game:GetService("Players").LocalPlayer
        ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, p)
    end
})

MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        ScawsHub:CreateNotification({
            Title = "Server Hopping...",
            Content = "Finding new server and reloading UI",
            Duration = 2,
            Type = "Info"
        })
        task.wait(0.5)
        local ts = game:GetService("TeleportService")
        local p = game:GetService("Players").LocalPlayer
        ts:Teleport(game.PlaceId, p)
    end
})

MiscTab:CreateButton({
    Name = "Copy Game Link",
    Callback = function()
        if setclipboard then
            setclipboard("https://www.roblox.com/games/" .. game.PlaceId)
            ScawsHub:CreateNotification({
                Title = "Copied!",
                Content = "Game link copied to clipboard",
                Duration = 3,
                Type = "Success"
            })
        end
    end
})

MiscTab:CreateButton({
    Name = "Copy Job ID",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            ScawsHub:CreateNotification({
                Title = "Copied!",
                Content = "Job ID copied to clipboard",
                Duration = 3,
                Type = "Success"
            })
        end
    end
})

MiscTab:CreateDropdown({
    Name = "Notification Test",
    Options = {"Info", "Success", "Warning", "Error"},
    Default = "Info",
    Callback = function(type)
        ScawsHub:CreateNotification({
            Title = type .. " Test",
            Content = "This is a " .. type .. " notification!",
            Duration = 3,
            Type = type
        })
    end
})

local statsLabel = MiscTab:CreateLabel("FPS: 0 | Ping: 0ms")

spawn(function()
    while task.wait(1) do
        local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        statsLabel.UpdateText("FPS: " .. fps .. " | Ping: " .. ping .. "ms")
    end
end)

MiscTab:CreateButton({
    Name = "Anti-AFK",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        ScawsHub:CreateNotification({
            Title = "Anti-AFK",
            Content = "Anti-AFK has been enabled",
            Duration = 3,
            Type = "Success"
        })
    end
})

print("Universal Script Hub loaded! Created by Zyy")local ScawsHub = loadstring(game:HttpGet("your_url_here"))()

local Window = ScawsHub:CreateWindow({
    Name = "ScawsHUB Tutorial",
    LoadingDuration = 2,
    ShowLoading = true
})

ScawsHub:CreateNotification({
    Title = "Welcome!",
    Content = "ScawsHUB loaded successfully!",
    Duration = 4,
    Type = "Success"
})

local Tab1 = Window:CreateTab("Buttons")
local Tab2 = Window:CreateTab("Toggles")
local Tab3 = Window:CreateTab("Sliders")
local Tab4 = Window:CreateTab("Dropdowns")
local Tab5 = Window:CreateTab("Advanced")

Tab1:CreateLabel("📌 Button Examples")

Tab1:CreateButton({
    Name = "Simple Button",
    Callback = function()
        print("Button clicked!")
    end
})

Tab1:CreateButton({
    Name = "Show Notification",
    Callback = function()
        ScawsHub:CreateNotification({
            Title = "Test",
            Content = "This is a test notification!",
            Duration = 3,
            Type = "Info"
        })
    end
})

Tab2:CreateLabel("🔘 Toggle Examples")

Tab2:CreateToggle({
    Name = "Example Toggle",
    Default = false,
    Callback = function(value)
        print("Toggle is:", value)
    end
})

Tab2:CreateToggle({
    Name = "Speed Boost",
    Default = false,
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if value then
                player.Character.Humanoid.WalkSpeed = 50
            else
                player.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

Tab3:CreateLabel("🎚️ Slider Examples")

Tab3:CreateSlider({
    Name = "Volume",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 5,
    Callback = function(value)
        print("Volume:", value)
    end
})

Tab3:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

Tab4:CreateLabel("📋 Dropdown Examples")

Tab4:CreateDropdown({
    Name = "Select Option",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Callback = function(option)
        print("Selected:", option)
    end
})

Tab4:CreateDropdown({
    Name = "Notification Type",
    Options = {"Info", "Success", "Warning", "Error"},
    Default = "Info",
    Callback = function(type)
        ScawsHub:CreateNotification({
            Title = type .. " Test",
            Content = "This is a " .. type .. " notification!",
            Duration = 3,
            Type = type
        })
    end
})

Tab5:CreateLabel("🚀 Advanced Features")

Tab5:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        local ts = game:GetService("TeleportService")
        local p = game:GetService("Players").LocalPlayer
        ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, p)
    end
})

local speedLabel = Tab5:CreateLabel("Current Speed: 16")

Tab5:CreateSlider({
    Name = "Dynamic Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        speedLabel.UpdateText("Current Speed: " .. value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

print("ScawsHUB Tutorial loaded! Created by Zyy")
