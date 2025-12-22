--============================================================
-- Sentinel Hub v4 Test
--============================================================

-- Load the UI module
local SentinelUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/main/Release/UI/SentinelUI.lua"
))()

-- Create the main window (toggle with RightShift)
local Window = SentinelUI.CreateWindow(Enum.KeyCode.RightShift)

--============================================================
-- MAIN TAB
--============================================================
local MainTab = Window:CreateTab("Main")
MainTab:Label("Sentinel Hub v4 Example")

-- Button example
MainTab:Button("Print Hello", function()
    print("Hello from SentinelUI v4!")
end)

-- Toggle example
MainTab:Toggle("God Mode", false, function(state)
    print("God Mode:", state)
end)

-- Slider example
MainTab:Slider(0, 100, 50, function(value)
    print("Slider value:", math.floor(value))
end)

--============================================================
-- PLAYER TAB
--============================================================
local PlayerTab = Window:CreateTab("Player")
PlayerTab:Label("Player Modifiers")

PlayerTab:Toggle("Infinite Jump", false, function(state)
    print("Infinite Jump:", state)
end)

PlayerTab:Button("Reset Character", function()
    local player = game.Players.LocalPlayer
    if player.Character then
        player.Character:BreakJoints()
    end
end)

--============================================================
-- MISC TAB
--============================================================
local MiscTab = Window:CreateTab("Misc")
MiscTab:Label("Miscellaneous Options")

MiscTab:Button("Destroy UI", function()
    Window:Destroy()
end)

-- Optional extra: demonstration sliders in Misc tab
MiscTab:Slider(1, 10, 5, function(val)
    print("Demo Slider value:", val)
end)

MiscTab:Toggle("Enable Feature X", true, function(state)
    print("Feature X Enabled:", state)
end)
