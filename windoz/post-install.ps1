<#
.SYNOPSIS
    Script de post-installation Windows - Configuration et optimisation du système
.DESCRIPTION
    Ce script configure Windows après installation : désactivation de fonctionnalités
    inutiles, installation de logiciels essentiels, optimisation des paramètres
.NOTES
    Auteur: romish17
    Nécessite: Droits administrateur
#>

#Requires -RunAsAdministrator

#region Configuration
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'Continue'

# URLs et chemins
$Config = @{
    WallpaperUrl = 'https://github.com/romish17/custom-install/blob/main/windoz/wallpapers/1.jpeg?raw=true'
    WallpaperPath = 'C:\Users\Public\Pictures\1.jpeg'
    TerminalConfigUrl = 'https://raw.githubusercontent.com/romish17/custom-install/refs/heads/main/windoz/dotfiles/terminal/settings.json'
    TerminalConfigPath = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
}

# Chemins registre
$RegPaths = @{
    NewStartPanel = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
    ClassicStartMenu = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu'
}

# Applications UWP à désinstaller
$UWPAppsToRemove = @(
    'Microsoft.Microsoft3DViewer'
    'Microsoft.MicrosoftOfficeHub'
    'Microsoft.MicrosoftSolitaireCollection'
    'Microsoft.MixedReality.Portal'
    'Microsoft.Office.OneNote'
    'Microsoft.People'
    'Microsoft.Wallet'
    'Microsoft.SkypeApp'
    'microsoft.windowscommunicationsapps'
    'Microsoft.WindowsFeedbackHub'
    'Microsoft.WindowsMaps'
    'Microsoft.WindowsSoundRecorder'
    'Microsoft.ZuneMusic'
    'Microsoft.ZuneVideo'
    'Microsoft.GamingApp'
    'Microsoft.BingNews'
    'Microsoft.BingWeather'
    'Clipchamp.Clipchamp'
    'MicrosoftTeams*'
)

# Logiciels Chocolatey à installer
$ChocoPackages = @(
    'wget', 'git', 'curl', 'vscode', 'spotify'
    'nerd-fonts-FiraCode', 'FiraCode', 'putty.install'
    'vlc', '7zip', 'oh-my-posh', 'veracrypt'
    'protonmail', '1password', 'virtualclonedrive'
    'termius', 'obsidian', 'steam', 'brave'
)
#endregion

#region Fonctions utilitaires
function Write-ProgressStep {
    param(
        [Parameter(Mandatory)]
        [string]$Activity,

        [Parameter(Mandatory)]
        [int]$StepNumber,

        [Parameter(Mandatory)]
        [int]$TotalSteps,

        [string]$Status = "En cours..."
    )

    $PercentComplete = [math]::Round(($StepNumber / $TotalSteps) * 100)
    Write-Progress -Activity $Activity -Status "$Status ($StepNumber/$TotalSteps)" -PercentComplete $PercentComplete
    Write-Host "`n[$StepNumber/$TotalSteps] $Activity" -ForegroundColor Cyan
    Write-Host "$('-' * 80)" -ForegroundColor DarkGray
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Yellow
}

