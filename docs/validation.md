# Validation

Validated on 2026-10-25 using Fedora 44 KDE aarch64, Plasma Keyboard 6.7.5 and Qt Virtual Keyboard 6.11.2.

- Clean upstream v6.7.5 download, patch dry run, patch application and native Release build through `scripts/build.sh`: passed.
- Bash syntax for every supplied shell script: passed.
- Fresh installation into an isolated home/data directory: passed.
- Reinstallation with a distinct backup of the existing installation: passed.
- Generated English and Russian key order and weights match the working tablet layouts: passed.
- All three letter rows have the same total weight; their initial offsets are 1.5, 1.75 and 2.25 letter widths: passed.
- Backspace uses a text label and no dedicated number row is generated: passed.
- Runtime modifier delivery and reset were checked with a separate Qt application; see [verification.txt](verification.txt).

The installation checks used temporary directories and did not replace the active tablet keyboard. Other architectures and distributions were not tested.

## Dependency installer update — 2026-11-12

`tests/install-deps.sh` passed under GNU Bash 5.3.15 (Git runtime on Windows): 19 distribution fixtures plus missing-file and invalid-argument checks. The cases cover Fedora, Nobara, Arch, Arch ARM, Manjaro, EndeavourOS, an Arch-like Kupfer fixture, generic derivatives, explicit-ID precedence and rejection of Ubuntu, unknown systems and unsupported enterprise distributions.

The tests use `--dry-run` and a blocking sudo stub; they execute no package manager. This verifies command selection, not live package installation or a fresh build on Arch. Real-device Arch-family usage was reported separately by comradeFreeman in [PR #1](https://github.com/kyurenbog/plasma-keyboard-desktop/pull/1).
