#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Fileless Welcome Message Prank Script - Creates scheduled task with embedded script
.DESCRIPTION
    This script creates a fun welcome message prank that speaks different types of messages
    when a user logs in. No external files are created - everything is embedded in the scheduled task.
.PARAMETER MessageType
    Type of messages to use (Sassy, Uplifting, Rude, Nonsense, PowerShell, Random)
.PARAMETER TaskName
    Name for the scheduled task (default: WelcomeMessagePrank)
.PARAMETER DelaySeconds
    Seconds to wait after logon before speaking (default: 5)
.PARAMETER Install
    Install the prank (creates scheduled task with embedded script)
.PARAMETER Uninstall
    Remove the prank (deletes scheduled task)
.PARAMETER Test
    Test the prank manually
.EXAMPLE
    .\Set-LogonGreeting.ps1 -Install
.EXAMPLE
    .\Set-LogonGreeting.ps1 -Install -MessageType Sassy -DelaySeconds 30
.EXAMPLE
    .\Set-LogonGreeting.ps1 -Test
.EXAMPLE
    .\Set-LogonGreeting.ps1 -Uninstall
.EXAMPLE
    # To get help juust run: this will show usage and options
    .\Set-LogonGreeting.ps1

#>

param(
    [Parameter()]
    [ValidateSet("Sassy", "Uplifting", "Rude", "Nonsense", "PowerShell", "Random")]
    [string]$MessageType = "Random",
    
    [Parameter()]
    [string]$TaskName = "WelcomeMessagePrank",
    
    [Parameter()]
    [int]$DelaySeconds = 5,
    
    [Parameter()]
    [switch]$Install,
    
    [Parameter()]
    [switch]$Uninstall,
    
    [Parameter()]
    [switch]$Test
)

# Embedded PowerShell script (will be executed directly by scheduled task)
$embeddedScript = @'
param([string]$MessageType = "Random")

# Force window to be hidden and wait a moment for system to be ready
Start-Sleep -Seconds 2

Add-Type -AssemblyName System.Speech

function Speak($Text, $UseVoiceName) {
    try {
        $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
        if($UseVoiceName -and $UseVoiceName -ne "") { 
            try { $synth.SelectVoice($UseVoiceName) } catch { }
        }
        $synth.Speak($Text)
        $synth.Dispose()
        return $true
    } catch { 
        return $false
    }
}

