-- Sentinel UI: launcher-style shell, native Roblox controls.
local SentinelUI = {}
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local colors = {
    base = Color3.fromRGB(11, 9, 22),
    panel = Color3.fromRGB(20, 16, 35),
    border = Color3.fromRGB(58, 47, 80),
    text = Color3.fromRGB(244, 239, 255),
    muted = Color3.fromRGB(171, 159, 195),
    accent = Color3.fromRGB(181, 137, 255),
}

local function create(class, parent, properties)
    local object = Instance.new(class)
    for key, value in pairs(properties or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function corner(object, radius)
    create("UICorner", object, {CornerRadius = UDim.new(0, radius)})
end

local function outline(object)
    create("UIStroke", object, {Color = colors.border, Thickness = 1})
end

local function text(parent, value, position, size, fontSize, color, font)
    return create("TextLabel", parent, {
        BackgroundTransparency = 1, Position = position, Size = size,
        Text = value, TextSize = fontSize, TextColor3 = color or colors.text,
        Font = font or Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local function button(parent, value, position, size)
    local control = create("TextButton", parent, {
        Position = position, Size = size, BackgroundColor3 = colors.panel,
        BorderSizePixel = 0, Text = value, TextColor3 = colors.text,
        Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = true,
    })
    corner(control, 5)
    return control
end

function SentinelUI.CreateWindow(toggleKey)
    toggleKey = toggleKey or Enum.KeyCode.RightShift
    local parent = player:WaitForChild("PlayerGui")
    local previous = parent:FindFirstChild("SentinelUI")
    if previous then previous:Destroy() end
    local gui = create("ScreenGui", parent, {
        Name = "SentinelUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    local connections, tabs = {}, {}
    local alive = true
    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end
    gui.Destroying:Connect(function()
        alive = false
        for _, connection in ipairs(connections) do connection:Disconnect() end
    end)

    local main = create("Frame", gui, {
        Name = "Main", Size = UDim2.fromOffset(900, 600),
        Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = colors.base, BorderSizePixel = 0, ClipsDescendants = true,
    })
    corner(main, 10)
    outline(main)
    local scale = create("UIScale", main, {})
    local function fit()
        local camera = workspace.CurrentCamera
        if camera then
            scale.Scale = math.max(0.1, math.min(1, (camera.ViewportSize.X - 24) / 900, (camera.ViewportSize.Y - 48) / 600))
        end
    end
    local viewportConnection
    local function watchCamera()
        if viewportConnection then viewportConnection:Disconnect() end
        if workspace.CurrentCamera then
            viewportConnection = connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), fit)
        end
        fit()
    end
    connect(workspace:GetPropertyChangedSignal("CurrentCamera"), watchCamera)
    watchCamera()

    local header = create("Frame", main, {
        Name = "Header", Size = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = colors.base, BorderSizePixel = 0, Active = true,
    })
    text(header, "S", UDim2.fromOffset(24, 12), UDim2.fromOffset(32, 48), 36, colors.accent, Enum.Font.Oswald)
    text(header, "S E N T I N E L", UDim2.fromOffset(70, 16), UDim2.fromOffset(180, 16), 10, colors.accent)
    text(header, "HUB", UDim2.fromOffset(69, 31), UDim2.fromOffset(180, 28), 25, nil, Enum.Font.Oswald)

    local avatar = create("ImageLabel", header, {
        Name = "Avatar", Position = UDim2.new(1, -342, 0, 15),
        Size = UDim2.fromOffset(42, 42), BackgroundColor3 = colors.panel,
        BorderSizePixel = 0, Image = "",
    })
    corner(avatar, 21)
    create("UIStroke", avatar, {Color = colors.accent, Thickness = 2})
    local fallback = text(avatar, "?", UDim2.new(), UDim2.fromScale(1, 1), 20, colors.accent)
    fallback.TextXAlignment = Enum.TextXAlignment.Center
    text(header, player.DisplayName, UDim2.new(1, -287, 0, 17), UDim2.fromOffset(142, 20), 14, nil, Enum.Font.GothamBold)
    text(header, "@" .. player.Name, UDim2.new(1, -287, 0, 38), UDim2.fromOffset(142, 16), 11, colors.muted)
    -- Thumbnail loading never blocks opening or unloading the window.
    task.spawn(function()
        for attempt = 1, 3 do
            if not alive then return end
            local ok, image, ready = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
            end)
            if not alive then return end
            if ok and ready then
                avatar.Image = image
                fallback.Visible = false
                return
            end
            if attempt < 3 then task.wait(1) end
        end
    end)

    local collapse = button(header, "-", UDim2.new(1, -128, 0, 23), UDim2.fromOffset(30, 28))
    collapse.Name = "Collapse"
    local unload = button(header, "Unload", UDim2.new(1, -88, 0, 23), UDim2.fromOffset(70, 28))
    unload.Name = "Unload"
    outline(unload)
    connect(unload.Activated, function() gui:Destroy() end)

    local body = create("Frame", main, {
        Name = "Body", Position = UDim2.fromOffset(0, 72), Size = UDim2.new(1, 0, 1, -72),
        BackgroundTransparency = 1,
    })
    local nav = create("ScrollingFrame", body, {
        Name = "Navigation", Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = colors.panel, BorderSizePixel = 0,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 2,
        ScrollBarImageColor3 = colors.accent,
    })
    create("UIPadding", nav, {PaddingLeft = UDim.new(0, 22), PaddingRight = UDim.new(0, 22)})
    create("UIListLayout", nav, {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})

    local hero = create("Frame", body, {
        Position = UDim2.fromOffset(0, 55), Size = UDim2.new(1, 0, 0, 142),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ClipsDescendants = true,
    })
    create("UIGradient", hero, {
        Color = ColorSequence.new(colors.panel, Color3.fromRGB(55, 27, 92)), Rotation = 15,
    })
    -- Native geometric accents keep the background independent of external assets.
    for i = 1, 3 do
        local shard = create("Frame", hero, {
            Size = UDim2.fromOffset(150, 230), Position = UDim2.new(1, -80 - i * 65, 0, -50),
            Rotation = 32, BackgroundTransparency = 0.88, BackgroundColor3 = colors.accent,
            BorderSizePixel = 0,
        })
        create("UIStroke", shard, {Color = colors.accent, Transparency = 0.7})
    end
    text(hero, "YOUR SPACE. YOUR CONTROL.", UDim2.fromOffset(26, 19), UDim2.new(1, -52, 0, 17), 10, colors.accent, Enum.Font.GothamBold)
    text(hero, "WELCOME BACK, " .. string.upper(player.DisplayName), UDim2.fromOffset(24, 43), UDim2.new(1, -52, 0, 44), 32, nil, Enum.Font.Oswald)
    local section = text(hero, "Select a tab to get started.", UDim2.fromOffset(26, 100), UDim2.new(1, -52, 0, 20), 13, colors.muted)
    local pages = create("Frame", body, {
        Position = UDim2.fromOffset(24, 213), Size = UDim2.new(1, -48, 1, -257), BackgroundTransparency = 1,
    })
    text(body, "SENTINEL HUB", UDim2.new(0, 24, 1, -32), UDim2.new(0.5, 0, 0, 22), 10, colors.muted)
    local hint = text(body, toggleKey.Name .. "  /  SHOW OR HIDE", UDim2.new(0.5, 0, 1, -32), UDim2.new(0.5, -24, 0, 22), 10, colors.muted)
    hint.TextXAlignment = Enum.TextXAlignment.Right

    local expanded = true
    connect(collapse.Activated, function()
        expanded = not expanded
        body.Visible = expanded
        main.Size = UDim2.fromOffset(900, expanded and 600 or 72)
        collapse.Text = expanded and "-" or "+"
    end)
    connect(Input.InputBegan, function(input, processed)
        if not processed and input.KeyCode == toggleKey and not Input:GetFocusedTextBox() then
            main.Visible = not main.Visible
        end
    end)

    local dragInput, dragStart, startPosition
    connect(header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragInput, dragStart, startPosition = input, input.Position, main.Position
        end
    end)
    connect(Input.InputChanged, function(input)
        if dragInput and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)
    connect(Input.InputEnded, function(input)
        if input == dragInput then dragInput = nil end
    end)

    local window = {}
    function window:CreateTab(name)
        local tabButton = button(nav, string.upper(name), UDim2.new(), UDim2.fromOffset(0, 51))
        tabButton.Name = name
        tabButton.AutomaticSize = Enum.AutomaticSize.X
        tabButton.BackgroundTransparency = 1
        tabButton.Font = Enum.Font.Oswald
        tabButton.TextSize = 19
        tabButton.LayoutOrder = #tabs + 1
        create("UIPadding", tabButton, {PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18)})
        local indicator = create("Frame", tabButton, {
            Position = UDim2.new(0, 0, 1, -3), Size = UDim2.new(1, 0, 0, 3),
            BackgroundColor3 = colors.accent, BorderSizePixel = 0, Visible = false,
        })
        local page = create("ScrollingFrame", pages, {
            Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3, ScrollBarImageColor3 = colors.accent, Visible = false,
            ScrollingDirection = Enum.ScrollingDirection.Y,
        })
        create("UIPadding", page, {PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 8)})
        create("UIListLayout", page, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        table.insert(tabs, {page = page, button = tabButton, indicator = indicator})
        local function select()
            for _, tab in ipairs(tabs) do
                local active = tab.page == page
                tab.page.Visible, tab.indicator.Visible = active, active
                tab.button.TextColor3 = active and colors.text or colors.muted
                tab.button.BackgroundTransparency = active and 0 or 1
            end
            section.Text = name .. "  /  Make it yours."
        end
        connect(tabButton.Activated, select)
        if #tabs == 1 then select() else tabButton.TextColor3 = colors.muted end

        local components, order = {}, 0
        local function row(class)
            order = order + 1
            local object = create(class, page, {
                Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = colors.panel,
                BorderSizePixel = 0, LayoutOrder = order,
            })
            corner(object, 6)
            outline(object)
            return object
        end
        function components:Label(value)
            local label = row("TextLabel")
            label.Text, label.TextColor3, label.TextSize = value, colors.muted, 13
            label.Font, label.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
            label.TextWrapped = true
            label.AutomaticSize = Enum.AutomaticSize.Y
            create("UIPadding", label, {PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})
            return label
        end
        function components:Button(value, callback)
            local control = row("TextButton")
            control.Text, control.AutoButtonColor = "", true
            text(control, value, UDim2.fromOffset(16, 0), UDim2.new(1, -90, 1, 0), 14, nil, Enum.Font.GothamBold)
            local arrow = text(control, ">", UDim2.new(1, -54, 0, 10), UDim2.fromOffset(38, 32), 20, colors.base, Enum.Font.GothamBold)
            arrow.TextXAlignment, arrow.BackgroundTransparency, arrow.BackgroundColor3 = Enum.TextXAlignment.Center, 0, colors.accent
            corner(arrow, 4)
            connect(control.Activated, function() if callback then callback() end end)
            return control
        end
        function components:Toggle(value, default, callback)
            local state = default == true
            local control = row("TextButton")
            control.Text, control.AutoButtonColor = "", true
            text(control, value, UDim2.fromOffset(16, 0), UDim2.new(1, -150, 1, 0), 14)
            local status = text(control, state and "ON" or "OFF", UDim2.new(1, -112, 0, 0), UDim2.fromOffset(40, 52), 10, colors.muted, Enum.Font.GothamBold)
            local track = create("Frame", control, {Position = UDim2.new(1, -64, 0, 14), Size = UDim2.fromOffset(46, 24), BorderSizePixel = 0, BackgroundColor3 = state and colors.accent or colors.border})
            corner(track, 12)
            local knob = create("Frame", track, {Position = UDim2.fromOffset(state and 25 or 3, 3), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = colors.text, BorderSizePixel = 0})
            corner(knob, 9)
            connect(control.Activated, function()
                state = not state
                status.Text = state and "ON" or "OFF"
                track.BackgroundColor3 = state and colors.accent or colors.border
                TweenService:Create(knob, TweenInfo.new(0.12), {Position = UDim2.fromOffset(state and 25 or 3, 3)}):Play()
                if callback then callback(state) end
            end)
            return control
        end
        return components
    end
    function window:Destroy() gui:Destroy() end
    return window
end
return SentinelUI
