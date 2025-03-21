# Sentinel Hub Loader

**Sentinel Hub** is a loader script for Roblox that provides an easy way to access and use various hubs, including the **Universal Hub** and the **Slime Slaying Online RPG (SSO) Hub**. The script is designed to automatically load the appropriate hub for your game, and more hubs will be added as the team grows.

## 🎮 Supported Game
- **Slime Slaying Online RPG** (Game ID: 15230308693)
    - This loader will automatically load the **Slime Slaying Online RPG Hub** if you're in the game.

## 🛠 How to Use

1. **Open Your Script Executor**:
   - First, you need to have a Roblox script executor that supports `loadstring()`. Some popular options are [Krnl](https://krnl.place), [Synapse X](https://www.synapse.to), or [ScriptWare](https://www.scriptware.app).
   
2. **Attach to Roblox**:
   - Launch Roblox and enter the game you want to play.
   - Attach your script executor to the Roblox client. The process of attaching varies based on the executor you're using, but it's usually a simple button click.

3. **Copy the Loadstring**:
   - Visit the [Sentinel Hub GitHub page](https://github.com/Vvoidddd/Sentinel-Hub) to get the latest loadstring for the loader.
   - On the GitHub page, and copy the loadstring:

     ```lua
     loadstring(game:HttpGet("https://raw.githubusercontent.com/Vvoidddd/Sentinel-Hub/refs/heads/main/Release/Loader.lua"))()
     ```

4. **Execute the Loadstring**:
   - Paste the copied loadstring into your script executor and execute it.
   - The loader will detect the game you're in and load the appropriate hub:
     - If you're in **Slime Slaying Online RPG**, it will load the **SSO Hub**.
     - For other games, it will load the **Universal Hub**.

## 🧑‍🤝‍🧑 Future Hubs
As the team grows, more game-specific hubs will be created, offering tailored features and functionalities for different Roblox games. Stay tuned for updates!

## ⚠️ Note
Make sure you're not in a restricted game. If you're in a restricted game, the loader will kick you out with a notification.

## 💬 Credits
- **Vvoidddd**: Developer of Sentinel Hub.
- **Luxware UI Library**: The UI framework powering the clean and interactive interface.

---

Enjoy using **Sentinel Hub** and stay tuned for new game hubs as we continue to expand!