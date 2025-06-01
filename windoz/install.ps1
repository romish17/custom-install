#----------------------------------------------------------[Declarations]----------------------------------------------------------
# Get serial number in BIOS
$SN = Get-CimInstance Win32_BIOS
$SN = $SN.serialnumber
# Get fab in BIOS
$Fab = Get-CimInstance Win32_BIOS
$Fab = $Fab.Manufacturer
# REG PATH
$NSP = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$CSM = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu"

# Conf term Windows
$TERM_CONF = "https://gitlab.rom-cloud.net/custom/win11/-/raw/main/dotfiles/terminal/settings.json"

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Set-ExecutionPolicy -Scope 'LocalMachine' -ExecutionPolicy 'RemoteSigned' -Force;
# Disable FilterAdministratorToken
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'FilterAdministratorToken' -Type DWord -Value 0

# Disable UAC
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -Type DWord -Value 0
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'ConsentPromptBehaviorAdmin' -Type DWord -Value 0

# Disable IPv6

# Get network adapters and their IPv6 status
$adapters = Get-NetAdapterBinding | Select-Object Name, DisplayName, ComponentID, Enabled

# Display status before disabling IPv6
Write-Host "Before disabling IPv6 where enabled:" -ForegroundColor Magenta
$adapters | ForEach-Object {
    if ($_.ComponentID -match 'ms_tcpip6' -and $_.Enabled -match 'False') {
        Write-Host "$($_.Name) ==> IPv6 Disabled" -ForegroundColor Yellow
    }
    if ($_.ComponentID -match 'ms_tcpip6' -and $_.Enabled -match 'True') {
        Write-Host "$($_.Name) ==> IPv6 Enabled" -ForegroundColor Green
        Disable-NetAdapterBinding -Name $_.Name -ComponentID 'ms_tcpip6'
    }
}

# Display status after disabling IPv6
Write-Host ""  # Add a blank line for readability
Write-Host "After disabling IPv6 where enabled:" -ForegroundColor Magenta
$adapters | ForEach-Object {
    if ($_.ComponentID -match 'ms_tcpip6' -and $_.Enabled -match 'False') {
        Write-Host "$($_.Name) ==> IPv6 Disabled" -ForegroundColor Yellow
    }
    if ($_.ComponentID -match 'ms_tcpip6' -and $_.Enabled -match 'True') {
        Write-Host "$($_.Name) ==> IPv6 Enabled" -ForegroundColor Green
    }
}

# Download wallpaper
$wallpaper_path = 'C:\Users\Public\Pictures\1.jpeg'
Invoke-WebRequest -Uri 'https://gitlab.rom-cloud.net/custom/win11/-/raw/main/wallpapers/1.jpeg' -OutFile $wallpaper_path

# Set wallpaper
$setwallpapersrc = @"
    using Microsoft.Win32;
    using System.Runtime.InteropServices;
    public class wallpaper {
        public const int SetDesktopWallpaper = 20;
        public const int UpdateIniFile = 0x01;
        public const int SendWinIniChange = 0x02;
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
        public static void SetWallpaper(string path) {
            RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
            key.SetValue(@"WallpaperStyle", "2");
            key.SetValue(@"TileWallpaper", "0");
            key.Close();
            SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
        }
    }
"@
Add-Type -TypeDefinition $setwallpapersrc
[wallpaper]::SetWallpaper($wallpaper_path)

# Lock screen
Write-Host "Set lockscreen..."
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -Name 'LockScreenImagePath' -Type String -Value $wallpaper_path
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP' -Name 'LockScreenImagePath' -Type String -Value $wallpaper_path
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP' -Name 'LockScreenImageUrl' -Type String -Value $wallpaper_path
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP' -Name 'LockScreenImageStatus' -Type DWord -Value 1

# Disable ads and bloatware
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SilentInstalledAppsEnabled' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SystemPaneSuggestionsEnabled' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SoftLandingEnabled' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'RotatingLockScreenEnabled' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'RotatingLockScreenOverlayEnabled' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-310093Enabled' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowSyncProviderNotifications' -Type DWord -Value 0

# Reglage extinction de l'ecran
powercfg /change monitor-timeout-ac 60 # Sur alimentation
powercfg /change monitor-timeout-dc 60 # Sur Batterie
# Reglage Veille
powercfg /change standby-timeout-ac 0 # Sur alimentation
powercfg /change standby-timeout-dc 0 # Sur Batterie

# Désactiver les suggestions d'applications dans ContentDeliveryManager
$ContentDeliveryManagerKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
)

