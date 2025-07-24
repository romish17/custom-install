**Exécution du Script** :
- Pour exécuter le script, ouvrez PowerShell en tant qu'administrateur.
  ```powershell
  Set-ExecutionPolicy -Scope 'LocalMachine' -ExecutionPolicy 'RemoteSigned'
  ```
- Exécutez le script :
  ```powershell
  irm "https://gitlab.rom-cloud.net/custom/win11/-/raw/main/install.ps1" | iex
  ```
