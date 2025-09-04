# 🔔 Random Notification Sounds Prank

A subtle but effective PowerShell prank that plays random notification sounds from applications installed on the computer at random intervals, making the victim constantly check for non-existent notifications.

## 🎯 Features

- **Finds notification sounds** from Windows and installed applications
- **Prioritizes app sounds** over standard Windows sounds
- **Randomized intervals** between notifications
- **Scheduled task option** - runs automatically at logon (Requires Admin)
- **Easy install/uninstall** with simple commands (Requires Admin)
- **Test mode** to try without committing to full duration
- **Run mode** to Run without committing to full implementation with schedule task

## 🚀 Quick Start

### Prerequisites
- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges (for scheduled task installation)

### Basic Usage

```powershell
# Run directly to output the help information
.\Start-Notification.ps1

# Run in test mode (to play one random sound)
.\Start-Notification.ps1 -Test

# Run with custom settings
.\Start-Notification.ps1 -Run -MinInterval 10 -MaxInterval 60 -Duration 15
```

### Installation as Scheduled Task

```powershell
# Install as scheduled task (runs at logon)
.\Start-Notification.ps1 -Install

# Uninstall the scheduled task
.\Start-Notification.ps1 -Uninstall
```

### Testing

```powershell
# Test by playing a single notification sound
.\Start-Notification.ps1 -Test
```

## ⚙️ Parameters

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `-MinInterval` | Minimum seconds between notifications | `30` | Any integer |
| `-MaxInterval` | Maximum seconds between notifications | `300` | Any integer |
| `-Duration` | How long the prank runs (minutes) | `30` | Any integer |
| `-NonWindowsProbability` | Chance (%) to use non-Windows sounds | `80` | 0-100 |
| `-TaskName` | Scheduled task name | `RandomNotificationPrank` | Any string |
| `-Install` | Install as scheduled task | - | Switch |
| `-Uninstall` | Remove scheduled task | - | Switch |
| `-Run` | Run the prank interactively | - | Switch |
| `-Test` | Test with a single sound | - | Switch |

## 🔍 How It Works

1. **Sound Discovery**
   - Searches for notification sound files (.wav) in common system and application directories
   - Categorizes sounds as Windows sounds or application sounds
   - Filters by file size and names containing terms like "notification", "alert", etc.

2. **Sound Selection**
   - Prioritizes application sounds over Windows sounds (customizable probability)
   - Randomly selects from available sounds at each interval

3. **Scheduled Task**
   - When installed, creates a scheduled task that runs at user logon
   - Task runs in hidden mode automatically

## 🛡️ When the Prank is Running

- **No visible window** when run in hidden mode
- **Random timing** makes it hard to track the source
- **Familiar notification sounds** create genuine confusion

## 🔧 Troubleshooting

### Common Issues

**"Script must be run as Administrator"**
- Right-click PowerShell and select "Run as Administrator"

**"Execution Policy" errors**
- The script uses `-ExecutionPolicy Bypass` when launching hidden

**No sound playing**
- Check Windows volume settings
- Ensure audio device is working

**Task not running at logon**
- Check Task Scheduler: `taskschd.msc` → Task Scheduler Library
- Verify task exists and is enabled

### Scheduled Task Management

**View the task:**
```powershell
Get-ScheduledTask -TaskName "RandomNotificationPrank" | Format-List
```

**Run the task manually:**
```powershell
Start-ScheduledTask -TaskName "RandomNotificationPrank"
```

## 🎨 Customization

### Changing Sound Preferences

Adjust the probability of non-Windows sounds:
```powershell
.\Start-Notification.ps1 -NonWindowsProbability 50
```

### Changing Search Locations

Edit the `$soundPaths` array in the script to add more search locations:
```powershell
$soundPaths = @(
    "$env:windir\Media",
    "$env:ProgramFiles",
    "${env:ProgramFiles(x86)}",
    "$env:LOCALAPPDATA",
    "$env:APPDATA",
    "C:\YourCustomPath"  # Add custom paths here
)
```

## ⚠️ Disclaimer

This script is for entertainment purposes only. Please use responsibly:
- Don't use in professional environments without permission
- Consider system impacts of scheduled tasks
- Use with consideration for others who share the computer
- Some sound effects might be startling depending on volume levels

## 🎭 Why This Prank Works

This prank exploits the Pavlovian response people have developed to notification sounds. Most users are conditioned to check their devices when they hear these familiar sounds, creating a subtle but effective confusion when the sound has no corresponding notification.

---

*Created with mischief in mind* 😈