$ContentDeliveryManagerValues = @(
    @{ Name = "ContentDeliveryAllowed"; Value = 0 },
    @{ Name = "SubscribedContent-338393Enabled"; Value = 0 },
    @{ Name = "SubscribedContent-353694Enabled"; Value = 0 },
    @{ Name = "SubscribedContent-SubscribedAppsEnabled"; Value = 0 }
)

foreach ($Key in $ContentDeliveryManagerKeys) {
    if (-not (Test-Path $Key)) { New-Item -Path $Key -Force | Out-Null }
    foreach ($Value in $ContentDeliveryManagerValues) {
        New-ItemProperty -Path $Key -Name $Value.Name -Value $Value.Value -PropertyType DWord -Force | Out-Null
    }
}

Write-Host "Suggestions d'applications désactivées dans ContentDeliveryManager."

# Désactiver l'installation automatique des pilotes et logiciels des périphériques
$DriverSearchingKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"
if (-not (Test-Path $DriverSearchingKey)) { New-Item -Path $DriverSearchingKey -Force | Out-Null }
New-ItemProperty -Path $DriverSearchingKey -Name "SearchOrderConfig" -Value 0 -PropertyType DWord -Force | Out-Null

Write-Host "Recherche automatique des pilotes et logiciels désactivée."

# Désactiver les recommandations via le Microsoft Store
$CloudContentKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
if (-not (Test-Path $CloudContentKey)) { New-Item -Path $CloudContentKey -Force | Out-Null }
New-ItemProperty -Path $CloudContentKey -Name "DisableWindowsConsumerFeatures" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $CloudContentKey -Name "DisableStoreSuggestions" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "Recommandations via le Microsoft Store désactivées."

# Désactiver les applications préinstallées lors d'une installation propre ou d'une réinitialisation
$AppHostKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost"
if (-not (Test-Path $AppHostKey)) { New-Item -Path $AppHostKey -Force | Out-Null }
New-ItemProperty -Path $AppHostKey -Name "EnablePreloadApps" -Value 0 -PropertyType DWord -Force | Out-Null

Write-Host "Applications préinstallées désactivées."

# Bloquer les applications tierces (optionnel)
New-ItemProperty -Path $CloudContentKey -Name "DisableThirdPartyApps" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "Applications tierces désactivées."

Write-Host "Toutes les modifications ont été appliquées avec succès !" -ForegroundColor Green


# Désactiver IPv6 sur toutes les interfaces réseau
Get-NetAdapter | ForEach-Object {
    Disable-NetAdapterBinding -Name $_.Name -ComponentID ms_tcpip6
}
# Désactiver IPv6 au niveau global (au niveau du registre)
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "DisabledComponents" -Value 0xFFFFFFFF -PropertyType DWord -Force
Write-Output "IPv6 a été désactivé sur toutes les interfaces réseau et au niveau global."


# Remove Teams chat
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" /f /v ChatIcon /t REG_DWORD /d 3
Get-AppxPackage MicrosoftTeams*|Remove-AppxPackage -AllUsers
Get-AppxProvisionedPackage -online | where-object {$_.PackageName -like '*MicrosoftTeams*'} | Remove-AppxProvisionedPackage -online

# Menu left
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAl' -Type DWord -Value 0
# Hide feed and weather widget
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_Layout' -Type DWord -Value 1
# No Upscale
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'LogPixels' -Type DWord -Value 96
# Dark theme
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Type DWord -Value 0
# Privacy
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoRecentDocsHistory' -Type DWord -Value 1
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'HideRecentlyAddedApps' -Type DWord -Value 1
# Disable searchbox
New-Item -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Force
Set-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name 'DisableSearchBoxSuggestions' -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Type DWord -Value 0
# View all icons in taskbar
Set-ItemProperty -Path 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify' -Name 'SystemTrayChevronVisibility' -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'EnableAutoTray' -Type DWord -Value 1
# Disable Copilot
Set-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -Type DWord -Value 1
# Disable Quick start boot
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Type DWord -Value 0
# Return to classic right click menu
New-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' -Force
# Show file extension
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Type DWord -Value 0
#### Edge ####
Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge' -Name 'HideFirstRunExperience' -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Edge' -Name 'HomepageLocation' -Type String -Value 'https://www.google.fr'
# Icon Ce PC
Set-ItemProperty -Path $NSP -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Type DWord -Value 0
Set-ItemProperty -Path $CSM -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Type DWord -Value 0
# Definition de la cle de registre du verouillage du pave numerique
Set-ItemProperty -Path 'Registry::HKU\.DEFAULT\Control Panel\Keyboard' -Name "InitialKeyboardIndicators" -Value "2"
# TaskbarEndTask
New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' -Force
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' -Name 'TaskbarEndTask' -Type DWord -Value 1

