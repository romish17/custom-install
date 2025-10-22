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

# Fonction pour vérifier et installer Chocolatey
function Install-Chocolatey {
    if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Installation de Chocolatey..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        refreshenv
        return $true
    }
    return $false
}

# Fonction pour installer une application
function Install-ChocoApp {
    param(
        [string]$AppName,
        [System.Windows.Controls.TextBox]$LogBox
    )

    $LogBox.Dispatcher.Invoke([action]{
        $LogBox.AppendText("Installation de $AppName...`r`n")
        $LogBox.ScrollToEnd()
    })

    try {
        $output = choco install $AppName -y 2>&1
        $LogBox.Dispatcher.Invoke([action]{
            $LogBox.AppendText("✓ $AppName installé avec succès`r`n")
            $LogBox.ScrollToEnd()
        })
    }
    catch {
        $LogBox.Dispatcher.Invoke([action]{
            $LogBox.AppendText("✗ Erreur lors de l'installation de $AppName : $_`r`n")
            $LogBox.ScrollToEnd()
        })
    }
}

# Fonction pour appliquer les tweaks Windows
function Apply-WindowsTweak {
    param(
        [string]$TweakName,
        [scriptblock]$TweakScript,
        [System.Windows.Controls.TextBox]$LogBox
    )

    $LogBox.Dispatcher.Invoke([action]{
        $LogBox.AppendText("Application de : $TweakName...`r`n")
        $LogBox.ScrollToEnd()
    })

    try {
        & $TweakScript
        $LogBox.Dispatcher.Invoke([action]{
            $LogBox.AppendText("✓ $TweakName appliqué avec succès`r`n")
            $LogBox.ScrollToEnd()
        })
    }
    catch {
        $LogBox.Dispatcher.Invoke([action]{
            $LogBox.AppendText("✗ Erreur lors de l'application de $TweakName : $_`r`n")
            $LogBox.ScrollToEnd()
        })
    }
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
            <TabItem Header="📦 Applications">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="150"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <GroupBox Header="Navigateurs Web">
                                <StackPanel>
                                    <CheckBox Name="chk_GoogleChrome" Content="Google Chrome"/>
                                    <CheckBox Name="chk_Firefox" Content="Mozilla Firefox"/>
                                    <CheckBox Name="chk_Brave" Content="Brave Browser"/>
                                    <CheckBox Name="chk_Edge" Content="Microsoft Edge"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Développement">
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

                            <GroupBox Header="Multimédia">
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
                                    <CheckBox Name="chk_Greenshot" Content="Greenshot (Capture d'écran)"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Sécurité">
                                <StackPanel>
                                    <CheckBox Name="chk_Bitwarden" Content="Bitwarden (Gestionnaire de mots de passe)"/>
                                    <CheckBox Name="chk_KeePass" Content="KeePass"/>
                                    <CheckBox Name="chk_Malwarebytes" Content="Malwarebytes"/>
                                </StackPanel>
                            </GroupBox>
                        </StackPanel>
                    </ScrollViewer>

                    <GroupBox Grid.Row="1" Header="Journal d'installation">
                        <TextBox Name="txt_AppLog" IsReadOnly="True" VerticalScrollBarVisibility="Auto"
                                 FontFamily="Consolas" Background="#1E1E1E" Foreground="#00FF00"/>
                    </GroupBox>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center">
                        <Button Name="btn_SelectAllApps" Content="Tout sélectionner" Width="150"/>
                        <Button Name="btn_DeselectAllApps" Content="Tout désélectionner" Width="150"/>
                        <Button Name="btn_InstallApps" Content="🚀 Installer les applications" Width="200"
                                Background="#0078D4" Foreground="White" FontWeight="Bold"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <!-- ONGLET TWEAKS WINDOWS -->
            <TabItem Header="⚙️ Tweaks Windows">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="150"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <GroupBox Header="Performance">
                                <StackPanel>
                                    <CheckBox Name="chk_DisableAnimations" Content="Désactiver les animations Windows"/>
                                    <CheckBox Name="chk_DisableTransparency" Content="Désactiver la transparence"/>
                                    <CheckBox Name="chk_DisableStartupApps" Content="Désactiver les applications au démarrage"/>
                                    <CheckBox Name="chk_EnableUltimatePerf" Content="Activer le mode Performance Ultime"/>
                                    <CheckBox Name="chk_DisableHibernation" Content="Désactiver l'hibernation"/>
                                    <CheckBox Name="chk_DisableSuperfetch" Content="Désactiver Superfetch"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Vie Privée">
                                <StackPanel>
                                    <CheckBox Name="chk_DisableTelemetry" Content="Désactiver la télémétrie Windows"/>
                                    <CheckBox Name="chk_DisableCortana" Content="Désactiver Cortana"/>
                                    <CheckBox Name="chk_DisableLocationTracking" Content="Désactiver la localisation"/>
                                    <CheckBox Name="chk_DisableAdvertisingID" Content="Désactiver l'ID de publicité"/>
                                    <CheckBox Name="chk_DisableActivityHistory" Content="Désactiver l'historique d'activité"/>
                                    <CheckBox Name="chk_DisableWebSearch" Content="Désactiver la recherche web dans le menu Démarrer"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Sécurité">
                                <StackPanel>
                                    <CheckBox Name="chk_EnableUAC" Content="Activer le contrôle de compte d'utilisateur (UAC)"/>
                                    <CheckBox Name="chk_EnableFirewall" Content="Activer le pare-feu Windows"/>
                                    <CheckBox Name="chk_EnableDefender" Content="Activer Windows Defender"/>
                                    <CheckBox Name="chk_DisableAutoplay" Content="Désactiver l'exécution automatique"/>
                                    <CheckBox Name="chk_EnableBitLocker" Content="Informations BitLocker (vérification)"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Interface Utilisateur">
                                <StackPanel>
                                    <CheckBox Name="chk_ShowFileExtensions" Content="Afficher les extensions de fichiers"/>
                                    <CheckBox Name="chk_ShowHiddenFiles" Content="Afficher les fichiers cachés"/>
                                    <CheckBox Name="chk_DisableShakeToMinimize" Content="Désactiver 'Secouer pour minimiser'"/>
                                    <CheckBox Name="chk_DisableSnapAssist" Content="Désactiver l'assistance d'accrochage"/>
                                    <CheckBox Name="chk_TaskbarSmallIcons" Content="Petites icônes de la barre des tâches"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Mises à jour">
                                <StackPanel>
                                    <CheckBox Name="chk_DisableAutoUpdates" Content="Désactiver les mises à jour automatiques"/>
                                    <CheckBox Name="chk_DisableDriverUpdates" Content="Désactiver les mises à jour de pilotes"/>
                                    <CheckBox Name="chk_DisableWindowsStore" Content="Désactiver les mises à jour du Windows Store"/>
                                </StackPanel>
                            </GroupBox>
                        </StackPanel>
                    </ScrollViewer>

                    <GroupBox Grid.Row="1" Header="Journal des modifications">
                        <TextBox Name="txt_TweakLog" IsReadOnly="True" VerticalScrollBarVisibility="Auto"
                                 FontFamily="Consolas" Background="#1E1E1E" Foreground="#00FF00"/>
                    </GroupBox>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center">
                        <Button Name="btn_SelectAllTweaks" Content="Tout sélectionner" Width="150"/>
                        <Button Name="btn_DeselectAllTweaks" Content="Tout désélectionner" Width="150"/>
                        <Button Name="btn_ApplyTweaks" Content="⚡ Appliquer les tweaks" Width="200"
                                Background="#0078D4" Foreground="White" FontWeight="Bold"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <!-- ONGLET CUSTOMISATION -->
            <TabItem Header="🎨 Customisation">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="150"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <GroupBox Header="Fond d'écran">
                                <StackPanel>
                                    <Label Content="Sélectionner un fond d'écran :"/>
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
                                            <ComboBoxItem Content="Étirer"/>
                                            <ComboBoxItem Content="Mosaïque"/>
                                            <ComboBoxItem Content="Centrer"/>
                                        </ComboBox>
                                    </StackPanel>
                                    <Button Name="btn_SetWallpaper" Content="Appliquer le fond d'écran" Width="200"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Thème">
                                <StackPanel>
                                    <RadioButton Name="rb_LightTheme" Content="Thème clair" GroupName="Theme" Margin="5"/>
                                    <RadioButton Name="rb_DarkTheme" Content="Thème sombre" GroupName="Theme" Margin="5" IsChecked="True"/>
                                    <Button Name="btn_ApplyTheme" Content="Appliquer le thème" Width="200"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Couleur d'accentuation">
                                <StackPanel>
                                    <Label Content="Sélectionner une couleur d'accentuation :"/>
                                    <ComboBox Name="cmb_AccentColor" Width="200" SelectedIndex="0">
                                        <ComboBoxItem Content="Bleu (par défaut)"/>
                                        <ComboBoxItem Content="Rouge"/>
                                        <ComboBoxItem Content="Vert"/>
                                        <ComboBoxItem Content="Violet"/>
                                        <ComboBoxItem Content="Orange"/>
                                        <ComboBoxItem Content="Rose"/>
                                    </ComboBox>
                                    <CheckBox Name="chk_ShowAccentOnStartTaskbar" Content="Afficher la couleur d'accentuation sur Démarrer et la barre des tâches" Margin="5"/>
                                    <Button Name="btn_ApplyAccentColor" Content="Appliquer la couleur" Width="200"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Personnalisation de l'explorateur">
                                <StackPanel>
                                    <CheckBox Name="chk_QuickAccessOff" Content="Désactiver l'accès rapide"/>
                                    <CheckBox Name="chk_ThisPCDefault" Content="Ouvrir l'explorateur sur 'Ce PC' par défaut"/>
                                    <CheckBox Name="chk_RemoveOneDrive" Content="Masquer OneDrive de l'explorateur"/>
                                    <Button Name="btn_ApplyExplorerCustom" Content="Appliquer les personnalisations" Width="250"/>
                                </StackPanel>
                            </GroupBox>

                            <GroupBox Header="Curseur de souris">
                                <StackPanel>
                                    <ComboBox Name="cmb_CursorScheme" Width="200" SelectedIndex="0">
                                        <ComboBoxItem Content="Windows par défaut"/>
                                        <ComboBoxItem Content="Windows inversé"/>
                                        <ComboBoxItem Content="Noir (système)"/>
                                        <ComboBoxItem Content="Grand (système)"/>
                                    </ComboBox>
                                    <Button Name="btn_ApplyCursor" Content="Appliquer le curseur" Width="200" Margin="5"/>
                                </StackPanel>
                            </GroupBox>
                        </StackPanel>
                    </ScrollViewer>

                    <GroupBox Grid.Row="1" Header="Journal de customisation">
                        <TextBox Name="txt_CustomLog" IsReadOnly="True" VerticalScrollBarVisibility="Auto"
                                 FontFamily="Consolas" Background="#1E1E1E" Foreground="#00FF00"/>
                    </GroupBox>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center">
                        <Button Name="btn_ResetCustom" Content="Restaurer les paramètres par défaut" Width="250"/>
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

# Récupérer les éléments de l'interface
$XAML.SelectNodes("//*[@Name]") | ForEach-Object {
    Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name) -Scope Script
}

