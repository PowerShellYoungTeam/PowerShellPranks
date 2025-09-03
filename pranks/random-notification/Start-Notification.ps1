<#
.SYNOPSIS
    Plays random notification sounds from installed applications at random intervals.

.DESCRIPTION
    This PowerShell prank script finds applications on the computer, 
    locates notification sound files, and plays a random one at random intervals.
    Can be installed as a scheduled task or run directly.

.PARAMETER MinInterval
    Minimum interval in seconds between notifications.
    Default: 30

.PARAMETER MaxInterval
    Maximum interval in seconds between notifications.
    Default: 300 (5 minutes)

.PARAMETER Duration
    How long the prank should run in minutes before stopping.
    Default: 30

.PARAMETER NonWindowsProbability
    Probability (percentage 0-100) of using non-Windows sounds.
    Default: 80

.PARAMETER TaskName
    Name for the scheduled task (when using -Install).
    Default: RandomNotificationPrank

.PARAMETER Install
    Install the prank as a scheduled task to run at startup.

.PARAMETER Uninstall
    Remove the scheduled task created by the -Install parameter.

.PARAMETER Test
    Test the prank by playing a single random sound.

.PARAMETER Run
    Run the prank by playing a random sounds.

.EXAMPLE
    .\Start-Notification.ps1
    # Plays random notification sounds with default settings

.EXAMPLE
    .\Start-Notification.ps1 -MinInterval 10 -MaxInterval 60 -Duration 15
    # Plays random notification sounds every 10-60 seconds for 15 minutes

.EXAMPLE
    .\Start-Notification.ps1 -Install
    # Installs the prank as a scheduled task that runs at startup

.EXAMPLE
    .\Start-Notification.ps1 -Test
    # Tests the prank by playing a single random notification sound

.EXAMPLE
    .\Start-Notification.ps1 -Run
    # Runs the prank by playing random notification sounds

.EXAMPLE
    .\Start-Notification.ps1 -Uninstall
    # Uninstalls the scheduled task created by -Install
#>

param (
    [Parameter()]
    [int]$MinInterval = 30,
    
    [Parameter()]
    [int]$MaxInterval = 300,
    
    [Parameter()]
    [int]$Duration = 30,
    
    [Parameter()]
    [int]$NonWindowsProbability = 80,
    
    [Parameter()]
    [string]$TaskName = "RandomNotificationPrank",
    
    [Parameter()]
    [switch]$Install,
    
    [Parameter()]
    [switch]$Uninstall,
        
    [Parameter()]
    [switch]$Test,
        
    [Parameter()]
    [switch]$Run
)

function Find-SoundFiles {
    [CmdletBinding()]
    param()
    
    # Create separate arrays for different sound types
    $windowsSounds = @()
    $applicationSounds = @()
    
    # Common locations for notification sounds
    $soundPaths = @(
        # Windows system sounds
        "$env:windir\Media",
        
        # Program Files directories
        "$env:ProgramFiles",
        "${env:ProgramFiles(x86)}",
        
        # AppData locations where apps might store notification sounds
        "$env:LOCALAPPDATA",
        "$env:APPDATA"
    )
    
    Write-Host "Searching for notification sounds..." -ForegroundColor Cyan
    
    foreach ($path in $soundPaths) {
        if (Test-Path $path) {
            # Find WAV and MP3 files that might be notification sounds
            # Limiting depth and using filters to avoid excessive searching
            try {
                $newFiles = Get-ChildItem -Path $path -Include *.wav -File -Recurse -Depth 4 -ErrorAction SilentlyContinue |
                    Where-Object { 
                        # Filter for likely notification sound files by size and path
                        $_.Length -lt 2MB -and 
                        ($_.FullName -match 'notification|alert|sound|media|audio' -or
                         $_.Name -match 'notification|alert|ding|chime|beep|message|new')
                    }
                
                # Categorize sounds based on their location
                foreach ($file in $newFiles) {
                    if ($file.FullName -like "$env:windir\Media*") {
                        $windowsSounds += $file
                    } else {
                        $applicationSounds += $file
                    }
                }
                
                Write-Host "Found $($newFiles.Count) potential sound files in $path" -ForegroundColor DarkGray
            }
            catch {
                # Silently continue if access is denied to some folders
                continue
            }
        }
    }
    
    # Create a result object with categorized sound files
    $result = [PSCustomObject]@{
        WindowsSounds = $windowsSounds
        ApplicationSounds = $applicationSounds
        AllSounds = $windowsSounds + $applicationSounds
    }
    
    Write-Host "Found $($applicationSounds.Count) application sounds and $($windowsSounds.Count) Windows system sounds" -ForegroundColor Cyan
    
    return $result
}