function Write-StepError {
    param([string]$Message)
    Write-Host "[ERREUR] $Message" -ForegroundColor Red
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = 'DWord'
    )

    try {
        if (!(Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -ErrorAction Stop
        return $true
    }
    catch {
        Write-StepError "Impossible de définir $Path\$Name : $_"
        return $false
    }
}
#endregion

#region Étapes de configuration
function Step-SystemInfo {
    Write-Success "Récupération des informations système..."
    $BIOS = Get-CimInstance Win32_BIOS
    Write-Info "Numéro de série: $($BIOS.SerialNumber)"
    Write-Info "Fabricant: $($BIOS.Manufacturer)"
}

function Step-SecuritySettings {
    Write-Success "Configuration de la sécurité et des permissions..."

    # Politique d'exécution
    Set-ExecutionPolicy -Scope 'LocalMachine' -ExecutionPolicy 'RemoteSigned' -Force

    # Désactiver UAC
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'FilterAdministratorToken' 0
    Set-RegistryValue 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' 'EnableLUA' 0
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'ConsentPromptBehaviorAdmin' 0

    Write-Success "UAC désactivé"
}

function Step-NetworkConfiguration {
    Write-Success "Configuration réseau..."

    # Désactivation IPv6
    Write-Info "Désactivation d'IPv6 sur toutes les interfaces..."
    $adapters = Get-NetAdapter
    foreach ($adapter in $adapters) {
        try {
            Disable-NetAdapterBinding -Name $adapter.Name -ComponentID 'ms_tcpip6' -ErrorAction SilentlyContinue
            Write-Info "  IPv6 désactivé sur $($adapter.Name)"
        }
        catch {
            Write-Info "  $($adapter.Name) - IPv6 déjà désactivé"
        }
    }

    # Désactivation IPv6 au niveau global
    Set-RegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents' 0xFFFFFFFF

    # Configuration profil réseau
    Set-NetConnectionProfile -NetworkCategory Private -ErrorAction SilentlyContinue

    Write-Success "Configuration réseau terminée"
}

function Step-RemoteDesktop {
    Write-Success "Configuration du Bureau à distance..."

    Set-RegistryValue 'HKLM:\System\CurrentControlSet\Control\Terminal Server' 'fDenyTSConnections' 0
    Set-RegistryValue 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' 'UserAuthentication' 0

    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue

    Write-Success "RDP activé"
}

function Step-Personalization {
    Write-Success "Personnalisation du système..."

    # Téléchargement du fond d'écran
    try {
        Invoke-WebRequest -Uri $Config.WallpaperUrl -OutFile $Config.WallpaperPath -UseBasicParsing
        Write-Info "Fond d'écran téléchargé"
    }
    catch {
        Write-StepError "Erreur lors du téléchargement du fond d'écran"
    }

    # Application du fond d'écran
    $wallpaperCode = @"
using Microsoft.Win32;
using System.Runtime.InteropServices;
public class Wallpaper {
    public const int SetDesktopWallpaper = 20;
    public const int UpdateIniFile = 0x01;
    public const int SendWinIniChange = 0x02;
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    public static void Set(string path) {
        RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
        key.SetValue(@"WallpaperStyle", "2");
        key.SetValue(@"TileWallpaper", "0");
        key.Close();
        SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
    }
}
"@
    Add-Type -TypeDefinition $wallpaperCode -ErrorAction SilentlyContinue
    [Wallpaper]::Set($Config.WallpaperPath)

    # Écran de verrouillage
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' 'LockScreenImagePath' $Config.WallpaperPath String
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP' 'LockScreenImagePath' $Config.WallpaperPath String
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP' 'LockScreenImageUrl' $Config.WallpaperPath String
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP' 'LockScreenImageStatus' 1

    # Thème sombre
    Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' 0
    Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'SystemUsesLightTheme' 0

    # Icône "Ce PC"
    Set-RegistryValue $RegPaths.NewStartPanel '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' 0
    Set-RegistryValue $RegPaths.ClassicStartMenu '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' 0

    Write-Success "Personnalisation appliquée"
}

function Step-DisableBloatware {
    Write-Success "Désactivation des fonctionnalités indésirables..."

    # Content Delivery Manager
    $cdmSettings = @{
        'SilentInstalledAppsEnabled' = 0
        'SystemPaneSuggestionsEnabled' = 0
        'SoftLandingEnabled' = 0
        'RotatingLockScreenEnabled' = 0
        'RotatingLockScreenOverlayEnabled' = 0
        'SubscribedContent-310093Enabled' = 0
        'SubscribedContent-338387Enabled' = 0
        'SubscribedContent-338393Enabled' = 0
        'SubscribedContent-353694Enabled' = 0
        'ContentDeliveryAllowed' = 0
    }

    foreach ($setting in $cdmSettings.GetEnumerator()) {
        Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' $setting.Key $setting.Value
    }

    # Microsoft Store et Cloud Content
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableStoreSuggestions' 1
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableThirdPartyApps' 1
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost' 'EnablePreloadApps' 0

    # Pilotes automatiques
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' 'SearchOrderConfig' 0

    # Teams Chat
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" /f /v ChatIcon /t REG_DWORD /d 3 2>$null

    Write-Success "Bloatware désactivé"
}

function Step-UITweaks {
    Write-Success "Optimisation de l'interface utilisateur..."

    # Menu Démarrer à gauche
    Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAl' 0
    Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarDa' 0
    Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_Layout' 1

    # Extensions de fichiers visibles
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' 0

    # Menu contextuel classique
    New-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' -Force | Out-Null

    # Désactiver la recherche
    Set-RegistryValue 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1
    Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 0

    # Désactiver Copilot
    Set-RegistryValue 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1

    # TaskbarEndTask
    Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' 'TaskbarEndTask' 1

    # Icônes système
    Set-RegistryValue 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify' 'SystemTrayChevronVisibility' 1
    Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'EnableAutoTray' 1

    # Pavé numérique
    Set-RegistryValue 'Registry::HKU\.DEFAULT\Control Panel\Keyboard' 'InitialKeyboardIndicators' '2' String

    # Edge
    Set-RegistryValue 'HKLM:\Software\Policies\Microsoft\Edge' 'HideFirstRunExperience' 1
    Set-RegistryValue 'HKCU:\Software\Policies\Microsoft\Edge' 'HomepageLocation' 'https://www.google.fr' String

    Write-Success "Interface optimisée"
}

function Step-PrivacySettings {
    Write-Success "Configuration de la confidentialité..."

    # Localisation
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}' 'SensorPermissionState' 0
    Set-RegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration' 'Status' 0

    # Cortana
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Personalization\Settings' 'AcceptedPrivacyPolicy' 0
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' 1
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' 1
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore' 'HarvestContacts' 0
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' 0

    # Feedback
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0
    Disable-ScheduledTask -TaskName 'Microsoft\Windows\Feedback\Siuf\DmClient' -ErrorAction SilentlyContinue | Out-Null
    Disable-ScheduledTask -TaskName 'Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload' -ErrorAction SilentlyContinue | Out-Null

    # Rapports d'erreurs
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' 'Disabled' 1
    Disable-ScheduledTask -TaskName 'Microsoft\Windows\Windows Error Reporting\QueueReporting' -ErrorAction SilentlyContinue | Out-Null

    # Services de diagnostic
    Stop-Service 'DiagTrack' -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    Set-Service 'DiagTrack' -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service 'dmwappushservice' -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    Set-Service 'dmwappushservice' -StartupType Disabled -ErrorAction SilentlyContinue

    # Historique et suggestions
    Set-RegistryValue 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoRecentDocsHistory' 1
    Set-RegistryValue 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'HideRecentlyAddedApps' 1

    # Télémétrie Windows
    Write-Info "Désactivation de la télémétrie Windows..."
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 0
    Set-RegistryValue 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 0

    # Désactiver les tâches planifiées de télémétrie
    $telemetryTasks = @(
        'Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser'
        'Microsoft\Windows\Application Experience\ProgramDataUpdater'
        'Microsoft\Windows\Autochk\Proxy'
        'Microsoft\Windows\Customer Experience Improvement Program\Consolidator'
        'Microsoft\Windows\Customer Experience Improvement Program\UsbCeip'
        'Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector'
    )
    foreach ($task in $telemetryTasks) {
        Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
    }

    # Historique d'activités
    Write-Info "Désactivation de l'historique d'activités..."
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' 0
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'PublishUserActivities' 0
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'UploadUserActivities' 0

    # Synchronisation des paramètres
    Write-Info "Désactivation de la synchronisation..."
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync' 'SyncPolicy' 5
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization' 'Enabled' 0
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings' 'Enabled' 0
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials' 'Enabled' 0

    # Partage Wi-Fi (Wi-Fi Sense)
    Write-Info "Désactivation du partage Wi-Fi..."
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting' 'Value' 0
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots' 'Value' 0

    # Expériences partagées
    Write-Info "Désactivation des expériences partagées..."
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP' 'RomeSdkChannelUserAuthzPolicy' 0
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP' 'CdpSessionUserAuthzPolicy' 0

    # Accès des applications aux informations de compte
    Write-Info "Restriction des permissions des applications..."
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation' 'Value' 'Deny' String
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' 'Value' 'Deny' String
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments' 'Value' 'Deny' String
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall' 'Value' 'Deny' String
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts' 'Value' 'Deny' String

    # Collecte de données d'écriture et de frappe
    Write-Info "Désactivation de la collecte de données d'écriture..."
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Input\TIPC' 'Enabled' 0
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization' 'AllowInputPersonalization' 0
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' 1
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' 1

    # Désactiver les diagnostics et données d'utilisation
    Write-Info "Désactivation des diagnostics complets..."
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack' 'ShowedToastAtLevel' 1
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0

    # Bloquer les hôtes de télémétrie Microsoft (via le fichier hosts)
    Write-Info "Blocage des serveurs de télémétrie..."
    $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
    $telemetryHosts = @(
        '0.0.0.0 vortex.data.microsoft.com'
        '0.0.0.0 vortex-win.data.microsoft.com'
        '0.0.0.0 telecommand.telemetry.microsoft.com'
        '0.0.0.0 telecommand.telemetry.microsoft.com.nsatc.net'
        '0.0.0.0 oca.telemetry.microsoft.com'
        '0.0.0.0 sqm.telemetry.microsoft.com'
        '0.0.0.0 watson.telemetry.microsoft.com'
        '0.0.0.0 redir.metaservices.microsoft.com'
        '0.0.0.0 choice.microsoft.com'
        '0.0.0.0 df.telemetry.microsoft.com'
        '0.0.0.0 reports.wes.df.telemetry.microsoft.com'
        '0.0.0.0 wes.df.telemetry.microsoft.com'
        '0.0.0.0 services.wes.df.telemetry.microsoft.com'
        '0.0.0.0 sqm.df.telemetry.microsoft.com'
        '0.0.0.0 telemetry.microsoft.com'
        '0.0.0.0 watson.ppe.telemetry.microsoft.com'
        '0.0.0.0 telemetry.appex.bing.net'
        '0.0.0.0 telemetry.urs.microsoft.com'
        '0.0.0.0 telemetry.appex.bing.net:443'
        '0.0.0.0 settings-sandbox.data.microsoft.com'
        '0.0.0.0 vortex-sandbox.data.microsoft.com'
        '0.0.0.0 survey.watson.microsoft.com'
        '0.0.0.0 watson.live.com'
        '0.0.0.0 watson.microsoft.com'
        '0.0.0.0 statsfe2.ws.microsoft.com'
        '0.0.0.0 corpext.msitadfs.glbdns2.microsoft.com'
        '0.0.0.0 compatexchange.cloudapp.net'
        '0.0.0.0 cs1.wpc.v0cdn.net'
        '0.0.0.0 a-0001.a-msedge.net'
        '0.0.0.0 statsfe2.update.microsoft.com.akadns.net'
        '0.0.0.0 sls.update.microsoft.com.akadns.net'
        '0.0.0.0 fe2.update.microsoft.com.akadns.net'
        '0.0.0.0 diagnostics.support.microsoft.com'
        '0.0.0.0 corp.sts.microsoft.com'
        '0.0.0.0 statsfe1.ws.microsoft.com'
        '0.0.0.0 pre.footprintpredict.com'
        '0.0.0.0 i1.services.social.microsoft.com'
        '0.0.0.0 i1.services.social.microsoft.com.nsatc.net'
        '0.0.0.0 feedback.windows.com'
        '0.0.0.0 feedback.microsoft-hohm.com'
        '0.0.0.0 feedback.search.microsoft.com'
    )

    try {
        $currentHosts = Get-Content $hostsPath -ErrorAction SilentlyContinue
        $hostsToAdd = $telemetryHosts | Where-Object { $currentHosts -notcontains $_ }
        if ($hostsToAdd) {
            Add-Content -Path $hostsPath -Value "`n# Blocage télémétrie Microsoft - Ajouté par script post-install" -ErrorAction SilentlyContinue
            Add-Content -Path $hostsPath -Value $hostsToAdd -ErrorAction SilentlyContinue
            Write-Info "  $($hostsToAdd.Count) domaines de télémétrie bloqués"
        }
    }
    catch {
        Write-StepError "Impossible de modifier le fichier hosts: $_"
    }

    Write-Success "Confidentialité configurée"
}