# ==================== ONGLET APPLICATIONS ====================

# Bouton Select All Apps
$btn_SelectAllApps.Add_Click({
    $XAML.SelectNodes("//CheckBox[starts-with(@Name, 'chk_')]") | ForEach-Object {
        $checkbox = $Window.FindName($_.Name)
        if ($checkbox -and $checkbox.Parent.Parent.Parent.Parent.Name -eq "MainTabControl") {
            $tabItem = $checkbox
            while ($tabItem -and $tabItem.GetType().Name -ne "TabItem") {
                $tabItem = $tabItem.Parent
            }
            if ($tabItem.Header -eq "📦 Applications") {
                $checkbox.IsChecked = $true
            }
        }
    }
})

# Bouton Deselect All Apps
$btn_DeselectAllApps.Add_Click({
    $XAML.SelectNodes("//CheckBox[starts-with(@Name, 'chk_')]") | ForEach-Object {
        $checkbox = $Window.FindName($_.Name)
        if ($checkbox -and $checkbox.Parent.Parent.Parent.Parent.Name -eq "MainTabControl") {
            $tabItem = $checkbox
            while ($tabItem -and $tabItem.GetType().Name -ne "TabItem") {
                $tabItem = $tabItem.Parent
            }
            if ($tabItem.Header -eq "📦 Applications") {
                $checkbox.IsChecked = $false
            }
        }
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
        $ctrl = $Window.FindName($checkbox)
        if ($ctrl.IsChecked) {
            $selectedApps += $appMapping[$checkbox]
        }
    }

    if ($selectedApps.Count -eq 0) {
        [System.Windows.MessageBox]::Show("Aucune application sélectionnée", "Information", "OK", "Information")
        $btn_InstallApps.IsEnabled = $true
        return
    }

    # Installation asynchrone
    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.ApartmentState = "STA"
    $runspace.ThreadOptions = "ReuseThread"
    $runspace.Open()
    $runspace.SessionStateProxy.SetVariable("selectedApps", $selectedApps)
    $runspace.SessionStateProxy.SetVariable("txt_AppLog", $txt_AppLog)
    $runspace.SessionStateProxy.SetVariable("btn_InstallApps", $btn_InstallApps)

    $powershell = [powershell]::Create().AddScript({
        # Vérifier et installer Chocolatey si nécessaire
        if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
            $txt_AppLog.Dispatcher.Invoke([action]{
                $txt_AppLog.AppendText("Installation de Chocolatey...`r`n")
                $txt_AppLog.ScrollToEnd()
            })

            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

            $txt_AppLog.Dispatcher.Invoke([action]{
                $txt_AppLog.AppendText("✓ Chocolatey installé`r`n`r`n")
                $txt_AppLog.ScrollToEnd()
            })
        }

        # Installer chaque application
        foreach ($app in $selectedApps) {
            $txt_AppLog.Dispatcher.Invoke([action]{
                $txt_AppLog.AppendText("Installation de $app...`r`n")
                $txt_AppLog.ScrollToEnd()
            })

            try {
                $output = choco install $app -y --no-progress 2>&1
                $txt_AppLog.Dispatcher.Invoke([action]{
                    $txt_AppLog.AppendText("✓ $app installé avec succès`r`n`r`n")
                    $txt_AppLog.ScrollToEnd()
                })
            }
            catch {
                $txt_AppLog.Dispatcher.Invoke([action]{
                    $txt_AppLog.AppendText("✗ Erreur lors de l'installation de $app`r`n`r`n")
                    $txt_AppLog.ScrollToEnd()
                })
            }
        }

        $txt_AppLog.Dispatcher.Invoke([action]{
            $txt_AppLog.AppendText("`r`n=== INSTALLATION TERMINÉE ===`r`n")
            $txt_AppLog.ScrollToEnd()
        })

        $btn_InstallApps.Dispatcher.Invoke([action]{
            $btn_InstallApps.IsEnabled = $true
        })
    })

    $powershell.Runspace = $runspace
    $powershell.BeginInvoke()
})

