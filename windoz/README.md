**Exécution du Script** :
- Pour exécuter le script, ouvrez PowerShell en tant qu'administrateur.
  ```powershell
  Set-ExecutionPolicy -Scope 'LocalMachine' -ExecutionPolicy 'RemoteSigned'
  ```
- Exécutez le script :
  ```powershell
  irm "https://github.com/romish17/custom-install/blob/main/windoz/post-install.ps1" | iex
  ```