function Start-RandomSound {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$SoundCollection,
        
        [Parameter()]
        [int]$NonWindowsProbability = 75
    )
    
    # Check if we have any sounds at all
    if ($SoundCollection.AllSounds.Count -eq 0) {
        Write-Warning "No sound files found."
        return
    }
    
    $randomSound = $null
    
    # If we have application sounds, prioritize them based on probability
    if ($SoundCollection.ApplicationSounds.Count -gt 0) {
        # Use probability to decide whether to use application sound or any sound
        $useApplicationSound = (Get-Random -Minimum 1 -Maximum 101) -le $NonWindowsProbability
        
        if ($useApplicationSound) {
            $randomSound = $SoundCollection.ApplicationSounds | Get-Random
            Write-Host "Playing application sound: $($randomSound.Name)" -ForegroundColor Green
        }
    }
    
    # If we didn't select an application sound (or none available), use any sound
    if ($null -eq $randomSound) {
        $randomSound = $SoundCollection.AllSounds | Get-Random
        
        # Indicate if this is a Windows sound
        if ($randomSound.FullName -like "$env:windir\Media*") {
            Write-Host "Playing Windows sound: $($randomSound.Name)" -ForegroundColor DarkGreen
        } else {
            Write-Host "Playing sound: $($randomSound.Name)" -ForegroundColor Green
        }
    }
    
    try {
        $player = New-Object System.Media.SoundPlayer
        $player.SoundLocation = $randomSound.FullName
        $player.playsync()
        
        # Wait for the sound to complete
        Start-Sleep -Milliseconds 500
        while ($player.playState -eq 3) {
            Start-Sleep -Milliseconds 100
        }
        
        # Release the COM object
        $player.Stop()
        Remove-Variable player
    }
    catch {
        Write-Warning "Failed to play sound: $($randomSound.FullName)"
        Write-Warning $_.Exception.Message
    }
}

# Function to install the prank as a scheduled task
function Install-NotificationPrank {
    Write-Host "🔔 Installing Random Notification Prank..." -ForegroundColor Magenta
    
    # Check if task already exists
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "Task '$TaskName' already exists. Removing old task..." -ForegroundColor Yellow
        Uninstall-NotificationPrank
    }

    try {
        # Ensure we have a full, absolute path to the script
        $currentScriptPath = $PSCommandPath
        if ([string]::IsNullOrEmpty($currentScriptPath)) {
            $currentScriptPath = $MyInvocation.MyCommand.Path
        }
        
        # Convert to absolute path if it's not already
        $scriptPath = $null
        if ([System.IO.Path]::IsPathRooted($currentScriptPath)) {
            $scriptPath = $currentScriptPath
        } else {
            $scriptPath = [System.IO.Path]::GetFullPath((Join-Path -Path (Get-Location).Path -ChildPath $currentScriptPath))
        }
        
        # Final fallback - use the current location and hardcoded filename
        if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
            $scriptPath = [System.IO.Path]::GetFullPath((Join-Path -Path (Get-Location).Path -ChildPath "Start-Notification.ps1"))
        }
        
        Write-Host "Using script path: $scriptPath" -ForegroundColor Cyan
        $actionArgs = "--headless powershell.exe -WindowStyle Hidden -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$scriptPath`" -Run -Duration $Duration -MinInterval $MinInterval -MaxInterval $MaxInterval -NonWindowsProbability $NonWindowsProbability"
        $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument $actionArgs
        
        # Create trigger for system startup
        $trigger = New-ScheduledTaskTrigger -AtLogon
        
        # Create principal (run as current user)
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
        
        # Create settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes $Duration)
        
        # Register the scheduled task
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Random notification sounds prank - plays random notification sounds at intervals"
        
        Write-Host "Successfully installed scheduled task: $TaskName" -ForegroundColor Green
        Write-Host "The prank will automatically run at next logon." -ForegroundColor Green
        Write-Host "Duration: $Duration minutes" -ForegroundColor Cyan
        Write-Host "Interval: $MinInterval to $MaxInterval seconds" -ForegroundColor Cyan
        Write-Host "Non-Windows sound probability: $NonWindowsProbability%" -ForegroundColor Cyan
        
        Write-Host "`nTo test now: .\Start-Notification.ps1 -Test" -ForegroundColor Yellow
        Write-Host "To uninstall: .\Start-Notification.ps1 -Uninstall" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Failed to install scheduled task: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to uninstall the prank
