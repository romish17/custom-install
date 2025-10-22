<#
.SYNOPSIS
    Script d'installation d'applications et de configuration Windows avec interface graphique
.DESCRIPTION
    Interface graphique permettant :
    - Installation d'applications via Chocolatey
    - Tweaks Windows (performance, vie privée)
    - Customisation (fond d'écran, thème)
.NOTES
    Auteur: Infrastructure Survival Kit
    Date: 2025-10-21
    Nécessite: Exécution en tant qu'Administrateur
#>

#Requires -RunAsAdministrator

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationCore

# Définir le type Wallpaper au début du script
$WallpaperType = @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

if (-not ([System.Management.Automation.PSTypeName]'Wallpaper').Type) {
    Add-Type -TypeDefinition $WallpaperType
}

# XAML de l'interface
[xml]$XAML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Windows Setup Tool" Height="700" Width="900"
    WindowStartupLocation="CenterScreen" ResizeMode="CanResize">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="FontSize" Value="12"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="Margin" Value="5,3"/>
            <Setter Property="FontSize" Value="11"/>
        </Style>
        <Style TargetType="GroupBox">
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="10"/>
        </Style>
    </Window.Resources>

    <Grid Margin="10">
        <TabControl Name="MainTabControl">

            <!-- ONGLET APPLICATIONS -->
            <TabItem Header="Applications" Name="tab_Applications">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="150"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                        <StackPanel Name="pnl_AppsList">
                            <GroupBox Header="Navigateurs Web">
                                <StackPanel>
                                    <CheckBox Name="chk_GoogleChrome" Content="Google Chrome"/>
                                    <CheckBox Name="chk_Firefox" Content="Mozilla Firefox"/>
                                    <CheckBox Name="chk_Brave" Content="Brave Browser"/>
                                    <CheckBox Name="chk_Edge" Content="Microsoft Edge"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Developpement">
                                <StackPanel>
                                    <CheckBox Name="chk_VSCode" Content="Visual Studio Code"/>
                                    <CheckBox Name="chk_Git" Content="Git"/>
                                    <CheckBox Name="chk_Python" Content="Python 3"/>
                                    <CheckBox Name="chk_NodeJS" Content="Node.js"/>
                                    <CheckBox Name="chk_Docker" Content="Docker Desktop"/>
                                    <CheckBox Name="chk_Postman" Content="Postman"/>
                                    <CheckBox Name="chk_NotePadPP" Content="Notepad++"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Communication">
                                <StackPanel>
                                    <CheckBox Name="chk_Slack" Content="Slack"/>
                                    <CheckBox Name="chk_Discord" Content="Discord"/>
                                    <CheckBox Name="chk_Teams" Content="Microsoft Teams"/>
                                    <CheckBox Name="chk_Zoom" Content="Zoom"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Multimedia">
                                <StackPanel>
                                    <CheckBox Name="chk_VLC" Content="VLC Media Player"/>
                                    <CheckBox Name="chk_Spotify" Content="Spotify"/>
                                    <CheckBox Name="chk_OBS" Content="OBS Studio"/>
                                    <CheckBox Name="chk_Audacity" Content="Audacity"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Utilitaires">
                                <StackPanel>
                                    <CheckBox Name="chk_7zip" Content="7-Zip"/>
                                    <CheckBox Name="chk_WinRAR" Content="WinRAR"/>
                                    <CheckBox Name="chk_Everything" Content="Everything (Recherche de fichiers)"/>
                                    <CheckBox Name="chk_TreeSize" Content="TreeSize Free"/>
                                    <CheckBox Name="chk_PowerToys" Content="Microsoft PowerToys"/>
                                    <CheckBox Name="chk_Greenshot" Content="Greenshot (Capture d ecran)"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Securite">
                                <StackPanel>
                                    <CheckBox Name="chk_Bitwarden" Content="Bitwarden (Gestionnaire de mots de passe)"/>
                                    <CheckBox Name="chk_KeePass" Content="KeePass"/>
                                    <CheckBox Name="chk_Malwarebytes" Content="Malwarebytes"/>
                                </StackPanel>
                            </GroupBox>
                        </StackPanel>
                    </ScrollViewer>

                    <GroupBox Grid.Row="1" Header="Journal d installation">
                        <TextBox Name="txt_AppLog" IsReadOnly="True" VerticalScrollBarVisibility="Auto"
                                 FontFamily="Consolas" Background="#1E1E1E" Foreground="#00FF00"/>
                    </GroupBox>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center">
                        <Button Name="btn_SelectAllApps" Content="Tout selectionner" Width="150"/>
                        <Button Name="btn_DeselectAllApps" Content="Tout deselectionner" Width="150"/>
                        <Button Name="btn_InstallApps" Content="Installer les applications" Width="200"
                                Background="#0078D4" Foreground="White" FontWeight="Bold"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <!-- ONGLET TWEAKS WINDOWS -->
            <TabItem Header="Tweaks Windows" Name="tab_Tweaks">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="150"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                        <StackPanel Name="pnl_TweaksList">
                            <GroupBox Header="Performance">
                                <StackPanel>
                                    <CheckBox Name="chk_DisableAnimations" Content="Desactiver les animations Windows"/>
                                    <CheckBox Name="chk_DisableTransparency" Content="Desactiver la transparence"/>
                                    <CheckBox Name="chk_EnableUltimatePerf" Content="Activer le mode Performance Ultime"/>
                                    <CheckBox Name="chk_DisableHibernation" Content="Desactiver l hibernation"/>
                                    <CheckBox Name="chk_DisableSuperfetch" Content="Desactiver Superfetch"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Vie Privee">
                                <StackPanel>
                                    <CheckBox Name="chk_DisableTelemetry" Content="Desactiver la telemetrie Windows"/>
                                    <CheckBox Name="chk_DisableCortana" Content="Desactiver Cortana"/>
                                    <CheckBox Name="chk_DisableLocationTracking" Content="Desactiver la localisation"/>
                                    <CheckBox Name="chk_DisableAdvertisingID" Content="Desactiver l ID de publicite"/>
                                    <CheckBox Name="chk_DisableActivityHistory" Content="Desactiver l historique d activite"/>
                                    <CheckBox Name="chk_DisableWebSearch" Content="Desactiver la recherche web dans le menu Demarrer"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Interface Utilisateur">
                                <StackPanel>
                                    <CheckBox Name="chk_ShowFileExtensions" Content="Afficher les extensions de fichiers"/>
                                    <CheckBox Name="chk_ShowHiddenFiles" Content="Afficher les fichiers caches"/>
                                    <CheckBox Name="chk_DisableShakeToMinimize" Content="Desactiver Secouer pour minimiser"/>
                                    <CheckBox Name="chk_TaskbarSmallIcons" Content="Petites icones de la barre des taches"/>
                                </StackPanel>
                            </GroupBox>
                        </StackPanel>
                    </ScrollViewer>

                    <GroupBox Grid.Row="1" Header="Journal des modifications">
                        <TextBox Name="txt_TweakLog" IsReadOnly="True" VerticalScrollBarVisibility="Auto"
                                 FontFamily="Consolas" Background="#1E1E1E" Foreground="#00FF00"/>
                    </GroupBox>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center">
                        <Button Name="btn_SelectAllTweaks" Content="Tout selectionner" Width="150"/>
                        <Button Name="btn_DeselectAllTweaks" Content="Tout deselectionner" Width="150"/>
                        <Button Name="btn_ApplyTweaks" Content="Appliquer les tweaks" Width="200"
                                Background="#0078D4" Foreground="White" FontWeight="Bold"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <!-- ONGLET CUSTOMISATION -->
            <TabItem Header="Customisation" Name="tab_Custom">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="150"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <GroupBox Header="Fond d ecran">
                                <StackPanel>
                                    <Label Content="Selectionner un fond d ecran :"/>
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <TextBox Name="txt_WallpaperPath" Grid.Column="0" Margin="5"
                                                 IsReadOnly="True" VerticalContentAlignment="Center"/>
                                        <Button Name="btn_BrowseWallpaper" Grid.Column="1" Content="Parcourir..." Width="100"/>
                                    </Grid>
                                    <StackPanel Orientation="Horizontal" Margin="5">
                                        <Label Content="Style :"/>
                                        <ComboBox Name="cmb_WallpaperStyle" Width="150" SelectedIndex="0">
                                            <ComboBoxItem Content="Remplir"/>
                                            <ComboBoxItem Content="Ajuster"/>
                                            <ComboBoxItem Content="Etirer"/>
                                            <ComboBoxItem Content="Mosaique"/>
                                            <ComboBoxItem Content="Centrer"/>
                                        </ComboBox>
                                    </StackPanel>
                                    <Button Name="btn_SetWallpaper" Content="Appliquer le fond d ecran" Width="200"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Theme">
                                <StackPanel>
                                    <RadioButton Name="rb_LightTheme" Content="Theme clair" GroupName="Theme" Margin="5"/>
                                    <RadioButton Name="rb_DarkTheme" Content="Theme sombre" GroupName="Theme" Margin="5" IsChecked="True"/>
                                    <Button Name="btn_ApplyTheme" Content="Appliquer le theme" Width="200"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Couleur d accentuation">
                                <StackPanel>
                                    <Label Content="Selectionner une couleur d accentuation :"/>
                                    <ComboBox Name="cmb_AccentColor" Width="200" SelectedIndex="0">
                                        <ComboBoxItem Content="Bleu (par defaut)"/>
                                        <ComboBoxItem Content="Rouge"/>
                                        <ComboBoxItem Content="Vert"/>
                                        <ComboBoxItem Content="Violet"/>
                                        <ComboBoxItem Content="Orange"/>
                                        <ComboBoxItem Content="Rose"/>
                                    </ComboBox>
                                    <CheckBox Name="chk_ShowAccentOnStartTaskbar" Content="Afficher la couleur sur Demarrer et la barre des taches" Margin="5"/>
                                    <Button Name="btn_ApplyAccentColor" Content="Appliquer la couleur" Width="200"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Personnalisation de l explorateur">
                                <StackPanel>
                                    <CheckBox Name="chk_QuickAccessOff" Content="Desactiver l acces rapide"/>
                                    <CheckBox Name="chk_ThisPCDefault" Content="Ouvrir l explorateur sur Ce PC par defaut"/>
                                    <CheckBox Name="chk_RemoveOneDrive" Content="Masquer OneDrive de l explorateur"/>
                                    <Button Name="btn_ApplyExplorerCustom" Content="Appliquer les personnalisations" Width="250"/>
                                </StackPanel>
                            </GroupBox>
                        </StackPanel>
                    </ScrollViewer>

                    <GroupBox Grid.Row="1" Header="Journal de customisation">
                        <TextBox Name="txt_CustomLog" IsReadOnly="True" VerticalScrollBarVisibility="Auto"
                                 FontFamily="Consolas" Background="#1E1E1E" Foreground="#00FF00"/>
                    </GroupBox>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center">
                        <Button Name="btn_ResetCustom" Content="Restaurer les parametres par defaut" Width="250"/>
                    </StackPanel>
                </Grid>
            </TabItem>

        </TabControl>
    </Grid>
</Window>
"@

# Charger XAML
$reader = (New-Object System.Xml.XmlNodeReader $XAML)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Fonction pour récupérer tous les éléments nommés
function Get-XamlObject {
    param($Name)
    try {
        return $Window.FindName($Name)
    }
    catch {
        return $null
    }
}

# Récupérer les éléments de l'interface
$pnl_AppsList = Get-XamlObject -Name "pnl_AppsList"
$pnl_TweaksList = Get-XamlObject -Name "pnl_TweaksList"
$txt_AppLog = Get-XamlObject -Name "txt_AppLog"
$txt_TweakLog = Get-XamlObject -Name "txt_TweakLog"
$txt_CustomLog = Get-XamlObject -Name "txt_CustomLog"
$btn_SelectAllApps = Get-XamlObject -Name "btn_SelectAllApps"
$btn_DeselectAllApps = Get-XamlObject -Name "btn_DeselectAllApps"
$btn_InstallApps = Get-XamlObject -Name "btn_InstallApps"
$btn_SelectAllTweaks = Get-XamlObject -Name "btn_SelectAllTweaks"
$btn_DeselectAllTweaks = Get-XamlObject -Name "btn_DeselectAllTweaks"
$btn_ApplyTweaks = Get-XamlObject -Name "btn_ApplyTweaks"
$btn_BrowseWallpaper = Get-XamlObject -Name "btn_BrowseWallpaper"
$btn_SetWallpaper = Get-XamlObject -Name "btn_SetWallpaper"
$btn_ApplyTheme = Get-XamlObject -Name "btn_ApplyTheme"
$btn_ApplyAccentColor = Get-XamlObject -Name "btn_ApplyAccentColor"
$btn_ApplyExplorerCustom = Get-XamlObject -Name "btn_ApplyExplorerCustom"
$btn_ResetCustom = Get-XamlObject -Name "btn_ResetCustom"
$txt_WallpaperPath = Get-XamlObject -Name "txt_WallpaperPath"
$cmb_WallpaperStyle = Get-XamlObject -Name "cmb_WallpaperStyle"
$rb_LightTheme = Get-XamlObject -Name "rb_LightTheme"
$rb_DarkTheme = Get-XamlObject -Name "rb_DarkTheme"
$cmb_AccentColor = Get-XamlObject -Name "cmb_AccentColor"
$chk_ShowAccentOnStartTaskbar = Get-XamlObject -Name "chk_ShowAccentOnStartTaskbar"
$chk_QuickAccessOff = Get-XamlObject -Name "chk_QuickAccessOff"
$chk_ThisPCDefault = Get-XamlObject -Name "chk_ThisPCDefault"
$chk_RemoveOneDrive = Get-XamlObject -Name "chk_RemoveOneDrive"

# Fonction pour obtenir toutes les checkboxes d'un panel
function Get-AllCheckBoxes {
    param($Panel)
    $checkboxes = @()
    foreach ($child in $Panel.Children) {
        if ($child -is [System.Windows.Controls.GroupBox]) {
            foreach ($subchild in $child.Content.Children) {
                if ($subchild -is [System.Windows.Controls.CheckBox]) {
                    $checkboxes += $subchild
                }
            }
        }
    }
    return $checkboxes
}

# ==================== ONGLET APPLICATIONS ====================

# Bouton Select All Apps
$btn_SelectAllApps.Add_Click({
    $checkboxes = Get-AllCheckBoxes -Panel $pnl_AppsList
    foreach ($cb in $checkboxes) {
        $cb.IsChecked = $true
    }
})

# Bouton Deselect All Apps
$btn_DeselectAllApps.Add_Click({
    $checkboxes = Get-AllCheckBoxes -Panel $pnl_AppsList
    foreach ($cb in $checkboxes) {
        $cb.IsChecked = $false
    }
})

# Installation des applications
$btn_InstallApps.Add_Click({
    $btn_InstallApps.IsEnabled = $false
    $txt_AppLog.Clear()

    # Mapping des checkboxes vers les packages Chocolatey
    $appMapping = @{
        'chk_GoogleChrome' = 'googlechrome'
        'chk_Firefox' = 'firefox'
        'chk_Brave' = 'brave'
        'chk_Edge' = 'microsoft-edge'
        'chk_VSCode' = 'vscode'
        'chk_Git' = 'git'
        'chk_Python' = 'python'
        'chk_NodeJS' = 'nodejs'
        'chk_Docker' = 'docker-desktop'
        'chk_Postman' = 'postman'
        'chk_NotePadPP' = 'notepadplusplus'
        'chk_Slack' = 'slack'
        'chk_Discord' = 'discord'
        'chk_Teams' = 'microsoft-teams'
        'chk_Zoom' = 'zoom'
        'chk_VLC' = 'vlc'
        'chk_Spotify' = 'spotify'
        'chk_OBS' = 'obs-studio'
        'chk_Audacity' = 'audacity'
        'chk_7zip' = '7zip'
        'chk_WinRAR' = 'winrar'
        'chk_Everything' = 'everything'
        'chk_TreeSize' = 'treesizefree'
        'chk_PowerToys' = 'powertoys'
        'chk_Greenshot' = 'greenshot'
        'chk_Bitwarden' = 'bitwarden'
        'chk_KeePass' = 'keepass'
        'chk_Malwarebytes' = 'malwarebytes'
    }

    $selectedApps = @()
    foreach ($checkbox in $appMapping.Keys) {
        $ctrl = Get-XamlObject -Name $checkbox
        if ($ctrl -and $ctrl.IsChecked) {
            $selectedApps += $appMapping[$checkbox]
        }
    }

    if ($selectedApps.Count -eq 0) {
        [System.Windows.MessageBox]::Show("Aucune application selectionnee", "Information", "OK", "Information")
        $btn_InstallApps.IsEnabled = $true
        return
    }

    # Installation avec job en arrière-plan
    $txt_AppLog.AppendText("Preparation de l'installation...`r`n")
    $txt_AppLog.ScrollToEnd()

    # Créer un script block pour le job
    $installScript = {
        param($apps)

        $results = @()

        # Vérifier Chocolatey
        if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
            $results += "CHOCO_INSTALL_START"
            try {
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                $results += "CHOCO_INSTALL_OK"
            }
            catch {
                $results += "CHOCO_INSTALL_ERROR:$_"
                return $results
            }
        }

        # Installer chaque application
        foreach ($app in $apps) {
            $results += "APP_START:$app"
            try {
                $output = choco install $app -y --no-progress --limit-output 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $results += "APP_OK:$app"
                }
                else {
                    $results += "APP_ERROR:$app"
                }
            }
            catch {
                $results += "APP_ERROR:$app"
            }
        }

        return $results
    }

    # Lancer le job
    $job = Start-Job -ScriptBlock $installScript -ArgumentList (,$selectedApps)

    # Timer pour vérifier l'état du job
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds(1)

    $timer.Add_Tick({
        if ($job.State -eq 'Running') {
            # Job toujours en cours
            return
        }

        # Job terminé
        $timer.Stop()

        if ($job.State -eq 'Completed') {
            $results = Receive-Job -Job $job

            foreach ($line in $results) {
                if ($line -like "CHOCO_INSTALL_START") {
                    $txt_AppLog.AppendText("Installation de Chocolatey...`r`n")
                }
                elseif ($line -like "CHOCO_INSTALL_OK") {
                    $txt_AppLog.AppendText("Chocolatey installe avec succes`r`n`r`n")
                }
                elseif ($line -like "CHOCO_INSTALL_ERROR:*") {
                    $txt_AppLog.AppendText("Erreur lors de l'installation de Chocolatey`r`n`r`n")
                }
                elseif ($line -like "APP_START:*") {
                    $appName = $line.Replace("APP_START:", "")
                    $txt_AppLog.AppendText("Installation de $appName...`r`n")
                }
                elseif ($line -like "APP_OK:*") {
                    $appName = $line.Replace("APP_OK:", "")
                    $txt_AppLog.AppendText("$appName installe avec succes`r`n`r`n")
                }
                elseif ($line -like "APP_ERROR:*") {
                    $appName = $line.Replace("APP_ERROR:", "")
                    $txt_AppLog.AppendText("Erreur lors de l'installation de $appName`r`n`r`n")
                }
                $txt_AppLog.ScrollToEnd()
            }

            $txt_AppLog.AppendText("`r`n=== INSTALLATION TERMINEE ===`r`n")
        }
        else {
            $txt_AppLog.AppendText("`r`n=== ERREUR LORS DE L'INSTALLATION ===`r`n")
        }

        $txt_AppLog.ScrollToEnd()
        Remove-Job -Job $job -Force
        $btn_InstallApps.IsEnabled = $true
    })

    $timer.Start()
})