Write-Host "Disabling Location Tracking..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0

Write-Host "Disabling Lock screen spotlight..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0

Write-Host "Enable automatic Maps updates..."
Remove-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -ErrorAction SilentlyContinue

Write-Host "Disabling Feedback..."
If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
	New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null

Write-Host "Disabling Cortana..."
If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings")) {
	New-Item -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization")) {
	New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Force | Out-Null
}

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
	New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0

Write-Host "Enabling Advertising ID..."
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -ErrorAction SilentlyContinue
If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy")) {
	New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 2

Write-Host "Disabling Error reporting..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null


Write-Host "Stopping and disabling Diagnostics Tracking Service..."
Stop-Service "DiagTrack" -WarningAction SilentlyContinue
Set-Service "DiagTrack" -StartupType Disabled

Write-Host "Stopping and disabling WAP Push Service..."
Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
Set-Service "dmwappushservice" -StartupType Disabled

# Conf par défaut du mode de parefeu

Write-Host "Setting current network profile to private..."
Set-NetConnectionProfile -NetworkCategory Private

Write-Host "Setting unknown networks profile to private..."
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Name "Category" -Type DWord -Value 1

Write-Host "Disabling automatic installation of network devices..."
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private")) {
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -Type DWord -Value 0

Write-Host "Disabling Remote Assistance..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0

Write-Host "Disabling Autoplay..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1

Write-Host "Disabling Autorun for all drives..."
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255


Write-Host "Disabling Hibernation..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernteEnabled" -Type Dword -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type Dword -Value 0

## Restart explorer 
taskkill /F /IM explorer.exe;start explorer
## Delete Builtin App

$UWPApps = @(
'Microsoft.Microsoft3DViewer',
'Microsoft.MicrosoftOfficeHub',
'Microsoft.MicrosoftSolitaireCollection',
'Microsoft.MixedReality.Portal',
'Microsoft.Office.OneNote',
'Microsoft.People',
'Microsoft.Wallet',
'Microsoft.SkypeApp',
'microsoft.windowscommunicationsapps',
'Microsoft.WindowsFeedbackHub',
'Microsoft.WindowsMaps',
'Microsoft.WindowsSoundRecorder',
'Microsoft.ZuneMusic',
'Microsoft.ZuneVideo',
'Microsoft.GamingApp',
'Microsoft.BingNews',
'Microsoft.BingWeather',
'Clipchamp.Clipchamp'
)

foreach ($UWPApp in $UWPApps) {
Get-AppxPackage -Name $UWPApp -AllUsers | Remove-AppxPackage
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -eq $UWPApp | Remove-AppxProvisionedPackage -Online
}

# Installation de WSL2 (prerequis pour Docker Desktop)
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Set PSRepository
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
# Installation du module mises a jour
Install-Module PSWindowsUpdate -force

### Choco install
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Disable Windows Update during software installation
net stop wuauserv

# Liste des packages à installer
$packages = @(
    "wget",
    "git",
    "curl",
    "vscode",
    "spotify",
    "nerd-fonts-FiraCode",
    "FiraCode",
    "putty.install",
    "vlc",
    "7zip",
    "oh-my-posh",
    "veracrypt",
    "protonmail",
    "onedrive",
    "1password",
    "tailscale",
    "virtualclonedrive",
    "xpipe",
    "termius",
    "GoogleChrome",
    "obsidian",
    "steam"
)

# Installation des packages
foreach ($package in $packages) {
    try {
        choco install $package -y
    } catch {
        Write-Host "Erreur lors de l'installation de $package"
    }
}

# Start Windows update service
net start wuauserv

# Config Windows Terminal
Invoke-WebRequest -Uri $TERM_CONF -OutFile $env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

# Navigateur par défaut
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name "ProgId" -Value "GoogleChrome"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name "ProgId" -Value "GoogleChrome"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\FileAssociations\.html\UserChoice" -Name "ProgId" -Value "GoogleChrome"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\FileAssociations\.htm\UserChoice" -Name "ProgId" -Value "GoogleChrome"
		

# OneDrive Conf
New-Item -Path "HKLM:\Software\Policies\Microsoft\OneDrive" -Name "EnableODIgnoreListFromGPO" -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\OneDrive\EnableODIgnoreListFromGPO" -Name "1" -Value "*.lnk" -PropertyType String -Force


# Installation des mises a jour + reboot
## Get-Command -Module PSWindowsUpdate
Install-WindowsUpdate -ForceDownload -ForceInstall -AcceptAll