# ==================== ONGLET TWEAKS ====================

# Boutons Select/Deselect All Tweaks
$btn_SelectAllTweaks.Add_Click({
    $Window.FindName('chk_DisableAnimations').IsChecked = $true
    $Window.FindName('chk_DisableTransparency').IsChecked = $true
    $Window.FindName('chk_DisableStartupApps').IsChecked = $true
    $Window.FindName('chk_EnableUltimatePerf').IsChecked = $true
    $Window.FindName('chk_DisableHibernation').IsChecked = $true
    $Window.FindName('chk_DisableSuperfetch').IsChecked = $true
    $Window.FindName('chk_DisableTelemetry').IsChecked = $true
    $Window.FindName('chk_DisableCortana').IsChecked = $true
    $Window.FindName('chk_DisableLocationTracking').IsChecked = $true
    $Window.FindName('chk_DisableAdvertisingID').IsChecked = $true
    $Window.FindName('chk_DisableActivityHistory').IsChecked = $true
    $Window.FindName('chk_DisableWebSearch').IsChecked = $true
    $Window.FindName('chk_EnableUAC').IsChecked = $true
    $Window.FindName('chk_EnableFirewall').IsChecked = $true
    $Window.FindName('chk_EnableDefender').IsChecked = $true
    $Window.FindName('chk_DisableAutoplay').IsChecked = $true
    $Window.FindName('chk_ShowFileExtensions').IsChecked = $true
    $Window.FindName('chk_ShowHiddenFiles').IsChecked = $true
    $Window.FindName('chk_DisableShakeToMinimize').IsChecked = $true
    $Window.FindName('chk_DisableSnapAssist').IsChecked = $true
    $Window.FindName('chk_TaskbarSmallIcons').IsChecked = $true
})

