-- Run from the repository root: lua tests/sentinel_ui_test.lua
-- Checks UI behavior with Roblox mocks; rendering still requires Roblox.
local signals, objects, pending = {}, {}, {}
local function signal()
    local s = {connections = {}}
    function s:Connect(callback)
        local c = {Connected = true, callback = callback}
        function c:Disconnect() self.Connected = false end
        table.insert(self.connections, c)
        return c
    end
    function s:Fire(...)
        for _, c in ipairs(self.connections) do if c.Connected then c.callback(...) end end
    end
    table.insert(signals, s)
    return s
end
local methods = {}
function methods:GetPropertyChangedSignal(name)
    self._events[name] = self._events[name] or signal()
    return self._events[name]
end
function methods:FindFirstChild(name)
    for _, object in ipairs(objects) do
        if object.Parent == self and object.Name == name then return object end
    end
end
methods.WaitForChild = methods.FindFirstChild
function methods:Destroy()
    if self._dead then return end
    self.Destroying:Fire()
    for _, object in ipairs(objects) do if object.Parent == self then object:Destroy() end end
    for _, event in pairs(self._events) do
        for _, c in ipairs(event.connections) do c:Disconnect() end
    end
    self.Parent = nil
    self._dead = true
end
Instance = {}
function Instance.new(class)
    local o = {_props = {Visible = true, Scale = 1, ClassName = class}, _events = {}}
    for _, name in ipairs({"Destroying", "Activated", "InputBegan", "InputChanged", "InputEnded"}) do o._events[name] = signal() end
    setmetatable(o, {
        __index = function(t, k) return methods[k] or t._props[k] or t._events[k] end,
        __newindex = function(t, k, v)
            if k:sub(1, 1) == "_" then rawset(t, k, v) else
                assert(not t._dead, "Write after destroy: " .. k)
                t._props[k] = v
            end
        end,
    })
    table.insert(objects, o)
    return o
end
Enum = setmetatable({}, {__index = function(t, kind)
    local values = setmetatable({}, {__index = function(v, key)
        local item = {Name = key}; rawset(v, key, item); return item
    end})
    rawset(t, kind, values); return values
end})
local function vector(x, y)
    return setmetatable({X = x or 0, Y = y or 0}, {__sub = function(a, b) return vector(a.X - b.X, a.Y - b.Y) end})
end
Vector2 = {new = vector}
UDim = {new = function(s, o) return {Scale = s, Offset = o} end}
UDim2 = {new = function(xs, xo, ys, yo) return {X = UDim.new(xs or 0, xo or 0), Y = UDim.new(ys or 0, yo or 0)} end}
UDim2.fromOffset = function(x, y) return UDim2.new(0, x, 0, y) end
UDim2.fromScale = function(x, y) return UDim2.new(x, 0, y, 0) end
Color3 = {new = function(...) return {...} end, fromRGB = function(...) return {...} end}
ColorSequence = {new = function(...) return {...} end}
TweenInfo = {new = function(...) return {...} end}
task = {spawn = function(f) table.insert(pending, f) end, wait = function() end}
local function flush()
    local queue = pending; pending = {}
    for _, f in ipairs(queue) do f() end
end
local player = Instance.new("Player")
player.Name, player.DisplayName, player.UserId = "Tester", "Test Player", 123
local playerGui = Instance.new("PlayerGui")
playerGui.Name, playerGui.Parent = "PlayerGui", player
local input = {InputBegan = signal(), InputChanged = signal(), InputEnded = signal()}
function input:GetFocusedTextBox() return self.focused end
local players = {LocalPlayer = player, requests = 0}
function players:GetUserThumbnailAsync(id, kind, size)
    assert(id == 123 and kind == Enum.ThumbnailType.HeadShot and size == Enum.ThumbnailSize.Size180x180)
    self.requests = self.requests + 1
    if self.onRequest then self.onRequest() end
    if self.fail then error("Thumbnail unavailable") end
    return "avatar-test", true
end
local tweens = {}
function tweens:Create(object, _, properties)
    return {Play = function() for key, value in pairs(properties) do object[key] = value end end}
