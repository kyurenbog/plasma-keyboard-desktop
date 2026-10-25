#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
build_root="${PLASMA_DESKTOP_BUILD_DIR:-$project_dir/build}"
mkdir -p -- "$build_root"
build_root="$(cd -- "$build_root" && pwd)"
source_dir="$build_root/plasma-keyboard-6.7.5"
if [[ ! -f "$build_root/.desktop-patched" ]]; then
  if [[ -e "$source_dir" ]]; then
    echo "Source directory already exists without the patch marker: $source_dir" >&2
    echo "Use a new PLASMA_DESKTOP_BUILD_DIR to avoid overwriting your sources." >&2
    exit 1
  fi
  curl --fail --location --retry 3 \
    https://github.com/KDE/plasma-keyboard/archive/refs/tags/v6.7.5.tar.gz \
    --output "$build_root/plasma-keyboard-6.7.5.tar.gz"
  tar -xzf "$build_root/plasma-keyboard-6.7.5.tar.gz" -C "$build_root"
  cp -- "$project_dir/protocols/fake-input.xml" "$source_dir/src/fake-input.xml"
  patch --batch --forward --dry-run -d "$source_dir" -p1 < "$project_dir/patches/desktop-shortcuts.patch"
  patch --batch --forward -d "$source_dir" -p1 < "$project_dir/patches/desktop-shortcuts.patch"
  touch "$build_root/.desktop-patched"
fi
cmake -S "$source_dir" -B "$build_root/cmake" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF \
  -DCMAKE_INSTALL_PREFIX="$HOME/.local/opt/plasma-keyboard-desktop" \
  -DPLASMA_KEYBOARD_SOUNDS_ENABLED=OFF \
  -DPLASMA_KEYBOARD_VIBRATION_ENABLED=OFF
cmake --build "$build_root/cmake" --target plasma-keyboard -j "${JOBS:-3}"
echo "Built: $build_root/cmake/bin/plasma-keyboard"