$btn_DeselectAllTweaks.Add_Click({
    $Window.FindName('chk_DisableAnimations').IsChecked = $false
    $Window.FindName('chk_DisableTransparency').IsChecked = $false
    $Window.FindName('chk_DisableStartupApps').IsChecked = $false
    $Window.FindName('chk_EnableUltimatePerf').IsChecked = $false
    $Window.FindName('chk_DisableHibernation').IsChecked = $false
    $Window.FindName('chk_DisableSuperfetch').IsChecked = $false
    $Window.FindName('chk_DisableTelemetry').IsChecked = $false
    $Window.FindName('chk_DisableCortana').IsChecked = $false
    $Window.FindName('chk_DisableLocationTracking').IsChecked = $false
    $Window.FindName('chk_DisableAdvertisingID').IsChecked = $false
    $Window.FindName('chk_DisableActivityHistory').IsChecked = $false
    $Window.FindName('chk_DisableWebSearch').IsChecked = $false
    $Window.FindName('chk_EnableUAC').IsChecked = $false
    $Window.FindName('chk_EnableFirewall').IsChecked = $false
    $Window.FindName('chk_EnableDefender').IsChecked = $false
    $Window.FindName('chk_DisableAutoplay').IsChecked = $false
    $Window.FindName('chk_ShowFileExtensions').IsChecked = $false
    $Window.FindName('chk_ShowHiddenFiles').IsChecked = $false
    $Window.FindName('chk_DisableShakeToMinimize').IsChecked = $false
    $Window.FindName('chk_DisableSnapAssist').IsChecked = $false
    $Window.FindName('chk_TaskbarSmallIcons').IsChecked = $false
})

