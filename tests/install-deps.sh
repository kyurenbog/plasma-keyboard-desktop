#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_dir="$(mktemp -d)"
trap 'rm -rf -- "$fixture_dir"' EXIT
count=0
mkdir -p "$fixture_dir/bin"
printf '#!/usr/bin/env bash\necho "FAIL: attempted package installation" >&2\nexit 99\n' > "$fixture_dir/bin/sudo"
if command -v chmod >/dev/null 2>&1; then chmod +x "$fixture_dir/bin/sudo"; fi
export PATH="$fixture_dir/bin:$PATH"

check_family() {
    local name=$1 id=$2 like=$3 expected=$4
    printf 'ID="%s"\nID_LIKE="%s"\n' "$id" "$like" > "$fixture_dir/os-release"
    local output
    output=$("$BASH" "$project_dir/scripts/install-deps.sh" --dry-run --os-release "$fixture_dir/os-release")
    [[ "$output" == *"Detected package family: $expected "* ]] || { echo "FAIL $name: $output"; exit 1; }
    if [[ "$expected" == arch ]]; then
        [[ "$output" == *'sudo pacman -Syu --needed '* && "$output" == *'qt6-virtualkeyboard'* && "$output" != *'--noconfirm'* ]]
    else
        [[ "$output" == *'sudo dnf install -y '* && "$output" == *'qt6-qtbase-private-devel'* && "$output" != *'pacman'* ]]
    fi
    count=$((count + 1))
    echo "PASS $name"
}
check_rejected() {
    local id=$1 like=$2
    printf 'ID="%s"\nID_LIKE="%s"\n' "$id" "$like" > "$fixture_dir/os-release"
    local output status=0
    output=$("$BASH" "$project_dir/scripts/install-deps.sh" --dry-run --os-release "$fixture_dir/os-release" 2>&1) || status=$?
    [[ "$status" == 2 && "$output" == *'Unsupported OS:'* && "$output" != *'Command:'* ]] || { echo "FAIL reject $id: $output"; exit 1; }
    count=$((count + 1))
    echo "PASS reject $id"
}
check_family Fedora fedora '' fedora
check_family Nobara nobara fedora fedora
check_family Arch arch '' arch
check_family ArchARM archarm arch arch
check_family Manjaro manjaro arch arch
check_family EndeavourOS endeavouros arch arch
check_family Kupfer-fixture kupfer arch arch
check_family ID-LIKE-list derivative 'unknown arch' arch
check_family Fedora-derivative derivative fedora fedora
check_family ID-priority fedora arch fedora
check_family Case-normalization ARCH ARCH arch
check_rejected ubuntu debian
check_rejected unknown ''
check_rejected rhel fedora
check_rejected rocky 'rhel centos fedora'
check_rejected almalinux 'rhel centos fedora'
check_rejected amzn 'centos rhel fedora'
check_rejected centos 'rhel fedora'
check_rejected enterprise-derivative 'rhel fedora'

if "$BASH" "$project_dir/scripts/install-deps.sh" --dry-run --os-release "$fixture_dir/missing" >/dev/null 2>&1; then exit 1; fi
if "$BASH" "$project_dir/scripts/install-deps.sh" --os-release "$fixture_dir/os-release" >/dev/null 2>&1; then exit 1; fi
if "$BASH" "$project_dir/scripts/install-deps.sh" --os-release >/dev/null 2>&1; then exit 1; fi
if "$BASH" "$project_dir/scripts/install-deps.sh" --unknown >/dev/null 2>&1; then exit 1; fi
"$BASH" -n "$project_dir/scripts/install-deps.sh"
echo "PASS: $count distro fixtures plus CLI validation. No package managers executed."
