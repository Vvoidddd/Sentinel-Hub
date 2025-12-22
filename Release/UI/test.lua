--============================================================
-- Sentinel Hub Example
--============================================================

-- Load SentinelUI from GitHub
local SentinelUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/main/Release/UI/SentinelUI.lua"
))()

-- Create Window (RightShift to toggle)
local Window = SentinelUI.CreateWindow(Enum.KeyCode.RightShift)

--============================================================
-- MAIN TAB
--============================================================
local MainTab = Window:CreateTab("Main")

MainTab:Label("Sentinel Hub Example UI")

MainTab:Button("Print Hello", function()
    print("Hello from SentinelUI")
end)

MainTab:Toggle("God Mode", false, function(state)
    print("God Mode:", state)
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

MiscTab:Label("Miscellaneous")

MiscTab:Button("Destroy UI", function()
    Window:Destroy()
end)
