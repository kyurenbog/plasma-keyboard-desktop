#!/usr/bin/env bash
set -euo pipefail
if [[ "$EUID" -eq 0 ]]; then
  echo 'Run as your normal desktop user, without sudo.' >&2
  exit 1
fi
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
build_root="${PLASMA_DESKTOP_BUILD_DIR:-$project_dir/build}"
binary="$build_root/cmake/bin/plasma-keyboard"
[[ -x "$binary" ]] || { echo 'First run: bash scripts/build.sh' >&2; exit 1; }
stock=/usr/share/plasma/keyboard/layouts
[[ -d "$stock" ]] || { echo 'System plasma-keyboard layouts are missing.' >&2; exit 1; }
data="${XDG_DATA_HOME:-$HOME/.local/share}"
prefix="${PLASMA_DESKTOP_PREFIX:-$HOME/.local/opt/plasma-keyboard-desktop}"
layouts="$data/plasma/keyboard/layouts"
desktop="$data/applications/org.kde.plasma.keyboard.desktop-extended.desktop"
stamp="$(date +%Y%m%d-%H%M%S)-$$"
backup="$data/plasma/keyboard/desktop-backups/$stamp"
mkdir -p -- "$backup" "$prefix/bin" "$data/applications"
if [[ -d "$layouts" ]]; then cp -a -- "$layouts" "$backup/layouts"; fi
if [[ -f "$desktop" ]]; then cp -a -- "$desktop" "$backup/keyboard.desktop"; fi
if [[ -f "$prefix/bin/plasma-keyboard" ]]; then cp -a -- "$prefix/bin/plasma-keyboard" "$backup/plasma-keyboard"; fi
stage="$(mktemp -d "$data/plasma/keyboard/.desktop-stage.XXXXXX")"
trap 'rm -rf -- "$stage"' EXIT
cp -a -- "$stock/." "$stage/"
python3 "$project_dir/scripts/generate_layouts.py" --output "$stage"
# Keep the old layout directory before moving the staged copy into place.
if [[ -e "$layouts" ]]; then mv -- "$layouts" "$backup/replaced-layouts"; fi
mv -- "$stage" "$layouts"
trap - EXIT
install -m755 -- "$binary" "$prefix/bin/plasma-keyboard.new"
mv -f -- "$prefix/bin/plasma-keyboard.new" "$prefix/bin/plasma-keyboard"
cat > "$desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Plasma Keyboard Extended
Exec="$prefix/bin/plasma-keyboard"
Icon=input-keyboard-virtual
NoDisplay=true
X-KDE-Wayland-VirtualKeyboard=true
EOF
printf 'Installed. Backup: %s\n' "$backup"
echo 'Activate: bash scripts/activate.sh'