# Application des tweaks
$btn_ApplyTweaks.Add_Click({
    $btn_ApplyTweaks.IsEnabled = $false
    $txt_TweakLog.Clear()

    # Désactiver les animations
    if ($chk_DisableAnimations.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation des animations...`r`n")
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Animations désactivées`r`n`r`n")
    }

    # Désactiver la transparence
    if ($chk_DisableTransparency.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation de la transparence...`r`n")
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Transparence désactivée`r`n`r`n")
    }

    # Mode Performance Ultime
    if ($chk_EnableUltimatePerf.IsChecked) {
        $txt_TweakLog.AppendText("Activation du mode Performance Ultime...`r`n")
        try {
            powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
            $txt_TweakLog.AppendText("✓ Mode Performance Ultime activé`r`n`r`n")
        }
        catch {
            $txt_TweakLog.AppendText("✗ Erreur lors de l'activation`r`n`r`n")
        }
    }

    # Désactiver l'hibernation
    if ($chk_DisableHibernation.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation de l'hibernation...`r`n")
        powercfg -h off
        $txt_TweakLog.AppendText("✓ Hibernation désactivée`r`n`r`n")
    }

    # Désactiver Superfetch
    if ($chk_DisableSuperfetch.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation de Superfetch...`r`n")
        Stop-Service "SysMain" -Force -ErrorAction SilentlyContinue
        Set-Service "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Superfetch désactivé`r`n`r`n")
    }

    # Désactiver la télémétrie
    if ($chk_DisableTelemetry.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation de la télémétrie...`r`n")
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" -ErrorAction SilentlyContinue
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Télémétrie désactivée`r`n`r`n")
    }

    # Désactiver Cortana
    if ($chk_DisableCortana.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation de Cortana...`r`n")
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Cortana désactivée`r`n`r`n")
    }

    # Désactiver la localisation
    if ($chk_DisableLocationTracking.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation de la localisation...`r`n")
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Localisation désactivée`r`n`r`n")
    }

    # Désactiver l'ID de publicité
    if ($chk_DisableAdvertisingID.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation de l'ID de publicité...`r`n")
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ ID de publicité désactivé`r`n`r`n")
    }

    # Désactiver l'historique d'activité
    if ($chk_DisableActivityHistory.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation de l'historique d'activité...`r`n")
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Historique d'activité désactivé`r`n`r`n")
    }

    # Désactiver la recherche web
    if ($chk_DisableWebSearch.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation de la recherche web...`r`n")
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Recherche web désactivée`r`n`r`n")
    }

    # Afficher les extensions
    if ($chk_ShowFileExtensions.IsChecked) {
        $txt_TweakLog.AppendText("Affichage des extensions de fichiers...`r`n")
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Extensions de fichiers affichées`r`n`r`n")
    }

    # Afficher les fichiers cachés
    if ($chk_ShowHiddenFiles.IsChecked) {
        $txt_TweakLog.AppendText("Affichage des fichiers cachés...`r`n")
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Fichiers cachés affichés`r`n`r`n")
    }

    # Désactiver Shake to Minimize
    if ($chk_DisableShakeToMinimize.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation de 'Secouer pour minimiser'...`r`n")
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -Value 1 -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ 'Secouer pour minimiser' désactivé`r`n`r`n")
    }

    # Désactiver Autoplay
    if ($chk_DisableAutoplay.IsChecked) {
        $txt_TweakLog.AppendText("Désactivation de l'exécution automatique...`r`n")
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 1 -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Exécution automatique désactivée`r`n`r`n")
    }

    # Petites icônes barre des tâches
    if ($chk_TaskbarSmallIcons.IsChecked) {
        $txt_TweakLog.AppendText("Activation des petites icônes...`r`n")
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Value 1 -ErrorAction SilentlyContinue
        $txt_TweakLog.AppendText("✓ Petites icônes activées`r`n`r`n")
    }

    $txt_TweakLog.AppendText("`r`n=== TWEAKS APPLIQUÉS ===`r`n")
    $txt_TweakLog.AppendText("Note: Un redémarrage peut être nécessaire pour certaines modifications.`r`n")
    $txt_TweakLog.ScrollToEnd()

    $btn_ApplyTweaks.IsEnabled = $true
})