function Step-DisableRecall {
    Write-Success "Désactivation de Microsoft Recall..."

    # Désactiver Recall via les stratégies de groupe
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
    Set-RegistryValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1

    # Désactiver les fonctionnalités AI/Recall
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'TurnOffWindowsCopilot' 1
    Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'AllowRecallEnablement' 0

    # Désactiver les captures d'écran automatiques
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DisableScreenshots' 1

    # Désactiver l'indexation AI
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AISearch' 'Enabled' 0 -ErrorAction SilentlyContinue

    # Supprimer le package Recall s'il existe
    Write-Info "Recherche et suppression du package Recall..."
    $recallPackages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like '*Recall*' -or $_.Name -like '*WindowsAI*' }
    foreach ($package in $recallPackages) {
        try {
            Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction SilentlyContinue
            Write-Info "  Package supprimé: $($package.Name)"
        }
        catch {
            Write-Info "  Impossible de supprimer: $($package.Name)"
        }
    }

    # Désactiver les tâches planifiées liées à Recall/AI
    $aiTasks = @(
        'Microsoft\Windows\WindowsAI\*'
        'Microsoft\Windows\AppID\SnapshotImageUpload'
    )
    foreach ($task in $aiTasks) {
        Get-ScheduledTask -TaskPath $task -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
    }

    # Désactiver les services liés à Recall
    $aiServices = @('AIService', 'RecallService')
    foreach ($service in $aiServices) {
        if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
            Stop-Service $service -Force -ErrorAction SilentlyContinue
            Set-Service $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Info "  Service désactivé: $service"
        }
    }

    Write-Success "Microsoft Recall désactivé"
}

