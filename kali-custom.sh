#!/usr/bin/env bash
# kali-cyberpunk-kde.sh — Thème Cyberpunk 2077 pour KDE Plasma (Kali Linux)
#
# Usage:
#   ./kali-cyberpunk-kde.sh apply   [--wallpaper "/path/to/img"]
#   ./kali-cyberpunk-kde.sh revert
#
# Le script attend un argument (apply ou revert). Si tu l’exécutes sans, il affichera une erreur.

set -euo pipefail

SAFE_MODE=0  # --safe : n'exécute aucune commande nécessitant l'UI/GL (libEGL), écrit seulement les fichiers

THEME_NAME="Cyberpunk2077"
ICON_THEME="Papirus-Dark"
CURSOR_THEME="Bibata-Modern-Classic"
WALLPAPER_PATH=""
BACKUP_DIR="$HOME/.local/share/kali-cyberpunk-backup"

log()  { printf "\033[1;36m[+]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[x]\033[0m %s\n" "$*"; }

usage() {
  cat << 'EOF'
Usage:
  $0 apply   [--wallpaper "/path/to/img"]
  $0 revert

Options:
  -h, --help   Affiche cette aide.

Exemples:
  bash kali-cyberpunk-kde.sh apply --wallpaper "$HOME/Pictures/cyberpunk.jpg"
  ./kali-cyberpunk-kde.sh revert
EOF
}

