-- Public UI-only preview; no private game scripts are loaded.
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/main/Release/UI/SentinelUI.lua"))()
assert(UI.Version == 3, "The updated UI is not available yet. Try again shortly.")
local window = UI.CreateWindow({Name = "Sentinel Hub | Control Preview", ConfigFile = "Sentinel_UI_Preview.json"})
local home = window:CreateHomeTab()
home:CreateLabel("UI-only preview. No game automation runs here.")
local controls = window:CreateTab("Controls")
local basics = controls:CreateSection("Basics")
basics:CreateButton({Name = "Test notification", Callback = function()
    window:Notification({Title = "Sentinel", Content = "Button works", Duration = 3})
end})
basics:CreateToggle({Name = "Toggle example", Flag = "Toggle", CurrentValue = false, Callback = function(value)
    window:SetStatus("Toggle: " .. tostring(value))
end})
local sliders = window:CreateTab("Sliders")
for _, settings in ipairs({
    {Name = "Integer", Range = {0, 100}, Increment = 1, CurrentValue = 50},
    {Name = "Decimal", Range = {0.01, 1}, Increment = 0.01, CurrentValue = 0.1},
    {Name = "Negative range", Range = {-25, 25}, Increment = 1, CurrentValue = 0},
}) do
    local name = settings.Name
    settings.Flag = name
    settings.Callback = function(value) window:SetStatus(name .. ": " .. tostring(value)) end
    sliders:CreateSlider(settings)
end
local choices = window:CreateTab("Selection")
local dropdown = choices:CreateDropdown({Name = "Single selection", Flag = "Single", Options = {"Head", "Torso", "HumanoidRootPart"}, CurrentOption = "Head"})
choices:CreateButton({Name = "Refresh options", Callback = function()
    dropdown:Set({Options = {"HumanoidRootPart", "Head", "Torso"}, CurrentOption = "HumanoidRootPart"})
end})
choices:CreateDropdown({
    Name = "Multi-selection", Flag = "Multi", Options = {"Carrot", "Strawberry", "Blueberry"},
    CurrentOption = {"Carrot"}, MultipleOptions = true,
    Callback = function(values) window:SetStatus("Selected: " .. table.concat(values, ", ")) end,
})
choices:CreateColorPicker({Name = "RGB color", Flag = "Color", Color = Color3.fromRGB(181, 137, 255), Callback = function(value)
    window:SetStatus(string.format("RGB: %.0f, %.0f, %.0f", value.R * 255, value.G * 255, value.B * 255))
end})
local settings = window:CreateTab("Settings")
settings:CreateParagraph({Title = "Configuration test", Content = "Save your values, change them, then Load to restore. Requires executor file support. Preview settings use Sentinel_UI_Preview.json."})
settings:BuildThemeSection()
settings:CreateDivider()
settings:BuildConfigSection()
settings:CreateButton({Name = "Unload preview", Callback = function() window:Destroy() end})
window:SetActiveTab(controls)
