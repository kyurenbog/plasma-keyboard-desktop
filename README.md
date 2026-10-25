# Plasma Keyboard Desktop

[Русская инструкция](README.ru.md) · English

Extended on-screen keyboard for **Fedora KDE Plasma on Wayland**. Adds desktop keys and shortcuts to Plasma Keyboard 6.7.5 while keeping English/Russian language switching.

This is a community patch and layout package, not an official KDE release. It builds an additional executable in your home directory; the Fedora package remains installed.

## Features

- Esc and F1–F12.
- Ctrl, Alt and Meta shortcuts, including combinations with arrows.
- Tab, Backspace, Enter, Delete, Home, End, Page Up and Page Down.
- Arrow keys and a standard staggered letter layout: Q → A → Z / Й → Ф → Я.
- English and Russian layouts with equal letter widths.
- No dedicated number row; use the symbols layer for numbers and symbols.
- A readable **Backspace** label instead of a glyph that may be missing from fonts.

## Compatibility

Tested on **Fedora 44 KDE, aarch64, Plasma Keyboard 6.7.5, Qt Virtual Keyboard 6.11.2**.

Requires a Plasma **Wayland** session and the system `plasma-keyboard` package. The build uses Qt ≥ 6.10, KDE Frameworks ≥ 6.26 and Plasma ≥ 6.7. It compiles natively, so there is no ARM-only binary in this repository. Other architectures/distributions have not been tested. The patch targets **v6.7.5**, not arbitrary newer versions.

## Install

Open Konsole in your regular desktop session. Only dependency installation uses sudo.

```bash
sudo dnf install -y git
git clone https://github.com/kyurenbog/plasma-keyboard-desktop.git
cd plasma-keyboard-desktop
bash scripts/install-deps.sh
bash scripts/build.sh
bash scripts/install.sh
bash scripts/activate.sh
```

`build.sh` downloads KDE's v6.7.5 source, applies the included patch and compiles it locally. Internet access and development packages are required. By default it uses three build jobs; use `JOBS=2 bash scripts/build.sh` if memory is limited. This build disables keyboard sounds and vibration.

Tap a text field to show the keyboard. You can also select **Plasma Keyboard Extended** under **System Settings → Keyboard → Virtual Keyboard**. If it does not appear immediately, reopen System Settings or sign out and back in.

The installer copies the system language layouts, then replaces the English fallback and Russian main layouts. Existing user layouts, desktop entry and custom executable are backed up. The script prints the backup path.

## Where to enable the keyboard and select languages

These are two separate KDE settings pages:

1. **System Settings → Keyboard → Virtual Keyboard**: select **Plasma Keyboard Extended**, not the ordinary Plasma Keyboard. Click **Apply** if enabled. The **Show Virtual Keyboard** setting at the top controls when it opens; the demonstrated tablet configuration uses **With Touch and Tablet**. Then touch a text field.
2. **System Settings → Keyboard → On-Screen Keyboard**: check the required languages, such as **American English** and **русский**, and click **Apply**. Use **Filter languages…** to find a language. Switch between the enabled languages with the on-screen keyboard's language button.

Names may vary between KDE translations. **Virtual Keyboard** selects the program; **On-Screen Keyboard** selects its languages and preferences. The system hardware keyboard layout is configured separately.

### Why Ukrainian looks different

The extended layouts currently cover English and Russian. Ukrainian (`uk_UA`) has its own stock `main.qml`, which the installer does not replace. Selecting Ukrainian therefore loads its ordinary layout: enabling a language does not automatically add function keys, Ctrl/Alt or staggered rows.

