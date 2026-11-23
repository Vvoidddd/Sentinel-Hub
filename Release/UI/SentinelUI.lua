-- Sentinel UI: launcher-style shell, native Roblox controls.
local SentinelUI = {Version = 3}
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
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

function SentinelUI.CreateWindow(options)
    if typeof(options) == "EnumItem" then options = {ToggleKey = options} end
    options = options or {}
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    local parent = player:WaitForChild("PlayerGui")
    local previous = parent:FindFirstChild("SentinelUI")
    if previous then previous:Destroy() end
    local gui = create("ScreenGui", parent, {
        Name = "SentinelUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    local connections, tabs, cleanup, controls = {}, {}, {}, {}
    local window = {}
    local loadingConfig = false
    local alive = true
    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end
    gui.Destroying:Connect(function()
        alive = false
        for _, connection in ipairs(connections) do connection:Disconnect() end
        for _, callback in ipairs(cleanup) do
            local ok, err = pcall(callback)
            if not ok then warn("[Sentinel cleanup] " .. tostring(err)) end
        end
    end)
    function window:Connect(signal, callback) return connect(signal, callback) end
    function window:OnDestroy(callback) table.insert(cleanup, callback) end
    function window:IsAlive() return alive end

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
    local footer = text(body, options.Name or "SENTINEL HUB", UDim2.new(0, 24, 1, -32), UDim2.new(0.5, 0, 0, 22), 10, colors.muted)
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


    local function finite(value)
        return type(value) == "number" and value == value and math.abs(value) < math.huge
    end
    local function bind(object, settings, flag, normalize, render)
        local handle = {Instance = object}
        function handle:Set(value, silent)
            assert(alive, "Sentinel window has been unloaded")
            value = normalize(value)
            self.Value = value
            render(value)
            if not silent then
                if options.ConfigFile and not loadingConfig then window:SaveConfig() end
                if settings.Callback then task.spawn(settings.Callback, self:Get()) end
            end
        end
        function handle:Get()
            if type(self.Value) == "table" then
                local copy = {}
                for k, v in pairs(self.Value) do copy[k] = v end
                return copy
            end
            return self.Value
        end
        flag = flag or settings.Flag
        if flag then
            assert(not controls[flag], "Duplicate control flag: " .. flag)
            controls[flag] = handle
        end
        return handle
    end

    function window:SetStatus(message) footer.Text = tostring(message) end
    function window:Notification(settings)
        self:SetStatus((settings.Title or "Sentinel") .. "  /  " .. (settings.Content or ""))
        local message = footer.Text
        task.delay(settings.Duration or 5, function()
            if alive and footer.Text == message then footer.Text = options.Name or "SENTINEL HUB" end
        end)
    end
    function window:SaveConfig()
        if not options.ConfigFile then return false, "No config file configured" end
        local ok, err = pcall(function()
            assert(writefile, "This environment does not support saving files")
            local values = {}
            for flag, control in pairs(controls) do
                local value = control:Get()
                values[flag] = typeof(value) == "Color3" and {Color = {value.R, value.G, value.B}} or value
            end
            writefile(options.ConfigFile, HttpService:JSONEncode(values))
        end)
        if not ok then warn("[Sentinel config] " .. tostring(err)) end
        return ok, err
    end
    function window:LoadConfig()
        if not options.ConfigFile or not isfile or not isfile(options.ConfigFile) then return false end
        local ok, err = pcall(function()
            local values = HttpService:JSONDecode(readfile(options.ConfigFile))
            assert(type(values) == "table", "Config must be an object")
            -- Validate the whole file before changing any controls.
            local staged = {}
            for flag, value in pairs(values) do
                local control = controls[flag]
                if control then
                    if type(value) == "table" and value.Color then
                        local c = value.Color
                        assert(type(c) == "table" and finite(c[1]) and finite(c[2]) and finite(c[3]), "Invalid saved color")
                        value = Color3.new(c[1], c[2], c[3])
                    end
                    staged[flag] = control.Validate(value)
                end
            end
            loadingConfig = true
            for flag, value in pairs(staged) do controls[flag]:Set(value) end
        end)
        loadingConfig = false
        if not ok then warn("[Sentinel config] " .. tostring(err)) end
        return ok, err
    end

    local function componentsFor(container)
        local components, order = {}, 0
        local function row(class, height)
            order = order + 1
            local object = create(class, container, {
                Size = UDim2.new(1, 0, 0, height or 52), BackgroundColor3 = colors.panel,
                BorderSizePixel = 0, LayoutOrder = order,
            })
            corner(object, 6)
            outline(object)
            return object
        end
        local function caption(object, settings, right)
            text(object, settings.Name or "", UDim2.fromOffset(16, 0), UDim2.new(1, -(right or 100), 0, settings.Description and 29 or 52), 14, nil, Enum.Font.GothamBold)
            if settings.Description then
                text(object, settings.Description, UDim2.fromOffset(16, 29), UDim2.new(1, -(right or 100), 0, 18), 11, colors.muted)
            end
        end
        function components:CreateLabel(settings)
            if type(settings) == "string" then settings = {Name = settings} end
            local label = row("TextLabel")
            label.TextColor3, label.TextSize = colors.muted, 13
            label.Font, label.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
            label.TextWrapped, label.AutomaticSize = true, Enum.AutomaticSize.Y
            create("UIPadding", label, {PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})
            local handle = {Instance = label}
            function handle:Set(value) label.Text = tostring(value) end
            handle:Set((settings.Name or "") .. (settings.Description and ("\n" .. settings.Description) or ""))
            return handle
        end
        function components:CreateParagraph(settings)
            return self:CreateLabel({Name = settings.Title, Description = settings.Content})
        end
        function components:CreateDivider()
            local line = row("Frame", 1)
            line.BackgroundColor3 = colors.border
            return line
        end
        function components:CreateButton(settings)
            local control = row("TextButton")
            control.Text, control.AutoButtonColor = "", true
            caption(control, settings)
            local arrow = text(control, ">", UDim2.new(1, -54, 0, 10), UDim2.fromOffset(38, 32), 20, colors.base, Enum.Font.GothamBold)
            arrow.TextXAlignment, arrow.BackgroundTransparency, arrow.BackgroundColor3 = Enum.TextXAlignment.Center, 0, colors.accent
            corner(arrow, 4)
            connect(control.Activated, function() if settings.Callback then settings.Callback() end end)
            return control
        end
        function components:CreateToggle(settings, flag)
            local control = row("TextButton")
            control.Text, control.AutoButtonColor = "", true
            caption(control, settings, 150)
            local status = text(control, "", UDim2.new(1, -112, 0, 0), UDim2.fromOffset(40, 52), 10, colors.muted, Enum.Font.GothamBold)
            local track = create("Frame", control, {Position = UDim2.new(1, -64, 0, 14), Size = UDim2.fromOffset(46, 24), BorderSizePixel = 0})
            corner(track, 12)
            local knob = create("Frame", track, {Size = UDim2.fromOffset(18, 18), BackgroundColor3 = colors.text, BorderSizePixel = 0})
            corner(knob, 9)
            local function normalize(value) assert(type(value) == "boolean", "Toggle requires a boolean"); return value end
            local handle = bind(control, settings, flag, normalize, function(state)
                status.Text = state and "ON" or "OFF"
                track.BackgroundColor3 = state and colors.accent or colors.border
                TweenService:Create(knob, TweenInfo.new(0.12), {Position = UDim2.fromOffset(state and 25 or 3, 3)}):Play()
            end)
            handle.Validate = normalize
            handle:Set(settings.CurrentValue == true, true)
            connect(control.Activated, function() handle:Set(not handle.Value) end)
            return handle
        end
        function components:CreateSlider(settings, flag)
            local minimum, maximum = settings.Range[1], settings.Range[2]
            local step = settings.Increment or 1
            assert(finite(minimum) and finite(maximum) and maximum > minimum and finite(step) and step > 0, "Invalid slider range or increment")
            local control = row("Frame", settings.Description and 94 or 78)
            caption(control, settings, 132)
            local field = create("TextBox", control, {
                Name = "Value", Position = UDim2.new(1, -114, 0, 12), Size = UDim2.fromOffset(96, 28),
                BackgroundColor3 = colors.base, TextColor3 = colors.text, BorderSizePixel = 0,
                Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false,
            })
            corner(field, 4)
            if settings.Suffix then
                local suffix = text(control, settings.Suffix, UDim2.new(1, -114, 0, 42), UDim2.fromOffset(96, 12), 10, colors.muted)
                suffix.TextXAlignment = Enum.TextXAlignment.Right
            end
            local track = button(control, "", UDim2.new(0, 18, 1, -25), UDim2.new(1, -36, 0, 16))
            track.Name, track.BackgroundColor3 = "Track", colors.border
            local fill = create("Frame", track, {Size = UDim2.new(), BackgroundColor3 = colors.accent, BorderSizePixel = 0})
            corner(fill, 4)
            local function normalize(value)
                assert(finite(value), "Slider requires a finite number")
                local clamped = math.clamp(value, minimum, maximum)
                if clamped == maximum then return maximum end
                return math.clamp(minimum + math.floor((clamped - minimum) / step + 0.5) * step, minimum, maximum)
            end
            local handle = bind(control, settings, flag, normalize, function(value)
                fill.Size = UDim2.fromScale((value - minimum) / (maximum - minimum), 1)
                field.Text = string.format("%.6g", value)
            end)
            handle.Validate = normalize
            handle:Set(settings.CurrentValue or minimum, true)
            connect(field.FocusLost, function()
                local value = tonumber(field.Text)
                if finite(value) then handle:Set(value) else field.Text = string.format("%.6g", handle.Value) end
            end)
            local dragging
            local function update(position)
                if track.AbsoluteSize.X > 0 then
                    local value = normalize(minimum + math.clamp((position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1) * (maximum - minimum))
                    if value ~= handle.Value then handle:Set(value) end
                end
            end
            connect(track.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = input; update(input.Position) end
            end)
            connect(Input.InputChanged, function(input)
                if dragging and (input == dragging or input.UserInputType == Enum.UserInputType.MouseMovement) then update(input.Position) end
            end)
            connect(Input.InputEnded, function(input) if input == dragging then dragging = nil end end)
            return handle
        end
        function components:CreateDropdown(settings, flag)
            local values = settings.Options or {}
            local multiple = settings.MultipleOptions == true
            local control = row("Frame")
            control.ClipsDescendants = true
            caption(control, settings, 240)
            local selection = button(control, "", UDim2.new(1, -220, 0, 12), UDim2.fromOffset(202, 28))
            selection.Name, selection.TextTruncate = "Selection", Enum.TextTruncate.AtEnd
            local list = create("ScrollingFrame", control, {
                Position = UDim2.fromOffset(16, 56), Size = UDim2.new(1, -32, 0, 140),
                CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0, BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 3,
            })
            local function normalize(value)
                local result = {}
                if not multiple then
                    if type(value) == "table" then value = value[1] end
                    if value == nil or value == "" then return "" end
                    assert(type(value) == "string" and table.find(values, value), "Unknown dropdown option")
                    return value
                end
                assert(type(value) == "table", "Multi-select requires an array")
                for _, option in ipairs(value) do
                    assert(type(option) == "string" and table.find(values, option), "Unknown dropdown option")
                    if not table.find(result, option) then table.insert(result, option) end
                end
                return result
            end
            local function render(value)
                local display = multiple and table.concat(value, ", ") or value
                selection.Text = (display ~= "" and display or "Select...") .. "  v"
                for _, choice in ipairs(list:GetChildren()) do
                    if choice:IsA("TextButton") then
                        local selected = multiple and table.find(value, choice.Name) or value == choice.Name
                        choice.Text = (selected and "[x] " or "[ ] ") .. choice.Name
                        choice.TextColor3 = selected and colors.accent or colors.text
                    end
                end
            end
            local handle = bind(control, settings, flag, normalize, render)
            handle.Validate = normalize
            handle:Set(settings.CurrentOption or (multiple and {} or ""), true)
            local function rebuild()
                list:ClearAllChildren()
                create("UIListLayout", list, {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
                for index, value in ipairs(values) do
                    local choice = button(list, value, UDim2.new(), UDim2.new(1, -6, 0, 30))
                    choice.Name = value
                    choice.LayoutOrder = index
                    -- Instance-owned events disconnect when the refreshed list is destroyed.
                    choice.Activated:Connect(function()
                        if multiple then
                            local selected = handle:Get()
                            local at = table.find(selected, value)
                            if at then table.remove(selected, at) else table.insert(selected, value) end
                            handle:Set(selected)
                        else
                            handle:Set(value)
                            list.Visible, control.Size = false, UDim2.new(1, 0, 0, 52)
                        end
                    end)
                end
                render(handle.Value)
            end
            local set = handle.Set
            function handle:Set(value, silent)
                if type(value) == "table" and (value.Options ~= nil or value.CurrentOption ~= nil) then
                    if value.Options then
                        for _, option in ipairs(value.Options) do assert(type(option) == "string", "Dropdown options must be strings") end
                        values = value.Options
                        local current = self:Get()
                        if multiple then
                            local kept = {}
                            for _, option in ipairs(current) do if table.find(values, option) then table.insert(kept, option) end end
                            current = kept
                        elseif not table.find(values, current) then current = "" end
                        set(self, current, silent)
                        rebuild()
                    end
                    if value.CurrentOption ~= nil then set(self, value.CurrentOption, silent) end
                else set(self, value, silent) end
            end
            rebuild()
            connect(selection.Activated, function()
                list.Visible = not list.Visible
                control.Size = UDim2.new(1, 0, 0, list.Visible and 204 or 52)
            end)
            return handle
        end
        function components:CreateColorPicker(settings, flag)
            local control = row("Frame", 86)
            caption(control, settings, 90)
            local swatch = create("Frame", control, {Position = UDim2.new(1, -54, 0, 12), Size = UDim2.fromOffset(36, 28), BorderSizePixel = 0})
            corner(swatch, 4)
            local fields = {}
            for index, channel in ipairs({"R", "G", "B"}) do
                local field = create("TextBox", control, {
                    Name = channel, Position = UDim2.new((index - 1) / 3, 34, 0, 53), Size = UDim2.new(1 / 3, -42, 0, 24),
                    BackgroundColor3 = colors.base, BorderSizePixel = 0, TextColor3 = colors.text,
                    Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, PlaceholderText = channel .. " (0-255)",
                })
                corner(field, 4)
                text(control, channel, UDim2.new((index - 1) / 3, 16, 0, 53), UDim2.fromOffset(16, 24), 10, colors.muted)
                fields[index] = field
            end
            local function normalize(value)
                assert(typeof(value) == "Color3" and finite(value.R) and finite(value.G) and finite(value.B), "Color picker requires Color3")
                return Color3.new(math.clamp(value.R, 0, 1), math.clamp(value.G, 0, 1), math.clamp(value.B, 0, 1))
            end
            local handle = bind(control, settings, flag, normalize, function(value)
                swatch.BackgroundColor3 = value
                for index, channel in ipairs({"R", "G", "B"}) do fields[index].Text = tostring(math.floor(value[channel] * 255 + 0.5)) end
            end)
            handle.Validate = normalize
            handle:Set(settings.Color or colors.accent, true)
            for _, field in ipairs(fields) do
                connect(field.FocusLost, function()
                    local r, g, b = tonumber(fields[1].Text), tonumber(fields[2].Text), tonumber(fields[3].Text)
                    if finite(r) and finite(g) and finite(b) then handle:Set(Color3.fromRGB(r, g, b)) else handle:Set(handle.Value, true) end
                end)
            end
            return handle
        end
        function components:CreateSection(name)
            if type(name) == "table" then name = name.Name end
            local group = row("Frame", 0)
            group.BackgroundTransparency = 1
            group.AutomaticSize = Enum.AutomaticSize.Y
            create("UIListLayout", group, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            local title = text(group, string.upper(name), UDim2.new(), UDim2.new(1, -16, 0, 28), 11, colors.accent, Enum.Font.GothamBold)
            title.LayoutOrder = 0
            return componentsFor(group)
        end
        function components:BuildConfigSection()
            local section = self:CreateSection("Configuration")
            section:CreateButton({Name = "Save configuration", Callback = function()
                local ok = window:SaveConfig(); window:SetStatus(ok and "Configuration saved" or "Could not save configuration")
            end})
            section:CreateButton({Name = "Load configuration", Callback = function()
                local ok = window:LoadConfig(); window:SetStatus(ok and "Configuration loaded" or "No valid configuration found")
            end})
        end
        function components:BuildThemeSection()
            self:CreateColorPicker({Name = "Accent color", Color = colors.accent, Callback = function(value)
                local old = colors.accent
                colors.accent = value
                for _, object in ipairs(main:GetDescendants()) do
                    if object:IsA("GuiObject") and object.BackgroundColor3 == old then object.BackgroundColor3 = value end
                    if (object:IsA("TextLabel") or object:IsA("TextButton")) and object.TextColor3 == old then object.TextColor3 = value end
                    if object:IsA("UIStroke") and object.Color == old then object.Color = value end
                end
            end}, "SentinelAccent")
        end
        -- Preserve the compact API used by the public UI demo.
        function components:Label(value) return self:CreateLabel(value) end
        function components:Button(value, callback) return self:CreateButton({Name = value, Callback = callback}) end
        function components:Toggle(value, default, callback)
            return self:CreateToggle({Name = value, CurrentValue = default, Callback = callback})
        end
        return components
    end

    function window:CreateTab(settings)
        local name = type(settings) == "table" and settings.Name or settings
        local tabButton = button(nav, string.upper(name), UDim2.new(), UDim2.fromOffset(0, 51))
        tabButton.Name, tabButton.AutomaticSize = name, Enum.AutomaticSize.X
        tabButton.BackgroundTransparency, tabButton.Font, tabButton.TextSize = 1, Enum.Font.Oswald, 19
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
        local components = componentsFor(page)
        local tab = {page = page, button = tabButton, indicator = indicator, components = components}
        table.insert(tabs, tab)
        connect(tabButton.Activated, function() window:SetActiveTab(components) end)
        if #tabs == 1 then window:SetActiveTab(components) else tabButton.TextColor3 = colors.muted end
        return components
    end
    function window:SetActiveTab(components)
        for _, tab in ipairs(tabs) do
            local active = tab.components == components
            tab.page.Visible, tab.indicator.Visible = active, active
            tab.button.TextColor3 = active and colors.text or colors.muted
            tab.button.BackgroundTransparency = active and 0 or 1
            if active then section.Text = tab.button.Name .. "  /  Make it yours." end
        end
    end
    function window:CreateHomeTab(settings)
        settings = settings or {}
        local home = self:CreateTab("Home")
        home:CreateLabel({Name = options.Name or "Sentinel Hub", Description = "Choose a tab above to get started."})
        if settings.DiscordInvite then home:CreateLabel("Community: discord.gg/" .. settings.DiscordInvite) end
        return home
    end
    function window:Destroy() gui:Destroy() end
    return window
end
return SentinelUI