function Uninstall-NotificationPrank {
    Write-Host "Uninstalling Random Notification Prank..." -ForegroundColor Magenta
    
    # Remove scheduled task if it exists
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        try {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-Host "Successfully removed scheduled task: $TaskName" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to remove scheduled task: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "No scheduled task named '$TaskName' was found." -ForegroundColor Yellow
    }
}

# Function to test the prank by playing a single sound
function Test-NotificationPrank {
    Write-Host "Testing Random Notification Prank..." -ForegroundColor Magenta
    
    try {
        # Find sound files
        $soundCollection = Find-SoundFiles
        
        if ($soundCollection.AllSounds.Count -eq 0) {
            Write-Host "No sound files found. Test failed." -ForegroundColor Red
            return
        }
        
        Write-Host "Found $($soundCollection.AllSounds.Count) sound files ($($soundCollection.ApplicationSounds.Count) application sounds, $($soundCollection.WindowsSounds.Count) Windows sounds)" -ForegroundColor Green
        
        # Play a single random sound
        Start-RandomSound -SoundCollection $soundCollection -NonWindowsProbability $NonWindowsProbability
        
        Write-Host "Test completed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to show help
function Show-NotificationPrankHelp {
    Write-Host @"
Random Notification Prank Script
================================

This script plays random notification sounds from various applications at
random intervals, making people check their devices for non-existent notifications.

USAGE:
    .\Start-Notification.ps1 [OPTIONS]

OPTIONS:
    -Install              Install the prank as a scheduled task to run at startup (Requires Admin)
    -Uninstall            Remove the scheduled task created by -Install (Requires Admin)
    -Test                 Test by playing a single random sound
    -MinInterval          Minimum seconds between sounds (default: 30)
    -MaxInterval          Maximum seconds between sounds (default: 300)
    -Duration             How long the prank runs in minutes (default: 30)
    -NonWindowsProbability Chance (%) to play non-Windows sounds (default: 80)
    -TaskName             Custom name for scheduled task (default: RandomNotificationPrank)

EXAMPLES:
    .\Start-Notification.ps1 -Install
    .\Start-Notification.ps1 -Install -MinInterval 10 -MaxInterval 60 -Duration 15
    .\Start-Notification.ps1 -Test
    .\Start-Notification.ps1 -Uninstall

"@ -ForegroundColor White
}

# Check if running as administrator when needed
if (($Install -or $Uninstall) -and -NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Administrator privileges are required to install or uninstall the scheduled task."
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Main execution logic based on parameters
if ($Install) {
    Install-NotificationPrank
    exit 0
}
elseif ($Uninstall) {
    Uninstall-NotificationPrank
    exit 0
}
elseif ($Test) {
    Test-NotificationPrank
    exit 0
} 
elseif ($Run) {
    # Start the prank
    $soundCollection = Find-SoundFiles
    while ($true) {
        Start-RandomSound -SoundCollection $soundCollection
        $sleep = Get-Random -Minimum $MinInterval -Maximum $MaxInterval
        write-output "Sleeping for $sleep seconds..."
        Start-Sleep -Seconds $sleep
    }
    exit 0
}
elseif (($MinInterval -eq 30) -and ($MaxInterval -eq 300) -and ($Duration -eq 30)) {
    # If no specific parameters given, show help
    Show-NotificationPrankHelp
    exit 0
}
