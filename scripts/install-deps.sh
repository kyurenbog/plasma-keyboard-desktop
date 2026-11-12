#!/usr/bin/env bash
set -euo pipefail

ID=""

if [ -f /etc/os-release ]; then
    source /etc/os-release
fi

DISTRO="${ID,,}"

ARCH_PKGS=(
    plasma-keyboard python curl tar patch cmake ninja gcc
    extra-cmake-modules qt6-base qt6-declarative
    qt6-virtualkeyboard qt6-wayland
    kcoreaddons ki18n kcmutils kconfig kcrash libplasma
    libxkbcommon wayland wayland-protocols
)

FEDORA_PKGS=(
    plasma-keyboard python3 curl tar patch cmake ninja-build gcc-c++
    extra-cmake-modules qt6-qtbase-private-devel qt6-qtdeclarative-devel
    qt6-qtvirtualkeyboard-devel qt6-qtwayland-devel
    kf6-kcoreaddons-devel kf6-ki18n-devel kf6-kcmutils-devel
    kf6-kconfig-devel kf6-kcrash-devel libplasma-devel
    libxkbcommon-devel wayland-devel wayland-protocols-devel
)

case "$DISTRO" in
    arch|archarm|manjaro|endeavouros)
        INSTALL_CMD="sudo pacman -S --needed --noconfirm"
        TARGET_PKGS=("${ARCH_PKGS[@]}")
        ;;

    fedora|rhel|rocky|almalinux|nobara|amzn)
        INSTALL_CMD="sudo dnf install -y"
        TARGET_PKGS=("${FEDORA_PKGS[@]}")
        ;;

    *)
        echo "Unrecognized OS ($DISTRO), falling back to Fedora/DNF"
        INSTALL_CMD="sudo dnf install -y"
        TARGET_PKGS=("${FEDORA_PKGS[@]}")
        ;;
esac

$INSTALL_CMD "${TARGET_PKGS[@]}"