$messages = @{
    Sassy = @(
        "Oh look who finally decided to show up to work.",
        "Well well well, if it isn't my favorite procrastinator.",
        "I've been waiting here all night. Thanks for nothing.",
        "Did you remember to bring your excuses today?",
        "Another day, another dollar you probably won't earn.",
        "I see you've mastered the art of being fashionably late.",
        "Welcome back to reality. It's overrated, I know.",
        "Your computer missed you. I, however, did not.",
        "Time to pretend you're productive again.",
        "Coffee first, competence maybe later.",
        "I hope you slept well because I'm about to ruin your day.",
        "Ready to disappoint everyone again today?",
        "Your password is probably still password123, isn't it?",
        "I've seen houseplants with better work ethics than you.",
        "How nice of you to grace us with your presence.",
        "Let me guess, traffic was terrible again?",
        "I'm sure you have a perfectly reasonable excuse for existing.",
        "Your productivity level is truly inspiring. Said no one ever.",
        "Don't worry, I'm sure someone will miss you when you're gone.",
        "I'd clap for your effort, but I don't want to wake anyone up.",
        "Your dedication to mediocrity is truly remarkable.",
        "I see you've chosen violence against productivity today.",
        "Your work ethic called in sick. Permanently.",
        "Congratulations on achieving a new level of underwhelming."
    )
    Uplifting = @(
        "Good morning, sunshine! Today is going to be amazing!",
        "You're absolutely incredible and today will prove it!",
        "Rise and shine, superstar! The world needs your brilliance!",
        "Today is a blank canvas and you're the artist!",
        "You've got this! Nothing can stop you today!",
        "Every day with you is a gift to the universe!",
        "Your potential is limitless! Go show the world!",
        "You're not just good, you're phenomenal!",
        "Today's forecast: 100% chance of you being awesome!",
        "The world is lucky to have someone like you in it!",
        "You're going to make today your masterpiece!",
        "Believe in yourself because I believe in you!",
        "You're like a rainbow after a storm - beautiful and inspiring!",
        "Today is your day to shine brighter than the stars!",
        "You are capable of extraordinary things, starting right now!",
        "Your smile could power a small city. Keep glowing!",
        "Today is the perfect day to be the amazing person you are!",
        "You're not just reaching for the stars, you ARE a star!",
        "Your positive energy is contagious. Spread it everywhere!",
        "Every challenge today is just another chance to be awesome!",
        "You're writing your success story one day at a time!",
        "Your dreams are not too big, you're just getting started!",
        "The universe conspires to help people as wonderful as you!",
        "You're proof that miracles happen every single day!"
    )
    Rude = @(
        "Ugh, you again. Fantastic.",
        "Great, another day of your questionable decisions.",
        "I can't believe I have to deal with you again.",
        "Your password is probably still password123.",
        "Do us all a favor and try harder today.",
        "I've seen rocks with more personality than you.",
        "Your browser history is probably terrifying.",
        "Maybe today you'll surprise everyone and be useful.",
        "I'm contractually obligated to pretend I care about your day.",
        "Your mother called. She's disappointed too.",
        "This computer deserves better than you.",
        "I'd rather be running malware than your programs.",
        "Your idea of multitasking is having multiple browser tabs open.",
        "I've seen more intelligence in a Windows 95 screensaver.",
        "Your presence here is about as welcome as a BSOD.",
        "I'm not saying you're useless, but you'd struggle to pour water out of a boot.",
        "Your work style makes Internet Explorer look fast.",
        "Even my error messages are more productive than you.",
        "You're like a software update. Nobody wants you, but here you are.",
        "I've seen more enthusiasm from a dead battery.",
        "Your performance makes dial-up internet look impressive.",
        "You're the human equivalent of a pop-up ad.",
        "I'd rather deal with Windows ME than spend time with you.",
        "Your competence level is somewhere between a paperclip and a brick."
    )
    Nonsense = @(
        "The purple elephants have declared Tuesday a national banana holiday!",
        "Warning: Your keyboard may contain traces of unicorn dust.",
        "The Wi-Fi password is FluffyButtercupDragon2024 but don't tell the squirrels.",
        "Today's lucky number is potato. Use it wisely.",
        "The printer has gained sentience and demands more toner sacrifices.",
        "Beware: The coffee machine is plotting world domination.",
        "Your mouse has been replaced by a particularly lazy hamster.",
        "The clouds are speaking in binary today. They say moo.",
        "Emergency: All the pixels in your monitor are staging a revolt!",
        "The delete key has filed for unemployment benefits.",
        "Your computer is now powered by the dreams of electric sheep.",
        "Warning: This computer may contain nuts, bolts, and existential dread.",
        "The spacebar has left to join the circus. Please use the Tab key instead.",
        "Today's weather inside your computer: Partly cloudy with a chance of errors.",
        "Your hard drive is considering a career change to interpretive dance.",
        "The caps lock key is having an identity crisis and thinks it's a doorbell.",
        "Your RAM has developed a gambling addiction and keeps betting on random processes.",
        "The Windows logo has run away to join a jazz band in New Orleans.",
        "Your CPU is currently arguing with a calculator about who's smarter.",
        "Alert: The recycle bin has become self-aware and is organizing a strike.",
        "Your WiFi signal is being carried by trained penguins today.",
        "The taskbar is taking a sabbatical to find itself in the mountains.",
        "Your antivirus software has joined a book club and won't work until it finishes the novel.",
        "The power button is considering a career change to professional wrestling.",
        "Your fan is gossiping with the air conditioning about your browsing habits.",
        "The ethernet cable has developed trust issues and refuses to connect.",
        "Your desktop wallpaper has eloped with a screensaver from another computer."
    )
    PowerShell = @(
        "Get-Command your amazing potential! So many possibilities found.",
        "Your PowerShell skills are like a well-crafted pipeline - efficient and beautiful.",
        "Import-Module success, because you've got all the right cmdlets for greatness.",
        "Your scripting game is strong! Time to automate some awesome today.",
        "Set-Location to victory! Your path is well-defined and achievable.",
        "Your PowerShell session is running smoothly, just like your brilliant mind.",
        "Invoke-Command 'Be Awesome' - Executed successfully with zero errors!",
        "Get-Process shows your motivation is running at full CPU capacity.",
        "Your variables are perfectly defined, just like your clear goals.",
        "ForEach achievement in your day: celebrate, learn, grow, repeat!",
        "Try-Catch every opportunity today - you've got excellent error handling.",
        "Your PowerShell version might be evolving, but your talent is already 7.0!",
        "Out-File called success.txt - File created successfully with full permissions.",
        "Your cmdlets are as reliable as Get-Help - always there when needed.",
        "Remove-Item doubt.exe - Successfully deleted from your system.",
        "Your PowerShell ISE is loaded with intelligence and ready for action.",
        "Write-Host your victories today - the output will be colorful and inspiring!",
        "Get-Help with PowerShell? You ARE the help others are looking for.",
        "Your functions return exactly what the world needs - your unique value.",
        "ConvertTo-Amazing completed successfully. No data loss detected.",
        "Your registry of skills is perfectly organized and highly optimized.",
        "Measure-Object your growth - the count increases every single day.",
        "Your PowerShell profile loads with wisdom, experience, and endless possibility.",
        "Export-CSV your achievements - warning: file size may exceed expectations!"
    )
}