# ==================== ONGLET CUSTOMISATION ====================

# Parcourir fond d'écran
$btn_BrowseWallpaper.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Images (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp"
    $openFileDialog.Title = "Sélectionner un fond d'écran"

    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txt_WallpaperPath.Text = $openFileDialog.FileName
    }
})

# Appliquer fond d'écran
$btn_SetWallpaper.Add_Click({
    if ([string]::IsNullOrWhiteSpace($txt_WallpaperPath.Text)) {
        [System.Windows.MessageBox]::Show("Veuillez sélectionner un fond d'écran", "Erreur", "OK", "Error")
        return
    }

    $txt_CustomLog.Clear()
    $txt_CustomLog.AppendText("Application du fond d'écran...`r`n")

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
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value $styleMap[$style].WallpaperStyle
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value $styleMap[$style].TileWallpaper

        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
        [Wallpaper]::SystemParametersInfo(0x0014, 0, $wallpaperPath, 0x0001 -bor 0x0002)

        $txt_CustomLog.AppendText("✓ Fond d'écran appliqué avec succès`r`n")
    }
    catch {
        $txt_CustomLog.AppendText("✗ Erreur lors de l'application du fond d'écran : $_`r`n")
    }
    $txt_CustomLog.ScrollToEnd()
})

# Appliquer thème
$btn_ApplyTheme.Add_Click({
    $txt_CustomLog.Clear()
    $txt_CustomLog.AppendText("Application du thème...`r`n")

    try {
        if ($rb_DarkTheme.IsChecked) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
            $txt_CustomLog.AppendText("✓ Thème sombre appliqué`r`n")
        }
        else {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1
            $txt_CustomLog.AppendText("✓ Thème clair appliqué`r`n")
        }
    }
    catch {
        $txt_CustomLog.AppendText("✗ Erreur lors de l'application du thème : $_`r`n")
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
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "AccentColorMenu" -Value $color -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AccentColor" -Value $color -ErrorAction SilentlyContinue

        if ($chk_ShowAccentOnStartTaskbar.IsChecked) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 1
        }
        else {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 0
        }

        $txt_CustomLog.AppendText("✓ Couleur d'accentuation appliquée`r`n")
    }
    catch {
        $txt_CustomLog.AppendText("✗ Erreur lors de l'application : $_`r`n")
    }
    $txt_CustomLog.ScrollToEnd()
})

