# Sentinel Hub Loader

**Sentinel Hub** is a powerful loader script for Roblox, designed to seamlessly load game-specific hubs, including the **Universal Hub** and **Slime Slaying Online RPG (SSO) Hub**. The script automatically detects the game you're playing and loads the appropriate hub. More hubs will be added as development continues.

## 🎮 Supported Game
- **Slime Slaying Online RPG** *(Game ID: 15230308693)*
    - The loader will automatically load the **Slime Slaying Online RPG Hub** when you join the game.

## 🛠 How to Use

### 1️⃣ Open Your Script Executor
To use Sentinel Hub, you need a Roblox script executor that supports `loadstring()`. Some popular options include:
- [Krnl](https://krnl.place)
- [Synapse X](https://www.synapse.to)
- [ScriptWare](https://www.scriptware.app)

### 2️⃣ Attach the Executor to Roblox
- Launch Roblox and join a game.
- Attach your script executor to the Roblox client.

### 3️⃣ Copy the Loadstring
Get the latest loadstring from below!

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/refs/heads/main/Release/Loader.lua"))()
```

### 4️⃣ Execute the Loadstring
- Paste the copied script into your executor.
- Execute it.
- The loader will detect the game you're in and load the correct hub:
  - If you're in **Slime Slaying Online RPG**, it will load the **SSO Hub**.
  - For unsupported games, the **Universal Hub** will load.

## 🚀 Future Expansions
As Sentinel Hub grows, more game-specific hubs will be developed, bringing new features and optimizations tailored to different Roblox games.

## ⚠️ Important Notice
- The loader **will not work** in restricted or blacklisted games.
- If you attempt to use it in a restricted game, you will be automatically kicked.

## 💬 Credits
- **Void (Vvoidddd)** – Lead Developer of Sentinel Hub
- **Deeeity** – Developer of the **Mercury UI Library** used for the UI framework

## 🤝 Contributors
- **Void (Vvoidddd)** – Lead Developer and Creator of Sentinel Hub
- **Deeeity** – Contributor to the Mercury UI Library

---

Stay updated for future releases and new game hubs! 🚀

