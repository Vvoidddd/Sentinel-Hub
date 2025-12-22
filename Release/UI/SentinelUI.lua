--============================================================
-- SentinelUI v2 - Recode by Void
--============================================================

local SentinelUI = {}

--============================================================
-- SERVICES
--============================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--============================================================
-- UTILS
--============================================================
local function round(n)
    return math.floor(n + 0.5)
end

local function makeDraggable(frame)
    local dragging = false
    local dragOffset

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragOffset = input.Position - frame.AbsolutePosition
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            frame.Position = UDim2.fromOffset(
                input.Position.X - dragOffset.X,
                input.Position.Y - dragOffset.Y
            )
        end
    end)
end

--============================================================
-- WINDOW
--============================================================
function SentinelUI.CreateWindow(toggleKey)
    toggleKey = toggleKey or Enum.KeyCode.RightShift

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SentinelUI"
    ScreenGui.Parent = game.CoreGui

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.fromOffset(600, 400)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Main.BorderSizePixel = 0

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    makeDraggable(Main)

    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(45, 45, 45)
    Stroke.Thickness = 1.5

    -- Title
    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.fromOffset(10, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Sentinel Hub"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.TextXAlignment = Left

    -- Sidebar
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.fromOffset(140, 350)
    Sidebar.Position = UDim2.fromOffset(0, 40)
    Sidebar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

    local TabLayout = Instance.new("UIListLayout", Sidebar)
    TabLayout.Padding = UDim.new(0, 6)

    -- Pages
    local Pages = Instance.new("Frame", Main)
    Pages.Size = UDim2.new(1, -150, 1, -50)
    Pages.Position = UDim2.fromOffset(150, 50)
    Pages.BackgroundTransparency = 1

    -- Toggle UI
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == toggleKey then
            Main.Visible = not Main.Visible
        end
    end)

    local Window = {}
    local Tabs = {}

    --============================================================
    -- TAB CREATION
    --============================================================
    function Window:CreateTab(name)
        local TabButton = Instance.new("TextButton", Sidebar)
        TabButton.Size = UDim2.new(1, -12, 0, 36)
        TabButton.Text = name
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 16
        TabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TabButton.BorderSizePixel = 0
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame", Pages)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.ScrollBarThickness = 4
        Page.CanvasSize = UDim2.new()
        Page.Visible = false
        Page.BackgroundTransparency = 1

        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0, 8)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 10)
        end)

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Page.Visible = false
            end
            Page.Visible = true
        end)

        local Components = {}

        --============================================================
        -- COMPONENTS
        --============================================================
        function Components:Label(text)
            local lbl = Instance.new("TextLabel", Page)
            lbl.Size = UDim2.new(1, -10, 0, 24)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextWrapped = true
            lbl.TextXAlignment = Left
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 15
            lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        end

        function Components:Button(text, callback)
            local btn = Instance.new("TextButton", Page)
            btn.Size = UDim2.new(1, -10, 0, 36)
            btn.Text = text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 16
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end

        function Components:Toggle(text, default, callback)
            local state = default or false

            local holder = Instance.new("Frame", Page)
            holder.Size = UDim2.new(1, -10, 0, 30)
            holder.BackgroundTransparency = 1

            local box = Instance.new("TextButton", holder)
            box.Size = UDim2.fromOffset(22, 22)
            box.Position = UDim2.fromOffset(0, 4)
            box.Text = ""
            box.BorderSizePixel = 0
            box.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

            local lbl = Instance.new("TextLabel", holder)
            lbl.Position = UDim2.fromOffset(30, 0)
            lbl.Size = UDim2.new(1, -30, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 16
            lbl.TextXAlignment = Left
            lbl.TextColor3 = Color3.new(1, 1, 1)

            box.MouseButton1Click:Connect(function()
                state = not state
                box.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
                if callback then callback(state) end
            end)
        end

        Tabs[#Tabs + 1] = {Page = Page}
        if #Tabs == 1 then
            Page.Visible = true
        end

        return Components
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

return SentinelUI