end
workspace = Instance.new("Workspace")
workspace.CurrentCamera = Instance.new("Camera")
workspace.CurrentCamera.ViewportSize = vector(1920, 1080)
game = {GetService = function(_, name) return ({Players = players, UserInputService = input, TweenService = tweens})[name] end}
local UI = dofile("Release/UI/SentinelUI.lua")
local window = UI.CreateWindow()
local gui = assert(playerGui:FindFirstChild("SentinelUI"))
local main = gui:FindFirstChild("Main")
local header, body = main:FindFirstChild("Header"), main:FindFirstChild("Body")
flush()
assert(header:FindFirstChild("Avatar").Image == "avatar-test")
local first, second = window:CreateTab("Home"), window:CreateTab("Settings")
local count, toggled = 0, nil
first:Label("Hello")
first:Button("Click", function() count = count + 1 end).Activated:Fire()
assert(count == 1)
local toggle = first:Toggle("Switch", false, function(state) toggled = state end)
toggle.Activated:Fire(); assert(toggled == true)
toggle.Activated:Fire(); assert(toggled == false)
local nav = body:FindFirstChild("Navigation")
nav:FindFirstChild("Settings").Activated:Fire()
for _, object in ipairs(objects) do
    if object.ClassName == "ScrollingFrame" and object.Name == "Home" then assert(not object.Visible) end
    if object.ClassName == "ScrollingFrame" and object.Name == "Settings" then assert(object.Visible) end
end
header:FindFirstChild("Collapse").Activated:Fire()
assert(not body.Visible and main.Size.Y.Offset == 72)
header:FindFirstChild("Collapse").Activated:Fire()
assert(body.Visible and main.Size.Y.Offset == 600)
input.InputBegan:Fire({KeyCode = Enum.KeyCode.RightShift}, true); assert(main.Visible)
input.focused = true
input.InputBegan:Fire({KeyCode = Enum.KeyCode.RightShift}, false); assert(main.Visible)
input.focused = nil
input.InputBegan:Fire({KeyCode = Enum.KeyCode.RightShift}, false); assert(not main.Visible)
input.InputBegan:Fire({KeyCode = Enum.KeyCode.RightShift}, false); assert(main.Visible)
local down = {UserInputType = Enum.UserInputType.MouseButton1, Position = vector(100, 100)}
header.InputBegan:Fire(down)
input.InputChanged:Fire({UserInputType = Enum.UserInputType.MouseMovement, Position = vector(140, 125)})
assert(main.Position.X.Offset == 40 and main.Position.Y.Offset == 25)
input.InputEnded:Fire(down)
input.InputChanged:Fire({UserInputType = Enum.UserInputType.MouseMovement, Position = vector(200, 200)})
assert(main.Position.X.Offset == 40)
workspace.CurrentCamera.ViewportSize = vector(640, 480)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Fire()
for _, object in ipairs(objects) do if object.ClassName == "UIScale" then assert(object.Scale > 0 and object.Scale < 1) end end
header:FindFirstChild("Unload").Activated:Fire()
assert(not playerGui:FindFirstChild("SentinelUI"))
for _, s in ipairs(signals) do for _, c in ipairs(s.connections) do assert(not c.Connected, "Listener leaked") end end
players.fail = true
local fallbackWindow = UI.CreateWindow()
local before = players.requests
flush()
assert(players.requests == before + 3)
fallbackWindow:Destroy()
players.fail = false
local lateWindow = UI.CreateWindow()
players.onRequest = function() lateWindow:Destroy() end
flush() -- Must not write to the destroyed avatar after the request returns.
players.onRequest = nil
local old = UI.CreateWindow()
local oldGui = playerGui:FindFirstChild("SentinelUI")
local replacement = UI.CreateWindow()
assert(oldGui._dead)
replacement:Destroy()
flush()
for _, s in ipairs(signals) do for _, c in ipairs(s.connections) do assert(not c.Connected, "Listener leaked after reload") end end
print("PASS: avatar, controls, navigation, collapse, shortcuts, drag, scaling, unload, retry, late response, reload")
