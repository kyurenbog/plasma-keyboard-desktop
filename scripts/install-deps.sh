#!/usr/bin/env bash
set -euo pipefail
sudo dnf install -y \
  plasma-keyboard python3 curl tar patch cmake ninja-build gcc-c++ \
  extra-cmake-modules qt6-qtbase-private-devel qt6-qtdeclarative-devel \
  qt6-qtvirtualkeyboard-devel qt6-qtwayland-devel \
  kf6-kcoreaddons-devel kf6-ki18n-devel kf6-kcmutils-devel \
  kf6-kconfig-devel kf6-kcrash-devel libplasma-devel \
  libxkbcommon-devel wayland-devel wayland-protocols-devel