function Step-PowerSettings {
    Write-Success "Configuration de l'alimentation..."

    # Extinction écran (60 min)
    powercfg /change monitor-timeout-ac 60
    powercfg /change monitor-timeout-dc 60

    # Jamais de mise en veille
    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0

    # Désactiver hibernation et démarrage rapide
    Set-RegistryValue 'HKLM:\System\CurrentControlSet\Control\Session Manager\Power' 'HibernteEnabled' 0
    Set-RegistryValue 'HKLM:\System\CurrentControlSet\Control\Session Manager\Power' 'HiberbootEnabled' 0
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings' 'ShowHibernateOption' 0

    Write-Success "Alimentation configurée"
}

function Step-SystemFeatures {
    Write-Success "Configuration des fonctionnalités système..."

    # Désactiver autoplay/autorun
    Set-RegistryValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers' 'DisableAutoplay' 1
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' 255

    # Désactiver Remote Assistance
    Set-RegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance' 'fAllowToGetHelp' 0

    # Configuration réseau automatique
    Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private' 'AutoSetup' 0

    Write-Success "Fonctionnalités système configurées"
}

function Step-RemoveUWPApps {
    Write-Success "Suppression des applications UWP indésirables..."

    $removed = 0
    foreach ($app in $UWPAppsToRemove) {
        try {
            Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like $app } |
                Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
            $removed++
            Write-Info "  $app supprimé"
        }
        catch {
            Write-Info "  $app non trouvé ou déjà supprimé"
        }
    }

    Write-Success "$removed applications supprimées"
}

