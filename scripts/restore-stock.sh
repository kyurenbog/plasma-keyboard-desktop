#!/usr/bin/env bash
set -euo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
layouts="$data/plasma/keyboard/layouts"
stamp="$(date +%Y%m%d-%H%M%S)-$$"
if [[ -d "$layouts" ]]; then
  mv -- "$layouts" "$data/plasma/keyboard/layouts.disabled-$stamp"
  echo "Saved custom layouts as layouts.disabled-$stamp"
fi
kwriteconfig6 --notify --file kwinrc --group Wayland --key InputMethod ''
sleep 1
kwriteconfig6 --notify --file kwinrc --group Wayland --key InputMethod /usr/share/applications/org.kde.plasma.keyboard.desktop
echo 'Stock Plasma Keyboard restored. Custom binaries and backups remain in your home directory.'
