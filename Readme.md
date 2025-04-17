# Sentinel Hub Loader

**Sentinel Hub** is a powerful loader script for Roblox, designed to seamlessly load game‑specific hubs, including the **Universal Hub**, **Slime Slaying Online RPG (SSO) Hub**, and **Bubble Gum Simulator INFINITY Hub**. The script automatically detects the game you’re playing and loads the appropriate hub. More hubs will be added as development continues.

## 🎮 Supported Games
- **Slime Slaying Online RPG** *(Game ID: 15230308693)*  
  The loader will automatically load the **SSO Hub** when you join this game.

- **Bubble Gum Simulator INFINITY** *(Game ID: 85896571713843)*  
  The loader will automatically load the **BGSI Hub** when you join this game.

## 🛠 How to Use

1. **Open Your Script Executor**  
   You need a Roblox executor that supports `loadstring()`, such as:
   - [Krnl](https://krnl.place)
   - [Synapse X](https://www.synapse.to)
   - [ScriptWare](https://www.scriptware.app)

2. **Attach to Roblox**  
   Launch Roblox, join any of the supported games, then attach your executor.

3. **Copy & Execute**  
   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/refs/heads/main/Release/Loader.lua"))()
   ```

4. **Sit Back**  
   Sentinel Hub will auto‑detect your game and load:
   - **SSO Hub** for Slime Slaying Online RPG  
   - **BGSI Hub** for Bubble Gum Simulator INFINITY  
   - **Universal Hub** for any other game

## 🚀 Future Expansions
More game‑specific hubs, new features, and optimizations are in the works—stay tuned!

## ⚠️ Important Notice
- The loader **won’t function** in restricted or blacklisted games.  
- Attempting to use it there may result in a kick or denial.

## 💬 Credits
- **Void (Vvoidddd)** – Lead Developer of Sentinel Hub  
- **Deeeity** – Author of the **Mercury UI Library** used for the interface  
