local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Theme = {
    Background = Color3.fromRGB(10, 10, 10),
    Accent = Color3.fromRGB(145, 85, 255),
    Section = Color3.fromRGB(20, 20, 20),
    Text = Color3.fromRGB(180, 130, 255),
    TextLight = Color3.fromRGB(210, 170, 255),
}

local function CreateSentinelUI()
    local SentinelUI = {}

    function SentinelUI:CreateWindow(toggleKey)
        local playerName = Players.LocalPlayer and Players.LocalPlayer.Name or "Guest"
        local Gui = Instance.new("ScreenGui")
        Gui.Name = "SentinelUI_" .. tostring(math.random(1000, 9999))
        Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        Gui.ResetOnSpawn = false
        Gui.Parent = game.CoreGui

        local Main = Instance.new("Frame")
        Main.Size = UDim2.fromOffset(580, 360)
        Main.Position = UDim2.new(0.5, -290, 0.5, -180)
        Main.BackgroundColor3 = Theme.Background
        Main.BorderSizePixel = 0
        Main.Active = true
        Main.Draggable = true
        Main.Parent = Gui

        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

        local Header = Instance.new("Frame")
        Header.Size = UDim2.new(1, 0, 0, 36)
        Header.BackgroundColor3 = Theme.Section
        Header.Parent = Main
        Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

        local HeaderLabel = Instance.new("TextLabel")
        HeaderLabel.Size = UDim2.new(1, -20, 1, 0)
        HeaderLabel.Position = UDim2.fromOffset(10, 0)
        HeaderLabel.BackgroundTransparency = 1
        HeaderLabel.TextColor3 = Theme.Text
        HeaderLabel.Font = Enum.Font.Code
        HeaderLabel.TextSize = 16
        HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
        HeaderLabel.Text = ("Sentinel Hub | Universal | User@%s | *Loading...*"):format(playerName)
        HeaderLabel.Parent = Header

        local TabPanel = Instance.new("Frame")
        TabPanel.Size = UDim2.new(0, 140, 1, -36)
        TabPanel.Position = UDim2.new(0, 0, 0, 36)
        TabPanel.BackgroundColor3 = Theme.Section
        TabPanel.Parent = Main

        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Padding = UDim.new(0, 4)
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabLayout.Parent = TabPanel

        local ContentPanel = Instance.new("Frame")
        ContentPanel.Size = UDim2.new(1, -140, 1, -36)
        ContentPanel.Position = UDim2.new(0, 140, 0, 36)
        ContentPanel.BackgroundColor3 = Theme.Background
        ContentPanel.Parent = Main

        local tabs = {}

        UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == (toggleKey or Enum.KeyCode.RightShift) then
                Main.Visible = not Main.Visible
            end
        end)

        function SentinelUI:CreateTab(tabName)
            local tabButton = Instance.new("TextButton")
            tabButton.Size = UDim2.new(1, -10, 0, 30)
            tabButton.BackgroundColor3 = Theme.Section
            tabButton.TextColor3 = Theme.Text
            tabButton.Font = Enum.Font.Code
            tabButton.TextSize = 15
            tabButton.Text = "> " .. tabName
            tabButton.BorderSizePixel = 0
            tabButton.AutoButtonColor = false
            tabButton.Parent = TabPanel
            Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 6)

            local tabContent = Instance.new("ScrollingFrame")
            tabContent.Size = UDim2.new(1, -20, 1, -20)
            tabContent.Position = UDim2.fromOffset(10, 10)
            tabContent.BackgroundTransparency = 1
            tabContent.ScrollBarThickness = 6
            tabContent.Visible = false
            tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
            tabContent.CanvasSize = UDim2.new()
            tabContent.Parent = ContentPanel

            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 8)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = tabContent

            tabButton.MouseButton1Click:Connect(function()
                for _, obj in ipairs(ContentPanel:GetChildren()) do
                    if obj:IsA("ScrollingFrame") then obj.Visible = false end
                end
                tabContent.Visible = true
                HeaderLabel.Text = ("Sentinel Hub | Universal | User@%s | *%s*"):format(playerName, tabName)
            end)

            if not next(tabs) then
                tabContent.Visible = true
                HeaderLabel.Text = ("Sentinel Hub | Universal | User@%s | *%s*"):format(playerName, tabName)
            end

            local api = {}

            function api:Label(text)
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -20, 0, 22)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Theme.Text
                lbl.Font = Enum.Font.Code
                lbl.TextSize = 14
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Text = text
                lbl.Parent = tabContent
                return lbl
            end

            function api:Button(text, callback)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -20, 0, 30)
                btn.BackgroundColor3 = Theme.Section
                btn.TextColor3 = Theme.Text
                btn.Font = Enum.Font.Code
                btn.TextSize = 14
                btn.Text = text
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = false
                btn.Parent = tabContent
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

                btn.MouseEnter:Connect(function()
                    btn.BackgroundColor3 = Theme.Accent
                    btn.TextColor3 = Color3.new(1, 1, 1)
                end)
                btn.MouseLeave:Connect(function()
                    btn.BackgroundColor3 = Theme.Section
                    btn.TextColor3 = Theme.Text
                end)

                btn.MouseButton1Click:Connect(callback)
                return btn
            end

            function api:Toggle(text, default, callback)
                local state = default or false
                local toggle = Instance.new("TextButton")
                toggle.Size = UDim2.new(1, -20, 0, 30)
                toggle.BackgroundColor3 = Theme.Section
                toggle.TextColor3 = Theme.Text
                toggle.Font = Enum.Font.Code
                toggle.TextSize = 14
                toggle.BorderSizePixel = 0
                toggle.AutoButtonColor = false
                toggle.Parent = tabContent
                Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

                local function update()
                    toggle.Text = ("%s: [%s]"):format(text, state and "ON" or "OFF")
                end
                update()

                toggle.MouseEnter:Connect(function()
                    toggle.BackgroundColor3 = Theme.Accent
                    toggle.TextColor3 = Color3.new(1, 1, 1)
                end)
                toggle.MouseLeave:Connect(function()
                    toggle.BackgroundColor3 = Theme.Section
                    toggle.TextColor3 = Theme.Text
                end)

                toggle.MouseButton1Click:Connect(function()
                    state = not state
                    update()
                    if callback then callback(state) end
                end)

                return toggle
            end

            tabs[tabName] = api
            return api
        end

        function SentinelUI:Destroy()
            Gui:Destroy()
        end

        return SentinelUI
    end

    return CreateSentinelUI
end

return CreateSentinelUI