Creating an extended `uk_UA/main.qml` as explained in the [custom-layout guide](docs/custom-layouts.md#example-ukrainian) gives Ukrainian the same style and key set. Complete support also requires checking Ukrainian letters, Shift and shortcuts: new codes for І, Ї, Є and Ґ are not automatically added to the C++ table. Other languages with their own stock `main.qml` need the same adaptation; languages using the shared fallback may already inherit its extended appearance.

## Use shortcuts

Modifiers are **one-shot toggles**, not keys you need to hold:

1. Tap **Ctrl**; it becomes highlighted.
2. Tap **C** to send Ctrl+C, or **V** to send Ctrl+V.
3. Ctrl resets after that key.

Tap several modifiers before the target key for a combination such as Ctrl+Alt+key. Tap an enabled modifier again to cancel it. Shift uses Qt's existing Shift key behavior.

Meta corresponds to the Windows/Super key. The actual action depends on the application's or Plasma's shortcuts. The system keyboard layout also affects physical key events; this package does not reconfigure your system language settings.

## Add your language

See [Creating a language layout](docs/custom-layouts.md) for a step-by-step example, key codes, row alignment, language selection, and preserving your changes during updates. [Русская версия](docs/custom-layouts.ru.md).

## Update

```bash
cd plasma-keyboard-desktop
git pull --ff-only
```

If only layouts or installer scripts changed, rerun `install.sh` and `activate.sh`. If the C++ patch or protocol changed, rebuild in a **new directory** first, so an old patched source tree is not reused:

```bash
export PLASMA_DESKTOP_BUILD_DIR="$PWD/build/update-$(date +%Y%m%d-%H%M%S)"
bash scripts/build.sh
bash scripts/install.sh
bash scripts/activate.sh
```

After major Qt/Plasma updates, rebuilding or adapting the patch may be necessary. The custom executable does not automatically receive Fedora's Plasma Keyboard fixes.

## Restore the stock keyboard

```bash
bash scripts/restore-stock.sh
```

This selects Fedora's original keyboard and renames the user layout folder to `layouts.disabled-<timestamp>` so stock layouts are loaded. It preserves the custom executable and backups. The command applies to the entire user keyboard layout folder, including layouts you added separately.

To restore a specific previous custom setup, use the printed installation backup folder. It contains the previous layouts and, when present, the previous executable and desktop entry. Do not overwrite files while the custom keyboard is running; switch to the stock keyboard first.

## Installed files

| Purpose | Default path |
| --- | --- |
| Custom executable | `~/.local/opt/plasma-keyboard-desktop/bin/plasma-keyboard` |
| Desktop entry | `~/.local/share/applications/org.kde.plasma.keyboard.desktop-extended.desktop` |
| Layouts | `~/.local/share/plasma/keyboard/layouts/` |
| Installation backups | `~/.local/share/plasma/keyboard/desktop-backups/` |
| Build sources and output | `./build/` |

The data paths respect `XDG_DATA_HOME`. `PLASMA_DESKTOP_BUILD_DIR` overrides the build directory; use the same value for build and install. `PLASMA_DESKTOP_PREFIX` optionally overrides the executable installation prefix. Run the scripts as your normal user, never with `sudo bash scripts/install.sh`.

## Troubleshooting

**The keyboard does not open:** run `activate.sh` from Konsole inside the Plasma session, then touch a text field. Check that the session is Wayland (`echo "$XDG_SESSION_TYPE"`). The executable must be started by KWin as the selected virtual keyboard; do not start it directly.

**Ctrl+C types a plain letter:** ensure the selected input method is **Plasma Keyboard Extended**. The layouts alone do not fix shortcuts in the original 6.7.5 executable. Restart through `activate.sh`.

**Build fails:** check the first actual error in the CMake/compiler output. Install dependencies and check version requirements. Older Fedora releases or newer incompatible upstream versions may need a different patch.

**Custom language layouts disappear:** all stock locales are copied, but existing user modifications are saved to the backup rather than merged automatically. Restore the necessary custom files from that backup.

For recent diagnostic messages:

```bash
journalctl --user --since "5 minutes ago" --no-pager | grep plasma-keyboard
```

## Implementation and verification

In Plasma Keyboard 6.7.5, textual key events are committed as text and the keysym path uses zero modifiers. The patch forwards shortcuts and supported special keys through **KWin fake-input**, using Linux keycodes. A queue releases modifiers before the next shortcut is sent. Ordinary text continues through the input method.

On the test tablet, a separate Qt application received Ctrl+A, Ctrl+C, Ctrl+Left, Shift+Left and Alt+X with the expected modifiers. F5 received no leftover modifiers. See [verification results](docs/verification.txt). The test input hook was removed from the production executable. Touch behavior and application-specific shortcuts still depend on the target app.

## License and credits

See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md). Based on [KDE Plasma Keyboard](https://invent.kde.org/plasma/plasma-keyboard), Qt Virtual Keyboard components, and KDE's [plasma-wayland-protocols](https://invent.kde.org/libraries/plasma-wayland-protocols). The system package and upstream authors retain their original copyrights and licenses.
