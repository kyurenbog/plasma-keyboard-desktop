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
