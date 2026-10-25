#!/usr/bin/env bash
set -euo pipefail
desktop="${XDG_DATA_HOME:-$HOME/.local/share}/applications/org.kde.plasma.keyboard.desktop-extended.desktop"
[[ -f "$desktop" ]] || { echo 'First run: bash scripts/install.sh' >&2; exit 1; }
kwriteconfig6 --notify --file kwinrc --group Wayland --key InputMethod ''
sleep 1
kwriteconfig6 --notify --file kwinrc --group Wayland --key InputMethod "$desktop"
echo 'Plasma Keyboard Extended activated. Tap a text field to open it.'
