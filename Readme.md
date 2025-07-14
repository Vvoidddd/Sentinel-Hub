
# Sentinel Hub Loader

**Sentinel Hub** is a universal multi-hub loader for Roblox. It auto-detects the current game and loads the appropriate hub interface. If the game isn’t specifically supported, it falls back to a feature-rich **Universal Hub UI** with a modular, customizable interface.

---

## 🎮 Supported Games

| Game                              | Place ID         | Hub           |
| --------------------------------- | ---------------- | ------------- |
| **Slime Slaying Online RPG**      | `15230308693`    | SSO Hub       |
| **Bubble Gum Simulator INFINITY** | `85896571713843` | BGSI Hub      |
| *(All others)*                    | *Any*            | Universal Hub |

---

## 🚀 How to Use

1. **Use a compatible script executor**:

   * [Krnl](https://krnl.place)
   * [Synapse X](https://www.synapse.to)
   * [ScriptWare](https://www.scriptware.app)

2. **Join a supported game** and attach your executor.

3. **Run the Loader**:

   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/main/Release/Loader.lua"))()


4. **Sentinel Hub auto-detects your game** and loads:

   * **SSO Hub** for Slime Slaying Online RPG
   * **BGSI Hub** for Bubble Gum Simulator INFINITY
   * **Universal Hub** for all other games

---

## 🧰 Universal Hub UI Library

The Universal Hub includes a fully modular Lua UI system built from scratch using Roblox instances (no external dependencies).

📁 **Module Path**:
[`SentinelUI.lua`](https://github.com/Vvoidddd/Sentinel-Hub/blob/main/Release/UI/SentinelUI.lua)

📥 **How to Load in Your Script**:

```lua
local SentinelUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/main/Release/UI/SentinelUI.lua"))()
local UI = SentinelUI.CreateWindow(Enum.KeyCode.RightShift)
```

---

## 📁 How to Create Tabs & Controls

Once you have `UI`, you can define any number of tabs with controls.

### ✅ Create a Tab

```lua
local tab = UI:CreateTab("Main")
```

### 🧩 Add Controls to Tab

```lua
tab:Label("Welcome to Sentinel UI")

tab:Button("Say Hello", function()
    print("Hello from Sentinel!")
end)

tab:Toggle("Enable Feature", false, function(state)
    print("Toggled:", state)
end)

tab:Slider("Volume", 0, 100, 50, function(value)
    print("Volume is now", value)
end)
```

### ❌ Close the UI Programmatically

```lua
UI:Destroy()
```

---

## 🧪 Full Example

```lua
local SentinelUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/main/Release/UI/SentinelUI.lua"))()
local UI = SentinelUI.CreateWindow(Enum.KeyCode.RightShift)

local main = UI:CreateTab("Main")
main:Label("Welcome!")
main:Button("Print Hello", function() print("Hello") end)
main:Toggle("Auto Farm", false, function(state) print("AutoFarm:", state) end)
-- Slider support not implemented in current UI module

local settings = UI:CreateTab("Settings")
settings:Label("Config")
settings:Button("Close UI", function() UI:Destroy() end)
```

---

## 🛡 Notices

* The loader **won’t function in protected/blacklisted games**
* Attempting to use it in restricted environments may result in a kick

---

## 🧠 Credits

* **Void (Vvoidddd)** – Lead Developer of Sentinel Hub and UI System



---

## test.lua 

```lua
local SentinelUI = loadstring(game\:HttpGet("[https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/main/Release/UI/SentinelUI.lua"))(](https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/main/Release/UI/SentinelUI.lua%22%29%29%28))
local UI = SentinelUI.CreateWindow(Enum.KeyCode.RightShift)

local terminal = UI\:CreateTab("Terminal")
terminal\:Label("Welcome to Sentinel UI Terminal!")
terminal\:Button("Print Hello", function()
print("Hello from Sentinel UI!")
end)
terminal\:Toggle("Auto Mode", false, function(state)
print("Auto Mode:", state)
end)

local settings = UI\:CreateTab("Settings")
settings\:Label("Settings Panel")
settings\:Button("Close UI", function()
UI\:Destroy()
end)