# ==================== ONGLET TWEAKS ====================

# Boutons Select/Deselect All Tweaks
$btn_SelectAllTweaks.Add_Click({
    $checkboxes = Get-AllCheckBoxes -Panel $pnl_TweaksList
    foreach ($cb in $checkboxes) {
        $cb.IsChecked = $true
    }
})

$btn_DeselectAllTweaks.Add_Click({
    $checkboxes = Get-AllCheckBoxes -Panel $pnl_TweaksList
    foreach ($cb in $checkboxes) {
        $cb.IsChecked = $false
    }
})

# Fonction pour créer une clé de registre si elle n'existe pas
function Ensure-RegistryPath {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

# Application des tweaks
$btn_ApplyTweaks.Add_Click({
    $btn_ApplyTweaks.IsEnabled = $false
    $txt_TweakLog.Clear()

    $chk_DisableAnimations = Get-XamlObject -Name "chk_DisableAnimations"
    $chk_DisableTransparency = Get-XamlObject -Name "chk_DisableTransparency"
    $chk_EnableUltimatePerf = Get-XamlObject -Name "chk_EnableUltimatePerf"
    $chk_DisableHibernation = Get-XamlObject -Name "chk_DisableHibernation"
    $chk_DisableSuperfetch = Get-XamlObject -Name "chk_DisableSuperfetch"
    $chk_DisableTelemetry = Get-XamlObject -Name "chk_DisableTelemetry"
    $chk_DisableCortana = Get-XamlObject -Name "chk_DisableCortana"
    $chk_DisableLocationTracking = Get-XamlObject -Name "chk_DisableLocationTracking"
    $chk_DisableAdvertisingID = Get-XamlObject -Name "chk_DisableAdvertisingID"
    $chk_DisableActivityHistory = Get-XamlObject -Name "chk_DisableActivityHistory"
    $chk_DisableWebSearch = Get-XamlObject -Name "chk_DisableWebSearch"
    $chk_ShowFileExtensions = Get-XamlObject -Name "chk_ShowFileExtensions"
    $chk_ShowHiddenFiles = Get-XamlObject -Name "chk_ShowHiddenFiles"
    $chk_DisableShakeToMinimize = Get-XamlObject -Name "chk_DisableShakeToMinimize"
    $chk_TaskbarSmallIcons = Get-XamlObject -Name "chk_TaskbarSmallIcons"

    # Désactiver les animations
    if ($chk_DisableAnimations.IsChecked) {
        $txt_TweakLog.AppendText("Desactivation des animations...`r`n")
        try {
            Ensure-RegistryPath "HKCU:\Control Panel\Desktop\WindowMetrics"
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force
            $txt_TweakLog.AppendText("Animations desactivees`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Désactiver la transparence
    if ($chk_DisableTransparency.IsChecked) {
        $txt_TweakLog.AppendText("Desactivation de la transparence...`r`n")
        try {
            Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force
            $txt_TweakLog.AppendText("Transparence desactivee`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Mode Performance Ultime
    if ($chk_EnableUltimatePerf.IsChecked) {
        $txt_TweakLog.AppendText("Activation du mode Performance Ultime...`r`n")
        try {
            $result = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1
            $txt_TweakLog.AppendText("Mode Performance Ultime active`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Désactiver l'hibernation
    if ($chk_DisableHibernation.IsChecked) {
        $txt_TweakLog.AppendText("Desactivation de l'hibernation...`r`n")
        try {
            powercfg -h off 2>&1 | Out-Null
            $txt_TweakLog.AppendText("Hibernation desactivee`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Désactiver Superfetch
    if ($chk_DisableSuperfetch.IsChecked) {
        $txt_TweakLog.AppendText("Desactivation de Superfetch...`r`n")
        try {
            Stop-Service "SysMain" -Force -ErrorAction SilentlyContinue
            Set-Service "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
            $txt_TweakLog.AppendText("Superfetch desactive`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Désactiver la télémétrie
    if ($chk_DisableTelemetry.IsChecked) {
        $txt_TweakLog.AppendText("Desactivation de la telemetrie...`r`n")
        try {
            Ensure-RegistryPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
            Ensure-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
            Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" -ErrorAction SilentlyContinue
            Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" -ErrorAction SilentlyContinue
            $txt_TweakLog.AppendText("Telemetrie desactivee`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Désactiver Cortana
    if ($chk_DisableCortana.IsChecked) {
        $txt_TweakLog.AppendText("Desactivation de Cortana...`r`n")
        try {
            Ensure-RegistryPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Type DWord -Force
            $txt_TweakLog.AppendText("Cortana desactivee`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Désactiver la localisation
    if ($chk_DisableLocationTracking.IsChecked) {
        $txt_TweakLog.AppendText("Desactivation de la localisation...`r`n")
        try {
            Ensure-RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -Type String -Force
            $txt_TweakLog.AppendText("Localisation desactivee`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Désactiver l'ID de publicité
    if ($chk_DisableAdvertisingID.IsChecked) {
        $txt_TweakLog.AppendText("Desactivation de l'ID de publicite...`r`n")
        try {
            Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Type DWord -Force
            $txt_TweakLog.AppendText("ID de publicite desactive`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Désactiver l'historique d'activité
    if ($chk_DisableActivityHistory.IsChecked) {
        $txt_TweakLog.AppendText("Desactivation de l'historique d'activite...`r`n")
        try {
            Ensure-RegistryPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Type DWord -Force
            $txt_TweakLog.AppendText("Historique d'activite desactive`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Désactiver la recherche web
    if ($chk_DisableWebSearch.IsChecked) {
        $txt_TweakLog.AppendText("Desactivation de la recherche web...`r`n")
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Type DWord -Force
            $txt_TweakLog.AppendText("Recherche web desactivee`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Afficher les extensions
    if ($chk_ShowFileExtensions.IsChecked) {
        $txt_TweakLog.AppendText("Affichage des extensions de fichiers...`r`n")
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Type DWord -Force
            $txt_TweakLog.AppendText("Extensions de fichiers affichees`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Afficher les fichiers cachés
    if ($chk_ShowHiddenFiles.IsChecked) {
        $txt_TweakLog.AppendText("Affichage des fichiers caches...`r`n")
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Type DWord -Force
            $txt_TweakLog.AppendText("Fichiers caches affiches`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Désactiver Shake to Minimize
    if ($chk_DisableShakeToMinimize.IsChecked) {
        $txt_TweakLog.AppendText("Desactivation de Secouer pour minimiser...`r`n")
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -Value 1 -Type DWord -Force
            $txt_TweakLog.AppendText("Secouer pour minimiser desactive`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    # Petites icônes barre des tâches
    if ($chk_TaskbarSmallIcons.IsChecked) {
        $txt_TweakLog.AppendText("Activation des petites icones...`r`n")
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Value 1 -Type DWord -Force
            $txt_TweakLog.AppendText("Petites icones activees`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("Erreur: $_`r`n`r`n")
        }
    }

    $txt_TweakLog.AppendText("`r`n=== TWEAKS APPLIQUES ===`r`n")
    $txt_TweakLog.AppendText("Note: Un redemarrage peut etre necessaire pour certaines modifications.`r`n")
    $txt_TweakLog.ScrollToEnd()

    $btn_ApplyTweaks.IsEnabled = $true
})

# ==================== ONGLET CUSTOMISATION ====================

# Parcourir fond d'écran
$btn_BrowseWallpaper.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Images (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp"
    $openFileDialog.Title = "Selectionner un fond d ecran"

    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txt_WallpaperPath.Text = $openFileDialog.FileName
    }
})

# Appliquer fond d'écran
$btn_SetWallpaper.Add_Click({
    if ([string]::IsNullOrWhiteSpace($txt_WallpaperPath.Text)) {
        [System.Windows.MessageBox]::Show("Veuillez selectionner un fond d ecran", "Erreur", "OK", "Error")
        return
    }

    $txt_CustomLog.Clear()
    $txt_CustomLog.AppendText("Application du fond d ecran...`r`n")

    $wallpaperPath = $txt_WallpaperPath.Text
    $style = $cmb_WallpaperStyle.SelectedIndex

    # Mapping des styles
    $styleMap = @{
        0 = @{TileWallpaper = "0"; WallpaperStyle = "10"} # Remplir
        1 = @{TileWallpaper = "0"; WallpaperStyle = "6"}  # Ajuster
        2 = @{TileWallpaper = "0"; WallpaperStyle = "2"}  # Étirer
        3 = @{TileWallpaper = "1"; WallpaperStyle = "0"}  # Mosaïque
        4 = @{TileWallpaper = "0"; WallpaperStyle = "0"}  # Centrer
    }

    try {
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value $styleMap[$style].WallpaperStyle -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value $styleMap[$style].TileWallpaper -Force

        [Wallpaper]::SystemParametersInfo(0x0014, 0, $wallpaperPath, 0x0001 -bor 0x0002)

        $txt_CustomLog.AppendText("Fond d ecran applique avec succes`r`n")
    }
    catch {
        $txt_CustomLog.AppendText("Erreur lors de l'application du fond d ecran : $_`r`n")
    }
    $txt_CustomLog.ScrollToEnd()
})

# Appliquer thème
$btn_ApplyTheme.Add_Click({
    $txt_CustomLog.Clear()
    $txt_CustomLog.AppendText("Application du theme...`r`n")

    try {
        Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        if ($rb_DarkTheme.IsChecked) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
            $txt_CustomLog.AppendText("Theme sombre applique`r`n")
        }
        else {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1 -Type DWord -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1 -Type DWord -Force
            $txt_CustomLog.AppendText("Theme clair applique`r`n")
        }
    }
    catch {
        $txt_CustomLog.AppendText("Erreur lors de l'application du theme : $_`r`n")
    }
    $txt_CustomLog.ScrollToEnd()
})

# Appliquer couleur d'accentuation
$btn_ApplyAccentColor.Add_Click({
    $txt_CustomLog.Clear()
    $txt_CustomLog.AppendText("Application de la couleur d'accentuation...`r`n")

    # Mapping des couleurs
    $colorMap = @{
        0 = 0xFF0078D4  # Bleu
        1 = 0xFFE81123  # Rouge
        2 = 0xFF00CC6A  # Vert
        3 = 0xFF8E44AD  # Violet
        4 = 0xFFFF8C00  # Orange
        5 = 0xFFE3008C  # Rose
    }

    try {
        $color = $colorMap[$cmb_AccentColor.SelectedIndex]
        Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
        Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\DWM"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "AccentColorMenu" -Value $color -Type DWord -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AccentColor" -Value $color -Type DWord -Force

        Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        if ($chk_ShowAccentOnStartTaskbar.IsChecked) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 1 -Type DWord -Force
        }
        else {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 0 -Type DWord -Force
        }

        $txt_CustomLog.AppendText("Couleur d'accentuation appliquee`r`n")
    }
    catch {
        $txt_CustomLog.AppendText("Erreur lors de l'application : $_`r`n")
    }
    $txt_CustomLog.ScrollToEnd()
})

# Appliquer personnalisation explorateur
$btn_ApplyExplorerCustom.Add_Click({
    $txt_CustomLog.Clear()
    $txt_CustomLog.AppendText("Application des personnalisations de l'explorateur...`r`n")

    try {
        if ($chk_QuickAccessOff.IsChecked) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0 -Type DWord -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Value 0 -Type DWord -Force
            $txt_CustomLog.AppendText("Acces rapide desactive`r`n")
        }

        if ($chk_ThisPCDefault.IsChecked) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 -Type DWord -Force
            $txt_CustomLog.AppendText("Ce PC defini par defaut`r`n")
        }

        if ($chk_RemoveOneDrive.IsChecked) {
            Ensure-RegistryPath "HKCU:\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
            Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0 -Type DWord -Force
            $txt_CustomLog.AppendText("OneDrive masque de l'explorateur`r`n")
        }

        $txt_CustomLog.AppendText("`r`nRedemarrage de l'explorateur...`r`n")
        Stop-Process -Name explorer -Force
        Start-Sleep -Seconds 2
        $txt_CustomLog.AppendText("Personnalisations appliquees`r`n")
    }
    catch {
        $txt_CustomLog.AppendText("Erreur lors de l'application : $_`r`n")
    }
    $txt_CustomLog.ScrollToEnd()
})

# Restaurer paramètres par défaut
$btn_ResetCustom.Add_Click({
    $result = [System.Windows.MessageBox]::Show("Voulez-vous vraiment restaurer tous les parametres de customisation par defaut ?", "Confirmation", "YesNo", "Question")

    if ($result -eq "Yes") {
        $txt_CustomLog.Clear()
        $txt_CustomLog.AppendText("Restauration des parametres par defaut...`r`n")

        try {
            # Restaurer thème par défaut
            Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1 -Type DWord -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1 -Type DWord -Force

            # Restaurer explorateur
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 2 -Type DWord -Force

            $txt_CustomLog.AppendText("Parametres restaures par defaut`r`n")
        }
        catch {
            $txt_CustomLog.AppendText("Erreur lors de la restauration : $_`r`n")
        }
        $txt_CustomLog.ScrollToEnd()
    }
})

# Afficher la fenêtre
$Window.ShowDialog() | Out-Null
