# 🎭 Welcome Message Prank Script

A fun PowerShell prank that greets you with random messages using text-to-speech when you log into Windows. Choose from sassy, uplifting, rude, or complete nonsense messages!

## 🎯 Features

- **50+ unique messages** across 4 different categories
- **Random voice selection** from your installed Windows voices
- **Automated scheduled task** creation for logon trigger  
- **Customizable delay** after logon
- **Hidden execution** (no visible PowerShell window)
- **Easy install/uninstall** with single commands
- **Test mode** to try it out without logging out Note that the test mode requires you to have it installed first.

## 📋 Message Categories

| Category | Description | Example |
|----------|-------------|---------|
| **Sassy** | Sarcastic and witty | "Oh look who finally decided to show up to work." |
| **Uplifting** | Positive and motivational | "You're absolutely incredible and today will prove it!" |
| **Rude** | Blunt and insulting | "I've seen rocks with more personality than you." |
| **Nonsense** | Random and absurd | "The purple elephants have declared Tuesday a national banana holiday!" |
| **PowerShell** | Encouraging programming and cmdlet humor | "Get-Command your amazing potential! So many possibilities found." |
| **Random** | Randomly picks from all categories | *Surprise me!* |

## 🚀 Quick Start

### Prerequisites
- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges
- Text-to-Speech voices installed (Pre installed on Windows by default comes with several)

### Installation

1. **Download the script** and save as `Set-LogonGreeting.ps1`

2. **Run PowerShell as Administrator**
   - Right-click PowerShell → "Run as Administrator"

3. **Install the prank**
   ```powershell
   .\Set-LogonGreeting.ps1 -Install
   ```

4. **Log out and back in** to hear your first welcome message!

## 🎮 Usage Examples

### Basic Installation
```powershell
# Install with default settings (Random messages, 10 second delay)
.\Set-LogonGreeting.ps1 -Install
```

### Custom Installation
```powershell
# Install with sassy messages and 30 second delay
.\Set-LogonGreeting.ps1 -Install -MessageType Sassy -DelaySeconds 30

# Install with custom task name
.\Set-LogonGreeting.ps1 -Install -TaskName "MyCustomWelcome"
```

### Testing
```powershell
# Test the prank without logging out
.\Set-LogonGreeting.ps1 -Test

# Test with specific message type
.\Set-LogonGreeting.ps1 -Test -MessageType Nonsense
```

### Uninstallation
```powershell
# Completely remove the prank
.\Set-LogonGreeting.ps1 -Uninstall
```

## ⚙️ Parameters

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `-Install` | Install the prank | - | Switch |
| `-Uninstall` | Remove the prank | - | Switch |
| `-Test` | Test manually | - | Switch |
| `-MessageType` | Type of messages | `Random` | `Sassy`, `Uplifting`, `Rude`, `Nonsense`, `PowerShell`, `Random` |
| `-TaskName` | Scheduled task name | `WelcomeMessagePrank` | Any string |
| `-DelaySeconds` | Delay after logon | `5` | Any integer |

## 📁 What Gets Created

When you install the prank, the script creates:

1. **Scheduled Task**: `WelcomeMessagePrank` (or your custom name)
   - Triggers on user logon
   - Runs hidden PowerShell window
   - Includes configurable delay

2. **Event Log Source**: `WelcomePrank` 
   - For optional logging (debugging purposes)

## 🎵 Voice Selection

The script automatically:
- Detects all installed Windows voices
- Randomly selects a different voice each time
- Falls back gracefully if no voices are available

To see your available voices:
```powershell
Add-Type -AssemblyName System.Speech
$synth = [System.Speech.Synthesis.SpeechSynthesizer]::new()
$synth.GetInstalledVoices() | ForEach-Object { $_.VoiceInfo.Name }
```

## 🔧 Troubleshooting

### Common Issues

**"Script must be run as Administrator"**
- Right-click PowerShell and select "Run as Administrator"

**"Execution Policy" errors**
- The script uses `-ExecutionPolicy Bypass` to avoid policy issues

**No sound/speech**
- Check Windows volume settings
- Test Windows Narrator: `Win+Ctrl+Enter`

**Task not running on logon**
- Check Task Scheduler: `taskschd.msc` → Task Scheduler Library
- Verify task exists and is enabled
- Check task history for error details

### Manual Management

**View the scheduled task:**
```powershell
Get-ScheduledTask -TaskName "WelcomeMessagePrank" | Format-List
```

**Run task manually:**
```powershell
Start-ScheduledTask -TaskName "WelcomeMessagePrank"
```

**Check task history:**
- Open Task Scheduler (`taskschd.msc`)
- Navigate to your task
- View the "History" tab

## 🎨 Customization

### Adding Your Own Messages

Edit the arrays in the main script:
```powershell
$sassyMessages = @(
    "Your custom sassy message here",
    "Another witty remark"
)
```

### Changing Voice Settings

Modify the `Speak` function to:
- Set specific voice: `$speechSynthesizer.SelectVoice("Microsoft Zira Desktop")`
- Adjust rate: `$speechSynthesizer.Rate = 2` (range: -10 to 10)
- Adjust volume: `$speechSynthesizer.Volume = 80` (range: 0 to 100)

## 🛡️ Security Notes

- Script requires Administrator privileges to create scheduled tasks
- Uses `ExecutionPolicy Bypass` for reliable execution
- Adds Windows Event Log source
- No network connectivity required
- No sensitive data stored or transmitted

## 🤝 Contributing

Want to add more messages or features? 

1. Add your messages to the appropriate category arrays
2. Test with different message types
3. Ensure compatibility with various Windows voices
4. Submit your improvements!

## 📜 License

This is a fun prank script for personal use. Use responsibly and considerately in shared environments!

## ⚠️ Disclaimer

This script is for entertainment purposes. Please use responsibly:
- Don't use in professional environments without permission
- Be mindful of others who share your computer
- Some messages contain mild humor that might not be appropriate for all audiences
- Test volume levels before deployment

## 🎉 Have Fun!

Enjoy surprising yourself (and others) with random welcome messages. Remember to uninstall before important presentations! 😄

---

*Made with ❤️ and a sense of humor*