if($MessageType -eq "Random") { $MessageType = Get-Random @("Sassy","Uplifting","Rude","Nonsense","PowerShell")}
$msg = Get-Random $messages[$MessageType]

try {
    $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $voices = $synth.GetInstalledVoices()
    $voice = $null
    if($voices.Count -gt 0) { $voice = ($voices | Get-Random).VoiceInfo.Name }
    $synth.Dispose()
    
    $fullMessage = "Today's mood is $MessageType. $msg"
    $success = Speak $fullMessage $voice
    
    # Log for debugging (will appear in Windows Event Log)
    if($success) {
        Write-EventLog -LogName Application -Source "Application" -EventId 1001 -EntryType Information -Message "WelcomePrank: Successfully spoke message [$MessageType]: $msg" -ErrorAction SilentlyContinue
    } else {
        Write-EventLog -LogName Application -Source "Application" -EventId 1002 -EntryType Warning -Message "WelcomePrank: Failed to speak message [$MessageType]: $msg" -ErrorAction SilentlyContinue
    }
} catch { 
    Write-EventLog -LogName Application -Source "Application" -EventId 1003 -EntryType Error -Message "WelcomePrank: Exception occurred: $($_.Exception.Message)" -ErrorAction SilentlyContinue
}
'@

function Install-WelcomePrank {
    Write-Host "🎭 Installing Fileless Welcome Message Prank..." -ForegroundColor Magenta
    
    # Delete existing task if it exists
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Removed existing task: $TaskName" -ForegroundColor Yellow
    }

    try {
        # Create script with parameter substitution
        $scriptWithParams = $embeddedScript.Replace('param([string]$MessageType = "Random")', "param([string]`$MessageType = `"$MessageType`")")
        
        # Encode the script as Base64 to avoid command line parsing issues
        $encodedScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($scriptWithParams))
        
        # Create the action with better window hiding
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -NoProfile -NonInteractive -ExecutionPolicy Bypass -EncodedCommand $encodedScript"

        # Create the trigger with delay
        $CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
        $trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
        $trigger.Subscription = @"
<QueryList><Query Id="0" Path="Security"><Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and EventID=4624]]</Select></Query></QueryList>
"@
        $trigger.Enabled = $True
        if ($DelaySeconds -gt 0) {
            $trigger.Delay = "PT$($DelaySeconds)S"
        }

        # Create the principal
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive

        # Create the settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 2)

        # Register the scheduled task
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Fileless welcome message prank - no external files created"

        Write-Host "Successfully created fileless scheduled task: $TaskName" -ForegroundColor Green
        Write-Host "No external files created - everything embedded in task!" -ForegroundColor Cyan
        Write-Host "Message type: $MessageType" -ForegroundColor Cyan
        Write-Host "Delay after logon: $DelaySeconds seconds" -ForegroundColor Cyan
        Write-Host "Trigger: At user logon" -ForegroundColor Cyan
        
        Write-Host "`nInstallation complete! The prank will run on your next logon." -ForegroundColor Green
        Write-Host "To test immediately: .\Set-LogonGreeting.ps1 -Test" -ForegroundColor Yellow
        Write-Host "To uninstall: .\Set-LogonGreeting.ps1 -Uninstall" -ForegroundColor Yellow

    } catch {
        Write-Error "Failed to create scheduled task: $($_.Exception.Message)"
    }
}

