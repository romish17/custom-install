# Automatisation de la Configuration Système Windows - README

Bienvenue dans le script d'automatisation de la configuration système Windows ! Ce script est conçu pour simplifier et rationaliser la configuration et la personnalisation d'un environnement Windows, en particulier pour les nouvelles installations ou les machines nouvellement provisionnées. Vous trouverez ci-dessous un résumé de ce que fait ce script et comment l'utiliser efficacement.

## Aperçu

Ce script automatise de nombreux aspects de la configuration et de l'optimisation d'un environnement Windows. Il garantit qu'une machine est prête pour la productivité en appliquant les meilleures pratiques, en supprimant les logiciels préinstallés, en configurant les paramètres, en installant les logiciels essentiels, et bien plus encore.

### Fonctionnalités :
- **Récupération des Informations du BIOS** : Récupère automatiquement et enregistre le numéro de série et les détails du fabricant du système à partir du BIOS.
- **Ajustements du Registre** : Applique de nombreuses modifications du registre pour optimiser les performances, améliorer la confidentialité et personnaliser l'expérience utilisateur.
- **Désactivation des Fonctionnalités Windows Inutiles** : Désactive des fonctionnalités telles que l'UAC, les logiciels préinstallés, les publicités et les applications préinstallées pour épurer le système.
- **Fond d'écran Personnalisé et Ajustements de l'Interface** : Télécharge et applique un fond d'écran personnalisé, configure les paramètres de la barre des tâches, et applique un thème sombre.
- **Installation de Logiciels via Chocolatey** : Installe automatiquement une liste sélectionnée d'applications essentielles en utilisant Chocolatey.
- **Personnalisation de Windows Terminal** : Télécharge et applique des paramètres personnalisés pour Windows Terminal.
- **Gestion de l'Énergie** : Configure les paramètres de gestion de l'énergie pour assurer une utilisation efficace sur l'alimentation secteur et sur batterie.
- **Prérequis WSL2 et Docker** : Active les fonctionnalités requises pour Docker Desktop et WSL2, préparant la machine pour le développement.
- **Mises à Jour Windows** : Installe les dernières mises à jour de Windows pour assurer la sécurité et la stabilité.

## Comment Utiliser

1. **Prérequis** :
    - Exécutez le script avec PowerShell 5.1 ou ultérieur.
    - Assurez-vous d'avoir des privilèges administratifs, car de nombreuses actions nécessitent des droits élevés.

2. **Exécution du Script** :
    - Pour exécuter le script, ouvrez PowerShell en tant qu'administrateur.
    - Définissez la politique d'exécution du script pour permettre son exécution :
      ```powershell
      Set-ExecutionPolicy -Scope 'LocalMachine' -ExecutionPolicy 'RemoteSigned'
      ```
    - Exécutez le script :
    ```powershell
    irm "https://gitlab.rom-cloud.net/custom/win11/-/raw/main/install.ps1" | iex
    ```
    ou 
    ```powershell
    irm "http://s.romish.cloud/s/d" | iex
    ```

3. **Personnalisation** :
    - Le script est conçu pour être personnalisable. N'hésitez pas à modifier la liste des applications ou les paramètres selon vos besoins.
    - Vous pouvez également ajuster les modifications du registre en fonction de vos préférences en matière de confidentialité, d'apparence et de fonctionnalité.

## Ce que le Script Fait

### Paramètres Système et Optimisations
- **Désactiver l'UAC** : Le contrôle de compte d'utilisateur est désactivé pour éviter les invites inutiles.
- **Désactiver IPv6** : IPv6 est désactivé globalement pour améliorer la compatibilité réseau.
- **Désactiver les Publicités et Logiciels Préinstallés** : Désactive les suggestions de Windows, les publicités et les applications préinstallées qui peuvent encombrer l'expérience utilisateur.
- **Configurer la Barre des Tâches et l'Interface** : Applique des paramètres pour personnaliser la barre des tâches, désactiver les widgets indésirables et activer un thème sombre cohérent.

### Fond d'écran Personnalisé
- Télécharge un fond d'écran personnalisé et l'applique comme fond d'écran par défaut et écran de verrouillage.

### Installation de Logiciels
- **Packages Chocolatey** : Installe divers logiciels utiles tels que Git, VLC, Docker Desktop, et plus encore en utilisant Chocolatey.
- **Sous-système Windows pour Linux** : Active les fonctionnalités WSL2, préparant le système pour le développement sous Linux.

### Gestion de l'Énergie
- Configure les paramètres de mise en veille de l'écran et de veille pour l'alimentation secteur et l'utilisation sur batterie afin d'étendre la durée de vie de la batterie et de réduire le marquage de l'écran.

### Windows Terminal
- Télécharge et applique une configuration personnalisée pour Windows Terminal, améliorant l'expérience en ligne de commande.

### Mises à Jour et Maintenance
- **Désactiver les Mises à Jour Pendant l'Installation des Logiciels** : Désactive les mises à jour automatiques pendant l'installation des logiciels pour éviter les interruptions.
- **Mises à Jour Automatiques** : Installe les mises à jour de Windows et redémarre automatiquement pour garantir l'application des derniers correctifs de sécurité.

## Notes
- **Version** : 0.4.7
- **Auteur** : Romish
- **Date de Création** : 12/11/2024
- **Objectif** : Automatiser et optimiser la configuration de Windows pour une expérience utilisateur rationalisée.

## Exemple d'Utilisation
Pour configurer et optimiser automatiquement un système Windows, exécutez simplement :
```powershell
irm "https://gitlab.rom-cloud.net/custom/win11/-/raw/main/install.ps1" | iex
```
ou 
```powershell
irm "http://s.romish.cloud/s/d" | iex
```

Profitez de votre configuration Windows nouvellement optimisée, propre et efficace !

---

N'hésitez pas à nous contacter pour toute question ou amélioration que vous souhaiteriez suggérer. Ce script évolue constamment pour s'adapter aux nouvelles fonctionnalités et aux meilleures pratiques !

