# HP OmenMon Game Profiles Manager

🎮 **Automatically adds OmenMon Profiles and optimize your HP Omen laptop for maximum gaming performance**

This intelligent system monitors for running games and instantly applies maximum fan speeds and GPU performance settings. When games close, it automatically restores normal power-saving settings.

## ✨ Key Features

### 🚀 **Automatic Game Detection**
- Monitors running processes for configured games
- Instant activation when games start
- Automatic restoration when games close
- Zero user interaction required

### ❄️ **Smart Fan Management**
- **FanMax=true** for maximum cooling during gaming
- **120-second refresh** to beat HP's 120-second timeout
- **Automatic restoration** to quiet operation when gaming ends
- **Proper working directory** ensures log files stay organized

### ⚡ **GPU Performance Boost**
- Maximum GPU power and performance during gaming
- Automatic return to power-saving mode when idle
- Seamless switching without manual intervention

### 🔄 **Multiple Operation Modes**
- **Silent Mode**: Runs completely in background with logging
- **Verbose Mode**: Shows detailed real-time status and actions
- **Startup Integration**: Auto-start with Windows (optional)

## 📁 File Structure

```
OmenMon/
├── GamePerformanceManagerSilent.bat     # to use with .vbs script
├── GamePerformanceManagerVerbose.bat    # Visible with full output
├── GameConfig.txt                       # Game list and settings
├── StartGameManagerHidden.vbs           # Background operation
├── InstallStartup.bat                   # Install to Windows startup
├── UninstallStartup.bat                 # Remove from Windows startup
├── GamePerformanceManager.log           # Activity log file
└── README.md                            # This file
```

## ⚙️ Configuration

### Game List
Edit `GameConfig.txt` to add/remove games:

```ini
[GAMES]
cyberpunk2077.exe
witcher3.exe
valorant.exe
csgo.exe
dota2.exe
fortnite.exe
your_game.exe
```

### Settings
Customize performance settings:

```ini
[GENERAL]
OMENMON_PATH=OmenMon.exe
CHECK_INTERVAL=5
LOG_FILE=GamePerformanceManager.log

[PERFORMANCE]
GPU_MODE=Maximum
FAN_MODE=Performance
GPU_RESTORE=Minimum
FAN_RESTORE=Default
```

## 🚀 Quick Start

### Method 1: Manual Operation
1. **Silent Background**: Run `StartGameManagerHidden.vbs`
2. **Verbose Monitoring**: Run `GamePerformanceManagerVerbose.bat`
3. Launch your games and enjoy maximum performance!

### Method 2: Automatic Startup
1. Run `InstallStartup.bat` (creates startup entry)
2. Restart Windows - automatic monitoring begins
3. To remove: Run `UninstallStartup.bat`

## 🔧 How It Works

### 🎯 **Game Detection Logic**
```
Every 5 seconds:
├── Check for running games from GameConfig.txt
├── If game found and not already active:
│   ├── Apply gaming profile (fans + GPU)
│   └── Start 120-second refresh timer
├── If gaming active:
│   ├── Every 120 seconds: Refresh fan settings
│   └── Continue monitoring
└── If no games and profile active:
    └── Restore normal settings
```

### ⚡ **Fan Timeout Prevention**
HP Omen laptops automatically reset fan settings after 120 seconds. Our solution:
- **Re-applies FanMax=true every 120 seconds**
- **Beats the 120-second timeout by 10 seconds**
- **Maintains constant cooling throughout gaming sessions**

### 📊 **Performance Profile**
| Mode | Fans | GPU | Power Usage | Noise | Performance |
|------|------|-----|-------------|-------|-------------|
| **Gaming** | 100% Max | Maximum | High | Loud | Maximum |
| **Normal** | Automatic | Minimum | Low | Quiet | Balanced |

## 🎮 Supported Games

**Pre-configured:**
- Cyberpunk 2077
- The Witcher 3
- Valorant
- Counter-Strike
- Dota 2
- Fortnite
- Apex Legends
- GTA 5
- Red Dead Redemption 2
- Minecraft

**Add any game** by editing `GameConfig.txt`!

## 📋 Requirements

- **HP Omen laptop** with OmenMon installed
- **Windows 10/11**
- **OmenMon.exe** accessible in PATH or script directory

## 🛠️ Advanced Features

### 🔄 **Automatic Startup Installation**
The `InstallStartup.bat` script:
1. Auto-detects your script location
2. Creates a VBS launcher in Windows startup
3. Sets proper working directory (prevents log files in startup folder)
4. Launches silently on Windows boot

### 📝 **Logging System**
- All activities logged to `GamePerformanceManager.log`
- Timestamps for every action
- Error reporting and warnings
- Perfect for troubleshooting

### 🎛️ **Verbose Mode Features**
```
>>> GAME DETECTED <<<
===============================
  ACTIVATING GAMING PROFILE
===============================
[STEP 1] Setting fans to maximum speed...
[SUCCESS] Fans set to maximum speed

[STEP 2] Setting fan mode to Performance...
[SUCCESS] Fan mode set to Performance

[REFRESH] Refreshing fan settings (preventing 120s timeout)...
[SUCCESS] Fan maximum setting refreshed
```

## 🚨 Troubleshooting

### **Fans not activating?**
- Check if OmenMon.exe is accessible
- Verify game name in GameConfig.txt matches exact process name
- Run verbose mode to see detailed status

### **Log files in wrong location?**
- Use InstallStartup.bat (sets proper working directory)

### **Games not detected?**
- Check exact process name in Task Manager
- Add full executable name to [GAMES] section
- Ensure no typos in GameConfig.txt

## 📞 Support

**Check the log file** for detailed activity information:
```
[2025-08-07 22:30:15] Gaming mode activated - Game: cyberpunk2077.exe
[2025-08-07 22:30:15] Fans set to maximum speed
[2025-08-07 22:30:15] Fan mode set to Performance
[2025-08-07 22:30:15] GPU set to maximum performance
```

---

## 🎯 **Get Maximum Gaming Performance - Automatically!**

No more manual fan control. No more thermal throttling. Just pure, consistent gaming performance whenever you need it.

**Start gaming at maximum performance in 30 seconds!** 🚀