function Step-EnableWSL {
    Write-Success "Activation de WSL2..."

    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null

    Write-Success "WSL2 activé"
}

function Step-InstallChocolatey {
    Write-Success "Installation de Chocolatey..."

    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Success "Chocolatey installé"
    }
    catch {
        Write-StepError "Échec de l'installation de Chocolatey: $_"
    }
}

function Step-InstallSoftware {
    Write-Success "Installation des logiciels via Chocolatey..."

    # Arrêter Windows Update temporairement
    Stop-Service 'wuauserv' -ErrorAction SilentlyContinue

    $installed = 0
    $total = $ChocoPackages.Count

    foreach ($package in $ChocoPackages) {
        $installed++
        $percent = [math]::Round(($installed / $total) * 100)
        Write-Progress -Id 1 -Activity "Installation des logiciels" -Status "$package ($installed/$total)" -PercentComplete $percent

        try {
            choco install $package -y --no-progress --limit-output 2>&1 | Out-Null
            Write-Info "  [OK] $package"
        }
        catch {
            Write-Info "  [ERREUR] $package"
        }
    }

    Write-Progress -Id 1 -Activity "Installation des logiciels" -Completed

    # Redémarrer Windows Update
    Start-Service 'wuauserv' -ErrorAction SilentlyContinue

    Write-Success "$installed/$total logiciels installés"
}

function Step-ConfigureTerminal {
    Write-Success "Configuration de Windows Terminal..."

    try {
        $terminalPath = Split-Path $Config.TerminalConfigPath
        if (!(Test-Path $terminalPath)) {
            New-Item -Path $terminalPath -ItemType Directory -Force | Out-Null
        }

        Invoke-WebRequest -Uri $Config.TerminalConfigUrl -OutFile $Config.TerminalConfigPath -UseBasicParsing
        Write-Success "Terminal configuré"
    }
    catch {
        Write-StepError "Erreur lors de la configuration du terminal: $_"
    }
}

