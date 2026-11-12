#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Arch package list contributed by comradeFreeman in pull request #1.
set -euo pipefail

dry_run=false
os_release_file=''
usage() {
    echo "Usage: bash scripts/install-deps.sh [--dry-run [--os-release FILE]]"
    echo "--dry-run prints the selected command without installing or updating packages."
    echo "--os-release selects a fixture file for dry-run testing only."
}
while (($#)); do
    case "$1" in
        --dry-run) dry_run=true; shift ;;
        --os-release)
            if (($# < 2)); then usage >&2; exit 2; fi
            os_release_file=$2; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done
if [[ -n "$os_release_file" && "$dry_run" != true ]]; then
    echo '--os-release is allowed only with --dry-run.' >&2
    exit 2
fi
if [[ -z "$os_release_file" ]]; then
    if [[ -r /etc/os-release ]]; then os_release_file=/etc/os-release
    else os_release_file=/usr/lib/os-release; fi
fi
if [[ ! -r "$os_release_file" ]]; then
    echo "Cannot read OS identification: $os_release_file" >&2
    exit 2
fi
ID=''
ID_LIKE=''
# os-release is a shell-compatible, locally supplied OS identification file.
source "$os_release_file"
distro_id=${ID,,}

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

family=''
case "$distro_id" in
    arch|archarm|manjaro|endeavouros) family=arch ;;
    fedora|nobara) family=fedora ;;
    rhel|centos|rocky|almalinux|amzn) family=unsupported ;;
esac
if [[ -z "$family" ]]; then
    # ID takes precedence. Inspect ID_LIKE in its declared order for derivatives.
    read -r -a related_distros <<< "${ID_LIKE,,}"
    for related_distro in "${related_distros[@]}"; do
        case "$related_distro" in
            arch|archarm|manjaro|endeavouros) family=arch; break ;;
            rhel|centos|rocky|almalinux|amzn) family=unsupported; break ;;
            fedora|nobara) family=fedora; break ;;
        esac
    done
fi
case "$family" in
    arch)
        install_cmd=(sudo pacman -Syu --needed)
        target_pkgs=("${ARCH_PKGS[@]}") ;;
    fedora)
        install_cmd=(sudo dnf install -y)
        target_pkgs=("${FEDORA_PKGS[@]}") ;;
    *)
        echo "Unsupported OS: ID=${ID:-unknown}, ID_LIKE=${ID_LIKE:-none}." >&2
        echo 'Supported package families: Fedora and Arch. No packages were changed.' >&2
        echo 'RHEL, CentOS, Rocky, AlmaLinux and Amazon Linux are not supported by this installer.' >&2
        exit 2 ;;
esac
printf 'Detected package family: %s (ID=%s)\n' "$family" "${ID:-unknown}"
if [[ "$dry_run" == true ]]; then
    printf 'Command: '
    printf '%q ' "${install_cmd[@]}" "${target_pkgs[@]}"
    printf '\n'
    exit 0
fi
if ! command -v "${install_cmd[1]}" >/dev/null 2>&1; then
    echo "Required package manager not found: ${install_cmd[1]}" >&2
    exit 1
fi
if [[ "$family" == arch ]]; then
    echo 'Pacman will perform a full system upgrade and install the build dependencies.'
    echo 'Review its transaction summary before confirming.'
fi
"${install_cmd[@]}" "${target_pkgs[@]}"
