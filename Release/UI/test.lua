-- Load UI module
local SentinelUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/main/Release/UI/SentinelUI.lua"
))()

local Window = SentinelUI.CreateWindow(Enum.KeyCode.RightShift)

-- Main Tab
local MainTab = Window:CreateTab("Main")
MainTab:Label("Sentinel Hub Example")
MainTab:Button("Print Hello", function() print("Hello!") end)
MainTab:Toggle("God Mode", false, function(state) print("God Mode:", state) end)
MainTab:Slider(0, 100, 50, function(val) print("Slider value:", val) end)
