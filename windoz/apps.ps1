[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | Out-Null

# Create the main window
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Software Installer via Chocolatey'
$form.Size = New-Object System.Drawing.Size(900, 600)
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(46, 52, 64) # Nord Background
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10) # Updated to a more modern font

# Title of the interface
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = 'Select the software to install:'
$titleLabel.Size = New-Object System.Drawing.Size(500, 20)
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(129, 161, 193) # Nord Frost
$form.Controls.Add($titleLabel)

# List of software
$softwares = @(
    'wget', 'git', 'curl', 'vscode', 'spotify', 'nerd-fonts-FiraCode', 'FiraCode',
    'putty.install', 'vlc', '7zip', 'oh-my-posh', 'pnpm', 'veracrypt', 'protonmail',
    'onedrive', 'nodejs', 'veeam-agent', 'ssh-manager', '1password', 'docker-desktop',
    'tailscale', 'signal', 'brave', 'virtualclonedrive', 'xpipe', 'virtualbox',
    'virtualbox-guest-additions-guest.install', 'vagrant'
)

# Define panels to hold checkboxes in multiple scrollable sections
$checkboxPanels = @()
$panelHeight = 400
$panelWidth = 240
$startXPanel = 40
$startYPanel = 60
$softwareChunks = @()

# Chunk the software list manually into groups of 12
for ($i = 0; $i -lt $softwares.Count; $i += 12) {
    $chunk = $softwares[$i..([math]::Min($i + 11, $softwares.Count - 1))]
    $softwareChunks += ,$chunk
}

foreach ($chunk in $softwareChunks) {
    $checkboxPanel = New-Object System.Windows.Forms.Panel
    $checkboxPanel.Size = New-Object System.Drawing.Size($panelWidth, $panelHeight)
    $checkboxPanel.Location = New-Object System.Drawing.Point($startXPanel, $startYPanel)
    $checkboxPanel.AutoScroll = $true
    $checkboxPanel.BackColor = [System.Drawing.Color]::FromArgb(59, 66, 82) # Nord Background slightly lighter
    $form.Controls.Add($checkboxPanel)
    $checkboxPanels += $checkboxPanel

    $yPosition = 10
    foreach ($software in $chunk) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $software
        $checkbox.Location = New-Object System.Drawing.Point(10, $yPosition)
        $checkbox.Size = New-Object System.Drawing.Size(200, 25)
        $checkbox.ForeColor = [System.Drawing.Color]::FromArgb(163, 190, 140) # Nord Green
        $checkbox.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Regular)
        $checkbox.FlatStyle = 'Flat'
        $checkbox.BackColor = [System.Drawing.Color]::FromArgb(72, 82, 96) # Slightly lighter background for better contrast
        $checkboxPanel.Controls.Add($checkbox)
        $checkboxes += $checkbox
        $yPosition += 30
    }
    $startXPanel += $panelWidth + 20
    if ($startXPanel + $panelWidth > $form.Width) {
        $startXPanel = 40
        $startYPanel += $panelHeight + 20
    }
}

# Install button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = 'Install'
$installButton.Size = New-Object System.Drawing.Size(100, 30)
$installButton.Location = New-Object System.Drawing.Point(750, 500)
$installButton.FlatStyle = 'Flat'
$installButton.BackColor = [System.Drawing.Color]::FromArgb(191, 97, 106) # Nord Red
$installButton.ForeColor = [System.Drawing.Color]::FromArgb(46, 52, 64) # Nord Background
$installButton.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$installButton.Add_Click({
    foreach ($checkbox in $checkboxes) {
        if ($checkbox.Checked) {
            $packageName = $checkbox.Text
            Write-Output "Installing $($checkbox.Text)..."
            Start-Process -NoNewWindow -FilePath 'powershell.exe' -ArgumentList "-Command choco install $packageName -y"
        }
    }
})
$form.Controls.Add($installButton)

# Show the form
[void]$form.ShowDialog()