function Step-InstallPowerShellModules {
    Write-Success "Installation des modules PowerShell..."

    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue | Out-Null
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue

    Write-Success "Modules PowerShell installés"
}

function Step-RestartExplorer {
    Write-Success "Redémarrage de l'Explorateur Windows..."

    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer

    Write-Success "Explorateur redémarré"
}

function Step-WindowsUpdate {
    Write-Success "Installation des mises à jour Windows..."
    Write-Info "Cette étape peut prendre plusieurs minutes..."

    try {
        Install-WindowsUpdate -ForceDownload -ForceInstall -AcceptAll -ErrorAction Stop
        Write-Success "Mises à jour installées"
    }
    catch {
        Write-StepError "Erreur lors de l'installation des mises à jour: $_"
    }
}
#endregion

#region Programme principal
function Start-PostInstallation {
    $startTime = Get-Date

    # Bannière
    Clear-Host
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "                   SCRIPT DE POST-INSTALLATION WINDOWS                     " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Auteur: romish17" -ForegroundColor Gray
    Write-Host "  Date: $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor Gray
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""

    # Définition des étapes
    $steps = @(
        @{ Name = 'Informations système'; Function = { Step-SystemInfo } }
        @{ Name = 'Configuration de la sécurité'; Function = { Step-SecuritySettings } }
        @{ Name = 'Configuration réseau'; Function = { Step-NetworkConfiguration } }
        @{ Name = 'Bureau à distance (RDP)'; Function = { Step-RemoteDesktop } }
        @{ Name = 'Personnalisation'; Function = { Step-Personalization } }
        @{ Name = 'Désactivation bloatware'; Function = { Step-DisableBloatware } }
        @{ Name = 'Optimisation interface'; Function = { Step-UITweaks } }
        @{ Name = 'Paramètres de confidentialité'; Function = { Step-PrivacySettings } }
        @{ Name = 'Désactivation Microsoft Recall'; Function = { Step-DisableRecall } }
        @{ Name = 'Paramètres d''alimentation'; Function = { Step-PowerSettings } }
        @{ Name = 'Fonctionnalités système'; Function = { Step-SystemFeatures } }
        @{ Name = 'Suppression applications UWP'; Function = { Step-RemoveUWPApps } }
        @{ Name = 'Activation WSL2'; Function = { Step-EnableWSL } }
        @{ Name = 'Installation modules PowerShell'; Function = { Step-InstallPowerShellModules } }
        @{ Name = 'Installation Chocolatey'; Function = { Step-InstallChocolatey } }
        @{ Name = 'Installation logiciels'; Function = { Step-InstallSoftware } }
        @{ Name = 'Configuration Terminal'; Function = { Step-ConfigureTerminal } }
        @{ Name = 'Redémarrage Explorateur'; Function = { Step-RestartExplorer } }
        @{ Name = 'Mises à jour Windows'; Function = { Step-WindowsUpdate } }
    )

    $totalSteps = $steps.Count
    $currentStep = 0

    # Exécution des étapes
    foreach ($step in $steps) {
        $currentStep++

        try {
            Write-ProgressStep -Activity $step.Name -StepNumber $currentStep -TotalSteps $totalSteps
            & $step.Function
        }
        catch {
            Write-StepError "Erreur lors de l'étape '$($step.Name)': $_"
        }

        Start-Sleep -Milliseconds 500
    }

    # Finalisation
    Write-Progress -Activity "Installation terminée" -Completed

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "                          INSTALLATION TERMINÉE                             " -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Durée totale: $($duration.Hours)h $($duration.Minutes)m $($duration.Seconds)s" -ForegroundColor Cyan
    Write-Host "  Étapes complétées: $totalSteps/$totalSteps" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Un redémarrage est FORTEMENT recommandé pour appliquer toutes les modifications." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""

    # Prompt de redémarrage
    $restart = Read-Host "Voulez-vous redémarrer maintenant? (O/N)"
    if ($restart -eq 'O' -or $restart -eq 'o') {
        Write-Host "Redémarrage dans 10 secondes..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
}

# Lancement du script
Start-PostInstallation
#endregion
