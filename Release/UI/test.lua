-- UI-only smoke test: button, toggle, collapse, RightShift, and Unload.
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/main/Release/UI/SentinelUI.lua"
))()
local window = UI.CreateWindow(Enum.KeyCode.RightShift)
local tab = window:CreateTab("UI Test")
tab:Label("Right Shift: show/hide. X: collapse. Unload: close.")
tab:Button("Test Button", function()
    print("Button works")
end)
tab:Toggle("Test Toggle", false, function(enabled)
    print("Toggle:", enabled)
end)