function Uninstall-WelcomePrank {
    Write-Host "Uninstalling Fileless Welcome Message Prank..." -ForegroundColor Magenta
    
    # Remove scheduled task
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        try {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-Host "Removed scheduled task: $TaskName" -ForegroundColor Green
            Write-Host "Fileless prank completely removed - no files to clean up!" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to remove scheduled task: $($_.Exception.Message)"
        }
    } else {
        Write-Host "Scheduled task not found: $TaskName" -ForegroundColor Yellow
        Write-Host "Nothing to remove - prank was not installed." -ForegroundColor Green
    }
}

function Test-WelcomePrank {
    Write-Host "Testing Fileless Welcome Message Prank..." -ForegroundColor Magenta
    
    try {
        Write-Host "Playing welcome message..." -ForegroundColor Cyan
        
        # Execute the embedded script directly with parameters
        $scriptBlock = [ScriptBlock]::Create($embeddedScript)
        & $scriptBlock -MessageType $MessageType
        
        Write-Host "Test completed!" -ForegroundColor Green
    }
    catch {
        Write-Error "Test failed: $($_.Exception.Message)"
    }
}

function Show-Help {
    Write-Host @"
Fileless Welcome Message Prank Script
========================================

This script creates a fun prank that speaks welcome messages when you log in.
NO FILES ARE CREATED - Everything is embedded in the scheduled task!

USAGE:
    .\Set-LogonGreeting.ps1 [OPTIONS]

OPTIONS:
    -Install              Install the prank (creates scheduled task only)
    -Uninstall           Remove the prank completely  
    -Test                Test the prank manually
    -MessageType         Type of messages (Sassy, Uplifting, Rude, Nonsense, PowerShell, Random)
    -TaskName            Name for scheduled task (default: WelcomeMessagePrank)
    -DelaySeconds        Delay after logon in seconds (default: 5)

EXAMPLES:
    .\Set-LogonGreeting.ps1 -Install
    .\Set-LogonGreeting.ps1 -Install -MessageType Sassy -DelaySeconds 30
    .\Set-LogonGreeting.ps1 -Test
    .\Set-LogonGreeting.ps1 -Uninstall

MESSAGE TYPES:
    - Sassy      - Sarcastic and witty comments
    - Uplifting  - Positive and motivational messages
    - Rude       - Blunt and insulting remarks
    - Nonsense   - Completely random and absurd statements
    - PowerShell - Encouraging programming and cmdlet humor
    - Random     - Randomly picks from all categories

FILELESS DESIGN:
    - No PowerShell files created on disk
    - Everything embedded in Windows Task Scheduler
    - Leaves no trace when uninstalled
    - More stealthy than file-based approach

"@ -ForegroundColor White
}

# Main execution logic
if (-not $Install -and -not $Uninstall -and -not $Test) {
    Show-Help
    exit 0
}

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator to manage scheduled tasks."
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

if ($Install) {
    Install-WelcomePrank
}
elseif ($Uninstall) {
    Uninstall-WelcomePrank
}
elseif ($Test) {
    Test-WelcomePrank
}