# Appliquer personnalisation explorateur
$btn_ApplyExplorerCustom.Add_Click({
    $txt_CustomLog.Clear()
    $txt_CustomLog.AppendText("Application des personnalisations de l'explorateur...`r`n")

    try {
        if ($chk_QuickAccessOff.IsChecked) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Value 0 -ErrorAction SilentlyContinue
            $txt_CustomLog.AppendText("✓ Accès rapide désactivé`r`n")
        }

        if ($chk_ThisPCDefault.IsChecked) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 -ErrorAction SilentlyContinue
            $txt_CustomLog.AppendText("✓ 'Ce PC' défini par défaut`r`n")
        }

        if ($chk_RemoveOneDrive.IsChecked) {
            Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0 -ErrorAction SilentlyContinue
            $txt_CustomLog.AppendText("✓ OneDrive masqué de l'explorateur`r`n")
        }

        $txt_CustomLog.AppendText("`r`nRedémarrage de l'explorateur...`r`n")
        Stop-Process -Name explorer -Force
        Start-Sleep -Seconds 2
        $txt_CustomLog.AppendText("✓ Personnalisations appliquées`r`n")
    }
    catch {
        $txt_CustomLog.AppendText("✗ Erreur lors de l'application : $_`r`n")
    }
    $txt_CustomLog.ScrollToEnd()
})

# Appliquer curseur
$btn_ApplyCursor.Add_Click({
    $txt_CustomLog.Clear()
    $txt_CustomLog.AppendText("Application du curseur...`r`n")

    # Mapping des schémas de curseur
    $cursorSchemes = @{
        0 = ""  # Par défaut
        1 = "%SystemRoot%\cursors\aero_arrow_i.cur"  # Inversé
        2 = "%SystemRoot%\cursors\arrow_r.cur"  # Noir
        3 = "%SystemRoot%\cursors\arrow_l.cur"  # Grand
    }

    try {
        $scheme = $cursorSchemes[$cmb_CursorScheme.SelectedIndex]
        if ($scheme -eq "") {
            # Restaurer par défaut
            Remove-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "Arrow" -ErrorAction SilentlyContinue
        }
        else {
            Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "Arrow" -Value $scheme -ErrorAction SilentlyContinue
        }

        [Wallpaper]::SystemParametersInfo(0x0057, 0, $null, 0x0001 -bor 0x0002)

        $txt_CustomLog.AppendText("✓ Curseur appliqué`r`n")
    }
    catch {
        $txt_CustomLog.AppendText("✗ Erreur lors de l'application : $_`r`n")
    }
    $txt_CustomLog.ScrollToEnd()
})

# Restaurer paramètres par défaut
$btn_ResetCustom.Add_Click({
    $result = [System.Windows.MessageBox]::Show("Voulez-vous vraiment restaurer tous les paramètres de customisation par défaut ?", "Confirmation", "YesNo", "Question")

    if ($result -eq "Yes") {
        $txt_CustomLog.Clear()
        $txt_CustomLog.AppendText("Restauration des paramètres par défaut...`r`n")

        try {
            # Restaurer thème par défaut
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1

            # Restaurer explorateur
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 2

            $txt_CustomLog.AppendText("✓ Paramètres restaurés par défaut`r`n")
        }
        catch {
            $txt_CustomLog.AppendText("✗ Erreur lors de la restauration : $_`r`n")
        }
        $txt_CustomLog.ScrollToEnd()
    }
})

# Afficher la fenêtre
$Window.ShowDialog() | Out-Null