backup_file() {
  local src="$1"
  [[ -f "$src" ]] || return 0
  mkdir -p "$BACKUP_DIR"
  local rel=${src#"$HOME/"}
  local dst="$BACKUP_DIR/${rel//\//__}.$(date +%Y%m%d%H%M%S).bak"
  cp -a "$src" "$dst"
}

ensure_packages() {
  if command -v apt >/dev/null 2>&1; then
    log "Vérification des paquets utiles (peut demander ton mot de passe)…"
    sudo apt update || true
    sudo apt install -y --no-install-recommends \
      papirus-icon-theme bibata-cursor-theme \
      mesa-utils mesa-utils-extra libegl1 libgl1-mesa-dri mesa-vulkan-drivers \
      qemu-guest-agent spice-vdagent || true
    # Optionnel: papirus-folders pour accents jaune
    if apt-cache show papirus-folders >/dev/null 2>&1; then
      sudo apt install -y papirus-folders || true
      papirus-folders -C yellow --theme Papirus-Dark || true
    fi
  else
    warn "Gestionnaire de paquets non géré par le script. Installe manuellement: papirus-icon-theme, bibata-cursor-theme."
  fi
}

create_kde_colorscheme() {
  local dir="$HOME/.local/share/color-schemes"
  mkdir -p "$dir"
  local file="$dir/${THEME_NAME}.colors"
  log "Création schéma de couleurs: $file"
  cat > "$file" << 'EOF'
[General]
ColorScheme=Cyberpunk2077
Name=Cyberpunk2077
shadeSortColumn=true

[Colors:Button]
BackgroundAlternate=30,30,30
BackgroundNormal=24,24,24
DecorationFocus=0,229,255
DecorationHover=255,255,0
ForegroundActive=0,229,255
ForegroundInactive=200,200,200
ForegroundLink=0,229,255
ForegroundNegative=255,68,68
ForegroundNeutral=255,255,0
ForegroundNormal=230,230,230
ForegroundPositive=0,229,150

[Colors:Selection]
BackgroundAlternate=0,229,255
BackgroundNormal=0,229,255
DecorationFocus=0,229,255
DecorationHover=255,255,0
ForegroundActive=0,0,0
ForegroundInactive=0,0,0
ForegroundLink=0,0,0
ForegroundNegative=0,0,0
ForegroundNeutral=0,0,0
ForegroundNormal=0,0,0
ForegroundPositive=0,0,0

[Colors:Tooltip]
BackgroundAlternate=33,33,33
BackgroundNormal=24,24,24
DecorationFocus=0,229,255
DecorationHover=255,255,0
ForegroundActive=230,230,230
ForegroundInactive=200,200,200
ForegroundLink=0,229,255
ForegroundNegative=255,68,68
ForegroundNeutral=255,255,0
ForegroundNormal=230,230,230
ForegroundPositive=0,229,150

[Colors:View]
BackgroundAlternate=28,28,28
BackgroundNormal=18,18,18
DecorationFocus=0,229,255
DecorationHover=255,255,0
ForegroundActive=0,229,255
ForegroundInactive=180,180,180
ForegroundLink=0,229,255
ForegroundNegative=255,68,68
ForegroundNeutral=255,255,0
ForegroundNormal=220,220,220
ForegroundPositive=0,229,150

[Colors:Window]
BackgroundAlternate=28,28,28
BackgroundNormal=16,16,16
DecorationFocus=0,229,255
DecorationHover=255,255,0
ForegroundActive=0,229,255
ForegroundInactive=180,180,180
ForegroundLink=0,229,255
ForegroundNegative=255,68,68
ForegroundNeutral=255,255,0
ForegroundNormal=220,220,220
ForegroundPositive=0,229,150

[Disabled]
ForegroundNormal=120,120,120

[WM]
activeBackground=16,16,16
activeBlend=0,229,255
activeForeground=230,230,230
inactiveBackground=28,28,28
inactiveBlend=120,120,120
inactiveForeground=170,170,170
EOF
}

apply_kde_settings() {
  # En mode SAFE, on écrit la config mais on n'appelle pas d'outils KDE qui peuvent casser si libEGL échoue
  if [[ "$SAFE_MODE" -eq 1 ]]; then
    warn "SAFE MODE: pas d'appel à plasma-apply-*, ni qdbus; seules les écritures de fichiers sont faites."
    kwriteconfig5 --file kdeglobals --group Icons --key Theme "$ICON_THEME" || true
    kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme "$CURSOR_THEME" || true
    kwriteconfig5 --file kdeglobals --group General --key AccentColor "0,229,255" || true
    return 0
  fi

  need_bin kwriteconfig5
  if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
    log "Application du schéma KDE…"
    plasma-apply-colorscheme "$THEME_NAME" || warn "Impossible d'appliquer le schéma via plasma-apply-colorscheme (libEGL?)."
  else
    warn "plasma-apply-colorscheme introuvable; on écrit quand même les fichiers."
  fi

  log "Application des icônes: $ICON_THEME"
  kwriteconfig5 --file kdeglobals --group Icons --key Theme "$ICON_THEME" || true

  log "Application du thème curseur: $CURSOR_THEME"
  kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme "$CURSOR_THEME" || true

  kwriteconfig5 --file kdeglobals --group General --key AccentColor "0,229,255" || true

  if [[ -n "$WALLPAPER_PATH" && -f "$WALLPAPER_PATH" ]]; then
    if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
      log "Application du fond d’écran…"
      plasma-apply-wallpaperimage "$WALLPAPER_PATH" || warn "Impossible d'appliquer le wallpaper (libEGL?)."
    else
      warn "plasma-apply-wallpaperimage introuvable — fond d’écran non appliqué automatiquement."
    fi
  fi

  log "Recharge de Plasma Shell…"
  if command -v qdbus >/dev/null 2>&1 && qdbus org.kde.plasmashell >/dev/null 2>&1; then
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.reloadConfig || true
  else
    warn "qdbus/plasmashell indisponible; reconnecte ta session pour voir les changements."
  fi
}

create_konsole_scheme() {
  local dir="$HOME/.local/share/konsole"
  mkdir -p "$dir"
  local file="$dir/${THEME_NAME}.colorscheme"
  log "Création schéma Konsole: $file"
  cat > "$file" << 'EOF'
[General]
Description=Cyberpunk 2077
Opacity=1

[Background]
Color=16,16,16

[BackgroundIntense]
Color=16,16,16

[Foreground]
Color=220,220,220

[ForegroundIntense]
Color=0,229,255

[Color0]
Color=24,24,24

[Color0Intense]
Color=40,40,40

[Color1]
Color=255,68,68

[Color1Intense]
Color=255,120,120

[Color2]
Color=0,229,150

[Color2Intense]
Color=0,255,180

[Color3]
Color=255,255,0

[Color3Intense]
Color=255,255,120

[Color4]
Color=0,229,255

[Color4Intense]
Color=120,255,255

[Color5]
Color=255,0,180

[Color5Intense]
Color=255,120,220

[Color6]
Color=0,180,255

[Color6Intense]
Color=120,220,255

[Color7]
Color=220,220,220

[Color7Intense]
Color=255,255,255
EOF

  local prof="$dir/${THEME_NAME}.profile"
  cat > "$prof" << EOF
[Appearance]
ColorScheme=${THEME_NAME}

[General]
Name=${THEME_NAME}
Command=/bin/bash
Parent=FALLBACK/
EOF

  kwriteconfig5 --file konsolerc --group "Desktop Entry" --key DefaultProfile "${THEME_NAME}.profile" || true
}

apply_gtk_hint() {
  mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
  echo "gtk-application-prefer-dark-theme=1" > "$HOME/.config/gtk-3.0/settings.ini"
  echo "gtk-application-prefer-dark-theme=1" > "$HOME/.config/gtk-4.0/settings.ini"
}

apply() {
  log "Sauvegarde de configs avant modifications…"
  backup_file "$HOME/.config/kdeglobals"
  backup_file "$HOME/.config/kcminputrc"
  backup_file "$HOME/.config/konsolerc"

  ensure_packages
  create_kde_colorscheme
  apply_kde_settings
  create_konsole_scheme
  apply_gtk_hint

  log "Fini. Si tu es en VM sans accélération 3D, utilise --safe et reconnecte ta session pour voir les changements."
}

revert() {
  warn "Restauration manuelle requise depuis: $BACKUP_DIR"
  warn "Ce script a créé des backups timestampés. Copie-les vers leurs emplacements d’origine si besoin."
  log  "Tu peux remettre Breeze par défaut avec:"
  echo "  plasma-apply-colorscheme BreezeDark"
  echo "  kwriteconfig5 --file kdeglobals --group Icons --key Theme Breeze"
  echo "  kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme Breeze"
}

parse_args() {
  if [[ $# -lt 1 ]]; then
    err "Commande manquante."
    usage
    exit 2
  fi
  case "$1" in
    -h|--help|help)
      usage
      exit 0
      ;;
    apply)
      shift
      # options pour apply
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --wallpaper)
            [[ -n "${2:-}" ]] || { err "--wallpaper requiert un chemin"; exit 2; }
            WALLPAPER_PATH="$2"; shift 2;;
          --safe)
            SAFE_MODE=1; shift;;
          *) err "Option inconnue: $1"; usage; exit 2;;
        esac
      done
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --wallpaper)
            [[ -n "${2:-}" ]] || { err "--wallpaper requiert un chemin"; exit 2; }
            WALLPAPER_PATH="$2"; shift 2;;
          *) err "Option inconnue: $1"; usage; exit 2;;
        esac
      done
      apply
      ;;
    revert)
      revert
      ;;
    *) err "Commande inconnue: $1"; usage; exit 2;;
  esac
}

parse_args "$@"
